// lib/main.dart
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'blocs/team_bloc/team_bloc.dart';
import 'blocs/leaderboard_bloc/leaderboard_bloc.dart';
import 'views/team_selection_screen.dart';
import 'views/leaderboard_screen.dart';
import 'views/home_screen.dart';

void main() {
  runApp(MyApp());
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MultiBlocProvider(
      providers: [
        // Provide the TeamBloc
        BlocProvider(create: (context) => TeamBloc()),
        // Provide the LeaderboardBloc
        BlocProvider(create: (context) => LeaderboardBloc()),
      ],
      child: MaterialApp(
        title: 'Algerian Fantasy App',
        theme: ThemeData(primarySwatch: Colors.blue),
        home: HomeScreen(),
        routes: {
          '/team-selection': (context) => TeamSelectionScreen(),
          '/leaderboard': (context) => LeaderboardScreen(),
        },
      ),
    );
  }
}

