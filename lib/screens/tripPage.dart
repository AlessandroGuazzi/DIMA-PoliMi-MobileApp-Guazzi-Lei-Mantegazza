
import 'package:dima_project/models/activityModel.dart';
import 'package:dima_project/models/tripModel.dart';
import 'package:dima_project/screens/itineraryPage.dart';
import 'package:dima_project/screens/tripExpensesPage.dart';
import 'package:dima_project/screens/mapPage.dart';
import 'package:dima_project/screens/tripInfoPage.dart';
import 'package:dima_project/screens/upsertTripPage.dart';
import 'package:dima_project/services/databaseService.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import '../services/googlePlacesService.dart';

class TripPage extends StatefulWidget {
  const TripPage({super.key, required this.trip, required this.isMyTrip});

  final TripModel trip;
  final bool isMyTrip;

  @override
  State<TripPage> createState() => _TripPageState();
}

class _TripPageState extends State<TripPage> with TickerProviderStateMixin {
  late TripModel _trip;
  late TabController _tabController;

  @override
  void initState() {
    super.initState();
    _trip = widget.trip;
    _tabController = TabController(length: 3, vsync: this);
  }

  @override
  void dispose() {
    _tabController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final imageUrl = widget.trip.imageRef != null
        ? GooglePlacesService().getImageUrl(widget.trip.imageRef!)
        : 'https://picsum.photos/800';

    return Scaffold(
      body: NestedScrollView(
        headerSliverBuilder: (context, innerBoxIsScrolled) => [
          SliverAppBar(
            expandedHeight: 250,
            pinned: true,
            floating: false,
            flexibleSpace: FlexibleSpaceBar(
              centerTitle: false,
              title: Text(
                _trip.title ?? 'No title',
              ),
              background: Stack(
                alignment: Alignment.center,
                fit: StackFit.expand,
                children: [
                  Image.network(
                    imageUrl,
                    fit: BoxFit.cover,
                  ),
                  Container(
                    color: Colors.black.withOpacity(0.2),
                    alignment: Alignment.center,
                    child: Text(
                      _trip.title ?? 'No title',
                      style: Theme.of(context).textTheme.displayLarge?.copyWith(color: Colors.white),
                      textAlign: TextAlign.center,
                    ),
                  ),
                ],
              ),
            ),
            bottom: PreferredSize(
              preferredSize: const Size.fromHeight(48),
              child: Container(
                color: Theme.of(context).scaffoldBackgroundColor,
                child: TabBar(
                  controller: _tabController,
                  tabs: const [
                    Tab(text: "Itinerario"),
                    Tab(text: 'Generale',),
                    Tab(text: "Spese"),
                  ],
                ),
              ),
            ),
            actions: widget.isMyTrip
                ? [
              IconButton(
                icon: const Icon(Icons.more_vert),
                onPressed: () => _showActions(context),
              ),
                  ]
                : null,
          ),
        ],
        body: TabBarView(
          controller: _tabController,
          children: [
            Itinerarypage(trip: _trip, isMyTrip: widget.isMyTrip),
            TripInfoPage(trip: _trip),
            TripExpensesPage(tripId: widget.trip.id ?? '',),
          ],
        ),
      ),
    );
  }

  void _showActions(BuildContext context) {
    showModalBottomSheet(
      context: context,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(20)),
      ),
      builder: (context) => SafeArea(
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            //handle
            Padding(
              padding: EdgeInsets.fromLTRB(200, 15, 200, 15),
              child: Container(
                height: 5,
                width: double.infinity,
                decoration: BoxDecoration(
                  color: Theme.of(context).dividerColor,
                  borderRadius:
                  BorderRadius.all(Radius.circular(100)), // Rounded edges
                ),
              ),
            ),

            ListTile(
              leading: const Icon(Icons.edit),
              title: const Text('Modifica'),
              onTap: () async {
                Navigator.pop(context); // close the bottom sheet
                final result = await Navigator.push(
                  context,
                  MaterialPageRoute(
                    builder: (context) => UpsertTripPage(
                      trip: widget.trip,
                      isUpdate: true,
                    ),
                  ),
                );
                //update ui trip
                if (result != null) {
                  setState(() {
                    _trip = result;
                  });
                }
              },
            ),
            ListTile(
              leading: const Icon(Icons.delete, color: Colors.red),
              title: const Text('Elimina'),
              onTap: () async {
                Navigator.pop(context); // close the bottom sheet
                final shouldDelete = await showDialog<bool>(
                  context: context,
                  builder: (context) => AlertDialog(
                    title: const Text('Conferma eliminazione'),
                    content: const Text('Vuoi eliminare questo viaggio?'),
                    actions: [
                      TextButton(
                        onPressed: () => Navigator.pop(context, false),
                        child: const Text('Annulla'),
                      ),
                      TextButton(
                        onPressed: () => Navigator.pop(context, true),
                        child: const Text('Elimina',
                            style: TextStyle(color: Colors.red)),
                      ),
                    ],
                  ),
                );

                if (shouldDelete == true) {
                  await DatabaseService().deleteTrip(_trip.id!);
                  if (context.mounted) Navigator.pop(context);
                }
              },
            ),
            ListTile(
              leading: const Icon(Icons.map_outlined),
              title: const Text('Apri mappa'),
              onTap: () {
                Navigator.pop(context);
                Navigator.push(
                  context,
                  MaterialPageRoute(
                    builder: (context) => MapPage(trip: _trip),
                  ),
                );
              },
            ),
          ],
        ),
      ),
    );
  }
}
