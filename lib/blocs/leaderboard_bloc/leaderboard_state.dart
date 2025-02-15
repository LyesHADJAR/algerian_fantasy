import 'package:algerian_fantasy/models/leaderboard_entry.dart';

abstract class LeaderboardState {}

class LeaderboardInitial extends LeaderboardState {}

class LeaderboardUpdated extends LeaderboardState {
  final List<LeaderboardEntry> entries;
  LeaderboardUpdated(this.entries);
}