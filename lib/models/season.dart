// lib/models/season.dart
import 'match.dart';
import 'club.dart';

class Season {
  final String name; // e.g. "2023-2024"
  final List<Club> clubs;
  final List<Match> fixtures;
  final DateTime startDate;
  final DateTime endDate;
  int currentMatchweek;
  
  Season({
    required this.name,
    required this.clubs,
    required this.fixtures,
    required this.startDate,
    required this.endDate,
    this.currentMatchweek = 1,
  });

  // Get matches for a specific matchweek
  List<Match> getMatchesForMatchweek(int matchweek) {
    // Assuming 8 matches per matchweek (for 16 teams)
    final startIndex = (matchweek - 1) * 8;
    final endIndex = startIndex + 8;
    
    if (startIndex >= fixtures.length) {
      return [];
    }
    
    final lastIndex = endIndex > fixtures.length ? fixtures.length : endIndex;
    return fixtures.sublist(startIndex, lastIndex);
  }
  
  // Check if all matches are played
  bool get isCompleted => fixtures.every((match) => match.isPlayed);
  
  // Factory method to create a season from JSON
  factory Season.fromJson(Map<String, dynamic> json, List<Club> allClubs) {
    // Parse fixtures
    final fixturesJson = json['fixtures'] as List;
    final fixtures = fixturesJson
        .map((fixtureJson) => Match.fromJson(fixtureJson, allClubs))
        .toList();

    return Season(
      name: json['name'],
      clubs: allClubs,
      fixtures: fixtures,
      startDate: DateTime.parse(json['startDate']),
      endDate: DateTime.parse(json['endDate']),
      currentMatchweek: json['currentMatchweek'] ?? 1,
    );
  }

  // Convert season to JSON
  Map<String, dynamic> toJson() {
    return {
      'name': name,
      'fixtures': fixtures.map((fixture) => fixture.toJson()).toList(),
      'startDate': startDate.toIso8601String(),
      'endDate': endDate.toIso8601String(),
      'currentMatchweek': currentMatchweek,
    };
  }
}