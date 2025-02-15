// lib/blocs/league_bloc/league_state.dart
import '../../models/match.dart';
import '../../models/season.dart';
import '../../models/player_points.dart';

abstract class LeagueState {}

class LeagueInitial extends LeagueState {}

class LeagueLoading extends LeagueState {}

class LeagueReady extends LeagueState {
  final Season season;
  LeagueReady(this.season);
}

class MatchweekSimulated extends LeagueState {
  final Season season;
  final List<Match> simulatedMatches;
  final List<PlayerPoints> playerPoints;
  final int matchweek;
  
  MatchweekSimulated({
    required this.season,
    required this.simulatedMatches,
    required this.playerPoints,
    required this.matchweek,
  });
}

class MatchSimulated extends LeagueState {
  final Season season;
  final Match simulatedMatch;
  final List<PlayerPoints> playerPoints;
  
  MatchSimulated({
    required this.season,
    required this.simulatedMatch,
    required this.playerPoints,
  });
}

class LeagueError extends LeagueState {
  final String message;
  LeagueError(this.message);
}