// lib/repository/player_repository.dart
import 'dart:convert';
import 'package:flutter/services.dart' show rootBundle;
import '../models/player.dart';
import '../models/club.dart';
import 'club_repository.dart';

class PlayerRepository {
  List<Player>? _cachedPlayers;
  
  PlayerRepository({ClubRepository? clubRepository});
  
  // Fetch all players from all clubs
  Future<List<Player>> fetchPlayers() async {
    // Return cached players if available
    if (_cachedPlayers != null) {
      return _cachedPlayers!;
    }
    
    try {
      // Load the clubs data (which contains players)
      final jsonString = await rootBundle.loadString('assets/data/clubs.json');
      final jsonData = json.decode(jsonString);
      
      if (jsonData['clubs'] == null) {
        throw Exception('Invalid clubs data format');
      }
      
      final clubsJson = jsonData['clubs'] as List;
      final allPlayers = <Player>[];
      
      // Extract players from each club
      for (final clubJson in clubsJson) {
        final clubName = Club.extractBaseName(clubJson['club_name'] as String);
        final playersJson = clubJson['players'] as List;
        
        for (final playerJson in playersJson) {
          allPlayers.add(Player.fromJson(playerJson, clubName));
        }
      }
      
      _cachedPlayers = allPlayers;
      return allPlayers;
    } catch (e) {
      // Return empty list as fallback
      return [];
    }
  }

  // Get players from a specific club
  Future<List<Player>> getPlayersByClub(String clubName) async {
    final allPlayers = await fetchPlayers();
    return allPlayers.where((player) => player.club == clubName).toList();
  }
  
  // Get a player by name
  Future<Player?> getPlayerByName(String name) async {
    final allPlayers = await fetchPlayers();
    try {
      return allPlayers.firstWhere((player) => player.name == name);
    } catch (e) {
      return null;
    }
  }
}