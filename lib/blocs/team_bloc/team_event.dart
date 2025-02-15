// lib/blocs/team_bloc/team_event.dart
import '../../models/player.dart';

abstract class TeamEvent {}

class AddPlayer extends TeamEvent {
  final Player player;
  AddPlayer(this.player);
}

class RemovePlayer extends TeamEvent {
  final Player player;
  RemovePlayer(this.player);
}

class ValidateTeam extends TeamEvent {}

class ResetValidation extends TeamEvent {}

