// lib/repository/player_repository.dart
import 'dart:convert';
import 'package:flutter/services.dart';
import '../models/player.dart';

class PlayerRepository {
  Future<List<Player>> fetchPlayers() async {
    // Load the JSON file from assets
    final String jsonString = await rootBundle.loadString(
      'assets/Algerian_fantasy_data.json',
    );

    // Decode the JSON string into a Map
    final Map<String, dynamic> jsonMap = json.decode(jsonString);

    // Extract the list of clubs
    final List<dynamic> clubs = jsonMap['clubs'];

    // Flatten the list of players from all clubs
    final List<Player> players = [];
    for (final club in clubs) {
      final String clubName = club['club_name'];
      final List<dynamic> clubPlayers = club['players'];
      for (final playerJson in clubPlayers) {
        players.add(Player.fromJson(playerJson, clubName));
      }
    }

    return players;
  }
}
