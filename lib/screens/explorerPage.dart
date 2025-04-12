import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:dima_project/models/tripModel.dart';
import 'package:dima_project/models/userModel.dart';
import 'package:dima_project/screens/tripPage.dart';
import 'package:dima_project/services/authService.dart';
import 'package:dima_project/services/databaseService.dart';
import 'package:dima_project/widgets/tripCardWidget.dart';
import 'package:flutter/material.dart';
import 'package:get/get_common/get_reset.dart';
import 'package:get/get_navigation/src/bottomsheet/bottomsheet.dart';

import '../utils/screenSize.dart';

//TODO: sorting

class ExplorerPage extends StatefulWidget {
  const ExplorerPage({super.key});

  @override
  State<ExplorerPage> createState() => _ExplorerPageState();
}

class _ExplorerPageState extends State<ExplorerPage> {
  late Future<List<TripModel>> _futureTrips;
  late Future<UserModel?> _futureCurrentUser;
  List<String> _savedTrips = [];
  List<TripModel> _allTrips = [];
  List<TripModel> _filteredTrips = [];

  @override
  void initState() {
    super.initState();
    _futureTrips = DatabaseService().getExplorerTrips();
    _futureCurrentUser =
        DatabaseService().getUserByUid(AuthService().currentUser!.uid);
  }

  void _handleTripSave(bool isSaved, String tripId) async {

    try {
      await DatabaseService().handleTripSave(isSaved, tripId);
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
        .where((trip) =>
            trip.title!.toLowerCase().contains(query.toLowerCase()))
        .toList();
  }

  @override
  Widget build(BuildContext context) {
    print('Build of explorer page...');
    return Scaffold(
      backgroundColor: Theme.of(context).scaffoldBackgroundColor,
      body: Column(
        children: [
          Padding(
            padding: const EdgeInsets.all(10.0),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.center,
              crossAxisAlignment: CrossAxisAlignment.center,
              children: [
                Expanded(
                  child: SearchBar(
                    hintText: "Cerca una destinazione...",
                    onChanged: (query) {
                      setState(() {
                        _filterTrips(query);
                      });
                    },
                    leading: Icon(
                      Icons.search,
                      color: Theme.of(context).primaryColor,
                    ),
                    backgroundColor:
                        Theme.of(context).searchBarTheme.backgroundColor,
                  ),
                ),
                IconButton(
                  onPressed: () => _openSortWidget(),
                  icon: Icon(
                    Icons.sort,
                    color: Theme.of(context).primaryColor,
                  ),
                )
              ],
            ),
          ),
          Expanded(
            //first futureBuilder wait for current user to be loaded
            child: FutureBuilder<UserModel?>(
              future: _futureCurrentUser,
              builder: (context, userSnapshot) {
                if (userSnapshot.connectionState == ConnectionState.waiting) {
                  return const Center(child: CircularProgressIndicator());
                } else if (userSnapshot.hasError) {
                  return Center(child: Text('Error: ${userSnapshot.error}'));
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

                    if (_allTrips.isEmpty && _filteredTrips.isEmpty) {
                      _allTrips = snapshot.data!;
                      _filteredTrips = _allTrips;
                    }


                    return _filteredTrips.isEmpty
                        ? const Center(
                            child: Text('No trips match your search'))
                        : ListView.builder(
                            itemCount: _filteredTrips.length,
                            itemBuilder: (context, index) {
                              final trip = _filteredTrips[index];
                              bool isSaved = _savedTrips.contains(trip.id);

                              return Padding(
                                padding: const EdgeInsets.fromLTRB(0, 0, 0, 11),
                                child: GestureDetector(
                                  onTap: () {
                                    Navigator.push(
                                        context,
                                        MaterialPageRoute<void>(
                                            builder: (context) => TripPage(
                                                trip: trip, isMyTrip: false)));
                                  },
                                  child: TripCardWidget(
                                    trip,
                                    isSaved,
                                    onSave:
                                        _handleTripSave, // callback to handle saving trips
                                  ),
                                ),
                              );
                            },
                          );
                  },
                );
              },
            ),
          ),
        ],
      ),
    );
  }

  Future<void> _openSortWidget() async {
    await showModalBottomSheet(
      context: context,
      builder: (BuildContext context) {
        return Container(
          padding: const EdgeInsets.all(8),
          color: Theme.of(context).scaffoldBackgroundColor,
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
                style: Theme.of(context).textTheme.bodyLarge,
              ),
              ListTile(
                leading: const Icon(Icons.access_time),
                title: const Text('Più recenti'),
                onTap: () {
                  setState(() {
                    _filteredTrips.sort((a, b) =>
                        (b.timestamp ?? Timestamp.now()).compareTo(a.timestamp ?? Timestamp.now()));
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
