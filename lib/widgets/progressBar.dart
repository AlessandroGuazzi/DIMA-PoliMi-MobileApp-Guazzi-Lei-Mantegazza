import 'package:flutter/material.dart';
import 'package:percent_indicator/linear_percent_indicator.dart';

class ProgressItem extends StatelessWidget {
  final String title;
  final String progress;
  final double percent;

  const ProgressItem({
    super.key,
    required this.title,
    required this.progress,
    required this.percent,
  });

  @override
  Widget build(BuildContext context) {
    return Card(
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Center(
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              Flexible(
                child: Padding(
                  padding: const EdgeInsets.only(bottom: 8),
                  child: Row(
                    mainAxisSize: MainAxisSize.max,
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      Expanded(
                        child: Text(
                          title,
                          overflow: TextOverflow.ellipsis,
                          style: Theme.of(context).textTheme.headlineSmall?.copyWith(fontWeight: FontWeight.bold)
                        ),
                      ),
                      Text(
                        progress,
                        style: Theme.of(context).textTheme.bodyLarge?.copyWith(color: Theme.of(context).primaryColor, fontWeight: FontWeight.bold)
                      ),
                    ],
                  ),
                ),
              ),
              LinearPercentIndicator(
                percent: percent,
                lineHeight: 8,
                animation: true,
                animateFromLastPercent: true,
                progressColor: Theme.of(context).primaryColor,
                backgroundColor: Theme.of(context).dividerColor,
              ),
            ],
          ),
        ),
      ),
    );
  }
}