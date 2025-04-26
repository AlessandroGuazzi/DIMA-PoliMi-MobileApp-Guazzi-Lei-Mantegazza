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
  bool isExpanded = false;


  @override
  Widget build(BuildContext context) {
    return Stack(
      children: [
        Padding(
          padding: const EdgeInsets.only(left: 0.2, top: 10.0, right: 21, bottom: 11.0),
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
                      iconSelector(widget.transport.transportType ?? 'default'), // Icona dinamica
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
                            Expanded(
                              child: Text(
                                widget.transport.departurePlace ?? 'N/A',
                                style: Theme.of(context).textTheme.headlineSmall,
                                overflow: TextOverflow.ellipsis,
                                maxLines: 1,
                              ),
                            ),
                          ],
                        ),
                        Row(
                          children: [
                            Icon(Icons.access_time_filled_outlined, size: 20, color: Theme.of(context).primaryColor),
                            const SizedBox(width: 3),
                            Text(
                              'Departure Time: ${widget.transport.departureDate != null ? '${widget.transport.departureDate!.hour.toString().padLeft(2, '0')}:${widget.transport.departureDate!.minute.toString().padLeft(2, '0')}' : 'N/A'}',
                            ),
                          ],
                        ),
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
                      if (widget.transport.duration != null)
                        Row(
                          children: [
                            Icon(Icons.timelapse, size: 20, color: Theme.of(context).primaryColor),
                            const SizedBox(width: 5),
                            Text('Duration: ${widget.transport.duration}'),
                          ],
                        ),
                      Row(
                        children: [
                          Icon(Icons.location_on, size: 20, color: Theme.of(context).primaryColor),
                          const SizedBox(width: 5),
                          Text('Destination: ${widget.transport.arrivalPlace ?? "N/A"}'),
                        ],
                      ),

                    ],
                  ),
                ),
              ]
            ],
          ),
        ),

        Positioned(
          bottom: ScreenSize.screenHeight(context) * 0.0001,
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
    ]
    );
  }


  IconData iconSelector(String transportType) {
    switch (transportType.toLowerCase()) {
      case 'bus':
        return Icons.directions_bus;
      case 'train':
        return Icons.train;
      case 'car':
        return Icons.directions_car;
      case 'ferry':
        return Icons.directions_boat;
      default:
        return Icons.directions_transit; // fallback icon
    }
  }


}
