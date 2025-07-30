import 'package:dima_project/models/flightModel.dart';
import 'package:dima_project/widgets/activity_widgets/activityDividerWidget.dart';
import 'package:flutter/material.dart';
import 'package:dima_project/utils/screenSize.dart';

class FlightCardWidget extends StatefulWidget {
  const FlightCardWidget(this.flight, {super.key});

  final FlightModel flight;

  @override
  State<FlightCardWidget> createState() => _FlightCardWidgetState();
}

class _FlightCardWidgetState extends State<FlightCardWidget> {
  bool isExpanded = false;

  @override
  /*Widget build(BuildContext context) {
    return Stack(
      children: [
        Padding(
          padding: const EdgeInsets.only(left: 3.0, top: 10.0, right: 3.0, bottom: 11.5),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // **Prima riga con info base**

              SizedBox(width: ScreenSize.screenWidth(context)*0.01),

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
                      size: 50,
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
                            Text(
                              '${widget.flight.departureAirPort?['iata'] ?? ''} \u2192 ${widget.flight.arrivalAirPort?['iata'] ?? ''}',
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
                            const SizedBox(width: 5),
                            Expanded(
                              child: Text(
                                'Departure Time: ${widget.flight.departureDate != null ? '${widget.flight.departureDate!.hour.toString().padLeft(2, '0')}:${widget.flight.departureDate!.minute.toString().padLeft(2, '0')}' : 'N/A'}',
                                overflow: TextOverflow.ellipsis, // opzionale
                              ),
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
                            const SizedBox(width: 5),
                            Expanded(
                                child: Text(
                                  'Arrival Time: ${widget.flight.arrivalDate != null ? '${widget.flight.arrivalDate!.hour.toString().padLeft(2, '0')}:${widget.flight.arrivalDate!.minute.toString().padLeft(2, '0')}' : 'N/A'}',
                                  overflow: TextOverflow.ellipsis,)
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

                        // Partenza
                        Row(
                          children: [
                            const Icon(Icons.flight_takeoff, size: 20),
                            const SizedBox(width: 6),
                            Expanded(
                              child: Text(
                                "Partenza: ${widget.flight.departureAirPort?['name']}",
                                style: Theme.of(context).textTheme.bodyMedium,
                              ),
                            ),
                          ],
                        ),
                        const SizedBox(height: 3),

                        // Arrivo
                        Row(
                          children: [
                            const Icon(Icons.flight_land, size: 20),
                            const SizedBox(width: 6),
                            Expanded(
                              child: Text(
                                "Arrivo: ${widget.flight.arrivalAirPort?['name']}",
                                style: Theme.of(context).textTheme.bodyMedium,
                              ),
                            ),
                          ],
                        ),
                        const SizedBox(height: 3),

                        // Costo
                        Row(
                          children: [
                            const Icon(Icons.attach_money, size: 20),
                            const SizedBox(width: 6),
                            Expanded(
                              child: Text(
                                "Costo: €${(widget.flight.expenses ?? 0).toStringAsFixed(2)}",
                                style: Theme.of(context).textTheme.bodyMedium,
                              ),
                            ),
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
          bottom: ScreenSize.screenHeight(context) * 0.00001,
          right: ScreenSize.screenWidth(context) * 0.003,
          child: IconButton(
            key: const Key('expandButton'),
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
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
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
                          Icon(Icons.access_time_filled_outlined, size: 20, color: primaryColor),
                          const SizedBox(width: 6),
                          Expanded(
                            child: Text(
                              'Departure Time: ${widget.flight.departureDate != null ? '${widget.flight.departureDate!.hour.toString().padLeft(2, '0')}:${widget.flight.departureDate!.minute.toString().padLeft(2, '0')}' : 'N/A'}',
                              overflow: TextOverflow.ellipsis,
                              style: theme.textTheme.bodyMedium?.copyWith(color: secondaryColor),
                            ),
                          ),
                        ],
                      ),
                      Row(
                        children: [
                          Icon(Icons.access_time_filled_outlined, size: 20, color: primaryColor),
                          const SizedBox(width: 6),
                          Expanded(
                            child: Text(
                              'Arrival Time: ${widget.flight.arrivalDate != null ? '${widget.flight.arrivalDate!.hour.toString().padLeft(2, '0')}:${widget.flight.arrivalDate!.minute.toString().padLeft(2, '0')}' : 'N/A'}',
                              overflow: TextOverflow.ellipsis,
                              style: theme.textTheme.bodyMedium?.copyWith(color: secondaryColor),
                            ),
                          ),
                        ],
                      ),
                    ],
                  ),
                ),
                IconButton(
                  key: const Key('expandButton'),
                  icon: Icon(isExpanded ? Icons.expand_less : Icons.expand_more, color: primaryColor),
                  onPressed: () => setState(() => isExpanded = !isExpanded),
                ),
              ],
            ),

            AnimatedCrossFade(
              firstChild: const SizedBox.shrink(),
              secondChild: Padding(
                padding: const EdgeInsets.only(top: 18),
                child: Column(
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
              ),
              crossFadeState: isExpanded ? CrossFadeState.showSecond : CrossFadeState.showFirst,
              duration: const Duration(milliseconds: 300),
            ),
          ],
        ),
      ),
    );
  }

}