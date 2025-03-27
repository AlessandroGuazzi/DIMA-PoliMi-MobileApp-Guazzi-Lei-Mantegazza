import 'package:dima_project/models/flightModel.dart';
import 'package:dima_project/widgets/activityDividerWidget.dart';
import 'package:flutter/material.dart';
import 'package:dima_project/utils/screenSize.dart';

class Flightcardwidget extends StatefulWidget {
  const Flightcardwidget(this.flight, {super.key});

  final FlightModel flight;

  @override
  State<Flightcardwidget> createState() => _FlightcardwidgetState();
}

class _FlightcardwidgetState extends State<Flightcardwidget> {
  bool isExpanded = false;

  @override
  Widget build(BuildContext context) {
    return Stack(
      children: [
        Padding(
          padding: const EdgeInsets.only(left: 0.2, top: 10.0, right: 3.0, bottom: 11.5),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // **Prima riga con info base**
              Row(
                children: [
                  Container(
                    padding: const EdgeInsets.all(12),
                    decoration: BoxDecoration(
                      shape: BoxShape.circle,
                      color: Theme.of(context).primaryColor.withOpacity(0.1),
                    ),
                    child: Icon(
                      Icons.flight,
                      size: MediaQuery.of(context).size.width * 0.1,
                      color: Theme.of(context).secondaryHeaderColor,
                    ),
                  ),

                  const activityDivider(),

                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Row(
                          children: [
                            Text('From: ', style: Theme.of(context).textTheme.titleLarge),
                            Text(
                              widget.flight.departureAirPort ?? 'N/A',
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
                            Text('Departure Time: ${widget.flight.departureDate != null ? '${widget.flight.departureDate!.hour.toString().padLeft(2, '0')}:${widget.flight.departureDate!.minute.toString().padLeft(2, '0')}' : 'N/A'}'),
                          ],
                        ),

                        Row(
                          children: [
                            Icon(
                              Icons.access_time_filled_outlined,
                              size: 20,
                              color: Theme.of(context).primaryColor,
                            ),
                            Text('Arrival Time: ${widget.flight.arrivalDate != null ? '${widget.flight.arrivalDate!.hour.toString().padLeft(2, '0')}:${widget.flight.arrivalDate!.minute.toString().padLeft(2, '0')}' : 'N/A'}')
                          ],
                        )
                      ],
                    ),
                  ),
                ],
              ),

              // **Espansione con dettagli aggiuntivi**
              if (isExpanded) ...[
                const Divider(),
                Padding(
                  padding: const EdgeInsets.only(top: 10),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        "Dettagli Extra:",
                        style: Theme.of(context).textTheme.titleMedium,
                      ),
                      const SizedBox(height: 5),
                      Text(
                        "Nessuna informazione aggiuntiva.",
                        style: Theme.of(context).textTheme.bodyMedium,
                      ),
                    ],
                  ),
                ),
              ]
            ],
          ),
        ),

        Positioned(
          bottom: ScreenSize.screenHeight(context) * 0.00001,
          right: ScreenSize.screenWidth(context) * 0.003,
          child: IconButton(
            icon: Icon(isExpanded ? Icons.expand_less : Icons.expand_more),
            onPressed: () {
              setState(() {
                isExpanded = !isExpanded;
              });
            },
          ),
        ),
      ],
    );
  }
}