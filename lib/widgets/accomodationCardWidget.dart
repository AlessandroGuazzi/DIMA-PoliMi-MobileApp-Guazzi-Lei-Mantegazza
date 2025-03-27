import 'package:dima_project/utils/screenSize.dart';
import 'package:dima_project/widgets/activityDividerWidget.dart';
import 'package:flutter/material.dart';
import 'package:dima_project/models/accomodationModel.dart';

class AccommodationCardWidget extends StatefulWidget {
  const AccommodationCardWidget(this.accommodation, {super.key});

  final AccommodationModel accommodation;

  @override
  _AccommodationCardWidgetState createState() => _AccommodationCardWidgetState();
}

class _AccommodationCardWidgetState extends State<AccommodationCardWidget> {
  bool isExpanded = false;

  @override
  Widget build(BuildContext context) {
    return Stack(
      children: [
        Padding(
          padding: const EdgeInsets.only(left: 0.2, top: 10.0, right: 3.0, bottom: 11.0),
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
                          '${widget.accommodation.name ?? 'N/A'}',
                          style: Theme.of(context).textTheme.headlineSmall,
                        ),

                        Row(
                          children: [
                            Icon(
                              Icons.access_time_filled_outlined,
                              size: 20,
                              color: Theme.of(context).primaryColor,
                            ),

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
      ]
    );
  }


}
