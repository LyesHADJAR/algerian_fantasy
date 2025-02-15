// lib/main_test.dart

import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'blocs/team_bloc/team_bloc.dart';
import 'views/team_selection_screen.dart';
import 'views/home_screen.dart';
import '../blocs/team_bloc/team_event.dart';

void main() {
  // Enable BlocObserver to print state changes during testing
  Bloc.observer = MyBlocObserver();
  runApp(const MyTestApp());
}

// Custom BlocObserver to log bloc events and state changes
class MyBlocObserver extends BlocObserver {
  @override
  void onEvent(Bloc bloc, Object? event) {
    super.onEvent(bloc, event);
  }

  @override
  void onChange(BlocBase bloc, Change change) {
    super.onChange(bloc, change);
  }

  @override
  void onTransition(Bloc bloc, Transition transition) {
    super.onTransition(bloc, transition);
  }

  @override
  void onError(BlocBase bloc, Object error, StackTrace stackTrace) {
    super.onError(bloc, error, stackTrace);
  }
}

class MyTestApp extends StatelessWidget {
  const MyTestApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MultiBlocProvider(
      providers: [
        BlocProvider(create: (context) => TeamBloc()..add(LoadTeams())),
      ],
      child: MaterialApp(
        title: 'Algerian Fantasy App - TEST',
        theme: ThemeData(primarySwatch: Colors.blue),
        home: HomeScreen(),
        routes: {
          '/team-selection': (context) => TeamSelectionScreen(),
        },
      ),
    );
  }
}
