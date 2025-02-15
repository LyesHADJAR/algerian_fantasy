// lib/blocs/league_bloc/league_bloc.dart
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:collection/collection.dart'; 
import 'league_event.dart';
import 'league_state.dart';
import '../../models/season.dart';
import '../../models/match.dart';
import '../../models/player_points.dart';
import '../../repository/club_repository.dart';
import '../../repository/match_repository.dart';

class LeagueBloc extends Bloc<LeagueEvent, LeagueState> {
  final ClubRepository _clubRepository;
  final MatchRepository _matchRepository;
  
  Season? _currentSeason;
  
  LeagueBloc({
    ClubRepository? clubRepository,
    MatchRepository? matchRepository,
  }) : 
    _clubRepository = clubRepository ?? ClubRepository(),
    _matchRepository = matchRepository ?? MatchRepository(),
    super(LeagueInitial()) {
    
    on<InitializeLeague>(_onInitializeLeague);
    on<SimulateMatchweek>(_onSimulateMatchweek);
    on<SimulateMatch>(_onSimulateMatch);
    on<ResetLeague>(_onResetLeague);
  }
  
  Season? get currentSeason => _currentSeason;
  
  // Initialize the league with fixtures
  Future<void> _onInitializeLeague(
    InitializeLeague event, 
    Emitter<LeagueState> emit
  ) async {
    try {
      emit(LeagueLoading());
      
      final clubs = await _clubRepository.fetchAllClubs();
      final fixtures = await _matchRepository.generateSeasonFixtures();
      
      final now = DateTime.now();
      _currentSeason = Season(
        name: '${now.year}-${now.year + 1}',
        clubs: clubs,
        fixtures: fixtures,
        startDate: now,
        endDate: now.add(Duration(days: fixtures.length * 7 ~/ 8 + 7)),
        currentMatchweek: 1,
      );
      
      emit(LeagueReady(_currentSeason!));
    } catch (e) {
      emit(LeagueError('Failed to initialize league: $e'));
    }
  }
  
  // Simulate all matches in the current matchweek
  Future<void> _onSimulateMatchweek(
    SimulateMatchweek event, 
    Emitter<LeagueState> emit
  ) async {
    if (_currentSeason == null) {
      emit(LeagueError('League not initialized'));
      return;
    }
    
    try {
      final currentMatchweek = _currentSeason!.currentMatchweek;
      final matchesToSimulate = _currentSeason!.getMatchesForMatchweek(currentMatchweek);
      
      if (matchesToSimulate.isEmpty) {
        emit(LeagueError('No more matches to simulate in this season'));
        return;
      }
      
      final simulatedMatches = <Match>[];
      final allPlayerPoints = <PlayerPoints>[];
      
      // Simulate each match
      for (final match in matchesToSimulate) {
        final simulatedMatch = await _matchRepository.simulateMatch(match);
        simulatedMatches.add(simulatedMatch);
        
        // Generate player points for this match
        final playerPoints = await _matchRepository.generatePlayerPointsForMatch(simulatedMatch);
        allPlayerPoints.addAll(playerPoints);
      }
      
      // Update the fixtures in the season
      final updatedFixtures = _currentSeason!.fixtures.map((fixture) {
        final simulatedFixture = simulatedMatches.firstWhereOrNull(
          (simulated) => 
            simulated.homeClub.name == fixture.homeClub.name && 
            simulated.awayClub.name == fixture.awayClub.name
        );
        
        if (simulatedFixture != null) {
          return simulatedFixture;
        }
        return fixture;
      }).toList();
      
      // Update the current season
      _currentSeason = Season(
        name: _currentSeason!.name,
        clubs: _currentSeason!.clubs,
        fixtures: updatedFixtures,
        startDate: _currentSeason!.startDate,
        endDate: _currentSeason!.endDate,
        currentMatchweek: currentMatchweek + 1,
      );
      
      emit(MatchweekSimulated(
        season: _currentSeason!,
        simulatedMatches: simulatedMatches,
        playerPoints: allPlayerPoints,
        matchweek: currentMatchweek,
      ));
    } catch (e) {
      emit(LeagueError('Failed to simulate matchweek: $e'));
    }
  }
  
  // Simulate a specific match
  Future<void> _onSimulateMatch(
    SimulateMatch event, 
    Emitter<LeagueState> emit
  ) async {
    if (_currentSeason == null) {
      emit(LeagueError('League not initialized'));
      return;
    }
    
    try {
      // Simulate the match
      final simulatedMatch = await _matchRepository.simulateMatch(event.match);
      
      // Generate player points for this match
      final playerPoints = await _matchRepository.generatePlayerPointsForMatch(simulatedMatch);
      
      // Update the fixture in the season
      final updatedFixtures = _currentSeason!.fixtures.map((fixture) {
        if (fixture.homeClub.name == simulatedMatch.homeClub.name && 
            fixture.awayClub.name == simulatedMatch.awayClub.name) {
          return simulatedMatch;
        }
        return fixture;
      }).toList();
      
      // Update the current season
      _currentSeason = Season(
        name: _currentSeason!.name,
        clubs: _currentSeason!.clubs,
        fixtures: updatedFixtures,
        startDate: _currentSeason!.startDate,
        endDate: _currentSeason!.endDate,
        currentMatchweek: _currentSeason!.currentMatchweek,
      );
      
      emit(MatchSimulated(
        season: _currentSeason!,
        simulatedMatch: simulatedMatch,
        playerPoints: playerPoints,
      ));
    } catch (e) {
      emit(LeagueError('Failed to simulate match: $e'));
    }
  }
  
  // Reset the league
  void _onResetLeague(ResetLeague event, Emitter<LeagueState> emit) {
    _currentSeason = null;
    emit(LeagueInitial());
  }
}