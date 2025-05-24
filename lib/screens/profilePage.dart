import 'package:dima_project/screens/medalsPage.dart';
import 'package:dima_project/screens/tripPage.dart';
import 'package:dima_project/utils/screenSize.dart';
import 'package:dima_project/widgets/trip_widgets/tripCardWidget.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:dima_project/services/authService.dart';
import 'package:dima_project/services/databaseService.dart';
import 'package:dima_project/screens/accountSettings.dart';
import 'package:intl/intl.dart';
import '../models/tripModel.dart';
import '../models/userModel.dart';
import '../utils/responsive.dart';
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

  @override
  Widget build(BuildContext context) {
    return ResponsiveLayout(
      mobileLayout: _buildMobileLayout(),
      tabletLayout: _buildTabletLayout(),
    );
  }

  Widget _futureUserBuilder(Widget Function(UserModel user) builder) {
    return FutureBuilder<UserModel?>(
      future: _currentUserFuture,
      builder: (context, snapshot) {
        if (snapshot.connectionState == ConnectionState.waiting) {
          return const Scaffold(body: Center(child: CircularProgressIndicator()));
        }

        if (snapshot.hasError || !snapshot.hasData) {
          return Scaffold(body: Center(child: Text('Errore: ${snapshot.error ?? 'Utente non trovato'}')));
        }

        final user = snapshot.data!;
        _savedTrips = DatabaseService().getTripsByIds(user.savedTrip);

        return builder(user);
      },
    );
  }

  Widget _buildMobileLayout() {
    return DefaultTabController(
      length: 2,
      child: _futureUserBuilder((user) {
        return Scaffold(
          body: SafeArea(
            child: NestedScrollView(
              headerSliverBuilder: (context, innerBoxIsScrolled) => [
                SliverAppBar(
                  expandedHeight: 320,
                  pinned: true,
                  floating: false,
                  backgroundColor: CupertinoColors.white,
                  centerTitle: true,
                  actions: [
                    IconButton(
                      icon: const Icon(Icons.settings, color: Colors.black),
                      onPressed: () => _showSettingsModal(user),
                    ),
                  ],
                  flexibleSpace: FlexibleSpaceBar(
                    collapseMode: CollapseMode.pin,
                    background: Column(
                      mainAxisAlignment: MainAxisAlignment.center,
                      crossAxisAlignment: CrossAxisAlignment.center,
                      children: [
                        CircleAvatar(
                          radius: 75,
                          backgroundImage: user.profilePic != null
                              ? NetworkImage(user.profilePic!) as ImageProvider
                              : const AssetImage('assets/profile.png'),
                        ),
                        const SizedBox(height: 16),
                        Text('${user.name} ${user.surname}',
                            style:Theme.of(context).textTheme.headlineMedium),
                        Text('@${user.username}',
                            style: Theme.of(context).textTheme.bodyMedium),
                      ],

                    ),
                  ),
                  bottom: const TabBar(
                    tabs: [
                      Tab(text: 'Viaggi Salvati'),
                      Tab(text: 'I Tuoi Viaggi'),
                    ],
                  ),
                ),
              ],
              body: TabBarView(
                children: [
                  _buildTripList(_savedTrips, isMyTrip: false),
                  _buildTripList(_futureTrips, isMyTrip: true),
                ],
              ),
            ),
          ),
        );
      }),
    );
  }

  Widget _buildTabletLayout() {
    return DefaultTabController(
      length: 2,
      child: _futureUserBuilder((user) {
        return Scaffold(
          body: Row(
            children: [
              //left section
              Expanded(
                flex: 2,
                child: Column(
                  children: [
                    //profile info
                    Expanded(
                      flex: 1,
                      child: Padding(
                        padding: const EdgeInsets.only(top: 30),
                        child: Column(
                          children: [
                            CircleAvatar(
                              radius: 100,
                              backgroundImage: user.profilePic != null
                                  ? NetworkImage(user.profilePic!) as ImageProvider
                                  : const AssetImage('assets/profile.png'),
                            ),
                            const SizedBox(height: 16),
                            Text('${user.name} ${user.surname}', style: Theme.of(context).textTheme.titleLarge),
                            Text('@${user.username}', style: Theme.of(context).textTheme.bodyMedium),
                          ],
                        ),
                      ),
                    ),

                    const Divider(),
                    //settings info
                    Expanded(
                      flex: 1,
                      child: SingleChildScrollView(
                        padding: const EdgeInsets.all(16.0),
                        child: _buildSettingsSection(user),
                      ),
                    ),
                  ],
                ),
              ),
              const VerticalDivider(width: 1),
              //right section
              Expanded(
                flex: 4,
                child: Column(
                  children: [
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
                          _buildTripList(_savedTrips, isMyTrip: false),
                          _buildTripList(_futureTrips, isMyTrip: true),
                        ],
                      ),
                    ),
                  ],
                ),
              ),
            ],
          ),
        );
      })
    );
  }

  //For tablet
  Widget _buildSettingsSection(UserModel user) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: [
        const Text(
          'Impostazioni',
          style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold),
        ),
        const SizedBox(height: 8),
        ListTile(
          leading: const Icon(Icons.person, color: Colors.black),
          title: const Text('Modifica Profilo', style: TextStyle(fontSize: 18)),
          onTap: () {
            Navigator.push(
              context,
              MaterialPageRoute(
                builder: (context) => AccountSettings(currentUserFuture: _currentUserFuture),
              ),
            ).then((_) => setState(() {
              _currentUserFuture = _loadCurrentUser();
            }));
          },
        ),
        ListTile(
          leading: const Icon(Icons.travel_explore_outlined, color: Colors.black),
          title: const Text('Nazioni Visitate', style: TextStyle(fontSize: 18)),
          onTap: () {
            Navigator.push(
              context,
              MaterialPageRoute(builder: (context) => const GamePage()),
            );
          },
        ),
        ListTile(
          leading: const Icon(Icons.monetization_on, color: Colors.black),
          title: const Text('Medaglie', style: TextStyle(fontSize: 18)),
          onTap: () {
            Navigator.push(
              context,
              MaterialPageRoute(
                builder: (context) => MedalsPage(username: user.username!, userId: user.id!),
              ),
            ).then((_) => setState(() {
              _currentUserFuture = _loadCurrentUser();
            }));
          },
        ),
        ListTile(
          leading: const Icon(Icons.logout, color: Colors.red),
          title: const Text('Log Out', style: TextStyle(fontSize: 18)),
          onTap: () async {
            await signOut();
          },
        ),
      ],
    );
  }

  //For mobile
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

  Widget _buildTripList(Future<List<TripModel>> future, {required bool isMyTrip}) {
    return FutureBuilder<List<TripModel>>(
      future: future,
      builder: (context, snapshot) {
        if (snapshot.connectionState == ConnectionState.waiting) {
          return const Center(child: CircularProgressIndicator());
        }

        if (snapshot.hasError || !snapshot.hasData || snapshot.data!.isEmpty) {
          return Center(child: Text(isMyTrip ? 'Nessun viaggio creato' : 'Nessun viaggio salvato'));
        }

        final trips = snapshot.data!;
        return ListView.builder(
          itemCount: trips.length,
          itemBuilder: (context, index) {
            final trip = trips[index];
            return GestureDetector(
              onTap: () {
                Navigator.push(
                  context,
                  MaterialPageRoute(
                    builder: (_) => TripPage(trip: trip, isMyTrip: isMyTrip),
                  ),
                );
              },
              child: TripCardWidget(trip, false, (a, b) {}, true),
            );
          },
        );
      },
    );
  }}