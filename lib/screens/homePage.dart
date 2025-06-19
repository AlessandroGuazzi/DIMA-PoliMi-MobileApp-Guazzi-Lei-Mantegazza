import 'package:dima_project/services/authService.dart';
import 'package:dima_project/services/databaseService.dart';
import 'package:flutter/material.dart';
import 'package:dima_project/screens/myTripsPage.dart';
import 'package:dima_project/screens/profilePage.dart';
import 'package:dima_project/screens/explorerPage.dart';

class MyHomePage extends StatefulWidget {
  MyHomePage({super.key, required this.title, DatabaseService? databaseService, authService})
      : databaseService = databaseService ?? DatabaseService(),
        authService = authService ?? AuthService();


  late final DatabaseService databaseService;
  late final AuthService authService;
  final String title;
  late List<Widget> _pages;

  @override
  State<MyHomePage> createState() => _MyHomePageState();
}

class _MyHomePageState extends State<MyHomePage> {
  int _selectedIndex = 0;



  @override
  void initState() {
    super.initState();
    widget._pages = [
      ExplorerPage(databaseService: widget.databaseService, authService: widget.authService,),
      MyTripsPage(databaseService: widget.databaseService),
      ProfilePage(databaseService: widget.databaseService, authService: widget.authService),
    ];
  }

  Future<void> signOut() async {
    await AuthService().signOut();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Theme.of(context).scaffoldBackgroundColor,
      appBar: AppBar(
        title: Text(widget.title),
      ),
      body: widget._pages[_selectedIndex],
      bottomNavigationBar: BottomNavigationBar(
        currentIndex: _selectedIndex,
        onTap: (index) => setState(() => _selectedIndex = index),
        items: const [
          BottomNavigationBarItem(
            icon: Icon(Icons.search),
            label: 'Esplora',
          ),
          BottomNavigationBarItem(
            icon: Icon(Icons.home),
            label: 'Home',
          ),
          BottomNavigationBarItem(
            icon: Icon(Icons.account_box),
            label: 'Profilo',
          ),
        ],
      ),
    );
  }
}
