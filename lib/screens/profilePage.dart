import 'package:dima_project/utils/screenSize.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:dima_project/services/authService.dart';
import 'package:dima_project/services/databaseService.dart';
import 'package:dima_project/screens/accountSettings.dart';

import '../models/userModel.dart';

class ProfilePage extends StatefulWidget {
  const ProfilePage({super.key});

  @override
  State<ProfilePage> createState() => _ProfilePageState();
}

class _ProfilePageState extends State<ProfilePage> {
  late Future<UserModel?> _currentUserFuture;

  Future<UserModel?> _loadCurrentUser() async {
    final user = FirebaseAuth.instance.currentUser;
    if (user != null) {
      return await DatabaseService().getUserByUid(user.uid);
    }
    return null;
  }

  @override
  void initState() {
    super.initState();
    _currentUserFuture = _loadCurrentUser();
  }

  Future<void> signOut() async{
    await AuthService().signOut();
  }

  void _showSettingsModal() {
    showModalBottomSheet(
      context: context,
      backgroundColor: Colors.transparent,
      isScrollControlled: true,
      builder: (BuildContext context) {
        return Container(
          height: 300, // Altezza della sheet
          decoration: const BoxDecoration(
            color: Colors.white,
            borderRadius: BorderRadius.only(
              topLeft: Radius.circular(20),
              topRight: Radius.circular(20),
            ),
          ),
          child: Padding(
            padding: const EdgeInsets.all(16.0),
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center, // Centra verticalmente
              children: [
                // Lista delle impostazioni
                Expanded(
                  child: ListView(
                    shrinkWrap: true, // Per evitare errori di overflow
                    children: [
                      ListTile(
                        title: const Text('Account', style: TextStyle(fontSize: 18)),
                        leading: const Icon(Icons.person, color: Colors.black),
                        onTap: () {
                          // Aggiungi azione per "Account"
                          Navigator.push(
                            context,
                            MaterialPageRoute(builder: (context) => AccountSettings(currentUserFuture: _currentUserFuture)),
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
                        title: const Text('Feedback', style: TextStyle(fontSize: 18)),
                        leading: const Icon(Icons.feedback, color: Colors.black),
                        onTap: () {
                          // Aggiungi azione per "Feedback"
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
                    const Expanded(
                      child: TabBarView(
                        children: [
                          Center(child: Text('Lista dei Viaggi Salvati')),
                          Center(child: Text('Lista dei Tuoi Viaggi')),
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