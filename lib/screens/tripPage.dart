import 'package:dima_project/models/accomodationModel.dart';
import 'package:dima_project/models/activityModel.dart';
import 'package:dima_project/models/attractionModel.dart';
import 'package:dima_project/models/transportModel.dart';
import 'package:dima_project/models/tripModel.dart';
import 'package:dima_project/screens/editActivityPage.dart';
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

  final TripModel trip;  //TODO FORSE UN OTTIMIZZAZIONE E' PASSARE SOLO L'ID DEL TRIP
  final bool isMyTrip;

  @override
  State<TripPage> createState() => _TripPageState();
}

class _TripPageState extends State<TripPage> {

  late Future<List<ActivityModel>> _futureActivities;
  //scrollController per le date
  //final ScrollController _scrollController = ScrollController();

  @override
  void initState() {
    super.initState();
    //trip = widget.trip; // Initialize with passed data
    _futureActivities = DatabaseService().getTripActivities(widget.trip);

    //print(widget.trip.id);  //TODO PRINT CHECK CAPIRE PERCHE' RITORNA SEMPRE LE STESSE ATTIVITA'
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
            IconButton(
              icon: const Icon(Icons.edit), // Icona a forma di pennino
              onPressed: () {
                print("Modifica attivata");
              },
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
                '${widget.trip.title}',
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
                  TripGeneralsPage(),
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


//alternativa al popupmenu
/*void _showActivityOption() {
    showModalBottomSheet(
      context: context,
      backgroundColor: Colors.transparent,
      builder: (BuildContext context) {
        return Align(
          alignment: Alignment.topRight, // Allinea in alto a destra
          child: Container(
            margin: const EdgeInsets.only(top: 50, right: 10), // Distanza dall'icona
            width: 200,
            decoration: BoxDecoration(
              color: Colors.white,
              borderRadius: BorderRadius.circular(12),
              boxShadow: [
                BoxShadow(
                  color: Colors.black.withOpacity(0.2),
                  blurRadius: 8,
                ),
              ],
            ),
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                ListTile(
                  leading: const Icon(Icons.edit),
                  title: const Text('Modifica'),
                  onTap: () {
                    Navigator.pop(context);
                    // Azione di modifica
                  },
                ),
                ListTile(
                  leading: const Icon(Icons.delete),
                  title: const Text('Elimina'),
                  onTap: () {
                    Navigator.pop(context);
                    // Azione di eliminazione
                  },
                ),
              ],
            ),
          ),
        );
      },
    );
  }*/




}
