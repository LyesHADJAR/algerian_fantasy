// lib/models/match.dart
import 'club.dart';

class Match {
  final Club homeClub;
  final Club awayClub;
  int homeScore;
  int awayScore;
  final DateTime matchDate;
  bool isPlayed;

  Match({
    required this.homeClub,
    required this.awayClub,
    this.homeScore = 0,
    this.awayScore = 0,
    required this.matchDate,
    this.isPlayed = false,
  });

  // Get the winning team (or null if draw)
  Club? get winner {
    if (!isPlayed) return null;
    if (homeScore > awayScore) return homeClub;
    if (awayScore > homeScore) return awayClub;
    return null; // Draw
  }

  // Check if it's a draw
  bool get isDraw => isPlayed && homeScore == awayScore;

  // Factory method to create a match from JSON
  factory Match.fromJson(Map<String, dynamic> json, List<Club> allClubs) {
    // Find clubs by name
    final homeClub = allClubs.firstWhere(
        (club) => club.name == json['homeClubName'],
        orElse: () => throw Exception('Home club not found'));
    
    final awayClub = allClubs.firstWhere(
        (club) => club.name == json['awayClubName'],
        orElse: () => throw Exception('Away club not found'));

    return Match(
      homeClub: homeClub,
      awayClub: awayClub,
      homeScore: json['homeScore'] ?? 0,
      awayScore: json['awayScore'] ?? 0,
      matchDate: DateTime.parse(json['matchDate']),
      isPlayed: json['isPlayed'] ?? false,
    );
  }

  // Convert match to JSON
  Map<String, dynamic> toJson() {
    return {
      'homeClubName': homeClub.name,
      'awayClubName': awayClub.name,
      'homeScore': homeScore,
      'awayScore': awayScore,
      'matchDate': matchDate.toIso8601String(),
      'isPlayed': isPlayed,
    };
  }
}