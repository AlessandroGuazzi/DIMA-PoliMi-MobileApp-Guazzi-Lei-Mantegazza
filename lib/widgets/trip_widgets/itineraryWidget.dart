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
import 'package:dima_project/widgets/activity_widgets/accommodationActivityCard.dart';
import 'package:dima_project/widgets/activity_widgets/attractionActivityCard.dart';
import 'package:dima_project/widgets/activity_widgets/flightActivityCard.dart';
import 'package:dima_project/widgets/activity_widgets/transportActivityCard.dart';
import 'package:dima_project/widgets/components/myBottomSheetHandle.dart';
import 'package:dima_project/widgets/trip_widgets/tripProgressBar.dart';
import 'package:flutter/material.dart';

class ItineraryWidget extends StatefulWidget {
  final DatabaseService databaseService;

  ItineraryWidget(
      {super.key, required this.trip, required this.isMyTrip, databaseService})
      : databaseService = databaseService ?? DatabaseService();

  final TripModel trip;
  final bool isMyTrip;

  @override
  State<ItineraryWidget> createState() => _ItineraryWidgetState();
}

class _ItineraryWidgetState extends State<ItineraryWidget> {
  late Stream<List<ActivityModel>> _activitiesStream;

  @override
  void initState() {
    super.initState();
    _activitiesStream = widget.databaseService.streamTripActivities(widget.trip);
  }

  /*
  This method run each time the widget is updated (rebuild),
  if the rebuild has new trip data,
  it triggers an update on the future to fetch the new activities.
  Overcoming the "limitations" of initState
   */
  @override
  void didUpdateWidget(covariant ItineraryWidget oldWidget) {
    super.didUpdateWidget(oldWidget);
    _activitiesStream = widget.databaseService.streamTripActivities(widget.trip);

  }

  Future<void> _goToNewItineraryPage(String type) async {
    await Navigator.push(
            context,
            MaterialPageRoute(
                builder: (context) =>
                    CreateActivityPage(type: type, trip: widget.trip, databaseService: widget.databaseService,)));
  }

  Widget _buildTripProgressBarWithButton() {
    final now = DateTime.now();
    final startDate = widget.trip.startDate;
    final endDate = widget.trip.endDate;

    final bool isTripActive = endDate != null && endDate.isAfter(now);

    return Padding(
      padding: const EdgeInsets.fromLTRB(15, 6, 12, 0),
      child: Row(
        children: [
          Expanded(
            child: startDate != null && endDate != null
                ? TripProgressBar(
              startDate: startDate,
              endDate: endDate,
            )
                : const Text('Nessuna data specificata'),
          ),
          const SizedBox(width: 15),
          isTripActive
              ? FloatingActionButton(
            key: const Key('newActivityButton'),
            heroTag: 'newActivityButton',
            mini: true,
            onPressed: _showNewActivityOption,
            tooltip: "Aggiungi attività",
            child: const Icon(Icons.add),
          )
              : const Icon(
            Icons.check_circle_outline,
            size: 35,
            color: Colors.green,
          ),
        ],
      ),
    );
  }


  @override
  Widget build(BuildContext context) {
    return Stack(children: [
      StreamBuilder<List<ActivityModel>>(
          stream: _activitiesStream,
          builder: (context, snapshot) {
            if (snapshot.connectionState == ConnectionState.waiting) {
              return const Center(child: CircularProgressIndicator());
            } else if (snapshot.hasError) {
              return Center(child: Text('Error: ${snapshot.error}'));
            } else if (!snapshot.hasData || snapshot.data!.isEmpty) {
              return Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  if (widget.isMyTrip) _buildTripProgressBarWithButton(),
                  Divider(
                    color: Theme.of(context).dividerColor,
                    thickness: 2.5,
                  ),
                  Expanded(
                    child: Center(
                      child: Text(
                        widget.isMyTrip
                        ? 'Inserisci la prima attività'
                        : 'Nessuna attività',
                      ),
                    ),
                  ),
                ],
              );
            }

            List<ActivityModel> activities = snapshot.data!;

            //ordinare le attività in base al timestamp
            activitiesSort(activities);

            Map<String, List<ActivityModel>> groupedActivities = {};

            for (var activity in activities) {
              DateTime date = getActivityDate(activity);
              // Formattazione della data per il raggruppamento
              String dateKey =
                  "${getItalianWeekday(date.weekday)} ${date.day}/${date.month}";

              if (!groupedActivities.containsKey(dateKey)) {
                groupedActivities[dateKey] = [];
              }
              groupedActivities[dateKey]!.add(activity);
            }

            return Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                if (widget.isMyTrip) _buildTripProgressBarWithButton(),

                Divider(
                  color: Theme.of(context).dividerColor,
                  thickness: 2.5,
                ),

                Expanded(
                  child: ListView.builder(
                    padding: EdgeInsets.zero,
                    itemCount: groupedActivities.length,
                    itemBuilder: (context, index) {
                      String dateKey = groupedActivities.keys.elementAt(index);
                      List<ActivityModel> dayActivities =
                          groupedActivities[dateKey]!;

                      return Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        mainAxisAlignment: MainAxisAlignment.start,
                        children: [
                          // **Intestazione con la data**
                          Padding(
                            padding: const EdgeInsets.symmetric(
                                vertical: 8.0, horizontal: 16.0),
                            child: Text(
                              dateKey, // Data formattata (Es: "24/03/2025")
                              style: Theme.of(context).textTheme.titleLarge,
                            ),
                          ),

                          ...dayActivities.map((activity) {
                            return Padding(
                              padding: const EdgeInsets.symmetric(
                                  vertical: 8.5, horizontal: 4.0),
                              child: Stack(
                                children: [
                                  _buildActivityCard(activity),

                                  // EDIT and DELETE buttons
                                  if (widget.isMyTrip)
                                    Positioned(
                                      top: ScreenSize.screenHeight(context) *
                                          0.001,
                                      right: ScreenSize.screenWidth(context) *
                                          0.003,
                                      child: PopupMenuButton<int>(
                                        key: const Key('activityMenu'),
                                        icon: Icon(Icons.more_horiz, color: Theme.of(context).primaryColor),
                                        onSelected: (value) async {
                                          if (value == 1) {
                                            // Azione Modifica
                                            await Navigator.push(
                                              context,
                                              MaterialPageRoute(
                                                builder: (context) =>
                                                    EditActivityPage(
                                                  trip: widget.trip,
                                                  activity: activity,
                                                ),
                                              ),
                                            );
                                            //refreshTrips();
                                          } else if (value == 2) {
                                            // Azione Elimina
                                            _showDeleteConfirmationDialog(
                                                context, activity);
                                          }
                                        },
                                        itemBuilder: (context) => [
                                          const PopupMenuItem<int>(
                                            value: 1,
                                            child: Row(
                                              children: [
                                                Icon(Icons.edit,
                                                    color: Colors.black),
                                                SizedBox(width: 8),
                                                Text("Modifica"),
                                              ],
                                            ),
                                          ),
                                          const PopupMenuItem<int>(
                                            value: 2,
                                            child: Row(
                                              children: [
                                                Icon(Icons.delete,
                                                    color: Colors.red),
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
                          }),
                        ],
                      );
                    },
                  ),
                ),
              ],
            );
          }),

    ]);
  }

  Widget _buildActivityCard(ActivityModel activity) {
    switch (activity.type) {
      case 'flight':
        return FlightActivityCard(activity as FlightModel);
      case 'accommodation':
        return AccommodationActivityCard(activity as AccommodationModel);
      case 'transport':
        return TransportActivityCard(activity as TransportModel);
      case 'attraction':
        return AttractionActivityCard(activity as AttractionModel);
      default:
        print('no attività');
        return const Placeholder();
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
    if (activity is FlightModel) {
      return activity.departureDate ??
          DateTime(1970, 1,
              1); //TODO MI RICHIEDE IL NULL CHECK, MA NELL'APP RENDEREMO LA DATA OBBLIGGATORIA
    } else if (activity is TransportModel) {
      return activity.departureDate ?? DateTime(1970, 1, 1);
    } else if (activity is AccommodationModel) {
      return activity.checkIn ?? DateTime(1970, 1, 1);
    } else if (activity is AttractionModel) {
      return activity.startDate ?? DateTime(1970, 1, 1);
    }
    throw Exception("Tipo di attività non supportato ${activity.type}");
  }

  //DELETE MESSAGE
  void _showDeleteConfirmationDialog(
      BuildContext context, ActivityModel activity) {
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
                widget.databaseService.deleteActivity(activity);
                Navigator.of(context).pop(); // Chiude il popup
                //refreshTrips();
              },
              child:
                  const Text("Conferma", style: TextStyle(color: Colors.red)),
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
    showModalBottomSheet(
      context: context,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(20)),
      ),
      builder: (context) => SafeArea(
        child: SingleChildScrollView(
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              const MyBottomSheetHandle(),
              Padding(
                padding: const EdgeInsets.all(12),
                child: Text(
                  'Crea una nuova attività',
                  style: Theme.of(context).textTheme.titleMedium,
                ),
              ),
              _buildOption(Icons.flight, 'Volo', 'flight'),
              _buildOption(Icons.hotel, 'Alloggio', 'accommodation'),
              _buildOption(
                  Icons.directions_bus, 'Altri Trasporti', 'transport'),
              _buildOption(Icons.attractions, 'Attrazione', 'attraction'),
              const SizedBox(height: 15),
            ],
          ),
        ),
      ),
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
            }));
  }
}
