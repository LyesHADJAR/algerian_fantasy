// lib/models/player.dart
class Player {
  final String name;
  final String position; // e.g., "FW", "MF", "DF", "GK"
  final double price; // Price in millions of DZD (changed to double)
  final String club; // Club name

  Player({
    required this.name,
    required this.position,
    required this.price,
    required this.club,
  });

  // Factory constructor to create a Player from JSON
  factory Player.fromJson(Map<String, dynamic> json, String clubName) {
    return Player(
      name: json['name'],
      position: json['position'],
      price: json['price'].toDouble(), // Ensure price is parsed as double
      club: clubName,
    );
  }
}