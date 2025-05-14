import 'package:flutter/material.dart';
import 'package:intl/intl.dart';

class TripProgressBar extends StatelessWidget {
  final DateTime startDate;
  final DateTime endDate;

  const TripProgressBar({
    super.key,
    required this.startDate,
    required this.endDate,
  });

  double _getProgress() {
    final now = DateTime.now();
    if (now.isBefore(startDate)) return 0.0;
    if (now.isAfter(endDate)) return 1.0;

    final total = endDate.difference(startDate).inMilliseconds;
    final elapsed = now.difference(startDate).inMilliseconds;
    return elapsed / total;
  }

  @override
  Widget build(BuildContext context) {
    return LayoutBuilder(
      builder: (context, constraints) {
        final progress = _getProgress();
        return Container(
          height: 24,
          decoration: BoxDecoration(
            color: Colors.grey[300],
            borderRadius: BorderRadius.circular(9),
          ),
          child: Stack(
            children: [
              FractionallySizedBox(
                widthFactor: progress.clamp(0.0, 1.0),
                child: Container(
                  decoration: BoxDecoration(
                    color: Colors.blue,
                    borderRadius: BorderRadius.circular(5),
                  ),
                ),
              ),
              Center(
                child: Text(
                  "${DateFormat('d MMM').format(startDate)}  -  ${DateFormat('d MMM').format(endDate)}",
                  style: const TextStyle(color: Colors.black),
                ),
              ),
            ],
          ),
        );
      },
    );
  }
}

