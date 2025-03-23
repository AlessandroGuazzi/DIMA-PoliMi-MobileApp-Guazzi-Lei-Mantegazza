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
    return Padding(
      padding: const EdgeInsets.all(16),
      child: Material(
        color: Colors.transparent,
        elevation: 2,
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(15),
        ),
        child: Container(
          width: double.infinity,
          decoration: BoxDecoration(
            color: Colors.white,
            boxShadow: const [
              BoxShadow(
                blurRadius: 4,
                color: Color(0x1A000000),
                offset: Offset(0, 2),
              )
            ],
            borderRadius: BorderRadius.circular(15),
          ),
          child: Padding(
            padding: const EdgeInsets.all(16),
            child: Column(
              mainAxisSize: MainAxisSize.max,
              children: [
                Padding(
                  padding: const EdgeInsets.only(bottom: 8),
                  child: Row(
                    mainAxisSize: MainAxisSize.max,
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      Text(
                        title,
                        style: const TextStyle(
                          fontFamily: 'Inter Tight',
                          letterSpacing: 0.0,
                          fontWeight: FontWeight.w600,
                          fontSize: 18,
                        ),
                      ),
                      Text(
                        progress,
                        style: TextStyle(
                          fontFamily: 'Inter Tight',
                          color: Theme.of(context).primaryColor,
                          letterSpacing: 0.0,
                          fontWeight: FontWeight.w600,
                          fontSize: 18,
                        ),
                      ),
                    ],
                  ),
                ),
                LinearPercentIndicator(
                  percent: percent,
                  lineHeight: 8,
                  animation: true,
                  animateFromLastPercent: true,
                  progressColor: Theme.of(context).primaryColor,
                  backgroundColor: Colors.grey[300]!,
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}