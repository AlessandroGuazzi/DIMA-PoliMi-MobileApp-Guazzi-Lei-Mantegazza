import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:dima_project/screens/createNewTripPage.dart';
import 'package:dima_project/widgets/tripCardWidget.dart';
import 'package:dima_project/models/tripModel.dart';
import 'package:dima_project/services/databaseService.dart';
import 'package:dima_project/screens/tripDetailPage.dart';

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
              return const Center(child: Text('No trips created yet'));
            }

            // List of trips, with null-check!
            List<TripModel> trips = snapshot.data!;

            return ListView.builder(
              itemCount: trips.length,
              itemBuilder: (context, index) {
                final trip = trips[index];
                return Padding(
                  padding: const EdgeInsets.symmetric(vertical: 10, horizontal: 8),
                  child: InkWell(
                      onTap: () {
                        print('go to TripPage');
                        Navigator.push(context, MaterialPageRoute<void>(builder: (context) => tripDetailPage()));

                      },
                      child: TripCardWidget(trip)
                  ),
                );
              },
            );

          },
        ),


        // Fixed positioned button
        Positioned(
          bottom: 20,
          right: 20,
          child: FloatingActionButton(
            onPressed: () {
              // Action when the button is pressed
              Navigator.push(context, MaterialPageRoute<void>(builder: (context) => Createnewtrippage()));
              print("Create New Trip");
            },
            backgroundColor: Colors.green,
            child: const Icon(Icons.add),
          ),
        ),
      ],
    );
  }
}




