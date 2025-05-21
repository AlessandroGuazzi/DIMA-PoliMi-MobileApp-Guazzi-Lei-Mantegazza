import 'package:dima_project/utils/responsive.dart';
import 'package:flutter/material.dart';
import 'package:dima_project/screens/upsertTripPage.dart';
import 'package:dima_project/widgets/trip_widgets/tripCardWidget.dart';
import 'package:dima_project/models/tripModel.dart';
import 'package:dima_project/services/databaseService.dart';
import 'package:dima_project/screens/tripPage.dart';

class MyTripsPage extends StatefulWidget {
  const MyTripsPage({super.key});

  @override
  State<MyTripsPage> createState() => _MyTripsPageState();
}

class _MyTripsPageState extends State<MyTripsPage> {
  late Future<List<TripModel>> _futureTrips;
  TripModel? _selectedTrip;
  late final bool _isTablet;

  @override
  void initState() {
    super.initState();
    _futureTrips = DatabaseService().getHomePageTrips();
  }

  Future<void> refreshTrips() async {
    setState(() {
      _futureTrips = DatabaseService().getHomePageTrips();
      print("refresheeeeeeed");
    });
  }

  void _goToNewTripPage() {
    Navigator.push(context,
            MaterialPageRoute(builder: (context) => const UpsertTripPage()))
        .then((value) => refreshTrips());
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
            return Center(child: Text('Error: ${snapshot.error}'));
          } else if (!snapshot.hasData || snapshot.data!.isEmpty) {
            return const Center(child: Text('Pianifica il tuo primo viaggio'));
          }

          final trips = snapshot.data!;

          return Stack(
            children: [
              ResponsiveLayout(
                  mobileLayout: _buildMobileLayout(trips),
                  tabletLayout: _buildTabletLayout(trips)),

              // Floating button
              //TODO: reposition it for tablet
            ],
          );
        },
      ),
      floatingActionButton: FloatingActionButton(
        heroTag: 'newTripButton',
        onPressed: _goToNewTripPage,
        child: const Icon(Icons.add),
      ),
      floatingActionButtonLocation: FloatingActionButtonLocation.endFloat,
    );
  }

  /*
  This method builds the list of trips tiles, already differentiating
  between tablet and mobile actions on tap of each card
   */
  Widget _myTripsList(List<TripModel> trips, Function onTileTap) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Padding(
          padding: const EdgeInsets.only(left: 10, top: 15, bottom: 5),
          child: Text(
            'I tuoi viaggi',
            style: Theme.of(context).textTheme.headlineLarge,
          ),
        ),
        Divider(),
        Expanded(
          child: ListView.builder(
            itemCount: trips.length,
            itemBuilder: (context, index) {
              final trip = trips[index];
              return Material(
                color: Theme.of(context).scaffoldBackgroundColor,
                child: InkWell(
                    onTap: () {
                      onTileTap(trip);
                    },
                    child: TripCardWidget(trip, false, (isSaved, id) {}, true)),
              );
            },
          ),
        ),
      ],
    );
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
              ? TripPage(trip: _selectedTrip!, isMyTrip: true)
              : const Center(child: Text('Seleziona un viaggio')),
        ),
      ],
    );
  }
}
