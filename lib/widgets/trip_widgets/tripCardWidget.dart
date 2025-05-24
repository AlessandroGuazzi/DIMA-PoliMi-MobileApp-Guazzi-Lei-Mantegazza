import 'package:dima_project/screens/profilePage.dart';
import 'package:dima_project/services/googlePlacesService.dart';
import 'package:dima_project/utils/screenSize.dart';
import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'package:dima_project/screens/medalsPage.dart';

import '../../models/tripModel.dart';

class TripCardWidget extends StatefulWidget {
  final TripModel trip;
  final bool isSaved;
  final Function(bool, String) onSave; // Callback to update ExplorerPage
  final bool isHome;

  const TripCardWidget(this.trip, this.isSaved, this.onSave, this.isHome,
      {super.key});

  @override
  State<TripCardWidget> createState() => _TripCardWidgetState();
}

class _TripCardWidgetState extends State<TripCardWidget> {
  @override
  Widget build(BuildContext context) {
    if (widget.isHome) {
      return _homeCardWidget();
    } else {
      return _explorerCardWidget();
    }
  }

  Widget _homeCardWidget() {
    DateTime startDate = widget.trip.startDate ?? DateTime.now();
    String startDateFormat = DateFormat('dd MMM yyyy').format(startDate);

    DateTime endDate = widget.trip.endDate ?? DateTime.now();
    String endDateFormat = DateFormat('dd MMM yyyy').format(endDate);

    return Padding(
      padding: const EdgeInsets.only(left: 5, right: 5),
      child: Card(
        color: Theme.of(context).cardColor,
        elevation: 1,
        child: Padding(
          padding: const EdgeInsets.all(8),
          child: Row(
            mainAxisSize: MainAxisSize.max,
            mainAxisAlignment: MainAxisAlignment.center,
            crossAxisAlignment: CrossAxisAlignment.center,
            children: [
              //--- trip-profile pic ---
            ClipRRect(
              borderRadius: BorderRadius.circular(12),
              child: Image.network(
                widget.trip.imageRef != null
                    ? GooglePlacesService().getImageUrl(widget.trip.imageRef!)
                    : 'https://picsum.photos/800',
                height: 100,
                width: 100,
                fit: BoxFit.cover,
              ),
            ),

              const SizedBox(width: 8),

              //--- trip details text ---
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      widget.trip.title ?? 'Titolo mancante',
                      style: Theme.of(context).textTheme.headlineMedium,
                    ),
                    const SizedBox(height: 6),
                    Row(
                      children: [
                        const Icon(Icons.calendar_today),
                        const SizedBox(width: 6),
                        Expanded(
                          child: Text(
                            '$startDateFormat - $endDateFormat',
                            overflow: TextOverflow.ellipsis,
                            style: Theme.of(context).textTheme.bodyMedium,
                          ),
                        ),
                      ],
                    ),
                    const SizedBox(height: 6),
                    Row(
                      children: [
                        const Icon(Icons.public),
                        const SizedBox(width: 6),
                        Text(
                          _displayCityNames(),
                          style: Theme.of(context).textTheme.bodyMedium,
                          softWrap: true,
                        )
                      ],
                    ),
                  ],
                ),
              ),

              const SizedBox(width: 8),
              const Icon(Icons.arrow_forward_ios),
            ],
          ),
        ),
      ),
    );
  }

  Widget _explorerCardWidget() {
    return Container(
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(10),
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
                      widget.trip.imageRef != null
                          ? GooglePlacesService()
                              .getImageUrl(widget.trip.imageRef!)
                          : 'https://picsum.photos/800',
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
                    style: Theme.of(context).textTheme.headlineLarge,
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
                    Expanded(
                      child: Wrap(spacing: 4, runSpacing: 4, children: [
                        Text(
                          _displayCityNames(),
                          style: Theme.of(context).textTheme.bodyLarge,
                          softWrap: true,
                        )
                      ]),
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
                              GestureDetector(
                                onTap: () {
                                  _goToProfilePage();
                                },
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
                                      '@${widget.trip.creatorInfo!['username'] ?? 'user'} · ${getTimePassed(widget.trip.timestamp?.toDate() ?? DateTime.now())}',
                                      style:
                                          Theme.of(context).textTheme.bodySmall,
                                    ),
                                    const SizedBox(
                                      width: 4,
                                    ),
                                  ],
                                ),
                              ),
                            ],
                          ),
                        ),
                        Row(
                          children: [
                            Text('${widget.trip.saveCounter ?? 'na'}'),
                            IconButton(
                                onPressed: () {
                                  _handleSaveButton();
                                },
                                icon: widget.isSaved
                                    ? Icon(
                                        Icons.bookmark_added_rounded,
                                        color: Theme.of(context).primaryColor,
                                      )
                                    : Icon(Icons.bookmark_add_outlined)),
                          ],
                        ),
                      ]),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }

  void _handleSaveButton() async {
    String tripId = widget.trip.id ?? 'null';
    widget.onSave(widget.isSaved, tripId); //notify parent
  }

  void _goToProfilePage() {
    Navigator.push(
      context,
      MaterialPageRoute(
          builder: (context) =>
              MedalsPage(username: widget.trip.creatorInfo!["username"], userId: widget.trip.creatorInfo!["id"])),
    );
  }

  String getTimePassed(DateTime postTimestamp) {
    final now = DateTime.now();
    final difference = now.difference(postTimestamp);

    if (difference.inSeconds < 60) {
      return '${difference.inSeconds} sec fa';
    } else if (difference.inMinutes < 60) {
      return '${difference.inMinutes} min fa';
    } else if (difference.inHours < 24) {
      return '${difference.inHours} ore fa';
    } else {
      return '${difference.inDays} giorni fa';
    }
  }

  String _displayCityNames() {
    if (widget.trip.cities != null && widget.trip.cities!.isNotEmpty) {
      final cities = widget.trip.cities!;
      if (cities.length > 1) {
        String result =
            cities.take(2).map((c) => c['name']).toList().join(' · ');
        final moreCount = cities.length - 2;
        if (moreCount > 0) {
          result += ' + $moreCount';
        }
        return result;
      } else {
        return cities.first['name'];
      }
    } else {
      return 'Nessun Luogo';
    }
  }
}
