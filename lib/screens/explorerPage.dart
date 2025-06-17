import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:dima_project/models/tripModel.dart';
import 'package:dima_project/models/userModel.dart';
import 'package:dima_project/screens/tripPage.dart';
import 'package:dima_project/services/authService.dart';
import 'package:dima_project/services/databaseService.dart';
import 'package:dima_project/utils/responsive.dart';
import 'package:dima_project/widgets/trip_widgets/tripCardWidget.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';

class ExplorerPage extends StatefulWidget {
  final AuthService authService;
  final DatabaseService databaseService;

  //the constructor can handle injected dependencies for testing
  ExplorerPage({
    super.key,
    AuthService? authService,
    DatabaseService? databaseService,
  })  : authService = authService ?? AuthService(),
        databaseService = databaseService ?? DatabaseService();

  @override
  State<ExplorerPage> createState() => _ExplorerPageState();
}

class _ExplorerPageState extends State<ExplorerPage> {
  late Future<List<TripModel>> _futureTrips;
  late Future<UserModel?> _futureCurrentUser;
  List<String> _savedTrips = [];
  List<TripModel> _allTrips = [];
  List<TripModel> _filteredTrips = [];
  TripModel? _selectedTrip;

  @override
  void initState() {
    super.initState();

    final User? currentUser = widget.authService.currentUser;
    if (currentUser != null) {
      _futureTrips = widget.databaseService.getExplorerTrips();
      _futureCurrentUser = widget.databaseService.getUserByUid(currentUser.uid);
    } else {
      _futureTrips = Future.value([]);
      _futureCurrentUser = Future.value(null);
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Theme.of(context).scaffoldBackgroundColor,
      body: FutureBuilder<UserModel?>(
        future: _futureCurrentUser,
        builder: (context, userSnapshot) {
          if (userSnapshot.connectionState == ConnectionState.waiting) {
            return const Center(child: CircularProgressIndicator());
          } else if (userSnapshot.hasError) {
            return Center(child: Text('Errore: ${userSnapshot.error}'));
          } else if (!userSnapshot.hasData) {
            return const Center(child: Text('Utente non trovato'));
          }

          if (_savedTrips.isEmpty) {
            _savedTrips = List<String>.from(userSnapshot.data!.savedTrip ?? []);
          }

          //second future builder wait for trips to be loaded
          return FutureBuilder<List<TripModel>>(
            future: _futureTrips,
            builder: (context, snapshot) {
              if (snapshot.connectionState == ConnectionState.waiting) {
                return const Center(child: CircularProgressIndicator());
              } else if (snapshot.hasError) {
                return Center(child: Text('Error: ${snapshot.error}'));
              } else if (!snapshot.hasData || snapshot.data!.isEmpty) {
                return const Center(child: Text('Nessun viaggio pubblico'));
              }

              //id statement ensures that this initialization is done only
              //the first time the widget is built
              if (_allTrips.isEmpty && _filteredTrips.isEmpty) {
                _allTrips = snapshot.data!;
                _filteredTrips = _allTrips;
              }

              return ResponsiveLayout(
                  mobileLayout: _buildMobileLayout(),
                  tabletLayout: _buildTabletLayout());
            },
          );
        },
      ),
    );
  }

  Widget _myTripsList(Function onTileTap) {
    return Expanded(
      child: _filteredTrips.isEmpty
          ? const Center(child: Text('Nessun viaggio trovato'))
          : ListView.builder(
              key: const Key('tripList'),
              itemCount: _filteredTrips.length,
              itemBuilder: (context, index) {
                final trip = _filteredTrips[index];
                bool isSaved = _savedTrips.contains(trip.id);

                return Padding(
                  padding: const EdgeInsets.only(bottom: 10),
                  child: GestureDetector(
                      onTap: () {
                        onTileTap(trip);
                      },
                      child: TripCardWidget(
                          trip, isSaved, _handleTripSave, false)),
                );
              },
            ),
    );
  }

  Widget _buildSearchBarSection() {
    return Padding(
      padding: const EdgeInsets.all(10.0),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.center,
        crossAxisAlignment: CrossAxisAlignment.center,
        children: [
          Expanded(
            child: SearchBar(
              elevation: WidgetStateProperty.all(1),
              hintText: "Cerca una destinazione...",
              onChanged: (query) {
                setState(() {
                  _filterTrips(query);
                });
              },
              leading: const Icon(
                Icons.search,
              ),
              trailing: [
                GestureDetector(
                    onTap: () => _openSortWidget(),
                    child: const Padding(
                      padding: EdgeInsets.all(8.0),
                      child: Icon(Icons.filter_alt_outlined),
                    ))
              ],
              backgroundColor: Theme.of(context).searchBarTheme.backgroundColor,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildMobileLayout() {
    //personalized action for mobile on touch of a trip tile
    onMobileTileTap(trip) => {
          Navigator.push(
              context,
              MaterialPageRoute<void>(
                  builder: (context) => TripPage(trip: trip, isMyTrip: false)))
        };

    return Column(
      children: [
        //--- Search bar section ---
        _buildSearchBarSection(),
        //--- Trip list section
        _myTripsList(onMobileTileTap),
      ],
    );
  }

  Widget _buildTabletLayout() {
    onTabletTileTap(trip) => {
          setState(() {
            _selectedTrip = trip;
          })
        };

    return Row(
      children: [
        Expanded(
          flex: 2,
          child: Column(
            children: [
              //--- Search bar section ---
              _buildSearchBarSection(),
              //--- Trip list section
              _myTripsList(onTabletTileTap),
            ],
          ),
        ),
        const VerticalDivider(width: 1),
        Expanded(
          flex: 3,
          child: _selectedTrip != null
              ? TripPage(trip: _selectedTrip!, isMyTrip: false)
              : const Center(child: Text('Seleziona un viaggio')),
        ),
      ],
    );
  }

  void _handleTripSave(bool isSaved, String tripId) async {
    try {
      await widget.databaseService.handleTripSave(isSaved, tripId);
      setState(() {
        TripModel trip = _filteredTrips.firstWhere((trip) => trip.id == tripId);
        if (isSaved) {
          _savedTrips.remove(tripId);
          //update the counter locally
          trip.saveCounter = (trip.saveCounter ?? 0) - 1;
        } else {
          _savedTrips.add(tripId);
          trip.saveCounter = (trip.saveCounter ?? 0) + 1;
        }
      });
    } on Exception catch (e) {
      SnackBar(content: Text('Errore $e'));
    }
  }

  void _filterTrips(String query) {
    _filteredTrips = _allTrips
        .where(
            (trip) => trip.title!.toLowerCase().contains(query.toLowerCase()))
        .toList();
  }

  Future<void> _openSortWidget() async {
    await showModalBottomSheet(
      context: context,
      builder: (BuildContext context) {
        return Container(
          decoration: BoxDecoration(borderRadius: BorderRadius.circular(25)),
          padding: const EdgeInsets.all(8),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              // Handle
              Padding(
                padding: const EdgeInsets.symmetric(vertical: 12),
                child: Container(
                  height: 5,
                  width: 60,
                  decoration: BoxDecoration(
                    color: Theme.of(context).dividerColor,
                    borderRadius: BorderRadius.circular(100),
                  ),
                ),
              ),
              Text(
                'Ordina Per',
                style: Theme.of(context).textTheme.titleLarge,
              ),
              ListTile(
                leading: const Icon(Icons.access_time),
                title: const Text('Più recenti'),
                onTap: () {
                  setState(() {
                    _filteredTrips.sort((a, b) =>
                        (b.timestamp ?? Timestamp.now())
                            .compareTo(a.timestamp ?? Timestamp.now()));
                  });
                  Navigator.pop(context);
                },
              ),
              ListTile(
                leading: const Icon(Icons.trending_up),
                title: const Text('Più popolari'),
                onTap: () {
                  setState(() {
                    _filteredTrips.sort((a, b) =>
                        (b.saveCounter ?? 0).compareTo(a.saveCounter ?? 0));
                  });
                  Navigator.pop(context);
                },
              ),
            ],
          ),
        );
      },
    );
  }
}
