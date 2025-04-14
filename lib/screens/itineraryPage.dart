import 'package:dima_project/models/accommodationModel.dart';
import 'package:dima_project/models/activityModel.dart';
import 'package:dima_project/models/attractionModel.dart';
import 'package:dima_project/models/flightModel.dart';
import 'package:dima_project/models/transportModel.dart';
import 'package:dima_project/models/tripModel.dart';
import 'package:dima_project/screens/createActivityPage.dart';
import 'package:dima_project/screens/editActivityPage.dart';
import 'package:dima_project/services/databaseService.dart';
import 'package:dima_project/utils/screenSize.dart';
import 'package:dima_project/widgets/accomodationCardWidget.dart';
import 'package:dima_project/widgets/attractionCardWidget.dart';
import 'package:dima_project/widgets/flightCardWidget.dart';
import 'package:dima_project/widgets/transportCardWidget.dart';
import 'package:flutter/material.dart';


class Itinerarypage extends StatefulWidget {
  const Itinerarypage({super.key, required this.trip, required this.isMyTrip});

  final TripModel trip;
  final bool isMyTrip;

  @override
  State<Itinerarypage> createState() => _ItinerarypageState();
}

class _ItinerarypageState extends State<Itinerarypage> {
  late Future<List<ActivityModel>> _futureActivities;
  //scrollController per le date
  //final ScrollController _scrollController = ScrollController();

  @override
  void initState() {
    super.initState();
    //trip = widget.trip; // Initialize with passed data
    _futureActivities = DatabaseService().getTripActivities(widget.trip);
  }

  void refreshTrips() {
    setState(() {
      _futureActivities = DatabaseService().getTripActivities(widget.trip);
    });
  }

  void _goToNewItineraryPage(String type)  {
    Navigator.push(context,
        MaterialPageRoute(builder: (context) => CreateActivityPage(type: type, trip: widget.trip))).then((value) => refreshTrips());

  }


  @override
  Widget build(BuildContext context) {
    return Stack(
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
                  // Formattazione della data per il raggruppamento
                  String dateKey = "${getItalianWeekday(date.weekday)} ${date.day}/${date.month}";

                  if (!groupedActivities.containsKey(dateKey)) {
                    groupedActivities[dateKey] = [];
                  }
                  groupedActivities[dateKey]!.add(activity);
                }

                return Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [

                    //TODO BARRA SOPRA ALL'ITINERIARIO, AGGIUNGI QUA IL BOTTONE
                    /*if (widget.isMyTrip)
                      Padding(
                        padding: const EdgeInsets.fromLTRB(16, 16, 16, 8),
                        child: Row(
                          children: [
                            Expanded(
                              child: TripProgressBar(
                                startDate: widget.trip.startDate!,
                                endDate: widget.trip.endDate!,
                              ),
                            ),
                            const SizedBox(width: 12),
                            IconButton(
                              onPressed: _showNewActivityOption,
                              icon: const Icon(Icons.add),
                              tooltip: "Aggiungi attività",
                            )
                          ],
                        ),
                      ),*/

                    Divider(
                      color: Theme.of(context).dividerColor, // Colore della linea
                      thickness: 2.5, // Spessore della linea
                      //height: ScreenSize.screenHeight(context) * 0.05, // Altezza complessiva
                    ),

                    // Lista principale scrollabile verticale
                    Expanded(
                      child: ListView.builder(
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
                                  dateKey, // Data formattata (Es: "24/03/2025")
                                  style: Theme.of(context).textTheme.titleLarge,
                                ),
                              ),

                              ...dayActivities.map((activity) {
                                return Padding(
                                  padding: const EdgeInsets.symmetric(vertical: 8.5, horizontal: 4.0),
                                  child: Stack(
                                    children: [
                                      Container(
                                        decoration: BoxDecoration(
                                          color: Theme.of(context).cardColor,
                                          borderRadius: BorderRadius.circular(16), // Rounded edges
                                          boxShadow: const [
                                            BoxShadow(
                                              color: Colors.black12, // Light shadow color
                                              blurRadius: 8, // Softness of the shadow
                                              offset: Offset(0, 4), // Position of the shadow
                                            ),
                                          ],
                                        ),
                                        child: _buildActivityCard(activity),
                                      ),


                                      // EDIT and DELETE buttons
                                      if (widget.isMyTrip)
                                        Positioned(
                                          top: ScreenSize.screenHeight(context) * 0.001,
                                          right: ScreenSize.screenWidth(context) * 0.003,
                                          child: PopupMenuButton<int>(
                                            icon: const Icon(Icons.more_horiz),
                                            onSelected: (value) async{
                                              if (value == 1) {
                                                // Azione Modifica
                                                await Navigator.push(
                                                  context,
                                                  MaterialPageRoute(
                                                    builder: (context) => EditActivityPage(
                                                      trip: widget.trip,
                                                      activity: activity,
                                                    ),
                                                  ),
                                                );
                                                refreshTrips();
                                              }
                                              else if (value == 2) {
                                                // Azione Elimina
                                                _showDeleteConfirmationDialog(context, activity);
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
                      ),
                    ),
                  ],
                );


              }
          ),

          //TODO METTERE IL BOTTONE ALTROVE, DA CAPIRE
          if(widget.isMyTrip)
            Positioned(
                bottom: 25,
                right: 25,
                child: FloatingActionButton(
                  onPressed: _showNewActivityOption,
                  child: const Icon(Icons.add),
                )
            )
        ]
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
    throw Exception("Tipo di attività non supportato ${activity.type}");
  }

  //DELETE MESSAGE
  void _showDeleteConfirmationDialog(BuildContext context, ActivityModel activity) {
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
                DatabaseService().deleteActivity(activity);
                Navigator.of(context).pop();// Chiude il popup
                refreshTrips();
              },
              child: const Text("Conferma", style: TextStyle(color: Colors.red)),
            ),
          ],
        );
      },
    );
  }

  String getItalianWeekday(int weekday) {
    const giorni = {
      1: "Lun",
      2: "Mar",
      3: "Mer",
      4: "Gio",
      5: "Ven",
      6: "Sab",
      7: "Dom",
    };
    return giorni[weekday] ?? "N/A";
  }


  void _showNewActivityOption() {
    showGeneralDialog(
      context: context,
      barrierDismissible: true,
      barrierLabel: "Nuova attività",
      transitionDuration: const Duration(milliseconds: 250),
      pageBuilder: (context, anim1, anim2) {
        return const SizedBox.shrink(); // Necessario per evitare problemi di rendering
      },
      transitionBuilder: (context, anim1, anim2, child) {
        return Transform.translate(
          offset: Offset(0, (1 - anim1.value) * 300), // Effetto slide dal basso
          child: Opacity(
            opacity: anim1.value,
            child: Align(
              alignment: Alignment.bottomRight, // Posiziona in basso
              child: Material(
                color: Colors.transparent,
                child: Container(
                  width: ScreenSize.screenWidth(context)*0.6,
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
                      Padding(
                        padding: const EdgeInsets.all(12),
                        child: Text(
                          'Crea una nuova attività',
                          style: Theme.of(context).textTheme.titleMedium,
                        ),
                      ),
                      _buildOption(Icons.flight, 'Volo', 'flight'),
                      _buildOption(Icons.hotel, 'Alloggio', 'accommodation'),
                      _buildOption(Icons.directions_bus, 'Altri Trasporti', 'transport'),
                      _buildOption(Icons.attractions, 'Attrazione', 'attraction'),
                      const SizedBox(height: 15),
                    ],
                  ),
                ),
              ),
            ),
          ),
        );
      },
    );
  }


  Widget _buildOption(IconData icon, String text, String type) {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 10),
      child: ListTile(
        title: Row(
          children: [
            Icon(icon),
            const SizedBox(width: 12),
            Text(text, style: Theme.of(context).textTheme.titleMedium),
          ],
        ),
          onTap: () {
            Navigator.of(context).pop(); // Close the modal
            _goToNewItineraryPage(type); // Navigate
          }
      )
    );
  }



}
