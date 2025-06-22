import 'package:dima_project/services/authService.dart';
import 'package:dima_project/services/databaseService.dart';
import 'package:flutter/material.dart';
import 'package:dima_project/screens/myTripsPage.dart';
import 'package:dima_project/screens/profilePage.dart';
import 'package:dima_project/screens/explorerPage.dart';

class MyHomePage extends StatefulWidget {
  MyHomePage({
    super.key,
    required this.title,
    databaseService,
    authService,
  })  : databaseService = databaseService ?? DatabaseService(),
        authService = authService ?? AuthService();

  final String title;
  final DatabaseService databaseService;
  final AuthService authService;

  @override
  State<MyHomePage> createState() => _MyHomePageState();
}

class _MyHomePageState extends State<MyHomePage> {
  int _selectedIndex = 0;

  List<Widget> get _pages => [
        ExplorerPage(
            databaseService: widget.databaseService, authService: widget.authService),
        MyTripsPage(databaseService: widget.databaseService),
        ProfilePage(
            databaseService: widget.databaseService, authService: widget.authService),
      ];

  Future<void> signOut() async {
    await widget.authService.signOut();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Theme.of(context).scaffoldBackgroundColor,
      appBar: AppBar(
        title: Text(widget.title),
      ),
      body: _pages[_selectedIndex],
      bottomNavigationBar: BottomNavigationBar(
        currentIndex: _selectedIndex,
        onTap: (index) => setState(() => _selectedIndex = index),
        items: const [
          BottomNavigationBarItem(
            key: Key('searchButton'),
            icon: Icon(Icons.search),
            label: 'Esplora',
          ),
          BottomNavigationBarItem(
            key: Key('homeButton'),
            icon: Icon(Icons.home),
            label: 'Home',
          ),
          BottomNavigationBarItem(
            key: Key('profileButton'),
            icon: Icon(Icons.account_box),
            label: 'Profilo',
          ),
        ],
      ),
    );
  }
}
