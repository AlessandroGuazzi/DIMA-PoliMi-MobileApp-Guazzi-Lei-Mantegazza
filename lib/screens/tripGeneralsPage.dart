import 'package:dima_project/utils/screenSize.dart';
import 'package:flutter/material.dart';

class TripGeneralsPage extends StatelessWidget {
  const TripGeneralsPage({super.key});

  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        SizedBox(
            width: double.infinity,
            height: ScreenSize.screenHeight(context)* 0.2,
            child: ClipRRect(
              borderRadius: BorderRadius.circular(12),
              child: ShaderMask(
                shaderCallback: (Rect bounds) {
                  return const LinearGradient(
                    begin: Alignment.center,
                    end: Alignment.bottomCenter,
                    colors: [Colors.white, Colors.transparent],
                  ).createShader(bounds);
                },
                blendMode: BlendMode.dstIn,
                child: Padding(
                  padding: const EdgeInsets.all(8.0), // Mantiene il padding
                  child: ClipRRect(
                    borderRadius: BorderRadius.circular(12), // Arrotonda i bordi
                    child: Image.network(
                      'https://picsum.photos/200',
                      width: double.infinity, //TODO CAMBIARE
                      height: ScreenSize.screenHeight(context)* 0.2,
                      fit: BoxFit.cover,
                    ),
                  ),
                ),
              ),
            )
        ),

        Row(
          children: [
            Icon(Icons.face_2),
          ],
        ),

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