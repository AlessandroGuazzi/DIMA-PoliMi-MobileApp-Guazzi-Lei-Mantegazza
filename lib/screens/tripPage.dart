import 'package:dima_project/models/tripModel.dart';
import 'package:dima_project/utils/screenSize.dart';
import 'package:dima_project/widgets/components/myBottomSheetHandle.dart';
import 'package:dima_project/widgets/trip_widgets/itineraryWidget.dart';
import 'package:dima_project/widgets/trip_widgets/tripExpensesWidget.dart';
import 'package:dima_project/screens/mapPage.dart';
import 'package:dima_project/widgets/trip_widgets/tripInfoWidget.dart';
import 'package:dima_project/screens/upsertTripPage.dart';
import 'package:dima_project/services/databaseService.dart';
import 'package:flutter/material.dart';

import '../widgets/components/myConfirmDialog.dart';

class TripPage extends StatefulWidget {
  final DatabaseService databaseService;
  final VoidCallback? onTripDeleted;

  TripPage(
      {super.key,
      required this.trip,
      required this.isMyTrip,
      databaseService,
      this.onTripDeleted})
      : databaseService = databaseService ?? DatabaseService();

  final TripModel trip;
  final bool isMyTrip;

  @override
  State<TripPage> createState() => _TripPageState();
}

class _TripPageState extends State<TripPage> with TickerProviderStateMixin {
  late TabController _tabController;
  late TripModel _trip;

  @override
  void initState() {
    super.initState();
    _tabController = TabController(length: 3, vsync: this);
    _trip = widget.trip;
  }

  @override
  void didUpdateWidget(covariant TripPage oldWidget) {
    super.didUpdateWidget(oldWidget);
    if (oldWidget.trip != widget.trip) {
      setState(() {
        _trip = widget.trip;
      });
    }
  }

  @override
  void dispose() {
    _tabController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: NestedScrollView(
        headerSliverBuilder: (context, innerBoxIsScrolled) => [
          SliverAppBar(
            expandedHeight: 280,
            pinned: true,
            floating: false,
            forceElevated: innerBoxIsScrolled,
            flexibleSpace: FlexibleSpaceBar(
              background: _buildAppBarBackground(context),
            ),
            bottom: PreferredSize(
              preferredSize: const Size.fromHeight(48),
              child: Container(
                color: Theme.of(context).scaffoldBackgroundColor,
                child: TabBar(
                  controller: _tabController,
                  tabs: const [
                    Tab(text: "Itinerario"),
                    Tab(
                      text: 'Generale',
                    ),
                    Tab(key: Key('expensesTab'), text: "Spese"),
                  ],
                ),
              ),
            ),
            actions: widget.isMyTrip
                ? [
                    IconButton(
                      key: const Key('editButton'),
                      icon: const Icon(Icons.more_vert),
                      onPressed: () => _showActions(context),
                    ),
                  ]
                : null,
          ),
        ],
        body: TabBarView(
          controller: _tabController,
          children: [
            ItineraryWidget(
              trip: _trip,
              isMyTrip: widget.isMyTrip,
              databaseService: widget.databaseService,
            ),
            TripInfoWidget(
              trip: _trip,
              isMyTrip: widget.isMyTrip,
            ),
            TripExpensesWidget(
              tripId: _trip.id ?? '',
              databaseService: widget.databaseService,
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildAppBarBackground(BuildContext context) {
    return Stack(
      fit: StackFit.expand,
      children: [
        _loadTripImage(),
        Container(
          color: Colors.black.withValues(alpha: 0.2),
          alignment: Alignment.center,
          child: Text(
            _trip.title ?? 'No title',
            style: Theme.of(context)
                .textTheme
                .displayLarge
                ?.copyWith(color: Colors.white),
            textAlign: TextAlign.center,
          ),
        ),
      ],
    );
  }

  Widget _loadTripImage() {
    final imageUrl = widget.trip.imageRef;
    Widget image;
    if (imageUrl != null && imageUrl != '') {
      image = Image.network(
        widget.trip.imageRef!,
        fit: BoxFit.cover,
        errorBuilder:
            (BuildContext context, Object error, StackTrace? stackTrace) {
          print('Error builder fired ');
          return Image.asset('assets/placeholder_landscape.jpg',
              fit: BoxFit.cover);
        },
      );
    } else {
      image =
          Image.asset('assets/placeholder_landscape.jpg', fit: BoxFit.cover);
    }
    return image;
  }

  void _showActions(BuildContext context) {
    showModalBottomSheet(
      context: context,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(20)),
      ),
      builder: (bottomSheetContext) => SafeArea(
        child: SingleChildScrollView(
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              //handle
              const MyBottomSheetHandle(),
          
              ListTile(
                leading: const Icon(Icons.edit),
                title: const Text('Modifica'),
                onTap: () async {
                  Navigator.pop(context); // close the bottom sheet
                  final result = await Navigator.push(
                    context,
                    MaterialPageRoute(
                      builder: (context) => UpsertTripPage(
                        trip: _trip,
                        isUpdate: true,
                      ),
                    ),
                  );
                  //update ui trip
                  if (result != null) {
                    WidgetsBinding.instance.addPostFrameCallback((_) {
                      if (mounted) {
                        setState(() {
                          _trip = result;
                        });
                      }
                    });
                  }
                },
              ),
              ListTile(
                leading: const Icon(Icons.delete, color: Colors.red),
                title: const Text('Elimina'),
                onTap: () => _handleDeleteTrip(context, bottomSheetContext),
              ),
          
              ListTile(
                leading: const Icon(Icons.map_outlined),
                title: const Text('Apri mappa'),
                onTap: () {
                  Navigator.pop(context);
                  Navigator.push(
                    context,
                    MaterialPageRoute(
                      builder: (context) => MapPage(trip: _trip),
                    ),
                  );
                },
              ),
          
              ListTile(
                leading: _trip.isPrivate ?? true
                    ? const Icon(Icons.share)
                    : const Icon(Icons.lock_outline),
                title: _trip.isPrivate ?? true
                    ? const Text('Pubblica')
                    : const Text('Rendi privato'),
                onTap: () async {
                  bool newPrivacy = !(_trip.isPrivate ?? true);
                  try {
                    //update db
                    await widget.databaseService
                        .updateTripPrivacy(_trip.id!, newPrivacy);
                    //update locally
                    setState(() {
                      _trip.isPrivate = newPrivacy;
                    });
                    Navigator.pop(bottomSheetContext);
                  } on Exception catch (e) {
                    showDialog(
                      context: context,
                      builder: (context) => AlertDialog(
                        title: const Text('Errore'),
                        content: const Text('Impossibile aggiornare'),
                        actions: [
                          TextButton(
                            onPressed: () => Navigator.pop(context),
                            child: const Text('OK'),
                          ),
                        ],
                      ),
                    );
                  }
                },
              ),
            ],
          ),
        ),
      ),
    );
  }

  Future<void> _handleDeleteTrip(
      BuildContext parentContext, BuildContext bottomSheetContext) async {
    Navigator.pop(bottomSheetContext);

    final shouldDelete = await showDialog<bool>(
      context: context,
      builder: (_) => MyConfirmDialog(
        key: const Key('deleteTripDialog'),
        icon: Icons.delete_forever_rounded,
        iconColor: Theme.of(context).colorScheme.error,
        title: 'Conferma Eliminazione',
        message: 'Vuoi davvero eliminare questo viaggio?',
        confirmText: 'Elimina',
        cancelText: 'Annulla',
        onConfirm: () => Navigator.pop(context, true),
      ),
    );

    if (shouldDelete == true) {
      await widget.databaseService.deleteTrip(_trip.id!);

      if (parentContext.mounted) {
        if (ScreenSize.isTablet(parentContext)) {
          //callback to notify parent
          if (widget.onTripDeleted != null) widget.onTripDeleted!();
        } else {
          Navigator.pop(parentContext); // Pop the TripPage
        }

        // Show confirmation SnackBar after popping
        Future.delayed(const Duration(milliseconds: 100), () {
          ScaffoldMessenger.of(parentContext).showSnackBar(
            const SnackBar(
              content: Text('Viaggio eliminato con successo'),
              behavior: SnackBarBehavior.floating,
            ),
          );
        });
      }
    }
  }
}
