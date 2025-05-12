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
                        Text(
                          widget.attraction.name ?? 'N/A',
                          style: Theme.of(context).textTheme.headlineSmall,
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



