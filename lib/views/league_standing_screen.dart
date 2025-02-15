// lib/views/league_standings_screen.dart
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import '../blocs/league_bloc/league_bloc.dart';
import '../blocs/league_bloc/league_state.dart';
import '../models/club.dart';
import '../models/match.dart';

class LeagueStandingsScreen extends StatelessWidget {
  const LeagueStandingsScreen({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('League Standings'),
      ),
      body: BlocBuilder<LeagueBloc, LeagueState>(
        builder: (context, state) {
          if (state is LeagueInitial) {
            return Center(
              child: ElevatedButton(
                onPressed: () {
                  context.read<LeagueBloc>().add(InitializeLeague());
                },
                child: Text('Initialize League'),
              ),
            );
          } else if (state is LeagueLoading) {
            return Center(child: CircularProgressIndicator());
          } else if (state is LeagueReady || 
                    state is MatchweekSimulated || 
                    state is MatchSimulated) {
            final season = state is LeagueReady ? state.season :
                         state is MatchweekSimulated ? state.season :
                         (state as MatchSimulated).season;
                         
            final standings = _calculateStandings(season.fixtures);
            
            return Column(
              children: [
                _buildStandingsTable(standings),
                SizedBox(height: 16),
                if (!season.isCompleted)
                  ElevatedButton(
                    onPressed: () {
                      context.read<LeagueBloc>().add(SimulateMatchweek());
                    },
                    child: Text('Simulate Next Matchweek'),
                  ),
              ],
            );
          } else if (state is LeagueError) {
            return Center(
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Text(
                    'Error: ${state.message}',
                    style: TextStyle(color: Colors.red),
                  ),
                  SizedBox(height: 16),
                  ElevatedButton(
                    onPressed: () {
                      context.read<LeagueBloc>().add(ResetLeague());
                    },
                    child: Text('Reset League'),
                  ),
                ],
              ),
            );
          }
          
          return Center(child: Text('Unknown state'));
        },
      ),
    );
  }
  
  Widget _buildStandingsTable(List<_ClubStanding> standings) {
    return Expanded(
      child: Padding(
        padding: const EdgeInsets.all(8.0),
        child: Column(
          children: [
            Container(
              color: Colors.grey[200],
              child: Padding(
                padding: const EdgeInsets.symmetric(vertical: 8.0),
                child: Row(
                  children: [
                    SizedBox(width: 40, child: Center(child: Text('#', style: TextStyle(fontWeight: FontWeight.bold)))),
                    Expanded(flex: 3, child: Text('Club', style: TextStyle(fontWeight: FontWeight.bold))),
                    SizedBox(width: 40, child: Center(child: Text('MP', style: TextStyle(fontWeight: FontWeight.bold)))),
                    SizedBox(width: 40, child: Center(child: Text('W', style: TextStyle(fontWeight: FontWeight.bold)))),
                    SizedBox(width: 40, child: Center(child: Text('D', style: TextStyle(fontWeight: FontWeight.bold)))),
                    SizedBox(width: 40, child: Center(child: Text('L', style: TextStyle(fontWeight: FontWeight.bold)))),
                    SizedBox(width: 40, child: Center(child: Text('GF', style: TextStyle(fontWeight: FontWeight.bold)))),
                    SizedBox(width: 40, child: Center(child: Text('GA', style: TextStyle(fontWeight: FontWeight.bold)))),
                    SizedBox(width: 40, child: Center(child: Text('GD', style: TextStyle(fontWeight: FontWeight.bold)))),
                    SizedBox(width: 40, child: Center(child: Text('Pts', style: TextStyle(fontWeight: FontWeight.bold)))),
                  ],
                ),
              ),
            ),
            Expanded(
              child: ListView.builder(
                itemCount: standings.length,
                itemBuilder: (context, index) {
                  final standing = standings[index];
                  return Container(
                    color: index % 2 == 0 ? Colors.grey[100] : Colors.white,
                    child: Padding(
                      padding: const EdgeInsets.symmetric(vertical: 8.0),
                      child: Row(
                        children: [
                          SizedBox(width: 40, child: Center(child: Text('${index + 1}'))),
                          Expanded(
                            flex: 3,
                            child: Row(
                              children: [
                                SizedBox(width: 8),
                                Text(standing.club.abbreviation, style: TextStyle(fontWeight: FontWeight.bold)),
                                SizedBox(width: 8),
                                Expanded(child: Text(standing.club.name, overflow: TextOverflow.ellipsis)),
                              ],
                            ),
                          ),
                          SizedBox(width: 40, child: Center(child: Text('${standing.played}'))),
                          SizedBox(width: 40, child: Center(child: Text('${standing.won}'))),
                          SizedBox(width: 40, child: Center(child: Text('${standing.drawn}'))),
                          SizedBox(width: 40, child: Center(child: Text('${standing.lost}'))),
                          SizedBox(width: 40, child: Center(child: Text('${standing.goalsFor}'))),
                          SizedBox(width: 40, child: Center(child: Text('${standing.goalsAgainst}'))),
                          SizedBox(width: 40, child: Center(child: Text('${standing.goalDifference}'))),
                          SizedBox(width: 40, child: Center(
                            child: Text(
                              '${standing.points}',
                              style: TextStyle(fontWeight: FontWeight.bold),
                            ),
                          )),
                        ],
                      ),
                    ),
                  );
                },
              ),
            ),
          ],
        ),
      ),
    );
  }
  
  List<_ClubStanding> _calculateStandings(List<Match> matches) {
    // Create a map to store club standings
    final standingsMap = <String, _ClubStanding>{};
    
    // Process all played matches
    for (final match in matches.where((m) => m.isPlayed)) {
      // Ensure home club is in standings
      if (!standingsMap.containsKey(match.homeClub.name)) {
        standingsMap[match.homeClub.name] = _ClubStanding(match.homeClub);
      }
      
      // Ensure away club is in standings
      if (!standingsMap.containsKey(match.awayClub.name)) {
        standingsMap[match.awayClub.name] = _ClubStanding(match.awayClub);
      }
      
      // Update home club standing
      final homeStanding = standingsMap[match.homeClub.name]!;
      homeStanding.played++;
      homeStanding.goalsFor += match.homeScore;
      homeStanding.goalsAgainst += match.awayScore;
      
      if (match.homeScore > match.awayScore) {
        // Home win
        homeStanding.won++;
        homeStanding.points += 3;
      } else if (match.homeScore < match.awayScore) {
        // Home loss
        homeStanding.lost++;
      } else {
        // Draw
        homeStanding.drawn++;
        homeStanding.points += 1;
      }
      
      // Update away club standing
      final awayStanding = standingsMap[match.awayClub.name]!;
      awayStanding.played++;
      awayStanding.goalsFor += match.awayScore;
      awayStanding.goalsAgainst += match.homeScore;
      
      if (match.awayScore > match.homeScore) {
        // Away win
        awayStanding.won++;
        awayStanding.points += 3;
      } else if (match.awayScore < match.homeScore) {
        // Away loss
        awayStanding.lost++;
      } else {
        // Draw
        awayStanding.drawn++;
        awayStanding.points += 1;
      }
    }
    
    // Convert map to list and sort by points, goal difference, goals scored
    final standings = standingsMap.values.toList();
    standings.sort((a, b) {
      if (a.points != b.points) {
        return b.points.compareTo(a.points);
      }
      if (a.goalDifference != b.goalDifference) {
        return b.goalDifference.compareTo(a.goalDifference);
      }
      return b.goalsFor.compareTo(a.goalsFor);
    });
    
    return standings;
  }
}

// Helper class to store club standings
class _ClubStanding {
  final Club club;
  int played = 0;
  int won = 0;
  int drawn = 0;
  int lost = 0;
  int goalsFor = 0;
  int goalsAgainst = 0;
  int points = 0;
  
  _ClubStanding(this.club);
  
  int get goalDifference => goalsFor - goalsAgainst;
}