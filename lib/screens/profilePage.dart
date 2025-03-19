import 'package:dima_project/utils/screenSize.dart';
import 'package:flutter/material.dart';
import 'package:dima_project/services/authService.dart';

class ProfilePage extends StatefulWidget {
  const ProfilePage({super.key});

  @override
  State<ProfilePage> createState() => _ProfilePageState();
}

class _ProfilePageState extends State<ProfilePage> {

  Future<void> signOut() async{
    await AuthService().signOut();
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
          title: const Text(
            'Profilo',
            style: TextStyle(
              fontSize: 22,
              fontWeight: FontWeight.bold,
              color: Colors.black,
            ),
          ),
          actions: [
            IconButton(
              icon: const Icon(Icons.settings, color: Colors.black),
              onPressed: () {},
            )
          ],
        ),
        body: SafeArea(
          child: Column(
            children: [
              const SizedBox(height: 24),
              Container(
                width: ScreenSize.screenWidth(context)*0.30,
                height: ScreenSize.screenHeight(context)*0.15,
                //width: 150,
                //height: 150,
                decoration: BoxDecoration(
                  shape: BoxShape.circle,
                  border: Border.all(
                    color: Theme.of(context).primaryColor,
                    width: 2,
                  ),
                  image: const DecorationImage(
                    image: AssetImage('assets/profile.png'),
                    fit: BoxFit.cover,
                  ),
                ),
              ),
              const SizedBox(height: 16),
              const Text(
                'Marco Rossi',
                style: TextStyle(
                  fontSize: 20,
                  fontWeight: FontWeight.w600,
                ),
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
        ),
      ),
    );
  }

}