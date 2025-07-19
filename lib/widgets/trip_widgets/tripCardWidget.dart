import 'package:dima_project/services/googlePlacesService.dart';
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
  void initState() {
    super.initState();
  }

  @override
  Widget build(BuildContext context) {
    if (widget.isHome) {
      return _homeCardWidget();
    } else {
      return _explorerCardWidget();
    }
  }

  Widget _homeCardWidget() {
    DateTime? startDate = widget.trip.startDate;
    String startDateFormat;
    if (startDate != null) {
      startDateFormat = DateFormat('dd MMM yyyy').format(startDate);
    } else {
      startDateFormat = 'No data';
    }

    DateTime? endDate = widget.trip.endDate;
    String endDateFormat;
    if (endDate != null) {
      endDateFormat = DateFormat('dd MMM yyyy').format(endDate);
    } else {
      endDateFormat = 'No data';
    }

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
                child: _loadTripImage(100, 100),
                /*
                child: widget.trip.imageRef != null
                //TODO: fix image ref
                    ? Image.network(
                        GooglePlacesService()
                            .getImageUrl(widget.trip.imageRef ?? ''),
                        height: 100,
                        width: 100,
                        fit: BoxFit.cover,
                      )
                    : Image.asset(
                        'assets/placeholder_landscape.jpg',
                        height: 100,
                        width: 100,
                        fit: BoxFit.cover,
                      ),

                 */
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
                        Expanded(
                          child: Text(
                            _displayCityNames(),
                            style: Theme.of(context).textTheme.bodyMedium,
                            softWrap: true,
                            overflow: TextOverflow.ellipsis,
                          ),
                        )
                      ],
                    ),
                  ],
                ),
              ),

              const SizedBox(width: 8),
              Icon(
                Icons.arrow_forward_ios,
                color: Theme.of(context).secondaryHeaderColor,
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _explorerCardWidget() {
    return Card(
      key: Key('tripCard_${widget.trip.id}'),
      elevation: 0,
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
                    child: _loadTripImage(null, null),
                    /*
                    child: widget.trip.imageRef == null
                    //TODO: fix image ref

                        ? Image.network(
                            GooglePlacesService()
                                .getImageUrl(widget.trip.imageRef ?? ''),
                            width: double.infinity,
                            fit: BoxFit.cover,
                          )
                        : Image.asset(
                            'assets/placeholder_landscape.jpg',
                            width: double.infinity,
                            fit: BoxFit.cover,
                          ),
                    */
                  ),
                )),
            Padding(
              padding: const EdgeInsetsDirectional.fromSTEB(16, 5, 16, 16),
              child: Column(
                mainAxisSize: MainAxisSize.max,
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    widget.trip.title ?? 'Titolo mancante',
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
                    crossAxisAlignment: CrossAxisAlignment.center,
                    children: [
                      //profile image and username
                      Expanded(
                        child: GestureDetector(
                          onTap: _goToProfilePage,
                          child: Row(
                            children: [
                              CircleAvatar(
                                radius: 15,
                                backgroundImage: widget
                                            .trip.creatorInfo?['profilePic'] !=
                                        null
                                    ? AssetImage(
                                        widget.trip.creatorInfo!['profilePic'])
                                    : const AssetImage('assets/profile.png'),
                              ),
                              const SizedBox(width: 4),
                              Expanded(
                                child: Text(
                                  '@${widget.trip.creatorInfo?['username'] ?? 'no_username'} · ${getTimePassed(widget.trip.timestamp?.toDate())}',
                                  style: Theme.of(context).textTheme.bodySmall,
                                  overflow: TextOverflow.ellipsis,
                                ),
                              ),
                            ],
                          ),
                        ),
                      ),

                      //save counter and icon
                      Row(
                        mainAxisSize: MainAxisSize.min,
                        children: [
                          Text(
                            '${widget.trip.saveCounter ?? 'na'}',
                            key: Key('saveCounter_${widget.trip.id}'),
                          ),
                          IconButton(
                            key: Key('saveButton_${widget.trip.id}'),
                            onPressed: _handleSaveButton,
                            icon: widget.isSaved
                                ? Icon(
                              Icons.bookmark_added_rounded,
                              color: Theme.of(context).primaryColor,
                            )
                                : const Icon(Icons.bookmark_add_outlined),
                          ),
                        ],
                      ),
                    ],
                  ),
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
          builder: (context) => MedalsPage(
              username: widget.trip.creatorInfo!["username"],
              userId: widget.trip.creatorInfo!["id"])),
    );
  }

  String getTimePassed(DateTime? postTimestamp) {
    if (postTimestamp == null) return 'no_time';

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

  Widget _loadTripImage(double? height, double? width) {
    final imageUrl = widget.trip.imageRef;
    Widget image;
    if (imageUrl != null && imageUrl != '') {
      image = Image.network(
        widget.trip.imageRef!,
        height: height,
        width: width,
        fit: BoxFit.cover,
        errorBuilder:
            (BuildContext context, Object error, StackTrace? stackTrace) {
          return Image.asset('assets/placeholder_landscape.jpg',
              height: height, width: width, fit: BoxFit.cover);
        },
      );
    } else {
      image = Image.asset('assets/placeholder_landscape.jpg',
          height: height, width: width, fit: BoxFit.cover);
    }
    return image;
  }
}
