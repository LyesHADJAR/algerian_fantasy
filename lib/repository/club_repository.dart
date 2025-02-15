// lib/repository/club_repository.dart
import 'dart:convert';
import 'package:flutter/services.dart' show rootBundle;
import '../models/club.dart';

class ClubRepository {
  // Cache for clubs
  List<Club>? _cachedClubs;
  
  // Get all clubs
  Future<List<Club>> fetchAllClubs() async {
    // Return cached clubs if available
    if (_cachedClubs != null) {
      return _cachedClubs!;
    }
    
    try {
      // Load the clubs data from the JSON file
      final jsonString = await rootBundle.loadString('assets/data/clubs.json');
      final jsonData = json.decode(jsonString);
      
      if (jsonData['clubs'] == null) {
        throw Exception('Invalid clubs data format');
      }
      
      final clubsJson = jsonData['clubs'] as List;
      _cachedClubs = clubsJson.map((clubJson) => Club.fromJson(clubJson)).toList();
      
      // Assign strength values if not present in JSON
      // This assigns values from 85 down to 67 for 16 teams
      int baseStrength = 85;
      for (int i = 0; i < _cachedClubs!.length; i++) {
        final club = _cachedClubs![i];
        // Adjust the field through a new instance since Club is immutable
        _cachedClubs![i] = Club(
          name: club.name,
          abbreviation: club.abbreviation,
          strength: baseStrength - i,
          kitImageUrl: club.kitImageUrl,
        );
            }
      
      return _cachedClubs!;
    } catch (e) {
      // Fallback to hardcoded data if JSON loading fails
      print('Error loading clubs: $e, using fallback data');
      
      _cachedClubs = _getFallbackClubs();
      return _cachedClubs!;
    }
  }

  // Get a club by name
  Future<Club?> getClubByName(String name) async {
    final clubs = await fetchAllClubs();
    try {
      return clubs.firstWhere(
        (club) => club.name == name || '${club.name} - ${club.abbreviation}' == name
      );
    } catch (e) {
      return null;
    }
  }
  
  // Get a club by abbreviation
  Future<Club?> getClubByAbbreviation(String abbreviation) async {
    final clubs = await fetchAllClubs();
    try {
      return clubs.firstWhere((club) => club.abbreviation == abbreviation);
    } catch (e) {
      return null;
    }
  }
  
  // Fallback club data if JSON loading fails
  List<Club> _getFallbackClubs() {
    return [
      Club(
        name: 'Mouloudia Club d\'Alger',
        abbreviation: 'MCA',
        strength: 85,
        kitImageUrl: 'Club_Kits/mca_kit.png',
      ),
      Club(
        name: 'Chabab Riadhi Belouizdad',
        abbreviation: 'CRB',
        strength: 83,
        kitImageUrl: 'Club_Kits/crb_kit.png',
      ),
      // Add the rest of your clubs here...
    ];
  }
}