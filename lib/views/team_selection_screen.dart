// lib/views/team_selection_screen.dart
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import '../blocs/team_bloc/team_bloc.dart';
import '../blocs/team_bloc/team_state.dart';
import '../models/player.dart';
import '../repository/player_repository.dart';
import '../blocs/team_bloc/team_event.dart';

class TeamSelectionScreen extends StatefulWidget {
  const TeamSelectionScreen({super.key});

  @override
  _TeamSelectionScreenState createState() => _TeamSelectionScreenState();
}

class _TeamSelectionScreenState extends State<TeamSelectionScreen> {
  final TextEditingController _searchController = TextEditingController();
  String _searchQuery = '';
  String? _selectedClub;
  String? _selectedPosition;
  double _minPrice = 0;
  double _maxPrice = 100; // Default max price (can be adjusted dynamically)

  @override
  void dispose() {
    _searchController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('Build Your Team'),
        // Show back button for all states except Initial
        leading:
            context.watch<TeamBloc>().state is! TeamInitial
                ? IconButton(
                  icon: Icon(Icons.arrow_back),
                  onPressed: () {
                    // Dispatch the ResetValidation event
                    context.read<TeamBloc>().add(ResetValidation());

                    // Navigate back to the home screen
                    Navigator.of(context).pop();
                  },
                )
                : null,
      ),
      body: BlocBuilder<TeamBloc, TeamState>(
        builder: (context, state) {
          if (state is TeamInitial || state is TeamUpdated) {
            return Column(
              children: [
                _buildTeamStatus(context),
                _buildBudgetRemaining(context),
                _buildSearchBar(),
                _buildFilters(),
                _buildPriceRangeFilter(),
                _buildPlayerList(context),
                _buildValidationButton(context),
              ],
            );
          } else if (state is TeamValid) {
            return Center(
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Text(
                    'Team is valid! Ready to simulate matches.',
                    style: TextStyle(
                      fontSize: 18,
                      fontWeight: FontWeight.bold,
                      color: Colors.green,
                    ),
                  ),
                  SizedBox(height: 16),
                  ElevatedButton(
                    onPressed: () {
                      context.read<TeamBloc>().add(ResetValidation());
                    },
                    child: Text('Back to Team Selection'),
                  ),
                ],
              ),
            );
          } else if (state is TeamInvalid) {
            return Center(
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Text(
                    'Error: ${state.message}',
                    style: TextStyle(
                      fontSize: 18,
                      color: Colors.red,
                      fontWeight: FontWeight.bold,
                    ),
                    textAlign: TextAlign.center,
                  ),
                  SizedBox(height: 16),
                  ElevatedButton(
                    onPressed: () {
                      context.read<TeamBloc>().add(ResetValidation());
                    },
                    child: Text('Back to Team Selection'),
                  ),
                ],
              ),
            );
          }
          return Center(child: CircularProgressIndicator());
        },
      ),
    );
  }

  Widget _buildTeamStatus(BuildContext context) {
    final teamBloc = context.watch<TeamBloc>();
    final playerCount = teamBloc.team.players.length;
    return Padding(
      padding: const EdgeInsets.all(16.0),
      child: Text(
        'Players: $playerCount/14',
        style: TextStyle(
          fontSize: 18,
          fontWeight: FontWeight.bold,
          color: playerCount == 14 ? Colors.green : Colors.blue,
        ),
      ),
    );
  }

  Widget _buildBudgetRemaining(BuildContext context) {
    final teamBloc = BlocProvider.of<TeamBloc>(context);
    return Padding(
      padding: const EdgeInsets.all(16.0),
      child: Text(
        'Remaining Budget: ${teamBloc.team.remainingBudget}M DZD',
        style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
      ),
    );
  }

  Widget _buildSearchBar() {
    return Padding(
      padding: const EdgeInsets.all(16.0),
      child: TextField(
        controller: _searchController,
        decoration: InputDecoration(
          hintText: 'Search for a player...',
          prefixIcon: Icon(Icons.search),
          border: OutlineInputBorder(borderRadius: BorderRadius.circular(8.0)),
        ),
        onChanged: (value) {
          setState(() {
            _searchQuery = value.toLowerCase();
          });
        },
      ),
    );
  }

  Widget _buildFilters() {
    final clubList = _getClubList();
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 16.0),
      child: Row(
        children: [
          Expanded(
            child: DropdownButtonFormField<String?>(
              value: _selectedClub,
              hint: Text('Filter by Club'),
              items: [
                DropdownMenuItem<String?>(value: null, child: Text('None')),
                ...clubList.entries.map((entry) {
                  return DropdownMenuItem(
                    value: entry.value,
                    child: Text(entry.value),
                  );
                }),
              ],
              onChanged: (value) {
                setState(() {
                  _selectedClub = value;
                });
              },
            ),
          ),
          SizedBox(width: 16),
          Expanded(
            child: DropdownButtonFormField<String?>(
              value: _selectedPosition,
              hint: Text('Filter by Position'),
              items: [
                DropdownMenuItem<String?>(value: null, child: Text('None')),
                ...['FW', 'MF', 'DF', 'GK'].map((position) {
                  return DropdownMenuItem(
                    value: position,
                    child: Text(position),
                  );
                }),
              ],
              onChanged: (value) {
                setState(() {
                  _selectedPosition = value;
                });
              },
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildPriceRangeFilter() {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 16.0, vertical: 8.0),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            'Price Range: ${_minPrice.toInt()}M - ${_maxPrice.toInt()}M DZD',
            style: TextStyle(fontSize: 16),
          ),
          RangeSlider(
            values: RangeValues(_minPrice, _maxPrice),
            min: 0,
            max: 100, // Adjust this based on the highest player price
            divisions: 100,
            labels: RangeLabels(
              '${_minPrice.toInt()}M',
              '${_maxPrice.toInt()}M',
            ),
            onChanged: (RangeValues values) {
              setState(() {
                _minPrice = values.start;
                _maxPrice = values.end;
              });
            },
          ),
        ],
      ),
    );
  }

  Widget _buildPlayerList(BuildContext context) {
    final playerRepository = PlayerRepository();
    final teamBloc = context.read<TeamBloc>();

    return FutureBuilder<List<Player>>(
      future: playerRepository.fetchPlayers(),
      builder: (context, snapshot) {
        if (snapshot.connectionState == ConnectionState.waiting) {
          return Center(child: CircularProgressIndicator());
        } else if (snapshot.hasError) {
          return Center(
            child: Text('Error loading players: ${snapshot.error}'),
          );
        } else if (!snapshot.hasData || snapshot.data!.isEmpty) {
          return Center(child: Text('No players available'));
        } else {
          final players = snapshot.data!;
          final filteredPlayers =
              players.where((player) {
                final matchesSearch = player.name.toLowerCase().contains(
                  _searchQuery,
                );
                final matchesClub =
                    _selectedClub == null ||
                    player.club.contains(_selectedClub!);
                final matchesPosition =
                    _selectedPosition == null ||
                    player.position == _selectedPosition;
                final matchesPrice =
                    player.price >= _minPrice && player.price <= _maxPrice;
                return matchesSearch &&
                    matchesClub &&
                    matchesPosition &&
                    matchesPrice;
              }).toList();

          return Expanded(
            child: ListView.builder(
              itemCount: filteredPlayers.length,
              itemBuilder: (context, index) {
                final player = filteredPlayers[index];
                final isPlayerInTeam = teamBloc.team.players.any(
                  (p) => p.name == player.name,
                );

                return Card(
                  elevation: isPlayerInTeam ? 0 : 2,
                  color: isPlayerInTeam ? Colors.green.shade50 : null,
                  child: ListTile(
                    leading: CircleAvatar(
                      backgroundColor:
                          isPlayerInTeam ? Colors.green : Colors.grey.shade200,
                      child: Text(
                        player.position,
                        style: TextStyle(
                          color: isPlayerInTeam ? Colors.white : Colors.black87,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                    ),
                    title: Text(
                      player.name,
                      style: TextStyle(
                        fontWeight:
                            isPlayerInTeam
                                ? FontWeight.bold
                                : FontWeight.normal,
                      ),
                    ),
                    subtitle: Text(
                      '${player.club} - ${player.price}M DZD',
                      style: TextStyle(
                        color: isPlayerInTeam ? Colors.green.shade700 : null,
                      ),
                    ),
                    trailing:
                        isPlayerInTeam
                            ? IconButton(
                              icon: Icon(
                                Icons.remove_circle_outline,
                                color: Colors.red,
                              ),
                              onPressed: () {
                                context.read<TeamBloc>().add(
                                  RemovePlayer(player),
                                );
                              },
                              tooltip: 'Remove from team',
                            )
                            : IconButton(
                              icon: Icon(Icons.add_circle_outline),
                              onPressed: () {
                                context.read<TeamBloc>().add(AddPlayer(player));
                              },
                              tooltip: 'Add to team',
                            ),
                  ),
                );
              },
            ),
          );
        }
      },
    );
  }

  Widget _buildValidationButton(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.all(16.0),
      child: ElevatedButton(
        onPressed: () {
          context.read<TeamBloc>().add(ValidateTeam());
        },
        child: Text('Validate Team'),
      ),
    );
  }

  // Helper method to get the list of clubs
  Map<String, String> _getClubList() {
    return {
      'Mouloudia Club d\'Alger': 'MCA',
      'Chabab Riadhi Belouizdad': 'CRB',
      'Union sportive de la médina d\'Alger': 'USMA',
      'Jeunesse sportive de Kabylie': 'JSK',
      'Paradou Athletic Club': 'PAC',
      'Club sportif constantinois': 'CSC',
      'Entente sportive sétifienne': 'ESS',
      'Association sportive olympique de Chlef': 'ASOC',
      'Union sportive madinet Khenchela': 'USMK',
      'Olympique Akbou': 'OA',
      'Mouloudia Club d\'Oran': 'MCO',
      'Mouloudia Club El Bayadh': 'MCB',
      'Jeunesse sportive de Saoura': 'JSS',
      'Nadjem Chabab Magra': 'NCM',
      'Espérance sportive de Mostaganem': 'ESM',
      'Union sportive de Biskra': 'USB',
    };
  }
}
