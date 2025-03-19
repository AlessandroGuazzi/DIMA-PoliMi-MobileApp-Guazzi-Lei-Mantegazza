import 'package:dima_project/models/activityModel.dart';
import 'package:dima_project/models/tripModel.dart';
import 'package:dima_project/services/databaseService.dart';
import 'package:dima_project/widgets/activityCardWidget.dart';
import 'package:dima_project/widgets/flightCardWidget.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:dima_project/utils/screenSize.dart';

class tripDetailPage extends StatefulWidget {
  const tripDetailPage({super.key, required this.trip});

  final TripModel trip;

  @override
  State<tripDetailPage> createState() => _tripDetailPageState();
}

class _tripDetailPageState extends State<tripDetailPage> {

  late TripModel trip; // Store trip data in state

  @override
  void initState() {
    super.initState();
    trip = widget.trip; // Initialize with passed data
    //_futureActivities = DatabaseService().getActivities()
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
                      '${trip.title}',
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
                          trip.cities?.join(' - ') ?? 'No cities available',
                          style: Theme.of(context).textTheme.bodyLarge,
                        ),
                      ],
                    ),


                  ],
                ),
              )
            ],
          ),

          Divider(
            color: Theme.of(context).secondaryHeaderColor, // Colore della linea
            thickness: 2.5, // Spessore della linea
            height: 20, // Altezza complessiva
          ),

          //TODO LISTA ATTIVITA'
          /*Expanded(
            child: FutureBuilder<List<ActivityModel>>(
              future: _futureactivity,
            ),
          ),*/

          Flightcardwidget()

        ],
      ),
    );
  }
}
