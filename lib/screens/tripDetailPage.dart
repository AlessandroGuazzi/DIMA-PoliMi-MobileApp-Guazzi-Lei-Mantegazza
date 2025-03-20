import 'package:dima_project/models/accomodationModel.dart';
import 'package:dima_project/models/activityModel.dart';
import 'package:dima_project/models/attractionModel.dart';
import 'package:dima_project/models/transportModel.dart';
import 'package:dima_project/models/tripModel.dart';
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
  const tripDetailPage({super.key, required this.trip});

  final TripModel trip;  //TODO FORSE UN OTTIMIZZAZIONE E' PASSARE SOLO L'ID DEL TRIP

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
          title: Text("Dima Project"),
          backgroundColor: Theme.of(context).primaryColor,
      ),
      body: Column(
        children: [
          Row(
            children: [
              Expanded(
                  child: SizedBox(
                    width: double.infinity,
                    height: 100,
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
                              width: double.infinity,
                              height: 100,
                              fit: BoxFit.cover,
                            ),
                          ),
                        ),
                      ),
                    )
                  ),
              ),
              
              Padding(
                padding: const EdgeInsetsDirectional.fromSTEB(16, 5, 16, 16),
                child: Column(
                  children: [
                    Text(
                      '${widget.trip.title}',
                      style: Theme.of(context).textTheme.displayMedium,
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

          Padding(
            padding: const EdgeInsets.only(top: 3.0, left: 8.0, right: 8.0, bottom: 5.0),
            child: Divider(
              color: Theme.of(context).primaryColor, // Colore della linea
              thickness: 2.5, // Spessore della linea
              height: ScreenSize.screenHeight(context) * 0.05, // Altezza complessiva
            ),
          ),


          // activities list
          Expanded(
            child: Stack(
              children: [

                // Linea verticale di sfondo
                Positioned.fill(
                  child: Align(
                    alignment: Alignment.centerLeft,
                    child: Container(
                      width: ScreenSize.screenWidth(context) * 0.18, // Spessore della linea
                      color: Theme.of(context).primaryColor.withOpacity(0.1), // Colore della linea
                    ),
                  ),
                ),



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

                    return ListView.builder(
                      itemCount: activities.length,
                      itemBuilder: (context, index) {
                        final activity = activities[index];
                        return Padding(
                          padding: const EdgeInsets.symmetric(
                              vertical: 8.0,
                              horizontal: 4.0),
                          child: _buildActivityCard(activity),
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
        return Accomodationcardwidget(activity as AccommodationModel);
      case 'transport':
        return Transportcardwidget(activity as TransportModel);
      case 'attraction':
        return Attractioncardwidget(activity as AttractionModel);
      default:
        print('no attività');
        return Placeholder(); // Widget di default se il tipo non è riconosciuto
    }
  }
}
