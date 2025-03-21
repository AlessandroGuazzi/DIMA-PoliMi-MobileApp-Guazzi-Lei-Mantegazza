import 'package:dima_project/services/databaseService.dart';
import 'package:flutter/material.dart';

import '../models/tripModel.dart';

class TripCardWidget extends StatefulWidget {
  final TripModel trip;
  final bool isSaved;
  final Function(bool, String) onSave; // Callback to update ExplorerPage


  const TripCardWidget(this.trip, this.isSaved, {required this.onSave, super.key});

  @override
  State<TripCardWidget> createState() => _TripCardWidgetState();
}

class _TripCardWidgetState extends State<TripCardWidget> {

  void _handleSaveButton () async {
    String tripId = widget.trip.id ?? 'null';
    widget.onSave(widget.isSaved, tripId); //notify parent
  }

  @override
  Widget build(BuildContext context) {
    return Container(
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(12),
      ),
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          mainAxisSize: MainAxisSize.max,
          children: [
            SizedBox(
                width: double.infinity,
                height: 200,
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
                    child: Image.network(
                      'https://picsum.photos/2000',
                      width: double.infinity,
                      fit: BoxFit.cover,
                    ),
                  ),
                )),
            Padding(
              padding: const EdgeInsetsDirectional.fromSTEB(16, 5, 16, 16),
              child: Column(
                mainAxisSize: MainAxisSize.max,
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    '${widget.trip.title}',
                    style: Theme.of(context).textTheme.headlineMedium,
                  ),
                  const SizedBox(height: 4),
                  Row(mainAxisSize: MainAxisSize.max, children: [
                    Icon(
                      Icons.place,
                      size: 20,
                      color: Theme.of(context).primaryColor,
                    ),
                    const SizedBox(
                      width: 4,
                    ),
                    Text(
                      widget.trip.cities?.join(' · ') ?? ' ',
                      style: Theme.of(context).textTheme.bodyLarge,
                    ),
                  ]),
                  const SizedBox(
                    height: 4,
                  ),
                  Row(
                      mainAxisSize: MainAxisSize.max,
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        //profile Image
                        Container(
                          child: Row(
                            children: [
                              ClipOval(
                                child: Image.network(
                                  //placeholder image
                                  'https://picsum.photos/30',
                                  width: 30,
                                  height: 30,
                                  fit: BoxFit.cover,
                                ),
                              ),
                              const SizedBox(
                                width: 4,
                              ),
                              //username
                              Text(
                                '@${widget.trip.creatorInfo!['username'] ?? 'user'}',
                                style: Theme.of(context).textTheme.bodySmall,
                              ),
                            ],
                          ),
                        ),
                        IconButton(
                            onPressed: () {
                              _handleSaveButton();
                            },
                            icon: widget.isSaved
                                ? Icon(Icons.favorite, color: Theme.of(context).primaryColor,)
                                : Icon(Icons.favorite_border)),
                      ]),
                  //space for icons
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }
}
