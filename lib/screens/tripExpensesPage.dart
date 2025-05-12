import 'package:dima_project/models/tripModel.dart';
import 'package:dima_project/services/CurrencyService.dart';
import 'package:dima_project/services/databaseService.dart';
import 'package:dima_project/utils/screenSize.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'package:pie_chart/pie_chart.dart';

import '../utils/CountryToCurrency.dart';

class TripExpensesPage extends StatefulWidget {
  const TripExpensesPage({super.key, required this.tripId});

  final String tripId;

  @override
  State<TripExpensesPage> createState() => _TripExpensesPageState();
}

class _TripExpensesPageState extends State<TripExpensesPage> {

  late Future<TripModel> trip;
  late int totalCost;
  late double flightExpense;
  late double accommodationExpense;
  late double attractionExpense;
  late double transportExpense;
  String _selectedCurrency = 'EUR';
  late List<String> _currencies;

  bool _expensesInitialized = false;

  @override
  void initState() {
    super.initState();
    trip = DatabaseService().loadTrip(widget.tripId);
  }


  @override
  Widget build(BuildContext context) {
    return FutureBuilder<TripModel?>(
      future: trip,
      builder: (context, snapshot) {
        if (snapshot.connectionState == ConnectionState.waiting) {
          return const Center(child: CircularProgressIndicator());
        }
        if (!snapshot.hasData || snapshot.data == null) {
          return const Center(child: Text('Trip not found.'));
        }

        final tripData = snapshot.data!;

        _currencies = CountryToCurrency().initializeCurrencies(tripData.nations);

        //assign only if it's the first time
        if (!_expensesInitialized) {
          flightExpense = (tripData.expenses?['flight'])?.toDouble() ?? 0.0;
          accommodationExpense = (tripData.expenses?['accommodation'])?.toDouble() ?? 0.0;
          attractionExpense = (tripData.expenses?['attraction'])?.toDouble() ?? 0.0;
          transportExpense = (tripData.expenses?['transport'])?.toDouble() ?? 0.0;
          totalCost = (flightExpense + attractionExpense + accommodationExpense + transportExpense).round();

          _expensesInitialized = true;
        }


        Map<String, double> dataMap = {
          "Voli": flightExpense,
          "Attrazioni": attractionExpense,
          "Trasporti": transportExpense,
          "Alloggio": accommodationExpense,
        };

        final colorList = <Color>[
          Colors.orange.shade400,
          Colors.blue.shade400,
          Colors.indigo.shade900,
          Colors.red.shade300,
        ];

        return Container(
          color: Theme.of(context).scaffoldBackgroundColor,
          child: SingleChildScrollView(
            child: Column(
              children: [
                // Dashboard Section
                Padding(
                  padding: const EdgeInsets.all(10.0),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      // --- Cost Summary ---
                      Card(
                        color: Theme.of(context).cardColor,
                        elevation: 2,
                        child: Padding(
                          padding: const EdgeInsets.all(15.0),
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Row(
                                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                                children: [
                                  const Column(
                                    mainAxisAlignment: MainAxisAlignment.start,
                                    crossAxisAlignment: CrossAxisAlignment.start,
                                    children: [
                                      Text(
                                        'Le tue spese',
                                        style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
                                      ),
                                      Text('Panoramica delle spese'),
                                    ],
                                  ),
                                  DropdownButton<String>(
                                    alignment: Alignment.center,
                                    value: _selectedCurrency,
                                    items: _currencies.map((currency) {
                                      return DropdownMenuItem(
                                        alignment: Alignment.center,
                                        value: currency,
                                        child: CountryToCurrency().formatPopularCurrencies(currency),
                                      );
                                    }).toList(),
                                    onChanged: (value) {
                                      if (value != null) {
                                          _updatePieChart(_selectedCurrency, value);
                                      }
                                    },
                                  ),
                                ],
                              ),
                              const SizedBox(height: 22),

                              PieChart(
                                dataMap: dataMap,
                                chartRadius: MediaQuery.of(context).size.width * 0.45,
                                centerText: "$totalCost $_selectedCurrency",
                                centerTextStyle: const TextStyle(
                                  fontSize: 17,
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
                                          '${value.toStringAsFixed(0)} $_selectedCurrency (${(totalCost > 0 ? (value / totalCost) * 100 : 0).toStringAsFixed(0)}%)',
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
                      ),
                      const SizedBox(height: 16),

                    ],
                  ),
                ),
              ],
            ),
          ),
        );
      },
    );
  }

  Future<void> _updatePieChart(String base, String target) async {
    num rate = await CurrencyService().getExchangeRate(base, target);
    setState(() {
      flightExpense = flightExpense * rate;
      accommodationExpense = accommodationExpense * rate;
      attractionExpense = attractionExpense * rate;
      transportExpense = transportExpense * rate;
      totalCost = (flightExpense + attractionExpense + accommodationExpense + transportExpense).round();
      _selectedCurrency = target;
    });

  }

}
