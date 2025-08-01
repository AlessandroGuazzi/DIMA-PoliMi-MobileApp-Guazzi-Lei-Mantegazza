import 'package:dima_project/screens/medalsPage.dart';
import 'package:dima_project/screens/tripPage.dart';
import 'package:dima_project/utils/screenSize.dart';
import 'package:dima_project/widgets/components/myBottomSheetHandle.dart';
import 'package:dima_project/widgets/trip_widgets/tripCardWidget.dart';
import 'package:dima_project/widgets/components/userProfileCard.dart';
import 'package:flutter/material.dart';
import 'package:dima_project/services/authService.dart';
import 'package:dima_project/services/databaseService.dart';
import 'package:dima_project/screens/accountSettings.dart';
import '../main.dart';
import '../models/tripModel.dart';
import '../models/userModel.dart';
import '../utils/responsive.dart';
import 'travelStatsPage.dart';

class ProfilePage extends StatefulWidget {
  late final DatabaseService databaseService;
  late final AuthService authService;
  final String? userId;
  final bool isCurrentUser;

  ProfilePage(
      {super.key,
      required this.userId,
      databaseService,
      authService, required this.isCurrentUser,})
      : databaseService = databaseService ?? DatabaseService(),
        authService = authService ?? AuthService();

  @override
  State<ProfilePage> createState() => _ProfilePageState();
}

class _ProfilePageState extends State<ProfilePage> {
  Future<UserModel?>? _userFuture;
  late Future<List<TripModel>> _createdTripsFuture;
  late Future<List<TripModel>> _savedTripsFuture;
  bool _isMyProfile = false;

  @override
  void initState() {
    super.initState();
    final currentUser = widget.authService.currentUser;


    if (currentUser != null && widget.userId != null) {
      //check if the user to be displayed is the current user
      if (currentUser.uid == widget.userId) {
        _isMyProfile = true;
      }
      _userFuture = widget.databaseService.getUserByUid(widget.userId!);
      _createdTripsFuture = widget.databaseService.getTripsOfUserWithPrivacy(widget.userId!, !_isMyProfile);
    }
  }

  Future<void> signOut() async {
    await widget.authService.signOut();
  }

  @override
  Widget build(BuildContext context) {
    return ResponsiveLayout(
      mobileLayout: _buildMobileLayout(),
      tabletLayout: _buildTabletLayout(),
    );
  }

  Widget _futureUserBuilder(Widget Function(UserModel user) builder) {
    if (_userFuture == null) {
      return const Scaffold(
        body: Center(child: Text('Nessun utente autenticato')),
      );
    }

    return FutureBuilder<UserModel?>(
      future: _userFuture,
      builder: (context, snapshot) {
        if (snapshot.connectionState == ConnectionState.waiting) {
          return const Scaffold(
            body: Center(child: CircularProgressIndicator()),
          );
        }

        if (snapshot.hasError || !snapshot.hasData) {
          return Scaffold(
            body: Center(
              child: Text(
                'Errore: ${snapshot.error ?? 'Utente non trovato'}',
              ),
            ),
          );
        }

        final user = snapshot.data!;
        _savedTripsFuture = widget.databaseService.getTripsByIds(user.savedTrip);

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
                  expandedHeight: 350,
                  pinned: true,
                  floating: false,
                  backgroundColor:
                      myAppKey.currentState?.currentTheme == ThemeMode.dark
                          ? Colors.black
                          : Colors.white,
                  centerTitle: true,
                  actions: [
                    IconButton(
                      key: const Key('Settings'),
                      icon: Icon(
                        key: const Key('settingsButton'),
                        Icons.settings,
                        color: myAppKey.currentState?.currentTheme ==
                                ThemeMode.dark
                            ? Colors.white
                            : Colors.black,
                      ),
                      onPressed: () => _showSettingsModal(user, _isMyProfile),
                    )
                  ],
                  flexibleSpace: FlexibleSpaceBar(
                    collapseMode: CollapseMode.pin,
                    background: Center(child: UserProfileCard(user: user)),
                  ),
                  bottom: const TabBar(
                    tabs: [
                      Tab(text: 'Viaggi Salvati'),
                      Tab(text: 'Viaggi Creati'),
                    ],
                  ),
                ),
              ],
              body: TabBarView(
                children: [
                  _buildTripList(_savedTripsFuture, isMyTrip: false),
                  _buildTripList(_createdTripsFuture, isMyTrip: widget.isCurrentUser),
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
                        child: SizedBox.expand(
                          child: UserProfileCard(user: user),
                        ),
                      ),

                      const Divider(),

                      //settings info
                      Expanded(
                        flex: 1,
                        child: SingleChildScrollView(
                          padding: const EdgeInsets.all(16.0),
                          child: _buildProfileMenuListView(
                              ScreenSize.isTablet(context), user),
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
                          Tab(text: 'Viaggi Creati'),
                        ],
                      ),
                      Expanded(
                        child: TabBarView(
                          children: [
                            _buildTripList(_savedTripsFuture, isMyTrip: false),
                            _buildTripList(_createdTripsFuture, isMyTrip: widget.isCurrentUser),
                          ],
                        ),
                      ),
                    ],
                  ),
                ),
              ],
            ),
          );
        }));
  }

  Widget _buildTripList(Future<List<TripModel>> future,
      {required bool isMyTrip}) {
    return FutureBuilder<List<TripModel>>(
      future: future,
      builder: (context, snapshot) {
        if (snapshot.connectionState == ConnectionState.waiting) {
          return const Center(child: CircularProgressIndicator());
        }

        if (snapshot.hasError || !snapshot.hasData || snapshot.data!.isEmpty) {
          return Center(
              child: Text(isMyTrip
                  ? 'Nessun viaggio creato'
                  : 'Nessun viaggio salvato'));
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
                    builder: (_) => TripPage(
                        trip: trip,
                        isMyTrip: isMyTrip,
                        databaseService: widget.databaseService),
                  ),
                );
              },
              child: TripCardWidget(trip, false, (a, b) {}, true),
            );
          },
        );
      },
    );
  }

  //For mobile
  void _showSettingsModal(UserModel user, bool isMyProfile) {
    showModalBottomSheet(
      context: context,
      isScrollControlled: false,
      builder: (BuildContext context) {
        return Container(
          decoration: const BoxDecoration(
            borderRadius: BorderRadius.only(
              topLeft: Radius.circular(15),
              topRight: Radius.circular(15),
            ),
          ),
          child: Padding(
            padding: const EdgeInsets.all(8.0),
            child: SingleChildScrollView(
              child: Column(
                mainAxisSize: MainAxisSize.min,
                children: [
                  const MyBottomSheetHandle(),
                  _buildProfileMenuListView(ScreenSize.isTablet(context), user)
                ],
              ),
            ),
          ),
        );
      },
    );
  }

  Widget _buildProfileMenuListView(bool isTablet, UserModel user) {
    return Column(
      children: [
        // Opzione "Modifica Profilo" condizionale
        if (_isMyProfile)
          ListTile(
            key: const Key('Modifica Profilo'),
            leading: const Icon(Icons.person),
            title: Text('Modifica Profilo',
                style: Theme.of(context).textTheme.bodyMedium),
            onTap: () {
              if (!isTablet) Navigator.pop(context);
              Navigator.push(
                context,
                MaterialPageRoute(
                  builder: (context) => AccountSettings(
                    currentUserFuture: _userFuture,
                    authService: widget.authService,
                  ),
                ),
              ).then((_) => setState(() {
                if (widget.userId != null) {
                  _userFuture =
                      widget.databaseService.getUserByUid(widget.userId!);
                }
              }));
            },
          ),
        ListTile(
          key: const Key('Nazioni Visitate'),
          leading: const Icon(Icons.travel_explore_outlined),
          title: Text('Nazioni Visitate',
              style: Theme.of(context).textTheme.bodyMedium),
          onTap: () {
            if (!isTablet) Navigator.pop(context);
            Navigator.push(
              context,
              MaterialPageRoute(
                  builder: (context) => TravelStatsPage(
                    databaseService: widget.databaseService,
                    userId: widget.userId!,
                  )),
            );
          },
        ),
        ListTile(
          leading: const Icon(Icons.monetization_on),
          title:
          Text('Medaglie', style: Theme.of(context).textTheme.bodyMedium),
          onTap: () {
            if (!isTablet) Navigator.pop(context);
            Navigator.push(
              context,
              MaterialPageRoute(
                builder: (context) => MedalsPage(
                    username: user.username!,
                    userId: user.id!,
                    databaseService: widget.databaseService),
              ),
            ).then((_) => setState(() {
              if (widget.userId != null) {
                _userFuture =
                    widget.databaseService.getUserByUid(widget.userId!);
              }
            }));
          },
        ),
        // Opzione "Tema" condizionale
        if (_isMyProfile)
          ListTile(
            key: const Key('Theme Settings'),
            title: Text(
                myAppKey.currentState?.currentTheme == ThemeMode.dark
                    ? 'Tema chiaro'
                    : 'Tema scuro',
                style: Theme.of(context).textTheme.bodyMedium),
            leading: Icon(
              myAppKey.currentState?.currentTheme == ThemeMode.dark
                  ? Icons.light_mode
                  : Icons.dark_mode,
            ),
            onTap: () {
              if (!isTablet) Navigator.pop(context);
              myAppKey.currentState?.toggleTheme();
            },
          ),
        // Opzione "Logout" condizionale
        if (_isMyProfile)
          ListTile(
            key: const Key('Logout'),
            leading: const Icon(Icons.logout, color: Colors.red),
            title: Text('Log Out', style: Theme.of(context).textTheme.bodyMedium),
            onTap: () async {
              await signOut();
              if (!isTablet) Navigator.of(context).pop();
            },
          ),
      ],
    );
  }
}
