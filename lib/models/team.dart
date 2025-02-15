// lib/models/team.dart
import 'player.dart';

class Team {
  final List<Player> players;
  final double remainingBudget;

  Team({
    required this.players,
    required this.remainingBudget,
  });
}