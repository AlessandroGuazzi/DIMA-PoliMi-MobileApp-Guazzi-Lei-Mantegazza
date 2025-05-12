import 'package:add_2_calendar/add_2_calendar.dart';
import 'package:dima_project/utils/screenSize.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:intl/intl.dart';

import '../models/tripModel.dart';
import 'mapPage.dart';

class TripInfoPage extends StatefulWidget {
  final TripModel trip;

  const TripInfoPage({super.key, required this.trip});

  @override
  State<TripInfoPage> createState() => _TripInfoPageState();
}

class _TripInfoPageState extends State<TripInfoPage> {
  @override
  Widget build(BuildContext context) {
    final start = widget.trip.startDate!;
    final end = widget.trip.endDate!;
    final now = DateTime.now();

    final durationDays = end.difference(start).inDays + 1;
    final daysUntilStart = start.difference(now).inDays;

    String statusText;
    if (now.isAfter(end)) {
      statusText = 'Viaggio concluso';
    } else if (now.isBefore(start)) {
      statusText = 'Inizia tra $daysUntilStart giorni';
    } else {
      final currentDay = now.difference(start).inDays + 1;
      statusText = 'Giorno $currentDay di $durationDays';
    }

    return SingleChildScrollView(
      child: Card(
        color: Theme.of(context).cardColor,
        elevation: 2,
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
        margin: const EdgeInsets.all(12),
        child: Padding(
          padding: const EdgeInsets.only(left: 16, right: 16, bottom: 16),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            mainAxisAlignment: MainAxisAlignment.start,
            children: [
              ListTile(
                contentPadding: EdgeInsets.zero,
                title: Text(
                  'Il tuo viaggio',
                  style: Theme.of(context).textTheme.headlineMedium,
                ),
                subtitle: Text(
                  'Panoramica del tuo viaggio',
                  style: Theme.of(context).textTheme.bodyMedium,
                ),
              ),
              Divider(),
              _buildInfoRow(context, Icons.explore, 'Dove',
                  Theme.of(context).textTheme.headlineMedium!, 30),
              const SizedBox(height: 8),
              Padding(
                padding: const EdgeInsets.only(left: 10),
                child: Column(
                  children: [
                    _buildInfoRow(
                        context,
                        Icons.flag,
                        widget.trip.nations!.map((c) => c['name']).join(' · '),
                        Theme.of(context).textTheme.bodyMedium!, 20),
                    const SizedBox(height: 8),
                    _buildInfoRow(
                        context,
                        Icons.location_city,
                        widget.trip.cities!.map((c) => c['name']).join(' · '),
                        Theme.of(context).textTheme.bodyMedium!, 20),
                  ],
                ),
              ),
              const SizedBox(height: 8),
              ElevatedButton(
                  onPressed: () {
                    Navigator.push(
                      context,
                      MaterialPageRoute(
                        builder: (context) => MapPage(trip: widget.trip),
                      ),
                    );
                  },
                  child: Row(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      Text('Apri mappa'),
                      const SizedBox(width: 8),
                      Icon(Icons.map),
                    ],
                  )),
              Divider(
                height: 30,
              ),
              _buildInfoRow(context, Icons.event, 'Quando',
                  Theme.of(context).textTheme.headlineMedium!, 30),
              const SizedBox(height: 8),
              Padding(
                padding: const EdgeInsets.only(left: 10),
                child: Column(
                  children: [
                    _buildInfoRow(
                      context,
                      Icons.date_range,
                      '${DateFormat('dd MMM yyyy').format(start)} - ${DateFormat('dd MMM yyyy').format(end)}',
                      Theme.of(context).textTheme.bodyMedium!,
                      20
                    ),
                    const SizedBox(height: 8),
                    _buildInfoRow(
                        context,
                        Icons.schedule,
                        '$durationDays giorni • $statusText',
                        Theme.of(context).textTheme.bodyMedium!, 20),
                  ],
                ),
              ),
              const SizedBox(height: 8),
              ElevatedButton(
                onPressed: () {
                  Add2Calendar.addEvent2Cal(_buildEvent());
                },
                child: Row(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    Text('Aggiungi al calendario'),
                    const SizedBox(width: 8),
                    Icon(Icons.calendar_month),
                  ],
                )
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildInfoRow(
      BuildContext context, IconData icon, String text, TextStyle style, double iconSize) {
    return Row(
      crossAxisAlignment: CrossAxisAlignment.center,
      mainAxisAlignment: MainAxisAlignment.start,
      children: [
        Icon(icon, size: iconSize),
        const SizedBox(width: 10),
        Expanded(
          child: Text(
            text,
            style: style,
            softWrap: true,
          ),
        ),
      ],
    );
  }

  Event _buildEvent() {
    final trip = widget.trip;

    return Event(
      title: 'Viaggio a ${trip.nations!.map((c) => '${c['name']} ${c['flag']}').join(', ')}',
      description: 'Il mio viaggio con Simply Travel',
      location: trip.cities!.map((c) => c['name']).join(', '),
      startDate: trip.startDate!,
      endDate: trip.endDate!.add(const Duration(days: 1)),
      // Inclusive
      allDay: true,
    );
  }
}
