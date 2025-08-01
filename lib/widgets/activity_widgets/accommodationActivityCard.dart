import 'package:dima_project/utils/screenSize.dart';
import 'package:flutter/material.dart';
import 'package:dima_project/models/accommodationModel.dart';

class AccommodationActivityCard extends StatefulWidget {
  const AccommodationActivityCard(this.accommodation, {super.key});

  final AccommodationModel accommodation;

  @override
  _AccommodationActivityCardState createState() => _AccommodationActivityCardState();
}

class _AccommodationActivityCardState extends State<AccommodationActivityCard> {
  bool isExpanded = false;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final primaryColor = theme.primaryColor;
    final secondaryColor = theme.colorScheme.secondary;

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
                              Icon(Icons.meeting_room, size: 20, color: primaryColor),
                              const SizedBox(width: 6),
                              Text(
                                'Check In: ${widget.accommodation.checkIn != null ? '${widget.accommodation.checkIn!.hour.toString().padLeft(2, '0')}:${widget.accommodation.checkIn!.minute.toString().padLeft(2, '0')}' : 'N/A'}',
                                style: theme.textTheme.bodyMedium?.copyWith(color: secondaryColor),
                              ),
                            ],
                          ),
                          const SizedBox(height: 3),
                          Row(
                            children: [
                              Icon(Icons.meeting_room_outlined, size: 20, color: primaryColor),
                              const SizedBox(width: 6),
                              Text(
                                'Check Out: ${widget.accommodation.checkOut != null ? '${widget.accommodation.checkOut!.hour.toString().padLeft(2, '0')}:${widget.accommodation.checkOut!.minute.toString().padLeft(2, '0')}' : 'N/A'}',
                                style: theme.textTheme.bodyMedium?.copyWith(color: secondaryColor),
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
              icon: Icon(isExpanded ? Icons.expand_less : Icons.expand_more, color: primaryColor, size: 25,),
              onPressed: () => setState(() => isExpanded = !isExpanded),
            ),
          ),
        ],
      ),
    );

  }



}
