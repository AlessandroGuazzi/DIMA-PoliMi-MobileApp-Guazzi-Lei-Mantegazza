import 'package:dima_project/models/tripModel.dart';
import 'package:dima_project/utils/screenSize.dart';
import 'package:flutter/material.dart';
import 'package:intl/intl.dart';

class TripGeneralsPage extends StatefulWidget {
  const TripGeneralsPage({super.key, required this.trip});

  final TripModel trip;

  @override
  State<TripGeneralsPage> createState() => _TripGeneralsPageState();
}

class _TripGeneralsPageState extends State<TripGeneralsPage> {
  @override
  Widget build(BuildContext context) {
    return SingleChildScrollView(
      child: Column(
        children: [
          SizedBox(
            width: double.infinity,
            height: ScreenSize.screenHeight(context) * 0.2,
            child: ClipRRect(
              borderRadius: BorderRadius.circular(12),
              child: Padding(
                padding: const EdgeInsets.all(8.0),
                child: ClipRRect(
                  borderRadius: BorderRadius.circular(12),
                  child: Image.network(
                    'https://picsum.photos/200',
                    width: double.infinity,
                    height: ScreenSize.screenHeight(context) * 0.2,
                    fit: BoxFit.cover,
                  ),
                ),
              ),
            ),
          ),

          const SizedBox(height: 10),

          // Dashboard Section
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 16.0),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [

                Row(
                  children: [
                    Icon(Icons.calendar_month),
                    const SizedBox(width: 10),
                    Text(
                      "${DateFormat('d MMM').format(widget.trip.startDate!)} - ${DateFormat('d MMM').format(widget.trip.endDate!)}",
                      style: Theme.of(context).textTheme.bodyMedium,
                    ),
                  ],
                ),

                const SizedBox(height: 16),

                // --- Cost Summary ---
                Container(
                  decoration: BoxDecoration(
                    color: Colors.black12,
                    borderRadius: BorderRadius.circular(16),
                  ),
                  padding: const EdgeInsets.all(16),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      const Text(
                        'Cost Summary',
                        style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
                      ),
                      const Text('An overview of your expenses.'),
                      const SizedBox(height: 16),
                      Row(
                        mainAxisAlignment: MainAxisAlignment.spaceAround,
                        children: [
                          _circularIndicator("Total Cost", 0.23, Colors.orange),
                          _circularIndicator("Course Grade", 0.93, Colors.blue),
                        ],
                      ),
                    ],
                  ),
                ),
                const SizedBox(height: 16),

                // --- Active Users ---
                Container(
                  decoration: BoxDecoration(
                    color: Colors.pinkAccent,
                    borderRadius: BorderRadius.circular(16),
                  ),
                  padding: const EdgeInsets.all(16),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      const Text(
                        'Active Users',
                        style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold, color: Colors.white),
                      ),
                      const Text(
                        'A small summary of your users base',
                        style: TextStyle(color: Colors.white70),
                      ),
                      const SizedBox(height: 16),
                      ClipRRect(
                        borderRadius: BorderRadius.circular(12),
                        child: LinearProgressIndicator(
                          value: 0.6,
                          color: Colors.white,
                          backgroundColor: Colors.white24,
                          minHeight: 12,
                        ),
                      ),
                    ],
                  ),
                ),
                const SizedBox(height: 16),

                // --- Total Users ---
                Container(
                  decoration: BoxDecoration(
                    color: Colors.black12,
                    borderRadius: BorderRadius.circular(16),
                  ),
                  padding: const EdgeInsets.all(16),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: const [
                      Text(
                        'Total User Count',
                        style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
                      ),
                      Text('An overview of all your users on your platform.'),
                      SizedBox(height: 12),
                      Text(
                        '56.4k',
                        style: TextStyle(fontSize: 32, fontWeight: FontWeight.bold),
                      ),
                    ],
                  ),
                ),
                const SizedBox(height: 32),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _circularIndicator(String label, double value, Color color) {
    return Column(
      children: [
        Stack(
          alignment: Alignment.center,
          children: [
            SizedBox(
              height: 80,
              width: 80,
              child: CircularProgressIndicator(
                value: value,
                color: color,
                backgroundColor: Colors.grey[800],
                strokeWidth: 8,
              ),
            ),
            Text('${(value * 100).round()}%',
                style: const TextStyle(fontWeight: FontWeight.bold)),
          ],
        ),
        const SizedBox(height: 8),
        Text(label),
      ],
    );
  }
}


/*
Row(
                        children: [
                          Icon(
                            Icons.place,
                            size: 20,
                            color: Theme.of(context).primaryColor,
                          ),
                          Text(
                            widget.trip.cities?.join(' - ') ?? 'No cities available',
                            style: Theme.of(context).textTheme.bodyLarge,
                          ),
                        ],
                      ),
 */