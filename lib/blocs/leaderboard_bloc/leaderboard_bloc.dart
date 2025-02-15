// lib/blocs/leaderboard_bloc/leaderboard_bloc.dart
import 'package:flutter_bloc/flutter_bloc.dart';
import 'leaderboard_event.dart';
import 'leaderboard_state.dart';
import '../../models/leaderboard_entry.dart';

class LeaderboardBloc extends Bloc<LeaderboardEvent, LeaderboardState> {
  LeaderboardBloc() : super(LeaderboardInitial()) {
    on<UpdateLeaderboard>(_onUpdateLeaderboard);
  }

  final List<LeaderboardEntry> _entries = [];

  void _onUpdateLeaderboard(UpdateLeaderboard event, Emitter<LeaderboardState> emit) {
    // Add the new entry to the leaderboard
    _entries.add(LeaderboardEntry(username: event.username, totalPoints: event.totalPoints));
    
    // Sort the entries by total points (descending)
    _entries.sort((a, b) => b.totalPoints.compareTo(a.totalPoints));
    
    // Emit the updated state
    emit(LeaderboardUpdated(_entries));
  }
}