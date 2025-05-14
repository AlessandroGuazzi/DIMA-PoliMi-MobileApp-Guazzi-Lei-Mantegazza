import 'package:dima_project/models/attractionModel.dart';
import 'package:dima_project/widgets/activityDividerWidget.dart';
import 'package:flutter/material.dart';
import 'package:dima_project/utils/screenSize.dart';

class Attractioncardwidget extends StatefulWidget {
  const Attractioncardwidget(this.attraction, {super.key});

  final AttractionModel attraction;

  @override
  State<Attractioncardwidget> createState() => _AttractioncardwidgetState();
}

class _AttractioncardwidgetState extends State<Attractioncardwidget> {
  bool isExpanded = false;

  @override
  Widget build(BuildContext context) {
    return Stack(
      children: [
        Padding(
          padding: const EdgeInsets.only(left: 3.0, top: 10.0, right: 3.0, bottom: 11.5),
          child: Container(
            /*padding: const EdgeInsets.all(10),
            decoration: BoxDecoration(
              color: Colors.grey[100], // sfondo tenue
              borderRadius: BorderRadius.circular(12),
            ),*/
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
                        iconSelector(widget.attraction.attractionType ?? 'default'),
                        size: MediaQuery.of(context).size.width * 0.1,
                        color: Theme.of(context).secondaryHeaderColor,
                      ),
                    ),

                    const activityDivider(),

                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Padding(
                            padding: const EdgeInsets.only(right: 30.0),
                            child: Text(
                              widget.attraction.name ?? 'N/A',
                              style: Theme.of(context).textTheme.headlineSmall,
                            ),
                          ),

                          Row(
                            children: [
                              Icon(
                                Icons.access_time_filled_outlined,
                                size: 20,
                                color: Theme.of(context).primaryColor,
                              ),
                              const SizedBox(width: 5),
                              Text(
                                widget.attraction.startDate != null && widget.attraction.endDate != null
                                    ? 'Time: ${widget.attraction.startDate!.hour.toString().padLeft(2, '0')}:${widget.attraction.startDate!.minute.toString().padLeft(2, '0')} - '
                                    '${widget.attraction.endDate!.hour.toString().padLeft(2, '0')}:${widget.attraction.endDate!.minute.toString().padLeft(2, '0')}'
                                    : 'Time: N/A',
                              )
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
                    padding: const EdgeInsets.only(top: 10, left: 4.0, right: 3.0),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          "Dettagli Extra:",
                          style: Theme.of(context).textTheme.titleMedium,
                        ),
                        const SizedBox(height: 6),

                        if (widget.attraction.address != null && widget.attraction.address!.isNotEmpty) ...[
                          Row(
                            children: [
                              Icon(Icons.location_on, size: 20, color: Theme.of(context).primaryColor),
                              const SizedBox(width: 6),
                              Expanded(child: Text(widget.attraction.address!)),
                            ],
                          ),
                          const SizedBox(height: 3),
                        ],

                        if (widget.attraction.attractionType != null && widget.attraction.attractionType!.isNotEmpty) ...[
                          Row(
                            children: [
                              Icon(Icons.category, size: 20, color: Theme.of(context).primaryColor),
                              const SizedBox(width: 5),
                              Row(
                                children: [
                                  Text(
                                    "Tipo: ${widget.attraction.attractionType == 'tourist_attraction'
                                        ? 'Tourist Attraction'
                                        : widget.attraction.attractionType}",
                                  ),
                                  const SizedBox(width: 3),
                                  Icon(
                                    iconSelector(widget.attraction.attractionType ?? 'default'),
                                  ),
                                ],
                              ),
                            ],
                          ),
                          const SizedBox(height: 3),
                        ],

                        if (widget.attraction.expenses != null) ...[
                          Row(
                            children: [
                              Icon(Icons.attach_money, size: 20, color: Theme.of(context).primaryColor),
                              const SizedBox(width: 5),
                              Text("Costo: €${widget.attraction.expenses!.toStringAsFixed(2)}"),
                            ],
                          ),
                          const SizedBox(height: 5),
                        ],

                        if (widget.attraction.description != null && widget.attraction.description!.isNotEmpty) ...[
                          Container(
                            margin: const EdgeInsets.only(top: 8),
                            padding: const EdgeInsets.all(12),
                            decoration: BoxDecoration(
                              color: Theme.of(context).secondaryHeaderColor,
                              borderRadius: BorderRadius.circular(12),
                              boxShadow: [
                                BoxShadow(
                                  color: Colors.grey.withOpacity(0.2),
                                  spreadRadius: 1,
                                  blurRadius: 6,
                                  offset: const Offset(0, 2),
                                ),
                              ],
                            ),
                            child: Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                Text(
                                  "Descrizione:",
                                  style: Theme.of(context).textTheme.titleSmall,
                                ),
                                const SizedBox(height: 6),
                                Text(
                                  widget.attraction.description!,
                                  style: Theme.of(context).textTheme.bodyMedium,
                                ),
                              ],
                            ),
                          ),
                        ],

                      ],
                    ),
                  ),
                ]


              ],
            ),
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
      ],
    );
  }

  // Scelta icona
  IconData iconSelector(String activityType) {
    switch (activityType.toLowerCase()) {
      case 'museum':
        return Icons.museum;
      case 'restaurant':
        return Icons.restaurant;
      case 'concert':
        return Icons.music_note;
      case 'stadium':
        return Icons.stadium;
      case 'park':
        return Icons.park;
      case 'monument':
        return Icons.account_balance;
      case 'mountain':
        return Icons.terrain;
      case 'tourist_attraction':
        return Icons.attractions;
      default:
        return Icons.photo;
    }
  }
}



