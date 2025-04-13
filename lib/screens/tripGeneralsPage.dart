import 'package:dima_project/models/tripModel.dart';
import 'package:dima_project/services/databaseService.dart';
import 'package:dima_project/utils/screenSize.dart';
import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'package:pie_chart/pie_chart.dart';

class TripGeneralsPage extends StatefulWidget {
  const TripGeneralsPage({super.key, required this.tripId});

  final String tripId;

  @override
  State<TripGeneralsPage> createState() => _TripGeneralsPageState();
}

class _TripGeneralsPageState extends State<TripGeneralsPage> {

  late Future<TripModel> trip;

  late num totalCost;

  @override
  void initState() {
    super.initState();
    trip = DatabaseService().loadTrip(widget.tripId);
  }


  @override
  Widget build(BuildContext context) {
    return FutureBuilder<TripModel?>(
      future: trip, // your Future<TripModel?> from initState
      builder: (context, snapshot) {
        if (snapshot.connectionState == ConnectionState.waiting) {
          return const Center(child: CircularProgressIndicator());
        }
        if (!snapshot.hasData || snapshot.data == null) {
          return const Center(child: Text('Trip not found.'));
        }

        final tripData = snapshot.data!;

        final flightExpense = (tripData.expenses?['flight'] as num?)?.toDouble() ?? 0.0;
        final accommodationExpense = (tripData.expenses?['accommodation'] as num?)?.toDouble() ?? 0.0;
        final attractionExpense = (tripData.expenses?['attraction'] as num?)?.toDouble() ?? 0.0;
        final transportExpense = (tripData.expenses?['transport'] as num?)?.toDouble() ?? 0.0;
        totalCost = flightExpense + attractionExpense + accommodationExpense + transportExpense;


        Map<String, double> dataMap = {
          "Flight": flightExpense,
          "Attractions": attractionExpense,
          "Transport": transportExpense,
          "Hotel": accommodationExpense,
        };

        final colorList = <Color>[
          Colors.orange.shade400,
          Colors.blue.shade400,
          Colors.indigo.shade900,
          Colors.red.shade300,
        ];

        return SingleChildScrollView(
          child: Column(
            children: [
              Container(
                margin: const EdgeInsets.all(12),
                decoration: BoxDecoration(
                  borderRadius: BorderRadius.circular(16),
                  color: Colors.white, // o Theme.of(context).cardColor
                  boxShadow: const [
                    BoxShadow(
                      color: Colors.black12,
                      blurRadius: 6,
                      offset: Offset(0, 3),
                    ),
                  ],
                ),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    ClipRRect(
                      borderRadius: const BorderRadius.only(
                        topLeft: Radius.circular(16),
                        topRight: Radius.circular(16),
                      ),
                      child: Image.network(
                        'https://picsum.photos/200',
                        width: double.infinity,
                        height: ScreenSize.screenHeight(context) * 0.23,
                        fit: BoxFit.cover,
                      ),
                    ),
                    Padding(
                      padding: const EdgeInsets.all(12.0),
                      child: Row(
                        children: [
                          const Icon(Icons.calendar_month, size: 20),
                          const SizedBox(width: 8),
                          Text(
                            "${DateFormat('d MMM').format(tripData.startDate!)} - ${DateFormat('d MMM').format(tripData.endDate!)}   Year: ${tripData.startDate!.year}",
                            style: Theme.of(context).textTheme.bodyLarge,
                          ),
                        ],
                      ),
                    ),
                  ],
                ),
              ),


              const SizedBox(height: 10),

              // Dashboard Section
              Padding(
                padding: const EdgeInsets.symmetric(horizontal: 16.0),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
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
                          const SizedBox(height: 22),

                          PieChart(
                            dataMap: dataMap,
                            chartRadius: MediaQuery.of(context).size.width * 0.45,
                            centerText: "$totalCost €",
                            centerTextStyle: const TextStyle(
                              fontSize: 17, // 👈 imposta la dimensione del testo
                              fontWeight: FontWeight.bold,
                              color: Colors.black,
                            ),
                            chartType: ChartType.ring,
                            colorList: colorList,
                            ringStrokeWidth: 35,
                            legendOptions: const LegendOptions(showLegends: false),
                            chartValuesOptions: const ChartValuesOptions(showChartValues: false),
                          ),
                          const SizedBox(height: 25),

                          Column(
                            children: List.generate(dataMap.length, (index) {
                              final entry = dataMap.entries.elementAt(index);
                              final color = colorList[index];
                              final label = entry.key;
                              final value = entry.value;

                              return Padding(
                                padding: const EdgeInsets.symmetric(vertical: 4.0, horizontal: 12),
                                child: Row(
                                  children: [
                                    Container(
                                      width: 16,
                                      height: 16,
                                      decoration: BoxDecoration(
                                        color: color,
                                        shape: BoxShape.circle,
                                      ),
                                    ),
                                    const SizedBox(width: 8),
                                    Expanded(
                                      child: Text(
                                        label,
                                        style: const TextStyle(fontSize: 16),
                                      ),
                                    ),
                                    Text(
                                      '${value.toStringAsFixed(0)}€ (${(totalCost > 0 ? (value / totalCost) * 100 : 0).toStringAsFixed(0)}%)',
                                      style: const TextStyle(fontSize: 16, fontWeight: FontWeight.w600),
                                    ),
                                  ],
                                ),
                              );
                            }),
                          ),

                        ],
                      ),
                    ),
                    const SizedBox(height: 16),

                  ],
                ),
              ),
            ],
          ),
        );
      },
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