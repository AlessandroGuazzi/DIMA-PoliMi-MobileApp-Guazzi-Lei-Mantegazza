import 'package:dima_project/models/accommodationModel.dart';
import 'package:dima_project/models/activityModel.dart';
import 'package:dima_project/models/attractionModel.dart';
import 'package:dima_project/models/transportModel.dart';
import 'package:dima_project/models/tripModel.dart';
import 'package:dima_project/screens/editActivityPage.dart';
import 'package:dima_project/screens/editTripPage.dart';
import 'package:dima_project/screens/itineraryPage.dart';
import 'package:dima_project/screens/tripGeneralsPage.dart';
import 'package:dima_project/screens/mapPage.dart';
import 'package:dima_project/services/databaseService.dart';
import 'package:dima_project/widgets/accomodationCardWidget.dart';
import 'package:dima_project/widgets/attractionCardWidget.dart';
import 'package:dima_project/widgets/flightCardWidget.dart';
import 'package:dima_project/widgets/transportCardWidget.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:dima_project/utils/screenSize.dart';
import '../models/flightModel.dart';

class TripPage extends StatefulWidget {
  const TripPage({super.key, required this.trip, required this.isMyTrip});

  final TripModel trip;
  final bool isMyTrip;

  @override
  State<TripPage> createState() => _TripPageState();
}

class _TripPageState extends State<TripPage> {

  late Future<List<ActivityModel>> _futureActivities;
  late TripModel _trip;

  @override
  void initState() {
    super.initState();
    //trip = widget.trip; // Initialize with passed data
    _futureActivities = DatabaseService().getTripActivities(widget.trip);
    _trip = widget.trip;
  }

  Future<void> refreshPage() async {
    TripModel newTrip = await DatabaseService().loadTrip(widget.trip.id!);
    setState(() {
      _trip = newTrip;
    });
  }


  @override
  Widget build(BuildContext context) {
    return DefaultTabController(
      length: 3, // Numero di tab
      child: Scaffold(
        appBar: AppBar(
          title: const Text("Simply Travel"),
          backgroundColor: Theme
              .of(context)
              .primaryColor,
          actions: widget.isMyTrip
              ? [
            PopupMenuButton<int>(
              icon: const Icon(Icons.more_vert), // Cambiato da edit ✏️ a "più opzioni"
              onSelected: (value) async {
                if (value == 1) {
                  // Modifica
                  await Navigator.push(
                    context,
                    MaterialPageRoute(
                      builder: (context) => EditTripPage(trip: _trip),
                    ),
                  );
                  await refreshPage();
                } else if (value == 2) {
                  // Elimina
                  final shouldDelete = await showDialog<bool>(
                    context: context,
                    builder: (context) => AlertDialog(
                      title: const Text('Conferma eliminazione'),
                      content: const Text('Sei sicuro di voler eliminare questo viaggio? Non sarà possibile tornare indietro!'),
                      actions: [
                        TextButton(
                          onPressed: () => Navigator.pop(context, false),
                          child: const Text('Annulla'),
                        ),
                        TextButton(
                          onPressed: () => Navigator.pop(context, true),
                          child: const Text('Elimina', style: TextStyle(color: Colors.red)),
                        ),
                      ],
                    ),
                  );

                  if (shouldDelete == true) {
                    await DatabaseService().deleteTrip(_trip.id!);
                    if (context.mounted) {
                      Navigator.pop(context); // Torni indietro a MyTripsPage
                    }
                  }
                }
              },
              itemBuilder: (context) => [
                const PopupMenuItem<int>(
                  value: 1,
                  child: Row(
                    children: [
                      Icon(Icons.edit, color: Colors.black),
                      SizedBox(width: 8),
                      Text('Modifica'),
                    ],
                  ),
                ),
                const PopupMenuItem<int>(
                  value: 2,
                  child: Row(
                    children: [
                      Icon(Icons.delete, color: Colors.red),
                      SizedBox(width: 8),
                      Text('Elimina'),
                    ],
                  ),
                ),
              ],
            ),
          ]
              : null,

        ),
        body: Column(
          children: [
            Container(
              color: Theme
                  .of(context)
                  .primaryColor
                  .withOpacity(0.15),
              padding: const EdgeInsets.all(16),
              width: double.infinity, // Espandi per evitare errori di layout
              child: Text(
                '${_trip.title}',
                textAlign: TextAlign.center,
                style: Theme
                    .of(context)
                    .textTheme
                    .headlineLarge,
              ),
            ),
            const Divider(
              thickness: 2.5,
            ),
            const TabBar(
              tabs: [
                Tab(text: "Itinerario"),
                Tab(text: "Generale"), // Tab 2
                Tab(text: "Mappa"),// Tab 1
              ],
            ),
            Expanded(
              child: TabBarView(
                physics: NeverScrollableScrollPhysics(),
                children: [
                  Itinerarypage(trip: widget.trip, isMyTrip: widget.isMyTrip),
                  TripGeneralsPage(tripId: widget.trip.id!),
                  MapPage(trip: widget.trip,),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }



  String _getFlagEmoji(String countryCode) {
    assert(countryCode.length == 2); // Assicurati che il codice paese sia lungo 2 caratteri
    int firstLetter = countryCode.codeUnitAt(0) - 0x41 + 0x1F1E6;
    int secondLetter = countryCode.codeUnitAt(1) - 0x41 + 0x1F1E6;
    return String.fromCharCode(firstLetter) + String.fromCharCode(secondLetter);
  }

}
