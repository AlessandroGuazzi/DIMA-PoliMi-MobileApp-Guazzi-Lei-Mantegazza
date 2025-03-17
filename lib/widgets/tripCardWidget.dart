import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';

import '../models/tripModel.dart';

class TripCardWidget extends StatelessWidget {
  final TripModel trip;

  const TripCardWidget(this.trip, {super.key});

  @override
  Widget build(BuildContext context) {

    // Generated code for this Container Widget...
    return Container(
      decoration: BoxDecoration(
        color: Colors.white,
        boxShadow: [
          BoxShadow(
            color: Colors.white,
          )
        ],
        borderRadius: BorderRadius.circular(12),
      ),
      child: Padding(
        padding: EdgeInsets.all(16),
        child: Column(
          mainAxisSize: MainAxisSize.max,
          children: [
            Stack(
              children: [
                Container(
                  width: double.infinity,
                  height: 200,
                  child: ClipRRect(
                    borderRadius: BorderRadius.circular(12),
                    child: ShaderMask(
                      shaderCallback: (Rect bounds) {
                        return LinearGradient(
                          begin: Alignment.center,
                          end: Alignment.bottomCenter,
                          colors: [Colors.white, Colors.transparent],
                        ).createShader(bounds);
                      },
                      blendMode: BlendMode.dstIn,
                      child: Image.network(
                        'https://picsum.photos/900',
                        width: double.infinity,
                        height: 200,
                        fit: BoxFit.cover,
                      ),
                    ),
                  )
                ),
              ],
            ),
            Padding(
              padding: EdgeInsetsDirectional.fromSTEB(16, 12, 16, 16),
              child: Column(
                mainAxisSize: MainAxisSize.max,
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    '${trip.title}',
                    style: Theme.of(context).textTheme.headlineMedium,
                  ),
                  SizedBox(height: 4),
                  Row(
                    mainAxisSize: MainAxisSize.max,
                    children: [
                      Icon(
                        Icons.place,
                        size: 16,
                      ),
                      SizedBox(width: 4,),
                      Text(trip.cities?.join(' - ') ?? 'No cities available'),

                    ]
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );


    /*
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

     */
  }
}