
// lib/blocs/league_bloc/league_event.dart
import '../../models/match.dart';

abstract class LeagueEvent {}

class InitializeLeague extends LeagueEvent {}

class SimulateMatchweek extends LeagueEvent {}

class SimulateMatch extends LeagueEvent {
  final Match match;
  SimulateMatch(this.match);
}

class ResetLeague extends LeagueEvent {}