import 'package:dima_project/models/flightModel.dart';
import 'package:flutter/material.dart';
import 'package:dima_project/utils/screenSize.dart';

class FlightActivityCard extends StatefulWidget {
  const FlightActivityCard(this.flight, {super.key});

  final FlightModel flight;

  @override
  State<FlightActivityCard> createState() => _FlightActivityCardState();
}

class _FlightActivityCardState extends State<FlightActivityCard> {
  bool isExpanded = false;

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
                        Icons.flight,
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
                            '${widget.flight.departureAirPort?['iata'] ?? ''} \u2192 ${widget.flight.arrivalAirPort?['iata'] ?? ''}',
                            style: theme.textTheme.headlineMedium,
                          ),
                          const SizedBox(height: 6),
                          Row(
                            children: [
                              Icon(Icons.flight_takeoff, size: 20, color: primaryColor),
                              const SizedBox(width: 6),
                              Expanded(
                                child: Text(
                                  'Partenza: ${widget.flight.departureDate != null ? '${widget.flight.departureDate!.hour.toString().padLeft(2, '0')}:${widget.flight.departureDate!.minute.toString().padLeft(2, '0')}' : 'N/A'}',
                                  overflow: TextOverflow.ellipsis,
                                  style: theme.textTheme.bodyMedium,
                                ),
                              ),
                            ],
                          ),
                          const SizedBox(height: 3),
                          Row(
                            children: [
                              Icon(Icons.flight_land, size: 20, color: primaryColor),
                              const SizedBox(width: 6),
                              Expanded(
                                child: Text(
                                  'Arrivo: ${widget.flight.arrivalDate != null ? '${widget.flight.arrivalDate!.hour.toString().padLeft(2, '0')}:${widget.flight.arrivalDate!.minute.toString().padLeft(2, '0')}' : 'N/A'}',
                                  overflow: TextOverflow.ellipsis,
                                  style: theme.textTheme.bodyMedium,
                                ),
                              ),
                            ],
                          ),
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
                      Row(
                        children: [
                          Icon(Icons.flight_takeoff, size: 20, color: primaryColor),
                          const SizedBox(width: 6),
                          Expanded(
                            child: Text(
                              "Partenza: ${widget.flight.departureAirPort?['name'] ?? ''}",
                              style: theme.textTheme.bodyLarge,
                              overflow: TextOverflow.ellipsis,
                            ),
                          ),
                        ],
                      ),
                      const SizedBox(height: 6),
                      Row(
                        children: [
                          Icon(Icons.flight_land, size: 20, color: primaryColor),
                          const SizedBox(width: 6),
                          Expanded(
                            child: Text(
                              "Arrivo: ${widget.flight.arrivalAirPort?['name'] ?? ''}",
                              style: theme.textTheme.bodyLarge,
                              overflow: TextOverflow.ellipsis,
                            ),
                          ),
                        ],
                      ),
                      const SizedBox(height: 6),
                      Row(
                        children: [
                          Icon(Icons.attach_money, size: 20, color: primaryColor),
                          const SizedBox(width: 6),
                          Expanded(
                            child: Text(
                              "Costo: €${(widget.flight.expenses ?? 0).toStringAsFixed(2)}",
                              style: theme.textTheme.bodyLarge,
                            ),
                          ),
                        ],
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
              key: const Key('expandButton'),
              icon: Icon(isExpanded ? Icons.expand_less : Icons.expand_more, color: primaryColor, size: 25,),
              onPressed: () => setState(() => isExpanded = !isExpanded),
            ),
          ),
        ],
      ),
    );


  }

}