import 'dart:math';  // For the min function used in extractAbbreviation

// lib/models/club.dart
class Club {
  final String name;
  final String abbreviation;
  final int strength; // 1-100 rating to use in match simulation
  final String kitImageUrl;

  Club({
    required this.name,
    required this.abbreviation,
    required this.strength,
    required this.kitImageUrl,
  });

  // Extract abbreviation from full name (e.g., "Mouloudia Club d'Alger - MCA" -> "MCA")
  static String extractAbbreviation(String fullName) {
    final parts = fullName.split(' - ');
    if (parts.length > 1) {
      return parts[1];
    }
    // Fallback if format is different
    return fullName.substring(0, min(3, fullName.length));
  }

  // Extract base name from full name (e.g., "Mouloudia Club d'Alger - MCA" -> "Mouloudia Club d'Alger")
  static String extractBaseName(String fullName) {
    final parts = fullName.split(' - ');
    if (parts.length > 1) {
      return parts[0];
    }
    return fullName;
  }

  // Factory method to create a club from JSON
  factory Club.fromJson(Map<String, dynamic> json) {
    final fullName = json['club_name'] as String;
    return Club(
      name: extractBaseName(fullName),
      abbreviation: extractAbbreviation(fullName),
      // Assign a default strength based on the position in the list (can be refined later)
      strength: json['strength'] ?? 75, 
      kitImageUrl: json['kit_image_url'] ?? '',
    );
  }

  // Convert club to JSON
  Map<String, dynamic> toJson() {
    return {
      'club_name': '$name - $abbreviation',
      'kit_image_url': kitImageUrl,
      'strength': strength,
    };
  }
}

