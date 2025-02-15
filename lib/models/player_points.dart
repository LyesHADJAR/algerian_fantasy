// lib/models/player_points.dart
import 'player.dart';

class PlayerPoints {
  final Player player;
  int matchPoints;
  final String matchDescription; // e.g. "MCA 2-1 CRB"
  final DateTime matchDate;

  PlayerPoints({
    required this.player,
    required this.matchPoints,
    required this.matchDescription,
    required this.matchDate,
  });

  // Factory method to create player points from JSON
  factory PlayerPoints.fromJson(Map<String, dynamic> json, List<Player> allPlayers) {
    // Find player by name
    final player = allPlayers.firstWhere(
        (p) => p.name == json['playerName'],
        orElse: () => throw Exception('Player not found'));

    return PlayerPoints(
      player: player,
      matchPoints: json['matchPoints'],
      matchDescription: json['matchDescription'],
      matchDate: DateTime.parse(json['matchDate']),
    );
  }

  // Convert player points to JSON
  Map<String, dynamic> toJson() {
    return {
      'playerName': player.name,
      'matchPoints': matchPoints,
      'matchDescription': matchDescription,
      'matchDate': matchDate.toIso8601String(),
    };
  }
}