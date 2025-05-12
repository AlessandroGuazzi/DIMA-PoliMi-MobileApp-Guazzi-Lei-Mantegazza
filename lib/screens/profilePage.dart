import 'package:dima_project/screens/medalsPage.dart';
import 'package:dima_project/screens/tripPage.dart';
import 'package:dima_project/utils/screenSize.dart';
import 'package:dima_project/widgets/tripCardWidget.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:dima_project/services/authService.dart';
import 'package:dima_project/services/databaseService.dart';
import 'package:dima_project/screens/accountSettings.dart';
import 'package:intl/intl.dart';
import '../models/tripModel.dart';
import '../models/userModel.dart';
import 'gamePage.dart';

class ProfilePage extends StatefulWidget {
  const ProfilePage({super.key});

  @override
  State<ProfilePage> createState() => _ProfilePageState();
}

class _ProfilePageState extends State<ProfilePage> {
  late Future<UserModel?> _currentUserFuture;
  late Future<List<TripModel>> _futureTrips;
  late Future<List<TripModel>> _savedTrips;

  Future<UserModel?> _loadCurrentUser() async {
    final user = FirebaseAuth.instance.currentUser;
    if (user != null) {
      return await DatabaseService().getUserByUid(user.uid);
    };
    return null;
  }

  @override
  void initState() {
    super.initState();
    _currentUserFuture = _loadCurrentUser();
    _futureTrips = DatabaseService().getHomePageTrips();
  }

  Future<void> signOut() async{
    await AuthService().signOut();
  }


  void _showSettingsModal(UserModel user) {
    showModalBottomSheet(
      context: context,
      backgroundColor: Colors.transparent,
      isScrollControlled: false,
      builder: (BuildContext context) {
        return Container(
          decoration: const BoxDecoration(
            color: Colors.white,
            borderRadius: BorderRadius.only(
              topLeft: Radius.circular(15),
              topRight: Radius.circular(15),
            ),
          ),
          child: Padding(
            padding: const EdgeInsets.all(16.0),
            child: Column(
              mainAxisSize: MainAxisSize.min, // Questo fa sì che la colonna abbia solo l'altezza necessaria
              children: [
                // Lista delle impostazioni
                ListView(
                  shrinkWrap: true, // Per evitare errori di overflow
                  physics: const NeverScrollableScrollPhysics(), // Disabilita lo scrolling della lista
                  children: [
                    ListTile(
                      title: const Text('Modifica Profilo', style: TextStyle(fontSize: 18)),
                      leading: const Icon(Icons.person, color: Colors.black),
                      onTap: () {
                        Navigator.pop(context);
                        Navigator.push(
                          context,
                          MaterialPageRoute(builder: (context) => AccountSettings(currentUserFuture: _currentUserFuture)),
                        ).then((value) => setState(() {_currentUserFuture = _loadCurrentUser();}));
                      },
                    ),
                    ListTile(
                      title: const Text('Nazioni Visitate', style: TextStyle(fontSize: 18)),
                      leading: const Icon(Icons.travel_explore_outlined, color: Colors.black),
                      onTap: () {
                        Navigator.pop(context);
                        Navigator.push(
                          context,
                          MaterialPageRoute(builder: (context) => const GamePage()),
                        );
                      },
                    ),
                    ListTile(
                      title: const Text('Medaglie', style: TextStyle(fontSize: 18)),
                      leading: const Icon(Icons.monetization_on, color: Colors.black),
                      onTap: () {
                        Navigator.pop(context);
                        Navigator.push(
                          context,
                          MaterialPageRoute(builder: (context) => MedalsPage(username: user.username!, userId: user.id!)),
                        ).then((value) => setState(() {_currentUserFuture = _loadCurrentUser();}));
                      },
                    ),
                    ListTile(
                      title: const Text('Log Out', style: TextStyle(fontSize: 18)),
                      leading: const Icon(Icons.logout, color: Colors.red),
                      onTap: () async {
                        await signOut();
                        Navigator.of(context).pop(); // Chiudi la sheet
                      },
                    ),
                  ],
                ),
              ],
            ),
          ),
        );
      },
    );
  }

  @override
  Widget build(BuildContext context) {
    return DefaultTabController(
      length: 2,
      child: FutureBuilder(
        future: _currentUserFuture,
        builder: (context, snapshot) {
          if (snapshot.connectionState == ConnectionState.waiting) {
            return const Scaffold(
              body: Center(child: CircularProgressIndicator()),
            );
          }

          if (snapshot.hasError) {
            return Scaffold(
              body: Center(child: Text('Errore: ${snapshot.error}')),
            );
          }

          if (snapshot.data == null) {
            return const Scaffold(
              body: Center(child: Text('Utente non trovato')),
            );
          }

          final user = snapshot.data!;
          _savedTrips = DatabaseService().getTripsByIds(user.savedTrip);

          return Scaffold(
            backgroundColor: const Color(0xFFF1F4F8),
            appBar: AppBar(
              backgroundColor: Colors.transparent,
              elevation: 0,
              centerTitle: true,
              actions: [
                IconButton(
                  icon: const Icon(Icons.settings, color: Colors.black),
                  onPressed: () {
                    _showSettingsModal(user); // Passa l'utente!
                  },
                ),
              ],
            ),
            body: SafeArea(
              child: Column(
                children: [
                  const SizedBox(height: 0),
                  Container(
                    width: ScreenSize.screenWidth(context) * 0.35,
                    height: ScreenSize.screenHeight(context) * 0.15,
                    decoration: BoxDecoration(
                      shape: BoxShape.circle,
                      border: Border.all(
                        color: Theme.of(context).primaryColor,
                        width: 2,
                      ),
                      image: DecorationImage(
                        image: user.profilePic == null
                            ? const AssetImage('assets/profile.png')
                            : NetworkImage(user.profilePic!),
                        fit: BoxFit.cover,
                      ),
                    ),
                  ),
                  const SizedBox(height: 16),
                  Column(
                    children: [
                      Text(
                        '${user.name} ${user.surname}',
                        style: const TextStyle(
                          fontSize: 20,
                          fontWeight: FontWeight.w600,
                        ),
                      ),
                      Text(
                        '@${user.username}',
                        style: TextStyle(
                          fontSize: 16,
                          color: Colors.grey[600],
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: 24),
                  TabBar(
                    indicatorColor: Theme.of(context).primaryColor,
                    labelColor: Colors.black,
                    unselectedLabelColor: Colors.grey,
                    tabs: const [
                      Tab(text: 'Viaggi Salvati'),
                      Tab(text: 'I Tuoi Viaggi'),
                    ],
                  ),
                  Expanded(
                    child: TabBarView(
                      children: [
                        FutureBuilder<List<TripModel>>(
                          future: _savedTrips,
                          builder: (context, snapshot) {
                            if (snapshot.connectionState == ConnectionState.waiting) {
                              return Container(
                                color: Colors.white,
                                child: const Center(child: CircularProgressIndicator()),
                              );
                            }

                            if (snapshot.hasError) {
                              return const Center(child: Text('Errore nel caricamento dei viaggi'));
                            }

                            final trips = snapshot.data!;

                            if (trips.isEmpty) {
                              return const Center(child: Text('Nessun viaggio salvato'));
                            }

                            return ListView.builder(
                              itemCount: trips.length,
                              itemBuilder: (context, index) {
                                final trip = trips[index];
                                return Padding(
                                  padding: const EdgeInsets.only(top: 5),
                                  child: GestureDetector(
                                    onTap: () {
                                      Navigator.push(
                                        context,
                                        MaterialPageRoute<void>(
                                          builder: (context) => TripPage(
                                            trip: trip,
                                            isMyTrip: false,
                                          ),
                                        ),
                                      );
                                    },
                                    child: TripCardWidget(trip, false, (a, b) {}, true),
                                  ),
                                );
                              },
                            );
                          },
                        ),
                        FutureBuilder<List<TripModel>>(
                          future: _futureTrips,
                          builder: (context, snapshot) {
                            if (snapshot.connectionState == ConnectionState.waiting) {
                              return Container(
                                color: Colors.white,
                                child: const Center(child: CircularProgressIndicator()),
                              );
                            }

                            if (snapshot.hasError) {
                              return const Center(child: Text('Errore nel caricamento dei viaggi'));
                            }

                            final trips = snapshot.data!;

                            if (trips.isEmpty) {
                              return const Center(child: Text('Nessun viaggio creato'));
                            }

                            return ListView.builder(
                              itemCount: trips.length,
                              itemBuilder: (context, index) {
                                final trip = trips[index];
                                return Padding(
                                  padding: const EdgeInsets.only(top: 5),
                                  child: GestureDetector(
                                    onTap: () {
                                      Navigator.push(
                                        context,
                                        MaterialPageRoute<void>(
                                          builder: (context) => TripPage(
                                            trip: trip,
                                            isMyTrip: true,
                                          ),
                                        ),
                                      );
                                    },
                                    child: TripCardWidget(trip, false, (a, b) {}, true),
                                  ),
                                );
                              },
                            );
                          },
                        ),
                      ],
                    ),
                  ),
                ],
              ),
            ),
          );
        },
      ),
    );
  }


}