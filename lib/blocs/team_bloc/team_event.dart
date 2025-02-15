// lib/blocs/team_bloc/team_event.dart
import 'package:flutter/foundation.dart';
import '../../models/player.dart';

@immutable
abstract class TeamEvent {}

class LoadTeams extends TeamEvent {
  final bool forceRefresh;
  
  LoadTeams({this.forceRefresh = false});
  
  @override
  String toString() => 'LoadTeams(forceRefresh: $forceRefresh)';
}

class AddPlayer extends TeamEvent {
  final Player player;
  
  AddPlayer(this.player);
  
  @override
  String toString() => 'AddPlayer(player: ${player.name})';
}

class RemovePlayer extends TeamEvent {
  final Player player;
  
  RemovePlayer(this.player);
  
  @override
  String toString() => 'RemovePlayer(player: ${player.name})';
}

class ValidateTeam extends TeamEvent {
  @override
  String toString() => 'ValidateTeam()';
}

class ResetValidation extends TeamEvent {
  @override
  String toString() => 'ResetValidation()';
}