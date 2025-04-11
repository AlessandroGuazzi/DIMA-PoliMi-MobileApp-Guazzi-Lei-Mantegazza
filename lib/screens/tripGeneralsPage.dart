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

        Map<String, double> dataMap = {
          "Flight": 42,
          "Shopping": 20,
          "Transport": 9,
          "Hotel": 23,
          "Food": 18,
        };

        final colorList = <Color>[
          Colors.orange.shade400,
          Colors.blue.shade400,
          Colors.indigo.shade900,
          Colors.red.shade300,
          Colors.orange.shade800,
        ];

        return SingleChildScrollView(
          child: Column(
            children: [
              SizedBox(
                width: double.infinity,
                height: ScreenSize.screenHeight(context) * 0.2,
                child: ClipRRect(
                  borderRadius: BorderRadius.circular(12),
                  child: Padding(
                    padding: const EdgeInsets.all(8.0),
                    child: ClipRRect(
                      borderRadius: BorderRadius.circular(12),
                      child: Image.network(
                        'https://picsum.photos/200',
                        width: double.infinity,
                        height: ScreenSize.screenHeight(context) * 0.2,
                        fit: BoxFit.cover,
                      ),
                    ),
                  ),
                ),
              ),

              const SizedBox(height: 10),

              // Dashboard Section
              Padding(
                padding: const EdgeInsets.symmetric(horizontal: 16.0),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Row(
                      children: [
                        const Icon(Icons.calendar_month),
                        const SizedBox(width: 10),
                        Text(
                          "${DateFormat('d MMM').format(tripData.startDate!)} - ${DateFormat('d MMM').format(tripData.endDate!)}   Year: ${tripData.startDate!.year}",
                          style: Theme.of(context).textTheme.bodyLarge,
                        ),
                      ],
                    ),

                    const SizedBox(height: 16),

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
                            centerText: "${tripData.expenses ?? 0.0} €",
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
                          //TODO SI PUO FARE EXPANDED
                          Column(
                            children: List.generate(dataMap.length, (index) {
                              final entry = dataMap.entries.elementAt(index);
                              final color = colorList[index];
                              final label = entry.key;
                              final value = entry.value;

                              return Padding(
                                padding: const EdgeInsets.symmetric(vertical: 4.0, horizontal: 16),
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
                                      '${value.toStringAsFixed(0)}%',
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

                    // --- Active Users ---
                    Container(
                      decoration: BoxDecoration(
                        color: Colors.pinkAccent,
                        borderRadius: BorderRadius.circular(16),
                      ),
                      padding: const EdgeInsets.all(16),
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          const Text(
                            'Active Users',
                            style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold, color: Colors.white),
                          ),
                          const Text(
                            'A small summary of your users base',
                            style: TextStyle(color: Colors.white70),
                          ),
                          const SizedBox(height: 16),
                          ClipRRect(
                            borderRadius: BorderRadius.circular(12),
                            child: LinearProgressIndicator(
                              value: 0.6,
                              color: Colors.white,
                              backgroundColor: Colors.white24,
                              minHeight: 12,
                            ),
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