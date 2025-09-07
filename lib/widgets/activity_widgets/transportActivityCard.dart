import 'package:dima_project/models/transportModel.dart';
import 'package:flutter/material.dart';
import 'package:dima_project/utils/screenSize.dart';

class TransportActivityCard extends StatefulWidget {
  const TransportActivityCard(this.transport, {super.key});

  final TransportModel transport;

  @override
  State<TransportActivityCard> createState() => _TransportActivityCardState();
}

class _TransportActivityCardState extends State<TransportActivityCard> {
  bool isExpanded = false;


  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final primaryColor = theme.primaryColor;

    final departure = widget.transport.departureDate;
    final durationMinutes = widget.transport.duration;
    final arrival = (departure != null && durationMinutes != null)
        ? departure.add(Duration(minutes: durationMinutes.toInt()))
        : null;



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
                        iconSelector(widget.transport.transportType ?? 'default'),
                        size: 48,
                        color: primaryColor,
                      ),
                    ),
                    const SizedBox(width: 16),
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Padding(
                            padding: const EdgeInsets.only(right: 9.0),
                            child: Text(
                              '${widget.transport.departurePlace ?? ""} → ${widget.transport.arrivalPlace ?? ""}',
                              style: theme.textTheme.headlineMedium,
                            ),
                          ),
                          const SizedBox(height: 6),
                          Row(
                            children: [
                              Icon(Icons.access_time, size: 20, color: primaryColor),
                              const SizedBox(width: 6),
                              Text(
                                'Partenza: ${widget.transport.departureDate != null ? '${widget.transport.departureDate!.hour.toString().padLeft(2, '0')}:${widget.transport.departureDate!.minute.toString().padLeft(2, '0')}' : 'N/A'}',
                                style: theme.textTheme.bodyMedium,
                              ),
                            ],
                          ),
                          const SizedBox(height: 3),
                          if (widget.transport.duration != null && widget.transport.duration != 0)
                            Row(
                              children: [
                                Icon(Icons.access_time_filled_outlined, size: 20, color: Theme.of(context).primaryColor),
                                const SizedBox(width: 3),
                                Text(
                                  'Arrivo: ${arrival != null
                                      ? '${arrival.hour.toString().padLeft(2, '0')}:${arrival.minute.toString().padLeft(2, '0')}'
                                      : 'N/A'}',
                                  style: theme.textTheme.bodyMedium,
                                ),
                              ],
                            )

                        ],
                      ),
                    ),
                  ],
                ),
                AnimatedCrossFade(
                  firstChild: const SizedBox.shrink(),
                  secondChild: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Divider(color: primaryColor.withOpacity(0.3), thickness: 1.2),
                      const SizedBox(height: 10),
                      if (widget.transport.transportType != null && widget.transport.transportType!.isNotEmpty)
                        Row(
                          children: [
                            Icon(iconSelector(widget.transport.transportType ?? 'default'), size: 20, color: primaryColor),
                            const SizedBox(width: 6),
                            Text(
                              "Trasporto via: ${widget.transport.transportType}",
                              style: theme.textTheme.bodyLarge,
                            ),
                          ],
                        ),
                      if (widget.transport.arrivalPlace != null && widget.transport.arrivalPlace!.isNotEmpty)
                        Padding(
                          padding: const EdgeInsets.only(top: 10),
                          child: Row(
                            children: [
                              Icon(Icons.location_on, size: 20, color: primaryColor),
                              const SizedBox(width: 6),
                              Expanded(
                                child: Text(
                                  "Destinazione: ${widget.transport.arrivalPlace!}",
                                  style: theme.textTheme.bodyLarge,
                                  overflow: TextOverflow.ellipsis,
                                ),
                              ),
                            ],
                          ),
                        ),
                      if (widget.transport.duration != null)
                        Padding(
                          padding: const EdgeInsets.only(top: 10),
                          child: Row(
                            children: [
                              Icon(Icons.timelapse, size: 20, color: primaryColor),
                              const SizedBox(width: 6),
                              Text(
                                'Durata: ${widget.transport.duration! >= 60 ? '${widget.transport.duration! ~/ 60}h ' : ''}'
                                    '${widget.transport.duration! % 60 > 0 ? '${widget.transport.duration! % 60}m' : (widget.transport.duration! < 60 ? '${widget.transport.duration!}m' : '')}',
                                style: theme.textTheme.bodyLarge,
                              )
                            ],
                          ),
                        ),
                      if (widget.transport.expenses != null)
                        Padding(
                          padding: const EdgeInsets.only(top: 10),
                          child: Row(
                            children: [
                              Icon(Icons.attach_money, size: 20, color: primaryColor),
                              const SizedBox(width: 6),
                              Text(
                                "Costo: €${widget.transport.expenses!.toStringAsFixed(2)}",
                                style: theme.textTheme.bodyLarge,
                              ),
                            ],
                          ),
                        ),
                    ],
                  ),
                  crossFadeState: isExpanded ? CrossFadeState.showSecond : CrossFadeState.showFirst,
                  duration: const Duration(milliseconds: 300),
                ),
              ],
            ),
          ),
          Positioned(
            bottom: ScreenSize.screenHeight(context) * 0.001,
            right: ScreenSize.screenWidth(context) * 0.003,
            child: IconButton(
              icon: Icon(isExpanded ? Icons.expand_less : Icons.expand_more, color: primaryColor,  size: 25,),
              onPressed: () => setState(() => isExpanded = !isExpanded),
            ),
          ),
        ],
      ),
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
