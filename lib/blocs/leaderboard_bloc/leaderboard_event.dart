abstract class LeaderboardEvent {}

class UpdateLeaderboard extends LeaderboardEvent {
  final String username;
  final int totalPoints;

  UpdateLeaderboard(this.username, this.totalPoints);
}