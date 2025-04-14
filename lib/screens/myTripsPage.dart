import 'package:dima_project/screens/mapPage.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:dima_project/screens/newTripPage.dart';
import 'package:dima_project/widgets/tripCardWidget.dart';
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

  @override
  void initState() {
    super.initState();
    _futureTrips = DatabaseService().getHomePageTrips();
  }

  void refreshTrips() {
    setState(() {
      _futureTrips = DatabaseService().getHomePageTrips();
    });
  }

  void _goToNewTripPage()  {
    Navigator.push(context,
            MaterialPageRoute(builder: (context) => const NewTripPage())).then((value) => refreshTrips());

  }

  @override
  Widget build(BuildContext context) {
    return Stack(
      children: [
        FutureBuilder<List<TripModel>>(
          future: _futureTrips,
          builder: (context, snapshot) {
            if (snapshot.connectionState == ConnectionState.waiting) {
              return const Center(child: CircularProgressIndicator());
            } else if (snapshot.hasError) {
              return Center(child: Text('Error: ${snapshot.error}'));
            } else if (!snapshot.hasData || snapshot.data!.isEmpty) {
              return const Center(child: Text('Pianifica il tuo primo viaggio'));
            }

            // List of trips, with null-check!
            List<TripModel> trips = snapshot.data!;

            return Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Padding(
                  padding: const EdgeInsets.only(left: 10, top: 15, bottom: 5),
                  child: Text('Pianifica i tuoi viaggi', style: Theme.of(context).textTheme.displayLarge,),
                ),
                Expanded(
                  child: ListView.builder(
                    itemCount: trips.length,
                    itemBuilder: (context, index) {
                      final trip = trips[index];
                      return Material(
                        color: Theme.of(context).scaffoldBackgroundColor,
                        child: InkWell(
                            onTap: () {
                              Navigator.push(
                                  context,
                                  MaterialPageRoute<void>(
                                      builder: (context) => TripPage(
                                        trip: trip,
                                        isMyTrip: true,
                                      )));
                            },
                            child: TripCardWidget(trip, false, (isSaved, id) {}, true)),
                      );
                    },
                  ),
                ),
              ],
            );
          },
        ),

        // Fixed positioned button
        Positioned(
          bottom: 20,
          right: 20,
          child: FloatingActionButton(
            onPressed: () {
              _goToNewTripPage();
            },
            backgroundColor: Theme.of(context).secondaryHeaderColor,
            child: const Icon(Icons.add),
          ),
        ),
      ],
    );
  }
}
