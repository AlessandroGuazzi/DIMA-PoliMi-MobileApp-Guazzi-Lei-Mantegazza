import 'package:dima_project/services/authService.dart';
import 'package:flutter/material.dart';
import 'package:dima_project/screens/myTripsPage.dart';
import 'package:dima_project/screens/profilePage.dart';
import 'package:dima_project/screens/explorerPage.dart';

class MyHomePage extends StatefulWidget {
  const MyHomePage({super.key, required this.title});

  final String title;

  @override
  State<MyHomePage> createState() => _MyHomePageState();
}

class _MyHomePageState extends State<MyHomePage> {


  Future<void> signOut() async{
    await AuthService().signOut();
  }

  @override
  Widget build(BuildContext context) {
    return DefaultTabController(
      length: 3,
      child: Scaffold(
        appBar: AppBar(
            title: Text("Dima Project"),
            backgroundColor: Theme.of(context).primaryColor
        ),
        body: const TabBarView(
            children: [
              profilePage(),
              MyTripsPage(),
              ExplorerPage()
            ]),
        bottomNavigationBar: const BottomAppBar(
            color: Colors.white,
            child: TabBar(
                indicatorColor: Colors.blueGrey,
                tabs: [
                  Tab(icon: Icon(Icons.search)),
                  Tab(icon: Icon(Icons.home)),
                  Tab(icon: Icon(Icons.account_box)),
                ])
        ),
      ),
    );
  }
}
