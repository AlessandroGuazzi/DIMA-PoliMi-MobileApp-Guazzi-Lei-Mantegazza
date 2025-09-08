import 'package:dima_project/models/userModel.dart';
import 'package:dima_project/screens/upsertTripPage.dart';
import 'package:dima_project/services/authService.dart';
import 'package:dima_project/services/databaseService.dart';
import 'package:dima_project/widgets/components/myAppBar.dart';
import 'package:flutter/material.dart';
import 'package:dima_project/screens/myTripsPage.dart';
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
  late Future<UserModel?> _userFuture;

  @override
  void initState() {
    super.initState();

    final currentUser = widget.authService.currentUser;
    if (currentUser != null) {
      _userFuture = widget.databaseService.getUserByUid(currentUser.uid);
    } else {
      _userFuture = Future.error('Utente non autenticato');
    }
  }

  List<Widget> get _pages => [
        ExplorerPage(
            databaseService: widget.databaseService,
            authService: widget.authService),
        MyTripsPage(databaseService: widget.databaseService),
      ];

  Future<void> signOut() async {
    await widget.authService.signOut();
  }

  @override
  Widget build(BuildContext context) {
    //TODO: improvement, pass directly currentUserData instead of fetching again from db
    return FutureBuilder(
      future: _userFuture,
      builder: (context, snapshot) {
        if (snapshot.connectionState == ConnectionState.waiting) {
          return const Scaffold(
            body: Center(child: CircularProgressIndicator()),
          );
        } else if (snapshot.hasError) {
          return Scaffold(
            body: Center(child: Text('Errore: ${snapshot.error}')),
          );
        } else if (!snapshot.hasData || snapshot.data == null) {
          return const Scaffold(
            body: Center(child: Text('Nessun dato utente trovato.')),
          );
        }

        final user = snapshot.data!;

        return Scaffold(
          backgroundColor: Theme.of(context).scaffoldBackgroundColor,
          extendBody: true,
          appBar: MyAppBar(
            user: user,
            context: context,
            databaseService: widget.databaseService,
            authService: widget.authService,
            rebuildAppBar: rebuildAppBar,
          ),
          body: _pages[_selectedIndex],
          floatingActionButton: FloatingActionButton(
            shape: const CircleBorder(),
            onPressed: () {
              Navigator.push(
                context,
                MaterialPageRoute(
                    builder: (_) => UpsertTripPage(
                          databaseService: widget.databaseService,
                          authService: widget.authService,
                        )),
              ).then((value) => setState(() {
                    print('Returned from upsertt');
                    _selectedIndex = 1;
                  }));
            },
            child: const Icon(Icons.add_location_alt_outlined, size: 30,),
          ),
          floatingActionButtonLocation:
              FloatingActionButtonLocation.centerDocked,
          bottomNavigationBar: BottomAppBar(
            shape: const CircularNotchedRectangle(),
            notchMargin: 10,
            child: Row(
              mainAxisAlignment: MainAxisAlignment.spaceAround,
              children: [
                // Left navigation item
                IconButton(
                  key: const Key('searchButton'),
                  icon: Icon(
                    Icons.search,
                    size: 27,
                    color: Theme.of(context).primaryColor,
                  ),
                  onPressed: () => setState(() => _selectedIndex = 0),
                  tooltip: 'Esplora',
                ),

                const SizedBox(width: 10),
                // Right navigation item
                IconButton(
                  key: const Key('homeButton'),
                  icon: Icon(
                    _selectedIndex == 1 ? Icons.home : Icons.home_outlined,
                    size: 27,
                    color: Theme.of(context).primaryColor,
                  ),
                  onPressed: () => setState(() => _selectedIndex = 1),
                  tooltip: 'Home',
                ),
              ],
            ),
          ),
        );
      },
    );
  }

  //callback method to rebuild appBar
  void rebuildAppBar() {
    setState(() {
      final currentUser = widget.authService.currentUser;
      if (currentUser != null) {
        _userFuture = widget.databaseService.getUserByUid(currentUser.uid);
      } else {
        _userFuture = Future.error('Utente non autenticato');
      }
    });
  }
}
