import 'package:dima_project/models/tripModel.dart';
import 'package:dima_project/services/databaseService.dart';
import 'package:dima_project/widgets/tripCardWidget.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';

class explorerPage extends StatefulWidget {
  const explorerPage({super.key});

  @override
  State<explorerPage> createState() => _explorerPageState();
}

class _explorerPageState extends State<explorerPage> {
  Future<List<TripModel>> _futureTrips = DatabaseService().getExplorerTrips();

  @override
  Widget build(BuildContext context) {

    return Scaffold(
      body: FutureBuilder(
        future: _futureTrips,
        builder: (context, snapshot) {
          if (snapshot.connectionState == ConnectionState.waiting) {
            return Center(child: CircularProgressIndicator());
          } else if (snapshot.hasError) {
            return Center(child: Text('Error: ${snapshot.error}'));
          } else if (!snapshot.hasData || snapshot.data!.isEmpty) {
            return const Center(
                child: Text('No public trips'));
          } else {
            List<TripModel> trips = snapshot.data!;
            return ListView.builder(
              itemCount: trips.length,
              itemBuilder: (context, index) {
                final trip = trips[index];
                return GestureDetector(
                  onTap: () {
                    //TODO
                  },
                  child: TripCardWidget(trip),
                );
              },
            );
          }
        }
      ),
    );
  }
}
