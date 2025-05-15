import 'package:dima_project/models/tripModel.dart';
import 'package:dima_project/widgets/myBottomSheetHandle.dart';
import 'package:dima_project/widgets/trip_widgets/itineraryWidget.dart';
import 'package:dima_project/widgets/trip_widgets/tripExpensesWidget.dart';
import 'package:dima_project/screens/mapPage.dart';
import 'package:dima_project/widgets/trip_widgets/tripInfoWidget.dart';
import 'package:dima_project/screens/upsertTripPage.dart';
import 'package:dima_project/services/databaseService.dart';
import 'package:flutter/material.dart';
import '../services/googlePlacesService.dart';

class TripPage extends StatefulWidget {
  const TripPage({super.key, required this.trip, required this.isMyTrip});

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
    final imageUrl = _trip.imageRef != null
        ? GooglePlacesService().getImageUrl(_trip.imageRef!)
        : 'https://picsum.photos/800';

    return Scaffold(
      body: NestedScrollView(
        headerSliverBuilder: (context, innerBoxIsScrolled) => [
          SliverAppBar(
            expandedHeight: 250,
            pinned: true,
            floating: false,
            flexibleSpace: FlexibleSpaceBar(
              centerTitle: true,
              background: Stack(
                alignment: Alignment.center,
                fit: StackFit.expand,
                children: [
                  Image.network(
                    imageUrl,
                    fit: BoxFit.cover,
                  ),
                  Container(
                    color: Colors.black.withOpacity(0.2),
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
              ),
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
                    Tab(text: "Spese"),
                  ],
                ),
              ),
            ),
            actions: widget.isMyTrip
                ? [
                    IconButton(
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
            ItineraryWidget(trip: _trip, isMyTrip: widget.isMyTrip),
            TripInfoWidget(trip: _trip),
            TripExpensesWidget(
              tripId: _trip.id ?? '',
            ),
          ],
        ),
      ),
    );
  }

  void _showActions(BuildContext context) {
    showModalBottomSheet(
      context: context,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(20)),
      ),
      builder: (bottomSheetContext) => SafeArea(
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
              onTap: () {
                bool newPrivacy = !(_trip.isPrivate ?? true);
                try {
                  //update db
                  DatabaseService().updateTripPrivacy(_trip.id!, newPrivacy);
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
    );
  }

  Future<void> _handleDeleteTrip(BuildContext parentContext, BuildContext bottomSheetContext) async {
    Navigator.pop(bottomSheetContext); // Close the bottom sheet

    final shouldDelete = await showDialog<bool>(
      context: parentContext,
      builder: (dialogContext) => AlertDialog(
        title: const Text('Conferma eliminazione'),
        content: const Text('Vuoi eliminare questo viaggio?'),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(dialogContext, false),
            child: const Text('Annulla'),
          ),
          TextButton(
            onPressed: () => Navigator.pop(dialogContext, true),
            child: const Text(
              'Elimina',
              style: TextStyle(color: Colors.red),
            ),
          ),
        ],
      ),
    );

    if (shouldDelete == true) {
      await DatabaseService().deleteTrip(_trip.id!);

      if (parentContext.mounted) {
        Navigator.pop(parentContext); // Pop the TripPage

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
