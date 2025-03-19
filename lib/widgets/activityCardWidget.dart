import 'package:flutter/material.dart';

import '../models/tripModel.dart';

class ActivityCardWidget extends StatelessWidget {
  const ActivityCardWidget({super.key});



  @override
  Widget build(BuildContext context) {
    return Container(
      height: 250,
      child: Row(
        children: [
          Container(
            padding: const EdgeInsets.all(12), // Adjust padding to control size
            decoration: BoxDecoration(
              shape: BoxShape.circle,
              color: Theme.of(context).primaryColor.withOpacity(0.1), // Background color
            ),
            child: Icon(
              Icons.airplane_ticket_outlined,
              size: 45,
              color: Theme.of(context).secondaryHeaderColor,
            ),
          ),

          VerticalDivider(
            width: 2.0,
            thickness: 1.5,
          ),
          Padding(
            padding: const EdgeInsetsDirectional.fromSTEB(16, 5, 16, 16),
            child: Column(
              children: [
                Text(
                  'Title',
                  style: Theme.of(context).textTheme.displayMedium,
                ),

                Row(
                  children: [
                    Text('Start Time'),
                    Icon(
                      Icons.lock_clock_outlined,
                      size: 20,
                      color: Theme.of(context).primaryColor,
                    )
                  ],
                )

              ],
            ),
          )
        ],
      ),
    );
  }
}
