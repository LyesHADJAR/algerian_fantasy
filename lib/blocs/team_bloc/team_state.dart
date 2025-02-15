// lib/blocs/team_bloc/team_state.dart
import '../../models/team.dart';

abstract class TeamState {}

class TeamInitial extends TeamState {}

class TeamUpdated extends TeamState {
  final Team team;
  TeamUpdated(this.team);
}

class TeamValid extends TeamState {
  final Team team;
  TeamValid(this.team);
}

class TeamInvalid extends TeamState {
  final String message;
  TeamInvalid(this.message);
}