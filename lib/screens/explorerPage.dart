import 'package:dima_project/models/tripModel.dart';
import 'package:dima_project/services/databaseService.dart';
import 'package:dima_project/widgets/tripCardWidget.dart';
import 'package:flutter/material.dart';

//TODO: sorting

class ExplorerPage extends StatefulWidget {
  const ExplorerPage({super.key});

  @override
  State<ExplorerPage> createState() => _ExplorerPageState();
}

class _ExplorerPageState extends State<ExplorerPage> {
  late Future<List<TripModel>> _futureTrips;
  String _searchQuery = "";

  @override
  void initState() {
    super.initState();
    _futureTrips = DatabaseService().getExplorerTrips();
  }

  List<TripModel> _filterTrips(List<TripModel> trips) {
    return trips
        .where((trip) => trip.title!
        .toLowerCase()
        .contains(_searchQuery.toLowerCase()))
        .toList();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Theme.of(context).scaffoldBackgroundColor,
      body: Column(
        children: [
          Padding(
            padding: const EdgeInsets.all(10.0),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.center,
              crossAxisAlignment: CrossAxisAlignment.center,
              children: [
                Expanded(
                  child: SearchBar(
                    hintText: "Search destinations...",
                    onChanged: (query) {
                      setState(() {
                        _searchQuery = query;
                      });
                    },
                    leading: Icon(Icons.search, color: Theme.of(context).primaryColor,),
                    backgroundColor: Theme.of(context).searchBarTheme.backgroundColor,
                  ),
                ),
                IconButton(
                    onPressed: null,
                    icon: Icon(Icons.sort, color: Theme.of(context).primaryColor,),

                )
              ],
            ),
          ),

          Expanded(
            child: FutureBuilder<List<TripModel>>(
              future: _futureTrips,
              builder: (context, snapshot) {
                if (snapshot.connectionState == ConnectionState.waiting) {
                  return const Center(child: CircularProgressIndicator());
                } else if (snapshot.hasError) {
                  return Center(child: Text('Error: ${snapshot.error}'));
                } else if (!snapshot.hasData || snapshot.data!.isEmpty) {
                  return const Center(child: Text('No public trips'));
                }

                List<TripModel> trips = snapshot.data!;
                List<TripModel> filteredTrips = _filterTrips(trips);

                return filteredTrips.isEmpty
                    ? const Center(child: Text('No trips match your search'))
                    : ListView.builder(
                  itemCount: filteredTrips.length,
                  itemBuilder: (context, index) {
                    final trip = filteredTrips[index];
                    return Padding(
                      padding: const EdgeInsets.fromLTRB(0, 0, 0, 10),
                      child: GestureDetector(
                        onTap: () {
                          // TODO: Handle click
                        },
                        child: TripCardWidget(trip),
                      ),
                    );
                  },
                );
              },
            ),
          ),
        ],
      ),
    );
  }
}
