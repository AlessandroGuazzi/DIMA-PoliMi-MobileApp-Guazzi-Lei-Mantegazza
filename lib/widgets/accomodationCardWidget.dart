import 'package:dima_project/models/accomodationModel.dart';
import 'package:flutter/material.dart';
import 'package:dima_project/utils/screenSize.dart';

class Accomodationcardwidget extends StatelessWidget {
  const Accomodationcardwidget(this.accomodation, {super.key});

  final AccommodationModel accomodation;

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
            Icons.holiday_village,
            size: 40,
            color: Theme.of(context).secondaryHeaderColor,
          ),
        ),

        SizedBox(
          height: ScreenSize.screenHeight(context) * 0.02,
          child: VerticalDivider(
            width: ScreenSize.screenWidth(context) * 0.01,
            thickness: 2.5,
          ),
        ),

        Padding(
          padding: const EdgeInsetsDirectional.fromSTEB(10, 5, 10, 10),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                '${accomodation.name ?? 'N/A'}',
                style: Theme.of(context).textTheme.headlineLarge,
              ),

              Row(
                children: [
                  const Text('CheckIn '),
                  Icon(
                    Icons.access_time_filled_outlined,
                    size: 20,
                    color: Theme.of(context).primaryColor,
                  ),

                  Text('${(accomodation.checkIn)?.day}' ?? 'N/A')

                ],
              )

            ],
          ),
        )
      ],
    );
  }
}
