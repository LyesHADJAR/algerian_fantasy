// lib/blocs/team_bloc/team_bloc.dart
import 'package:flutter_bloc/flutter_bloc.dart';
import 'team_event.dart';
import 'team_state.dart';
import '../../models/team.dart';

class TeamBloc extends Bloc<TeamEvent, TeamState> {
  TeamBloc() : super(TeamInitial()) {
    on<AddPlayer>(_onAddPlayer);
    on<RemovePlayer>(_onRemovePlayer);
    on<ValidateTeam>(_onValidateTeam);
    on<ResetValidation>(_onResetValidation);
  }

  final double budgetLimit = 100.0;
  Team _team = Team(players: [], remainingBudget: 100.0);

  Team get team => _team;

  

  void _onAddPlayer(AddPlayer event, Emitter<TeamState> emit) {
    // Check if team is full
    if (_team.players.length >= 14) {
      emit(TeamInvalid('Team is full! Maximum 14 players (11 + 3 substitutes)'));
      emit(TeamUpdated(_team));
      return;
    }

    // Check if player is already in team
    if (_team.players.any((player) => player.name == event.player.name)) {
      emit(TeamInvalid('Player is already in the team!'));
      emit(TeamUpdated(_team));
      return;
    }

    if (_team.remainingBudget >= event.player.price) {
      _team = Team( 
        players: [..._team.players, event.player],
        remainingBudget: _team.remainingBudget - event.player.price,
      );
      emit(TeamUpdated(_team));
    } else {
      emit(TeamInvalid('Budget exceeded!'));
      emit(TeamUpdated(_team));
    }
  }

  void _onRemovePlayer(RemovePlayer event, Emitter<TeamState> emit) {
    _team = Team(
      players: _team.players.where((player) => player.name != event.player.name).toList(),
      remainingBudget: _team.remainingBudget + event.player.price,
    );
    emit(TeamUpdated(_team));
  }

  void _onValidateTeam(ValidateTeam event, Emitter<TeamState> emit) {
    // Check total number of players
    if (_team.players.length != 14) {
      emit(TeamInvalid('Team must have exactly 14 players (11 starters + 3 substitutes)!'));
      return;
    }

    // Count players by position
    final gkCount = _team.players.where((player) => player.position == 'GK').length;
    final defCount = _team.players.where((player) => player.position == 'DF').length;
    final midCount = _team.players.where((player) => player.position == 'MF').length;
    final fwdCount = _team.players.where((player) => player.position == 'FW').length;

    // Validate minimum requirements for each position
    if (gkCount < 2) {
      emit(TeamInvalid('Need at least 2 goalkeepers (1 starter + 1 substitute)'));
      return;
    }
    if (defCount < 5) {
      emit(TeamInvalid('Need at least 5 defenders (4 starters + 1 substitute)'));
      return;
    }
    if (midCount < 4) {
      emit(TeamInvalid('Need at least 4 midfielders'));
      return;
    }
    if (fwdCount < 3) {
      emit(TeamInvalid('Need at least 3 forwards (2 starters + 1 substitute)'));
      return;
    }

    emit(TeamValid(_team));
  }

  void _onResetValidation(ResetValidation event, Emitter<TeamState> emit) {
    emit(TeamUpdated(_team));
  }
}