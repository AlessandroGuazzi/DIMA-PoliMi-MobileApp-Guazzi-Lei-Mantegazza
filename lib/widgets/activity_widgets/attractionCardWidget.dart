import 'package:dima_project/models/attractionModel.dart';
import 'package:dima_project/widgets/activity_widgets/activityDividerWidget.dart';
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
  /*Widget build(BuildContext context) {
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
                        size: 50,
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
                          Padding(
                            padding: EdgeInsets.only(right: ScreenSize.screenWidth(context) * 0.01),
                            child: Container(
                              width: double.infinity,
                              margin: const EdgeInsets.only(top: 8),
                              padding: const EdgeInsets.all(12),
                              decoration: BoxDecoration(
                                color: Theme.of(context).primaryColor.withOpacity(0.1),
                                borderRadius: BorderRadius.circular(12),
                                /*boxShadow: [
                                  BoxShadow(
                                    color: Colors.grey.withOpacity(0.2),
                                    spreadRadius: 1,
                                    blurRadius: 6,
                                    offset: const Offset(0, 2),
                                  ),
                                ],*/
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
  }*/

  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final primaryColor = theme.primaryColor;
    final secondaryColor = theme.colorScheme.secondary;

    return Card(
      elevation: 6,
      margin: const EdgeInsets.symmetric(horizontal: 0, vertical: 0),
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
      child: Stack(
        children: [
          Padding(
            padding: const EdgeInsets.all(16),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Row(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Container(
                      padding: const EdgeInsets.all(14),
                      decoration: BoxDecoration(
                        shape: BoxShape.circle,
                        gradient: LinearGradient(
                          colors: [
                            primaryColor.withOpacity(0.2),
                            primaryColor.withOpacity(0.05),
                          ],
                          begin: Alignment.topLeft,
                          end: Alignment.bottomRight,
                        ),
                      ),
                      child: Icon(
                        iconSelector(widget.attraction.attractionType ?? 'default'),
                        size: 48,
                        color: primaryColor,
                      ),
                    ),
                    const SizedBox(width: 16),
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            widget.attraction.name ?? 'N/A',
                            style: theme.textTheme.headlineMedium,
                          ),
                          const SizedBox(height: 6),
                          Row(
                            children: [
                              Icon(Icons.access_time_filled_outlined, size: 20, color: primaryColor),
                              const SizedBox(width: 6),
                              Text(
                                widget.attraction.startDate != null && widget.attraction.endDate != null
                                    ? '${widget.attraction.startDate!.hour.toString().padLeft(2, '0')}:${widget.attraction.startDate!.minute.toString().padLeft(2, '0')} - '
                                    '${widget.attraction.endDate!.hour.toString().padLeft(2, '0')}:${widget.attraction.endDate!.minute.toString().padLeft(2, '0')}'
                                    : 'Orario non disponibile',
                                style: theme.textTheme.bodyMedium?.copyWith(color: secondaryColor),
                              ),
                            ],
                          ),
                        ],
                      ),
                    ),
                    // Rimuovo il bottone qui per spostarlo nel Positioned
                  ],
                ),
                AnimatedCrossFade(
                  firstChild: const SizedBox.shrink(),
                  secondChild: Padding(
                    padding: const EdgeInsets.only(top: 18, bottom: 48), // Spazio per il bottone
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Divider(color: primaryColor.withOpacity(0.3), thickness: 1.2),
                        const SizedBox(height: 10),

                        if (widget.attraction.address != null && widget.attraction.address!.isNotEmpty)
                          Row(
                            children: [
                              Icon(Icons.location_on, size: 20, color: primaryColor),
                              const SizedBox(width: 6),
                              Expanded(
                                child: Text(
                                  widget.attraction.address!,
                                  style: theme.textTheme.bodyLarge,
                                  overflow: TextOverflow.ellipsis,
                                ),
                              ),
                            ],
                          ),

                        if (widget.attraction.attractionType != null && widget.attraction.attractionType!.isNotEmpty) ...[
                          const SizedBox(height: 10),
                          Row(
                            children: [
                              Icon(Icons.category, size: 20, color: primaryColor),
                              const SizedBox(width: 6),
                              Text(
                                "Tipo: ${widget.attraction.attractionType == 'tourist_attraction' ? 'Attrazione Turistica' : widget.attraction.attractionType}",
                                style: theme.textTheme.bodyLarge,
                              ),
                            ],
                          ),
                        ],

                        if (widget.attraction.expenses != null) ...[
                          const SizedBox(height: 10),
                          Row(
                            children: [
                              Icon(Icons.attach_money, size: 20, color: primaryColor),
                              const SizedBox(width: 6),
                              Text(
                                "Costo: €${widget.attraction.expenses!.toStringAsFixed(2)}",
                                style: theme.textTheme.bodyLarge,
                              ),
                            ],
                          ),
                        ],

                        if (widget.attraction.description != null && widget.attraction.description!.isNotEmpty) ...[
                          const SizedBox(height: 16),
                          Container(
                            width: double.infinity,
                            padding: const EdgeInsets.all(14),
                            decoration: BoxDecoration(
                              color: primaryColor.withOpacity(0.1),
                              borderRadius: BorderRadius.circular(12),
                            ),
                            child: Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                Text(
                                  "Descrizione:",
                                  style: theme.textTheme.titleMedium?.copyWith(fontWeight: FontWeight.bold),
                                ),
                                const SizedBox(height: 8),
                                Text(
                                  widget.attraction.description!,
                                  style: theme.textTheme.bodyMedium,
                                  maxLines: 5,
                                  overflow: TextOverflow.ellipsis,
                                ),
                              ],
                            ),
                          ),
                        ],
                      ],
                    ),
                  ),
                  crossFadeState:
                  isExpanded ? CrossFadeState.showSecond : CrossFadeState.showFirst,
                  duration: const Duration(milliseconds: 300),
                ),
              ],
            ),
          ),

          Positioned(
            bottom: ScreenSize.screenHeight(context) * 0.001,
            right: ScreenSize.screenWidth(context) * 0.003,
            child: IconButton(
              icon: Icon(isExpanded ? Icons.expand_less : Icons.expand_more, color: primaryColor),
              onPressed: () => setState(() => isExpanded = !isExpanded),
            ),
          ),
        ],
      ),
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



