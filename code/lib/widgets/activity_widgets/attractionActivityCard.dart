import 'package:dima_project/models/attractionModel.dart';
import 'package:flutter/material.dart';
import 'package:dima_project/utils/screenSize.dart';

import '../../utils/PlacesType.dart';

class AttractionActivityCard extends StatefulWidget {
  const AttractionActivityCard(this.attraction, {super.key});

  final AttractionModel attraction;

  @override
  State<AttractionActivityCard> createState() => _AttractionActivityCardState();
}

class _AttractionActivityCardState extends State<AttractionActivityCard> {
  bool isExpanded = false;

  final Map<PlacesType, String> activityTypes = {
    PlacesType.museum: 'Museo',
    PlacesType.restaurant: 'Ristorante',
    PlacesType.stadium: 'Stadio',
    PlacesType.park: 'Parco Naturale',
    PlacesType.zoo: 'Zoo',
    PlacesType.church: 'Chiesa',
    PlacesType.movie_theater: 'Cinema',
    PlacesType.tourist_attraction: 'Attrazione turistica',
  };

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final primaryColor = theme.primaryColor;

    return Card(
      margin: const EdgeInsets.symmetric(horizontal: 1, vertical: 1),
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
      child: Stack(
        children: [
          Padding(
            padding: const EdgeInsets.all(16),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Row(
                  crossAxisAlignment: CrossAxisAlignment.center,
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
                        iconSelector(
                            widget.attraction.attractionType ?? 'default'),
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
                              Icon(Icons.schedule,
                                  size: 20, color: primaryColor),
                              const SizedBox(width: 6),
                              Expanded(
                                child: Text(
                                  widget.attraction.startDate != null &&
                                          widget.attraction.endDate != null
                                      ? '${widget.attraction.startDate!.hour.toString().padLeft(2, '0')}:${widget.attraction.startDate!.minute.toString().padLeft(2, '0')} - '
                                          '${widget.attraction.endDate!.hour.toString().padLeft(2, '0')}:${widget.attraction.endDate!.minute.toString().padLeft(2, '0')}'
                                      : 'Orario non disponibile',
                                  style: theme.textTheme.bodyMedium,
                                  overflow: TextOverflow.ellipsis,
                                ),
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
                    padding: const EdgeInsets.only(bottom: 14),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Divider(
                            color: primaryColor.withOpacity(0.3),
                            thickness: 1.2),
                        const SizedBox(height: 10),
                        if (widget.attraction.address != null &&
                            widget.attraction.address!.isNotEmpty)
                          Row(
                            children: [
                              Icon(Icons.location_on,
                                  size: 20, color: primaryColor),
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
                        if (widget.attraction.attractionType != null &&
                            widget.attraction.attractionType!.isNotEmpty) ...[
                          const SizedBox(height: 10),
                          Row(
                            children: [
                              Icon(
                                  iconSelector(
                                      widget.attraction.attractionType ??
                                          'default'),
                                  size: 20,
                                  color: primaryColor),
                              const SizedBox(width: 6),
                              Text(
                                "Tipo: ${translateType(widget.attraction.attractionType!)}",
                                style: theme.textTheme.bodyLarge,
                              ),
                            ],
                          ),
                        ],
                        if (widget.attraction.expenses != null) ...[
                          const SizedBox(height: 10),
                          Row(
                            children: [
                              Icon(Icons.attach_money,
                                  size: 20, color: primaryColor),
                              const SizedBox(width: 6),
                              Text(
                                "Costo: €${widget.attraction.expenses!.toStringAsFixed(2)}",
                                style: theme.textTheme.bodyLarge,
                              ),
                            ],
                          ),
                        ],
                        if (widget.attraction.description != null &&
                            widget.attraction.description!.isNotEmpty) ...[
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
                                  style: theme.textTheme.titleMedium
                                      ?.copyWith(fontWeight: FontWeight.bold),
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
                  crossFadeState: isExpanded
                      ? CrossFadeState.showSecond
                      : CrossFadeState.showFirst,
                  duration: const Duration(milliseconds: 300),
                ),
              ],
            ),
          ),
          Positioned(
            bottom: ScreenSize.screenHeight(context) * 0.001,
            right: ScreenSize.screenWidth(context) * 0.003,
            child: IconButton(
              icon: Icon(
                isExpanded ? Icons.expand_less : Icons.expand_more,
                color: primaryColor,
                size: 25,
              ),
              onPressed: () => setState(() => isExpanded = !isExpanded),
            ),
          ),
        ],
      ),
    );
  }

  String translateType(String type) {
    switch (type) {
      case 'museum':
        return 'Museo';
      case 'restaurant':
        return 'Ristorante';
      case 'stadium':
        return 'Stadio';
      case 'park':
        return 'Parco Naturale';
      case 'zoo':
        return 'Zoo';
      case 'church':
        return 'Chiesa';
      case 'movie_theater':
        return 'Cinema';
      case 'tourist_attraction':
        return 'Attrazione turistica';
      default:
        return 'Sconosciuto';
    }
  }

  // Scelta icona
  IconData iconSelector(String activityType) {
    switch (activityType.toLowerCase()) {
      case 'museum':
        return Icons.museum;
      case 'restaurant':
        return Icons.restaurant;
      case 'stadium':
        return Icons.stadium;
      case 'park':
        return Icons.park;
      case 'zoo':
        return Icons.pets;
      case 'church':
        return Icons.church;
      case 'movie_theater':
        return Icons.movie;
      case 'tourist_attraction':
        return Icons.attractions;
      default:
        return Icons.photo;
    }
  }
}
