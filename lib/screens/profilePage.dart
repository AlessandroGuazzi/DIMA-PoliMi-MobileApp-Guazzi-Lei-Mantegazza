import 'package:dima_project/screens/gamePage.dart';
import 'package:dima_project/screens/gamePage2.dart';
import 'package:dima_project/screens/tripDetailPage.dart';
import 'package:dima_project/utils/screenSize.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:dima_project/services/authService.dart';
import 'package:dima_project/services/databaseService.dart';
import 'package:dima_project/screens/accountSettings.dart';
import 'package:intl/intl.dart';
import '../models/tripModel.dart';
import '../models/userModel.dart';

class ProfilePage extends StatefulWidget {
  const ProfilePage({super.key});

  @override
  State<ProfilePage> createState() => _ProfilePageState();
}

class _ProfilePageState extends State<ProfilePage> {
  late Future<UserModel?> _currentUserFuture;
  late Future<List<TripModel>> _futureTrips;

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


  void _showSettingsModal() {
    showModalBottomSheet(
      context: context,
      backgroundColor: Colors.transparent,
      isScrollControlled: false, // Impostalo su false per evitare problemi di altezza
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
                        // Aggiungi azione per "Account"
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
                          MaterialPageRoute(builder: (context) => const GamePage2()),
                        );
                      },
                    ),
                    ListTile(
                      title: const Text('Preferenze', style: TextStyle(fontSize: 18)),
                      leading: const Icon(Icons.tune, color: Colors.black),
                      onTap: () {
                        // Aggiungi azione per "Preferenze"
                        Navigator.of(context).pop(); // Chiudi la sheet
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
      child: Scaffold(
        backgroundColor: const Color(0xFFF1F4F8),
        appBar: AppBar(
          backgroundColor: Colors.transparent,
          elevation: 0,
          centerTitle: true,
          actions: [
            IconButton(
              icon: const Icon(Icons.settings, color: Colors.black),
              onPressed: () {
                _showSettingsModal();
              },
            )
          ],
        ),
        body: FutureBuilder(
            future: _currentUserFuture,
            builder: (context, snapshot) {

              if (snapshot.connectionState == ConnectionState.waiting) {
                return const Center(child: CircularProgressIndicator());
              }

              if (snapshot.hasError) {
                return Center(child: Text('Errore: ${snapshot.error}'));
              }

              if (snapshot.data == null) {
                return const Center(child: Text('Utente non trovato'));
              }

              return SafeArea(
                child: Column(
                  children: [
                    const SizedBox(height: 0),
                    Container(
                      width: ScreenSize.screenWidth(context)*0.35,
                      height: ScreenSize.screenHeight(context)*0.15,
                      decoration: BoxDecoration(
                        shape: BoxShape.circle,
                        border: Border.all(
                          color: Theme.of(context).primaryColor,
                          width: 2,
                        ),
                        image: DecorationImage(
                          image: snapshot.data!.profilePic == null
                              ? const AssetImage('assets/profile.png')
                              : NetworkImage(snapshot.data!.profilePic!),
                          fit: BoxFit.cover,
                        )
                      ),
                    ),
                    const SizedBox(height: 16),
                    Column(
                      children: [
                        Text(
                          '${snapshot.data!.name} ${snapshot.data!.surname}',
                          style: const TextStyle(
                            fontSize: 20,
                            fontWeight: FontWeight.w600,
                          ),
                        ),
                        Text(
                          '@${snapshot.data!.username}',
                          style: TextStyle(
                          fontSize: 16,
                          color: Colors.grey[600], // Colore grigio per lo username
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
                          const Center(
                              child: Text('Lista dei Viaggi Salvati'),
                          ),
                          FutureBuilder<List<TripModel>>(
                            future: _futureTrips,
                            builder: (context, snapshot) {
                              if (snapshot.connectionState == ConnectionState.waiting) {
                                return const Center(child: CircularProgressIndicator());
                              }

                              if (snapshot.hasError) {
                                return const Center(child: Text('Errore nel caricamento dei viaggi'));
                              }

                              final trips = snapshot.data!;

                              if (trips.isEmpty) {
                                return const Center(child: Text('Nessun viaggio creato'));
                              }

                              return ListView.builder(
                                padding: const EdgeInsets.all(16),
                                itemCount: trips.length,
                                itemBuilder: (context, index) {
                                  final trip = trips[index];
                                  return Card(
                                    margin: const EdgeInsets.only(bottom: 16),
                                    elevation: 4, // Aggiungi un'ombra per dare profondità
                                    shape: RoundedRectangleBorder(
                                      borderRadius: BorderRadius.circular(8), // Angoli arrotondati
                                    ),
                                    child: ListTile(
                                      contentPadding: const EdgeInsets.all(16),
                                      leading: Container(
                                        padding: const EdgeInsets.all(8),
                                        decoration: BoxDecoration(
                                          color: Theme.of(context).primaryColor.withAlpha(100), // Sfondo del cerchio
                                          shape: BoxShape.circle,
                                        ),
                                        child: const Icon(
                                          Icons.travel_explore,
                                          color: Colors.white, // Colore dell'icona
                                        ),
                                      ),
                                      title: Text(
                                        trip.title ?? 'Viaggio senza titolo',
                                        style: const TextStyle(
                                          fontWeight: FontWeight.bold,
                                          fontSize: 18, // Dimensione del titolo
                                        ),
                                      ),
                                      subtitle: Column(
                                        crossAxisAlignment: CrossAxisAlignment.start,
                                        children: [
                                          Text(
                                            'Nazioni: ${trip.nations?.map((n) => n['name']).join(', ')}',
                                            style: TextStyle(
                                              fontSize: 14, // Dimensione del testo
                                              color: Theme.of(context).hintColor, // Colore del testo
                                            ),
                                          ),
                                          Text(
                                            'Date: ${DateFormat('dd/MM/yyyy').format(trip.startDate!)} - '
                                                '${DateFormat('dd/MM/yyyy').format(trip.endDate!)}',
                                            style: TextStyle(
                                              fontSize: 14, // Dimensione del testo
                                              color: Theme.of(context).hintColor, // Colore del testo
                                            ),
                                          ),
                                        ],
                                      ),
                                      trailing: Icon(
                                        Icons.arrow_forward_ios,
                                        color: Theme.of(context).primaryColor, // Colore della freccia
                                      ),
                                      onTap: () {
                                        Navigator.push(context, MaterialPageRoute<void>(builder: (context) => tripDetailPage(trip: trip)));
                                      },
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
              );
            }
        ),
      ),
    );
  }

}