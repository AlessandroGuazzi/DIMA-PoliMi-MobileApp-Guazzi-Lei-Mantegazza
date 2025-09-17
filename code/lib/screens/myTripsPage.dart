import 'package:dima_project/utils/responsive.dart';
import 'package:flutter/material.dart';
import 'package:dima_project/widgets/trip_widgets/tripCardWidget.dart';
import 'package:dima_project/models/tripModel.dart';
import 'package:dima_project/services/databaseService.dart';
import 'package:dima_project/screens/tripPage.dart';

class MyTripsPage extends StatefulWidget {
  final DatabaseService databaseService;

  //constructor with injection for mocking
  MyTripsPage({
    super.key,
    DatabaseService? databaseService,
  }) : databaseService = databaseService ?? DatabaseService();

  @override
  State<MyTripsPage> createState() => _MyTripsPageState();
}

class _MyTripsPageState extends State<MyTripsPage> {
  late Future<List<TripModel>> _futureTrips;
  TripModel? _selectedTrip;

  @override
  void initState() {
    super.initState();
    _futureTrips = widget.databaseService.getHomePageTrips();
  }

  @override
  void didUpdateWidget(covariant MyTripsPage oldWidget) {
    print('mytripspage didupdatewidget');
    super.didUpdateWidget(oldWidget);
    //reassign future on widget update
    _futureTrips = widget.databaseService.getHomePageTrips();
  }

  @override
  Widget build(BuildContext context) {
    //future builder that wait for the trips to be loaded
    return Scaffold(
      body: FutureBuilder<List<TripModel>>(
        future: _futureTrips,
        builder: (context, snapshot) {
          if (snapshot.connectionState == ConnectionState.waiting) {
            return const Center(child: CircularProgressIndicator());
          } else if (snapshot.hasError) {
            return Center(child: Text('Errore: ${snapshot.error}'));
          } else if (!snapshot.hasData || snapshot.data!.isEmpty) {
            return const Center(child: Text('Pianifica il tuo primo viaggio'));
          }

          final trips = snapshot.data!;

          return Stack(
            children: [
              ResponsiveLayout(
                  mobileLayout: _buildMobileLayout(trips),
                  tabletLayout: _buildTabletLayout(trips)),
            ],
          );
        },
      ),
    );
  }

  Widget _myTripsList(List<TripModel> trips, Function onTileTap) {
    final splitTrips = splitPastFutureTrips(trips);
    List<TripModel>? pastTrips = splitTrips['pastTrips'];
    List<TripModel>? futureTrips = splitTrips['futureTrips'];

    return DefaultTabController(
      length: 2,
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          TabBar(
            //labelColor: Theme.of(context).primaryColor,
            unselectedLabelColor: Colors.grey,
            indicatorColor: Theme.of(context).primaryColor,
            labelStyle: Theme.of(context).textTheme.titleMedium,
            unselectedLabelStyle: Theme.of(context).textTheme.bodySmall,
            tabs: const [
              Tab(text: 'I tuoi viaggi'), // Upcoming Trips
              Tab(text: 'Viaggi passati'), // Past Trips
            ],
          ),
          Expanded(
            child: TabBarView(
              children: [
                // Upcoming Trips
                (futureTrips == null || futureTrips.isEmpty)
                    ? const Center(child: Text('Nessun viaggio in programma.'))
                    : ListView.builder(
                        itemCount: futureTrips.length,
                        itemBuilder: (context, index) {
                          final trip = futureTrips[index];
                          return Material(
                            color: Theme.of(context).scaffoldBackgroundColor,
                            child: InkWell(
                              onTap: () => onTileTap(trip),
                              child: TripCardWidget(
                                  trip, false, (isSaved, id) {}, true),
                            ),
                          );
                        },
                      ),

                // Past Trips
                (pastTrips == null || pastTrips.isEmpty)
                    ? const Center(child: Text('Nessun viaggio passato.'))
                    : ListView.builder(
                        itemCount: pastTrips.length,
                        itemBuilder: (context, index) {
                          final trip = pastTrips[index];
                          return Material(
                            color: Theme.of(context).scaffoldBackgroundColor,
                            child: InkWell(
                              onTap: () => onTileTap(trip),
                              child: TripCardWidget(
                                  trip, false, (isSaved, id) {}, true),
                            ),
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

  Map<String, List<TripModel>> splitPastFutureTrips(List<TripModel> trips) {
    final pastTrips = trips
        .where((trip) =>
            trip.endDate != null && trip.endDate!.isBefore(DateTime.now()))
        .toList();

    final List<TripModel> futureTrips =
        trips.toSet().difference(pastTrips.toSet()).toList();

    return {
      'pastTrips': pastTrips,
      'futureTrips': futureTrips,
    };
  }

  Widget _buildMobileLayout(List<TripModel> trips) {
    return _myTripsList(
        trips,
        (trip) => {
              Navigator.push(
                context,
                MaterialPageRoute<void>(
                  builder: (context) => TripPage(
                    trip: trip,
                    isMyTrip: true,
                    databaseService: widget.databaseService,
                  ),
                ),
              ).then((_) {
                refreshTrips();
              })
            });
  }

  Widget _buildTabletLayout(List<TripModel> trips) {
    return Row(
      children: [
        Expanded(
          flex: 2,
          child: _myTripsList(
              trips,
              (trip) => {
                    setState(() {
                      _selectedTrip = trip;
                    })
                  }),
        ),
        const VerticalDivider(width: 1),
        Expanded(
          flex: 3,
          child: _selectedTrip != null
              ? TripPage(
                  trip: _selectedTrip!,
                  isMyTrip: true,
                  databaseService: widget.databaseService,
                  onTripDeleted: () => refreshTrips(),
                  onTripUpdated: (updatedTrip) => refreshWithoutUnselecting(updatedTrip),
                )
              : const Center(child: Text('Seleziona un viaggio')),
        ),
      ],
    );
  }

  Future<void> refreshTrips() async {
    setState(() {
      _futureTrips = widget.databaseService.getHomePageTrips();
      _selectedTrip = null;
    });
  }

  Future<void> refreshWithoutUnselecting(TripModel updatedTrip) async {
    setState(() {
      _futureTrips = widget.databaseService.getHomePageTrips();
      _selectedTrip = updatedTrip;
    });
  }
}
