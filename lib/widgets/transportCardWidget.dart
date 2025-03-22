import 'package:dima_project/models/transportModel.dart';
import 'package:dima_project/widgets/activityDividerWidget.dart';
import 'package:flutter/material.dart';
import 'package:dima_project/utils/screenSize.dart';

class Transportcardwidget extends StatefulWidget {
  const Transportcardwidget(this.transport, {super.key});

  final TransportModel transport;

  @override
  State<Transportcardwidget> createState() => _TransportcardwidgetState();
}

class _TransportcardwidgetState extends State<Transportcardwidget> {
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
            Icons.directions_bus,   //TODO VOGLIAMO DISTINGUERE TRA BUS, TAXI, TRAGHETTO etc?
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
              Row(
                children: [
                  Text('From: ', style: Theme.of(context).textTheme.titleLarge),
                  Text(
                    '${widget.transport.departurePlace ?? 'N/A'}',
                    style: Theme.of(context).textTheme.headlineSmall,
                  ),
                ],
              ),

              Row(
                children: [
                  Icon(
                    Icons.access_time_filled_outlined,
                    size: 20,
                    color: Theme.of(context).primaryColor,
                  ),

                Text('Departure Time: ${widget.transport.departureDate != null ? '${widget.transport.departureDate!.hour.toString().padLeft(2, '0')}:${widget.transport.departureDate!.minute.toString().padLeft(2, '0')}' : 'N/A'}'),
                ],
              )

              /* //TODO PER ORA IL TRASPORTO NON HA UJN ARRIVAL DATE MA SOLO DURATA
              Row(
                children: [
                  Icon(
                    Icons.access_time_filled_outlined,
                    size: 20,
                    color: Theme.of(context).primaryColor,
                  ),

                  Text('Arrival Time: ${transport.arrivalDate != null ? '${transport.arrivalDate!.hour.toString().padLeft(2, '0')}:${flight.arrivalDate!.minute.toString().padLeft(2, '0')}' : 'N/A'}')
                ],
              )*/

            ],
          ),
        )
      ],
    );
  }
}
