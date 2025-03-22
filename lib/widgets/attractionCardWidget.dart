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
  @override
  Widget build(BuildContext context) {

    return Row(
      children: [
        Container(
          padding: const EdgeInsets.all(12), // Adjust padding to control size
          decoration: BoxDecoration(
            shape: BoxShape.circle,
            color: Theme.of(context).primaryColor.withOpacity(0.1), // Background color
          ),
          child: Icon(
            iconSelector(widget.attraction.attractionType ?? 'default'),
            size: ScreenSize.screenWidth(context) * 0.1,
            color: Theme.of(context).secondaryHeaderColor,
          ),
        ),

        const activityDivider(),

        Padding(
          padding: const EdgeInsetsDirectional.fromSTEB(10, 5, 10, 10),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                '${widget.attraction.name ?? 'N/A'}',
                style: Theme.of(context).textTheme.headlineSmall,
              ),

              Row(
                children: [

                  Icon(
                    Icons.access_time_filled_outlined,
                    size: 20,
                    color: Theme.of(context).primaryColor,
                  ),

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
        )
      ],
    );
  }

  //SCELTA ICONA
  IconData iconSelector(String activityType) {
    switch (activityType.toLowerCase()) {
      case 'museo':
        return Icons.museum;
      case 'ristorante':
        return Icons.restaurant;
      case 'concerto':
        return Icons.music_note;
      case 'stadio':
        return Icons.stadium;
      case 'parco naturale':
        return Icons.park;
      case 'monumento':
        return Icons.account_balance;
      case 'montagna':
        return Icons.terrain;
      default:
        return Icons.photo; // Icona di default per attività generali
    }
  }
}


