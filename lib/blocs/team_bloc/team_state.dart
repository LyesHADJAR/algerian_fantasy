// lib/blocs/team_bloc/team_state.dart
import 'package:flutter/foundation.dart';
import '../../models/team.dart';

@immutable
abstract class TeamState {}

class TeamInitial extends TeamState {}

class TeamLoading extends TeamState {}

class TeamUpdated extends TeamState {
  final Team team;
  
  TeamUpdated(this.team);
  
  @override
  String toString() => 'TeamUpdated(team: ${team.players.length} players, budget: ${team.remainingBudget})';
}

class TeamValid extends TeamState {
  final Team team;
  
  TeamValid(this.team);
  
  @override
  String toString() => 'TeamValid(team: ${team.players.length} players)';
}

class TeamInvalid extends TeamState {
  final String message;
  
  TeamInvalid(this.message);
  
  @override
  String toString() => 'TeamInvalid(message: $message)';
}

class TeamError extends TeamState {
  final String error;
  
  TeamError(this.error);
  
  @override
  String toString() => 'TeamError(error: $error)';
}