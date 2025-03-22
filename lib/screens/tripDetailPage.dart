import 'package:dima_project/models/accomodationModel.dart';
import 'package:dima_project/models/activityModel.dart';
import 'package:dima_project/models/attractionModel.dart';
import 'package:dima_project/models/transportModel.dart';
import 'package:dima_project/models/tripModel.dart';
import 'package:dima_project/screens/editActivityPage.dart';
import 'package:dima_project/services/databaseService.dart';
import 'package:dima_project/widgets/accomodationCardWidget.dart';
import 'package:dima_project/widgets/attractionCardWidget.dart';
import 'package:dima_project/widgets/flightCardWidget.dart';
import 'package:dima_project/widgets/transportCardWidget.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:dima_project/utils/screenSize.dart';

import '../models/flightModel.dart';

class tripDetailPage extends StatefulWidget {
  const tripDetailPage({super.key, required this.trip, required this.isMyTrip});

  final TripModel trip;  //TODO FORSE UN OTTIMIZZAZIONE E' PASSARE SOLO L'ID DEL TRIP
  final bool isMyTrip;

  @override
  State<tripDetailPage> createState() => _tripDetailPageState();
}

class _tripDetailPageState extends State<tripDetailPage> {

  //late TripModel trip; // Store trip data in state
  late Future<List<ActivityModel>> _futureActivities;

  @override
  void initState() {
    super.initState();
    //trip = widget.trip; // Initialize with passed data
    _futureActivities = DatabaseService().getTripActivities(widget.trip);

    print(widget.trip.id);  //TODO PRINT CHECK CAPIRE PERCHE' RITORNA SEMPRE LE STESSE ATTIVITA'
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text("Simply Travel"),
        backgroundColor: Theme.of(context).primaryColor,
        actions: [
          IconButton(
            icon: Icon(Icons.edit), // Icona a forma di pennino
            onPressed: () {
              // Azione quando l'icona viene premuta
              print("Modifica attivata");
            },
          ),
        ],
      ),
      body: Column(
        children: [
          Container(
            color: Theme.of(context).primaryColor.withOpacity(0.15),
            child: Row(
              children: [
                Expanded(
                    child: SizedBox(
                      width: double.infinity,
                      height: 95,
                      child: ClipRRect(
                        borderRadius: BorderRadius.circular(12),
                        child: ShaderMask(
                          shaderCallback: (Rect bounds) {
                            return const LinearGradient(
                              begin: Alignment.center,
                              end: Alignment.bottomCenter,
                              colors: [Colors.white, Colors.transparent],
                            ).createShader(bounds);
                          },
                          blendMode: BlendMode.dstIn,
                          child: Padding(
                            padding: const EdgeInsets.all(8.0), // Mantiene il padding
                            child: ClipRRect(
                              borderRadius: BorderRadius.circular(12), // Arrotonda i bordi
                              child: Image.network(
                                'https://picsum.photos/200',
                                width: double.infinity, //TODO CAMBIARE
                                height: 95,
                                fit: BoxFit.cover,
                              ),
                            ),
                          ),
                        ),
                      )
                    ),
                ),

                //TODO ADD EXPANDED
                Padding(
                  padding: const EdgeInsetsDirectional.fromSTEB(16, 5, 16, 16),
                  child: Column(
                    children: [
                      Text(
                        '${widget.trip.title}',
                        style: Theme.of(context).textTheme.headlineLarge,
                      ),

                      Row(
                        children: [
                          Icon(
                            Icons.place,
                            size: 20,
                            color: Theme.of(context).primaryColor,
                          ),
                          Text(
                            widget.trip.cities?.join(' - ') ?? 'No cities available',
                            style: Theme.of(context).textTheme.bodyLarge,
                          ),
                        ],
                      ),

                    ],
                  ),
                )
              ],
            ),
          ),

          Divider(
            color: Theme.of(context).dividerColor, // Colore della linea
            thickness: 2.5, // Spessore della linea
            height: ScreenSize.screenHeight(context) * 0.05, // Altezza complessiva
          ),


          // activities list
          Expanded(
            child: Stack(
              children: [




                FutureBuilder(
                  future: _futureActivities,
                  builder: (context, snapshot){
                    if (snapshot.connectionState == ConnectionState.waiting) {
                      return const Center(child: CircularProgressIndicator());
                    } else if (snapshot.hasError) {
                      return Center(child: Text('Error: ${snapshot.error}'));
                    } else if (!snapshot.hasData || snapshot.data!.isEmpty) {
                      return const Center(child: Text('No activities created'));
                    }

                    List<ActivityModel> activities = snapshot.data!;
                    print('List of Activities');

                    //ordinare le attività in base al timestamp
                    activitiesSort(activities);

                    Map<String, List<ActivityModel>> groupedActivities = {};

                    for (var activity in activities) {
                      DateTime date = getActivityDate(activity);
                      String dateKey = "${date.day}/${date.month}"; // Formattazione per il raggruppamento

                      if (!groupedActivities.containsKey(dateKey)) {
                        groupedActivities[dateKey] = [];
                      }
                      groupedActivities[dateKey]!.add(activity);
                    }

                    return ListView.builder(
                      itemCount: groupedActivities.length,
                      itemBuilder: (context, index) {
                        String dateKey = groupedActivities.keys.elementAt(index);
                        List<ActivityModel> dayActivities = groupedActivities[dateKey]!;

                        return Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            // **Intestazione con la data**
                            Padding(
                              padding: const EdgeInsets.symmetric(vertical: 8.0, horizontal: 16.0),
                              child: Text(
                                dateKey,  // Data formattata (Es: "24/03/2025")
                                style: Theme.of(context).textTheme.titleLarge,
                              ),
                            ),

                            ...dayActivities.map((activity) {
                              return Padding(
                                padding: const EdgeInsets.symmetric(vertical: 8.0, horizontal: 4.0),
                                child: Stack(
                                  children: [
                                    Container(
                                      color: Theme.of(context).cardColor,
                                      child: _buildActivityCard(activity),
                                    ),
                                    if (widget.isMyTrip)
                                      Positioned(
                                        top: ScreenSize.screenHeight(context) * 0.001,
                                        right: ScreenSize.screenWidth(context) * 0.003,
                                        child: PopupMenuButton<int>(
                                          icon: const Icon(Icons.more_horiz),
                                          onSelected: (value) {
                                            if (value == 1) {
                                              // Azione Modifica
                                              Navigator.push(
                                                context,
                                                MaterialPageRoute<void>(
                                                  builder: (context) => EditActivityPage(activity: activity),
                                                ),
                                              );
                                            } else if (value == 2) {
                                              // Azione Elimina
                                              _showDeleteConfirmationDialog(context);
                                            }
                                          },
                                          itemBuilder: (context) => [
                                            const PopupMenuItem<int>(
                                              value: 1,
                                              child: Row(
                                                children: [
                                                  Icon(Icons.edit, color: Colors.black),
                                                  SizedBox(width: 8),
                                                  Text("Modifica"),
                                                ],
                                              ),
                                            ),
                                            const PopupMenuItem<int>(
                                              value: 2,
                                              child: Row(
                                                children: [
                                                  Icon(Icons.delete, color: Colors.red),
                                                  SizedBox(width: 8),
                                                  Text("Elimina"),
                                                ],
                                              ),
                                            ),
                                          ],
                                        ),
                                      ),
                                  ],
                                ),
                              );
                            }).toList(),
                          ],
                        );
                      },
                    );

                  }
                ),
              ]
            ),
          )

        ],
      ),
    );
  }


  Widget _buildActivityCard(ActivityModel activity) {
    switch (activity.type) {
      case 'flight':
        return Flightcardwidget(activity as FlightModel);
      case 'accommodation':
        return AccommodationCardWidget(activity as AccommodationModel);
      case 'transport':
        return Transportcardwidget(activity as TransportModel);
      case 'attraction':
        return Attractioncardwidget(activity as AttractionModel);
      default:
        print('no attività');
        return Placeholder(); // Widget di default se il tipo non è riconosciuto
    }
  }


  void activitiesSort(List<ActivityModel> activities) {
    activities.sort((a, b) {
      DateTime dateA = getActivityDate(a);
      DateTime dateB = getActivityDate(b);
      return dateA.compareTo(dateB);
    });
  }


  DateTime getActivityDate(ActivityModel activity) {
    if (activity is FlightModel ) {
      return activity.departureDate ?? DateTime(1970, 1, 1);   //TODO MI RICHIEDE IL NULL CHECK, MA NELL'APP RENDEREMO LA DATA OBBLIGGATORIA
    } else if (activity is TransportModel){
      return activity.departureDate ?? DateTime(1970, 1, 1);
    } else if (activity is AccommodationModel) {
      return activity.checkIn ?? DateTime(1970, 1, 1);
    } else if (activity is AttractionModel) {
      return activity.startDate ?? DateTime(1970, 1, 1);
    }
    throw Exception("Tipo di attività non supportato");
  }


  void _showDeleteConfirmationDialog(BuildContext context) {
    showDialog(
      context: context,
      builder: (BuildContext context) {
        return AlertDialog(
          title: const Text("Conferma eliminazione"),
          content: const Text("Sei sicuro di voler eliminare questa attività?"),
          actions: [
            TextButton(
              onPressed: () {
                Navigator.of(context).pop(); // Chiude il popup senza eliminare
              },
              child: const Text("Annulla"),
            ),
            TextButton(
              onPressed: () {
                //TODO Funzione per eliminare l'attività
                Navigator.of(context).pop(); // Chiude il popup
              },
              child: const Text("Conferma", style: TextStyle(color: Colors.red)),
            ),
          ],
        );
      },
    );
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
