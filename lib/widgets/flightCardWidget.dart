import 'package:dima_project/models/flightModel.dart';
import 'package:dima_project/widgets/activityDecorationsWidget.dart';
import 'package:flutter/material.dart';
import 'package:dima_project/utils/screenSize.dart';

class Flightcardwidget extends StatelessWidget {
  const Flightcardwidget(this.flight, {super.key});

  final FlightModel flight;




  @override
  Widget build(BuildContext context) {
    
    return Row(
      children: [
        Container(
          padding: const EdgeInsets.all(12), // Adjust padding to control size
          decoration: BoxDecoration(
            shape: BoxShape.circle,
            color: Theme.of(context).primaryColor.withOpacity(0.1), // Background color
          ),
          child: Icon(
            Icons.airplane_ticket,
            size: ScreenSize.screenWidth(context) * 0.1,
            color: Theme.of(context).secondaryHeaderColor,
          ),
        ),

        const activityDivider(),

        Padding(
          padding: const EdgeInsetsDirectional.fromSTEB(10, 5, 10, 10),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                'From: ${flight.departureAirPort ?? 'N/A'}',
                style: Theme.of(context).textTheme.headlineLarge,
              ),

              Row(
                children: [
                  const Text('Departure Time'),
                  Icon(
                    Icons.access_time_filled_outlined,
                    size: 20,
                    color: Theme.of(context).primaryColor,
                  ),

                  Text(flight.departureDate != null ? '${flight.departureDate!.day}' : 'N/A')


                ],
              )

            ],
          ),
        )
      ],
    );
  }

}
