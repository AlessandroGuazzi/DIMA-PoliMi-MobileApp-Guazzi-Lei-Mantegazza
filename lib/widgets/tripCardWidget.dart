import 'package:dima_project/utils/screenSize.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';

import '../models/tripModel.dart';

class TripCardWidget extends StatefulWidget {
  TripModel trip;

  TripCardWidget(this.trip, {super.key});

  @override
  State<TripCardWidget> createState() => _TripCardWidgetState();
}

class _TripCardWidgetState extends State<TripCardWidget> {
  late TripModel _trip;

  @override
  void initState() {
    super.initState();
    _trip = widget.trip;
  }

  @override
  Widget build(BuildContext context) {

    return Container(

      decoration: BoxDecoration(
        color: Colors.transparent,
      ),
      child: Card(
        clipBehavior: Clip.antiAlias,
        color: Theme.of(context).cardColor,
        elevation: 5,
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(12),
        ),
        child: Padding(
          padding: EdgeInsetsDirectional.fromSTEB(12, 12, 12, 12),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              ClipRRect(
                borderRadius: BorderRadius.circular(8),
                //placeholder image
                child: Image.network(
                  'https://picsum.photos/100',
                  fit: BoxFit.cover,
                ),
              ),
              Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    '${_trip.title}',
                    style: Theme.of(context).textTheme.headlineSmall,
                  ),
                  Row(
                    mainAxisSize: MainAxisSize.max,
                    children: [
                      Icon(
                        Icons.calendar_today,
                        size: 20,
                      ),
                      //placeholder for date
                      Text(
                        'Oct 15 - Oct 18, 2024',
                        style: Theme.of(context).textTheme.bodyMedium
                      ),
                    ]
                  ),
                ]
              ),
            ]
          ),
        ),
      ),
    );
  }
}