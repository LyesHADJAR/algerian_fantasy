// lib/repository/match_repository.dart
import 'dart:math';
import '../models/match.dart';
import '../models/player_points.dart';
import 'club_repository.dart';
import 'player_repository.dart';

class MatchRepository {
  final ClubRepository _clubRepository;
  final PlayerRepository _playerRepository;
  final Random _random = Random();

  MatchRepository({
    ClubRepository? clubRepository,
    PlayerRepository? playerRepository,
  }) : 
    _clubRepository = clubRepository ?? ClubRepository(),
    _playerRepository = playerRepository ?? PlayerRepository();

  // Generate a full season of fixtures
  Future<List<Match>> generateSeasonFixtures() async {
    final clubs = await _clubRepository.fetchAllClubs();
    final fixtures = <Match>[];
    final now = DateTime.now();
    
    // For a round-robin tournament, each team plays against every other team twice
    // (home and away)
    for (int round = 0; round < 2; round++) {
      for (int i = 0; i < clubs.length; i++) {
        for (int j = i + 1; j < clubs.length; j++) {
          if (round == 0) {
            // First half of season - home and away as is
            fixtures.add(Match(
              homeClub: clubs[i],
              awayClub: clubs[j],
              matchDate: now.add(Duration(days: fixtures.length * 7)), // Weekly games
            ));
          } else {
            // Second half of season - swap home and away
            fixtures.add(Match(
              homeClub: clubs[j],
              awayClub: clubs[i],
              matchDate: now.add(Duration(days: fixtures.length * 7)), // Weekly games
            ));
          }
        }
      }
    }
    
    // Shuffle the fixtures while preserving date order
    fixtures.shuffle(_random);
    
    // Reassign dates to maintain weekly schedule
    for (int i = 0; i < fixtures.length; i++) {
      fixtures[i] = Match(
        homeClub: fixtures[i].homeClub,
        awayClub: fixtures[i].awayClub,
        matchDate: now.add(Duration(days: i * 7 ~/ 8)), // 8 matches per matchweek
      );
    }
    
    return fixtures;
  }

  // Simulate a match
  Future<Match> simulateMatch(Match match) async {
    if (match.isPlayed) {
      return match; // Match already played
    }
    
    // Get base score based on team strength (0-5 goals)
    double homeExpectedGoals = match.homeClub.strength / 20; // 0-5 scale
    double awayExpectedGoals = match.awayClub.strength / 20; // 0-5 scale
    
    // Add home advantage
    homeExpectedGoals += 0.5;
    
    // Add randomness
    int homeScore = _generateGoals(homeExpectedGoals);
    int awayScore = _generateGoals(awayExpectedGoals);
    
    // Update match with results
    match.homeScore = homeScore;
    match.awayScore = awayScore;
    match.isPlayed = true;
    
    return match;
  }
  
  // Generate player points for a match
  Future<List<PlayerPoints>> generatePlayerPointsForMatch(Match match) async {
    if (!match.isPlayed) {
      throw Exception('Cannot generate points for a match that hasn\'t been played');
    }
    
    final matchDescription = '${match.homeClub.abbreviation} ${match.homeScore}-${match.awayScore} ${match.awayClub.abbreviation}';
    final players = await _playerRepository.fetchPlayers();
    final result = <PlayerPoints>[];
    
    // Filter players from the two clubs in the match
    final matchPlayers = players.where((player) => 
      player.club == match.homeClub.name || 
      player.club == match.awayClub.name
    ).toList();
    
    for (final player in matchPlayers) {
      final isHomeTeam = player.club == match.homeClub.name;
      final teamWon = isHomeTeam ? match.homeScore > match.awayScore : match.awayScore > match.homeScore;
      final isDraw = match.homeScore == match.awayScore;
      
      // Base points
      int points = 2; // Appearance points
      
      // Points based on result
      if (teamWon) {
        points += 4;
      } else if (isDraw) {
        points += 2;
      }
      
      // Points based on position and performance
      if (player.position == 'GK') {
        // Clean sheet bonus
        final concededGoals = isHomeTeam ? match.awayScore : match.homeScore;
        if (concededGoals == 0) {
          points += 4;
        }
      } else if (player.position == 'DF') {
        // Clean sheet bonus (smaller for defenders)
        final concededGoals = isHomeTeam ? match.awayScore : match.homeScore;
        if (concededGoals == 0) {
          points += 3;
        }
      } else if (player.position == 'MF' || player.position == 'FW') {
        // Random chance of goal or assist for attacking players
        if (_random.nextDouble() < 0.3) { // 30% chance of goal or assist
          points += 5;
        }
      }
      
      // Random performance adjustment (-2 to +2)
      points += _random.nextInt(5) - 2;
      
      // Ensure minimum points is 0
      points = max(0, points);
      
      result.add(PlayerPoints(
        player: player,
        matchPoints: points,
        matchDescription: matchDescription,
        matchDate: match.matchDate,
      ));
    }
    
    return result;
  }
  
  // Helper method to generate goals based on expected goals
  int _generateGoals(double expectedGoals) {
    // Poisson distribution would be more realistic, but using simplified approach
    double randomFactor = _random.nextDouble() * 2.0 - 1.0; // -1.0 to 1.0
    double adjustedExpectedGoals = expectedGoals + randomFactor;
    
    // Ensure non-negative
    adjustedExpectedGoals = max(0, adjustedExpectedGoals);
    
    // Convert to integer with rounding
    return adjustedExpectedGoals.round();
  }
}