import 'package:dima_project/utils/screenSize.dart';
import 'package:dima_project/widgets/activity_widgets/activityDividerWidget.dart';
import 'package:flutter/material.dart';
import 'package:dima_project/models/accommodationModel.dart';

class AccommodationCardWidget extends StatefulWidget {
  const AccommodationCardWidget(this.accommodation, {super.key});

  final AccommodationModel accommodation;

  @override
  _AccommodationCardWidgetState createState() => _AccommodationCardWidgetState();
}

class _AccommodationCardWidgetState extends State<AccommodationCardWidget> {
  bool isExpanded = false;

  @override
  /*Widget build(BuildContext context) {
    return Stack(
      children: [
        Padding(
          padding: const EdgeInsets.only(left: 3.0, top: 10.0, right: 3.0, bottom: 11.0),
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
                      Icons.hotel,
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
                            '${widget.accommodation.name ?? 'N/A'}',
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
                            Text('CheckIn: ${widget.accommodation.checkIn != null ? '${widget.accommodation.checkIn!.hour.toString().padLeft(2, '0')}:${widget.accommodation.checkIn!.minute.toString().padLeft(2, '0')}' : 'N/A'}')
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
                            Text('CheckOut: ${widget.accommodation.checkOut != null ? '${widget.accommodation.checkOut!.hour.toString().padLeft(2, '0')}:${widget.accommodation.checkOut!.minute.toString().padLeft(2, '0')}' : 'N/A'}')
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

                      if (widget.accommodation.address != null) ...[
                        Row(
                          children: [
                            Icon(Icons.location_on, color: Theme.of(context).primaryColor),
                            const SizedBox(width: 6),
                            Expanded(
                              child: Text(widget.accommodation.address!),
                            ),
                          ],
                        ),
                        const SizedBox(height: 3),
                      ],

                      if (widget.accommodation.expenses != null) ...[
                        Row(
                          children: [
                            Icon(Icons.attach_money, color: Theme.of(context).primaryColor),
                            const SizedBox(width: 5),
                            Text("Costo: €${widget.accommodation.expenses!.toStringAsFixed(2)}"),
                          ],
                        ),
                        const SizedBox(height: 3),
                      ],

                      if (widget.accommodation.contacts != null && widget.accommodation.contacts!.isNotEmpty) ...[
                        Text("Contatti:", style: Theme.of(context).textTheme.bodyMedium,),
                        ...widget.accommodation.contacts!.entries.map((entry) => Padding(
                          padding: const EdgeInsets.only(left: 8, top: 2),
                          child: Text("${entry.key}: ${entry.value}"),
                        )),
                      ]

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
                        Icons.hotel,
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
                            widget.accommodation.name ?? 'N/A',
                            style: theme.textTheme.headlineMedium,
                          ),
                          const SizedBox(height: 6),
                          Row(
                            children: [
                              Icon(Icons.access_time_filled_outlined, size: 20, color: primaryColor),
                              const SizedBox(width: 6),
                              Text(
                                'CheckIn: ${widget.accommodation.checkIn != null ? '${widget.accommodation.checkIn!.hour.toString().padLeft(2, '0')}:${widget.accommodation.checkIn!.minute.toString().padLeft(2, '0')}' : 'N/A'}',
                                style: theme.textTheme.bodyMedium?.copyWith(color: secondaryColor),
                              ),
                            ],
                          ),
                          Row(
                            children: [
                              Icon(Icons.access_time_filled_outlined, size: 20, color: primaryColor),
                              const SizedBox(width: 6),
                              Text(
                                'CheckOut: ${widget.accommodation.checkOut != null ? '${widget.accommodation.checkOut!.hour.toString().padLeft(2, '0')}:${widget.accommodation.checkOut!.minute.toString().padLeft(2, '0')}' : 'N/A'}',
                                style: theme.textTheme.bodyMedium?.copyWith(color: secondaryColor),
                              ),
                            ],
                          ),
                        ],
                      ),
                    ),
                    // Bottone rimosso da qui per spostarlo in basso a destra
                  ],
                ),
                AnimatedCrossFade(
                  firstChild: const SizedBox.shrink(),
                  secondChild: Padding(
                    padding: const EdgeInsets.only(top: 18, bottom: 48), // lascia spazio per il bottone
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Divider(color: primaryColor.withOpacity(0.3), thickness: 1.2),
                        const SizedBox(height: 10),
                        if (widget.accommodation.address != null && widget.accommodation.address!.isNotEmpty)
                          Row(
                            children: [
                              Icon(Icons.location_on, size: 20, color: primaryColor),
                              const SizedBox(width: 6),
                              Expanded(
                                child: Text(
                                  widget.accommodation.address!,
                                  style: theme.textTheme.bodyLarge,
                                  overflow: TextOverflow.ellipsis,
                                ),
                              ),
                            ],
                          ),
                        if (widget.accommodation.expenses != null)
                          Padding(
                            padding: const EdgeInsets.only(top: 10),
                            child: Row(
                              children: [
                                Icon(Icons.attach_money, size: 20, color: primaryColor),
                                const SizedBox(width: 6),
                                Text(
                                  "Costo: €${widget.accommodation.expenses!.toStringAsFixed(2)}",
                                  style: theme.textTheme.bodyLarge,
                                ),
                              ],
                            ),
                          ),
                        if (widget.accommodation.contacts != null && widget.accommodation.contacts!.isNotEmpty)
                          Padding(
                            padding: const EdgeInsets.only(top: 10),
                            child: Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                Text("Contatti:", style: theme.textTheme.titleMedium?.copyWith(fontWeight: FontWeight.bold)),
                                ...widget.accommodation.contacts!.entries.map((entry) => Padding(
                                  padding: const EdgeInsets.only(left: 8, top: 2),
                                  child: Text("${entry.key}: ${entry.value}", style: theme.textTheme.bodyMedium),
                                )),
                              ],
                            ),
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



}
