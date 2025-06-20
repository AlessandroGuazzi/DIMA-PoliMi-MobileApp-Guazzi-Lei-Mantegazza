import 'package:dima_project/models/tripModel.dart';
import 'package:dima_project/services/CurrencyService.dart';
import 'package:dima_project/services/databaseService.dart';
import 'package:dima_project/utils/responsive.dart';
import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'package:pie_chart/pie_chart.dart';
import '../../utils/CountryToCurrency.dart';
import '../../utils/screenSize.dart';

class TripExpensesWidget extends StatefulWidget {
  final DatabaseService databaseService;
  final CurrencyService currencyService;
  final String tripId;

  TripExpensesWidget({super.key, required this.tripId, databaseService, currencyService})
      : databaseService = databaseService ?? DatabaseService(),
        currencyService = currencyService ?? CurrencyService();

  @override
  State<TripExpensesWidget> createState() => _TripExpensesWidgetState();
}

class _TripExpensesWidgetState extends State<TripExpensesWidget> {
  late Future<TripModel?> _futureTrip;

  //original value
  late double _originalFlightExpense;
  late double _originalAccommodationExpense;
  late double _originalAttractionExpense;
  late double _originalTransportExpense;

  late double totalCost;
  late double flightExpense;
  late double accommodationExpense;
  late double attractionExpense;
  late double transportExpense;

  String _selectedCurrency = 'EUR';
  late List<String> _currencies;

  bool _expensesInitialized = false;
  bool _widgetUpdated = false;

  final colorList = <Color>[
    Colors.orange.shade400,
    Colors.blue.shade400,
    Colors.indigo.shade900,
    Colors.red.shade300,
  ];

  @override
  void initState() {
    super.initState();
    _futureTrip = widget.databaseService.loadTrip(widget.tripId);
  }

  @override
  void didUpdateWidget(covariant TripExpensesWidget oldWidget) {
    super.didUpdateWidget(oldWidget);
    if (oldWidget.tripId != widget.tripId) {
      WidgetsBinding.instance.addPostFrameCallback((_) {
        if (mounted) {
          setState(() {
            _futureTrip = widget.databaseService.loadTrip(widget.tripId);
            _widgetUpdated = true;
          });
        }
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    return FutureBuilder<TripModel?>(
      future: _futureTrip,
      builder: (context, snapshot) {
        if (snapshot.connectionState == ConnectionState.waiting) {
          return const Center(child: CircularProgressIndicator());
        }
        if (!snapshot.hasData) {
          return const Center(child: Text('Viaggio non trovato'));
        }
        if (snapshot.hasError) {
          return Center(child: Text('Errore: ${snapshot.error}'));
        }

        final tripData = snapshot.data!;

        _currencies =
            CountryToCurrency().initializeCurrencies(tripData.nations);

        //assign only if it's the first time or if widget is updated
        if (!_expensesInitialized || _widgetUpdated) {
          // Store original values
          _originalFlightExpense =
              (tripData.expenses?['flight'])?.toDouble() ?? 0.0;
          _originalAccommodationExpense =
              (tripData.expenses?['accommodation'])?.toDouble() ?? 0.0;
          _originalAttractionExpense =
              (tripData.expenses?['attraction'])?.toDouble() ?? 0.0;
          _originalTransportExpense =
              (tripData.expenses?['transport'])?.toDouble() ?? 0.0;

          flightExpense = _originalFlightExpense;
          accommodationExpense = _originalAccommodationExpense;
          attractionExpense = _originalAttractionExpense;
          transportExpense = _originalTransportExpense;

          totalCost = flightExpense +
              attractionExpense +
              accommodationExpense +
              transportExpense; // Removed .round()

          _expensesInitialized = true;
          _widgetUpdated = false;
        }

        Map<String, double> dataMap = {
          "Voli": flightExpense,
          "Attrazioni": attractionExpense,
          "Trasporti": transportExpense,
          "Alloggio": accommodationExpense,
        };

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
                        elevation: 2,
                        child: Padding(
                          padding: const EdgeInsets.all(20.0),
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Row(
                                mainAxisAlignment:
                                    MainAxisAlignment.spaceBetween,
                                children: [
                                  const Column(
                                    mainAxisAlignment: MainAxisAlignment.start,
                                    crossAxisAlignment:
                                        CrossAxisAlignment.start,
                                    children: [
                                      Text(
                                        'Le tue spese',
                                        style: TextStyle(
                                            fontSize: 18,
                                            fontWeight: FontWeight.bold),
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
                                        child: CountryToCurrency()
                                            .formatPopularCurrencies(currency),
                                      );
                                    }).toList(),
                                    onChanged: (value) {
                                      if (value != null) {
                                        _updatePieChart(value);
                                      }
                                    },
                                  ),
                                ],
                              ),
                              const SizedBox(height: 22),
                              ResponsiveLayout(
                                  mobileLayout: _mobileLayout(dataMap),
                                  tabletLayout: _tabletLayout(dataMap)),
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

  Widget _tabletLayout(Map<String, double> dataMap) {
    return Row(
      crossAxisAlignment: CrossAxisAlignment.center,
      mainAxisAlignment: MainAxisAlignment.spaceBetween,
      children: [
        PieChart(
          dataMap: dataMap,
          chartRadius: 200,
          centerWidget: Text(
            "${formatCompact(totalCost)} $_selectedCurrency",
            style: Theme.of(context).textTheme.headlineMedium,
          ),
          // Added two decimals
          chartType: ChartType.ring,
          colorList: colorList,
          ringStrokeWidth: 35,
          legendOptions: const LegendOptions(showLegends: false),
          chartValuesOptions: const ChartValuesOptions(showChartValues: false),
        ),
        const SizedBox(width: 25),
        SizedBox(
          width: 350,
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.center,
            children: List.generate(dataMap.length, (index) {
              final entry = dataMap.entries.elementAt(index);
              final color = colorList[index];
              final label = entry.key;
              final value = entry.value;

              int percentage =
                  (totalCost > 0 ? (value / totalCost) * 100 : 0).round();

              return Padding(
                padding:
                    const EdgeInsets.symmetric(vertical: 4.0, horizontal: 12),
                child: Row(
                  children: [
                    Icon(
                      _getIconForLabel(label),
                      color: color,
                    ),
                    const SizedBox(width: 8),
                    Expanded(
                      child: Text(
                        label,
                        style: const TextStyle(fontSize: 16),
                      ),
                    ),
                    Text(
                      '${formatCompact(value)} $_selectedCurrency ($percentage%)',
                      style: const TextStyle(
                          fontSize: 16, fontWeight: FontWeight.w600),
                    ),
                  ],
                ),
              );
            }),
          ),
        ),
      ],
    );
  }

  Widget _mobileLayout(Map<String, double> dataMap) {
    return Column(
      children: [
        PieChart(
          dataMap: dataMap,
          chartRadius: 200,
          centerText: "${totalCost.toStringAsFixed(2)} $_selectedCurrency",
          centerTextStyle: Theme.of(context).textTheme.headlineMedium,
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

            int percentage =
                (totalCost > 0 ? (value / totalCost) * 100 : 0).round();

            return Padding(
              padding:
                  const EdgeInsets.symmetric(vertical: 4.0, horizontal: 12),
              child: Row(
                children: [
                  Icon(
                    _getIconForLabel(label),
                    color: color,
                  ),
                  const SizedBox(width: 8),
                  Expanded(
                    child: Text(
                      label,
                      style: const TextStyle(fontSize: 16),
                    ),
                  ),
                  Text(
                    '${formatCompact(value)} $_selectedCurrency ($percentage%)',
                    style: const TextStyle(
                        fontSize: 16, fontWeight: FontWeight.w600),
                  ),
                ],
              ),
            );
          }),
        ),
      ],
    );
  }

  Future<void> _updatePieChart(String targetCurrency) async {
    String baseCurrency = 'EUR';

    if (targetCurrency == baseCurrency) {
      setState(() {
        flightExpense = _originalFlightExpense;
        accommodationExpense = _originalAccommodationExpense;
        attractionExpense = _originalAttractionExpense;
        transportExpense = _originalTransportExpense;
        totalCost = flightExpense +
            attractionExpense +
            accommodationExpense +
            transportExpense;
        _selectedCurrency = targetCurrency;
      });
    } else {
      num rate =
          await widget.currencyService.getExchangeRate(baseCurrency, targetCurrency);
      setState(() {
        flightExpense = _originalFlightExpense * rate;
        accommodationExpense = _originalAccommodationExpense * rate;
        attractionExpense = _originalAttractionExpense * rate;
        transportExpense = _originalTransportExpense * rate;
        totalCost = flightExpense +
            attractionExpense +
            accommodationExpense +
            transportExpense;
        _selectedCurrency = targetCurrency;
      });
    }
  }

  IconData _getIconForLabel(String label) {
    switch (label) {
      case 'Voli':
        return Icons.flight;
      case 'Attrazioni':
        return Icons.attractions;
      case 'Trasporti':
        return Icons.directions_bus;
      case 'Alloggio':
        return Icons.hotel;
      default:
        return Icons.euro;
    }
  }

  String formatCompact(double value, {int decimals = 2, String locale = 'it'}) {

    final fmt = NumberFormat.compact(locale: locale);

    return fmt.format(value);
  }
}
