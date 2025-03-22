import 'package:dima_project/utils/screenSize.dart';
import 'package:flutter/material.dart';
import 'package:dima_project/models/accomodationModel.dart';

class AccommodationCardWidget extends StatefulWidget {
  const AccommodationCardWidget(this.accomodation, {super.key});

  final AccommodationModel accomodation;

  @override
  _AccommodationCardWidgetState createState() => _AccommodationCardWidgetState();
}

class _AccommodationCardWidgetState extends State<AccommodationCardWidget> {
  bool isExpanded = false;

  @override
  Widget build(BuildContext context) {
    return Card(
      elevation: 2,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
      child: Stack(
        children: [
          Padding(
            padding: const EdgeInsets.all(12.0),
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
                        Icons.holiday_village,
                        size: MediaQuery.of(context).size.width * 0.1,
                        color: Theme.of(context).secondaryHeaderColor,
                      ),
                    ),
                    const SizedBox(width: 10),
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            '${widget.accomodation.name ?? 'N/A'}',
                            style: Theme.of(context).textTheme.headlineSmall,
                          ),

                          Row(
                            children: [
                              Icon(
                                Icons.access_time_filled_outlined,
                                size: 20,
                                color: Theme.of(context).primaryColor,
                              ),

                              Text('CheckIn: ${widget.accomodation.checkIn != null ? '${widget.accomodation.checkIn!.hour.toString().padLeft(2, '0')}:${widget.accomodation.checkIn!.minute.toString().padLeft(2, '0')}' : 'N/A'}')
                            ],
                          ),

                          Row(
                            children: [
                              Icon(
                                Icons.access_time_filled_outlined,
                                size: 20,
                                color: Theme.of(context).primaryColor,
                              ),

                              Text('CheckOut: ${widget.accomodation.checkOut != null ? '${widget.accomodation.checkOut!.hour.toString().padLeft(2, '0')}:${widget.accomodation.checkOut!.minute.toString().padLeft(2, '0')}' : 'N/A'}')
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
          bottom: ScreenSize.screenHeight(context) * 0.001,
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
      ),
    );
  }

  // **Funzione per formattare l'orario**
  String _formatTime(TimeOfDay? time) {
    if (time == null) return 'N/A';
    return '${time.hour.toString().padLeft(2, '0')}:${time.minute.toString().padLeft(2, '0')}';
  }
}
