import 'package:dima_project/services/databaseService.dart';
import 'package:dima_project/utils/screenSize.dart';
import 'package:flutter/material.dart';
import 'package:countries_world_map/countries_world_map.dart';
import 'package:countries_world_map/data/maps/world_map.dart';
import '../models/tripModel.dart';
import '../widgets/progressBar.dart';

class TravelStatsPage extends StatefulWidget {
  late final DatabaseService databaseService;

  TravelStatsPage({super.key, databaseService})
      : databaseService = databaseService ?? DatabaseService();

  @override
  State<TravelStatsPage> createState() => _TravelStatsPageState();
}

class _TravelStatsPageState extends State<TravelStatsPage> {
  late Future<List<TripModel>> _completedTrips;

  Map<String, Color> _createCountryColorMap(List<TripModel> trips) {
    final Map<String, Color> countryColors = {};

    for (final trip in trips) {
      for (final nation in trip.nations ?? []) {
        final code = nation['code'];
        if (code != null && code.toString().isNotEmpty) {
          countryColors[code.toString()] = Theme.of(context).primaryColor;
        }
      }
    }
    return countryColors;
  }

  List<T> removeDuplicates<T>(List<T> list) {
    return list.toSet().toList();
  }

  List<String> extractCountryCodes(List<TripModel> trips) {
    final List<String> countryCodes = [];

    for (final trip in trips) {
      for (final nation in trip.nations ?? []) {
        final code = nation['code'];
        if (code != null && code.toString().isNotEmpty) {
          countryCodes.add(code.toString());
        }
      }
    }

    return countryCodes;
  }

  Map<String, int> countCountriesByContinent(List<String> countryCodes) {
    Map<String, List<String>> continents = {
      'Europe': [
        'aD',
        'aL',
        'aT',
        'aX',
        'bA',
        'bE',
        'bG',
        'bV',
        'cH',
        'cY',
        'cZ',
        'dE',
        'dK',
        'eE',
        'eS',
        'fI',
        'fO',
        'fR',
        'gB',
        'gE',
        'gG',
        'gI',
        'gR',
        'hR',
        'hU',
        'iE',
        'iM',
        'iS',
        'iT',
        'jE',
        'lI',
        'lT',
        'lU',
        'lV',
        'mC',
        'mD',
        'mE',
        'mF',
        'mK',
        'mT',
        'nL',
        'nO',
        'pL',
        'pT',
        'rO',
        'rS',
        'sE',
        'sI',
        'sJ',
        'sK',
        'sM',
        'tF',
        'vA',
        'bY',
        'rU',
        'xK',
        'uA'
      ],
      'Asia': [
        'aE',
        'aF',
        'aM',
        'aZ',
        'bD',
        'bH',
        'bN',
        'bT',
        'cN',
        'hK',
        'iD',
        'iL',
        'iN',
        'iQ',
        'iO',
        'iR',
        'jO',
        'jP',
        'kG',
        'kH',
        'kP',
        'kR',
        'kW',
        'kZ',
        'lA',
        'lB',
        'lK',
        'mM',
        'mN',
        'mO',
        'mY',
        'mV',
        'oM',
        'pH',
        'pK',
        'pS',
        'qA',
        'sA',
        'sG',
        'sY',
        'tH',
        'tJ',
        'tL',
        'tM',
        'tR',
        'tW',
        'uZ',
        'vN',
        'yE',
        'nP',
        'sS'
      ],
      'Africa': [
        'aO',
        'bF',
        'bL',
        'bM',
        'bI',
        'yT',
        'bJ',
        'bW',
        'cD',
        'cF',
        'cG',
        'cI',
        'cM',
        'cV',
        'dJ',
        'dZ',
        'eG',
        'eH',
        'eR',
        'eT',
        'gA',
        'gH',
        'gM',
        'gN',
        'gQ',
        'gW',
        'kE',
        'kM',
        'lR',
        'lS',
        'lY',
        'mA',
        'mG',
        'mL',
        'mR',
        'mU',
        'mW',
        'mZ',
        'nA',
        'nE',
        'nG',
        'rE',
        'rW',
        'sC',
        'sD',
        'sH',
        'sL',
        'sN',
        'sO',
        'sT',
        'sZ',
        'tD',
        'tG',
        'tN',
        'tZ',
        'uG',
        'zA',
        'zM',
        'zW'
      ],
      'North America': [
        'aI',
        'aG',
        'aW',
        'bB',
        'bS',
        'cA',
        'cR',
        'cU',
        'dM',
        'dO',
        'gD',
        'gT',
        'hN',
        'hT',
        'jM',
        'kN',
        'kY',
        'lC',
        'mX',
        'nI',
        'pA',
        'pM',
        'pR',
        'sV',
        'sX',
        'tC',
        'tT',
        'uS',
        'vC',
        'vG',
        'vI',
        'bZ',
        'gL',
        'gP',
        'gU',
        'mS',
        'mQ',
        'uM'
      ],
      'South America': [
        'aR',
        'bO',
        'bR',
        'cL',
        'cO',
        'eC',
        'fK',
        'gF',
        'gY',
        'pE',
        'pY',
        'sR',
        'uY',
        'vE',
        'cW',
        'bQ'
      ],
      'Oceania': [
        'aS',
        'aU',
        'cK',
        'cX',
        'fJ',
        'fM',
        'gS',
        'kI',
        'mH',
        'mP',
        'nF',
        'nU',
        'nZ',
        'pF',
        'pG',
        'pN',
        'pW',
        'sB',
        'tK',
        'tO',
        'tV',
        'vU',
        'wF',
        'wS',
        'cC',
        'hM',
        'nR',
        'nC'
      ]
    };

    Map<String, int> countMap = {
      'Europe': 0,
      'Asia': 0,
      'Africa': 0,
      'North America': 0,
      'South America': 0,
      'Oceania': 0
    };

    for (var country in countryCodes) {
      for (var continent in continents.entries) {
        if (continent.value.contains(country)) {
          countMap[continent.key] = countMap[continent.key]! + 1;
          break;
        }
      }
    }

    return countMap;
  }

  int countContinents(Map<String, int> a) {
    int count = 0;
    a.forEach((key, value) => count += (value != 0) ? 1 : 0);
    return count;
  }

  @override
  void initState() {
    super.initState();
    _completedTrips = widget.databaseService.getCompletedTrips();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: FutureBuilder(
        future: _completedTrips,
        builder: (context, snapshot) {
          if (snapshot.connectionState == ConnectionState.waiting) {
            return const Center(child: CircularProgressIndicator());
          }

          if (snapshot.hasError) {
            return Center(child: Text('Errore: ${snapshot.error}'));
          }

          var completedTrips = snapshot.data!;
          var map = _createCountryColorMap(completedTrips);
          var list = extractCountryCodes(completedTrips);
          list = removeDuplicates(list);
          var map2 = countCountriesByContinent(list);
          var tot = countContinents(map2);

          final List<Map<String, dynamic>> data = [
            {
              'title': 'Europa',
              'progress': '${map2['Europe']}/51',
              'percent': map2['Europe']! / 51
            },
            {
              'title': 'Asia',
              'progress': '${map2['Asia']}/70',
              'percent': map2['Asia']! / 70
            },
            {
              'title': 'America Settentrionale',
              'progress': '${map2['North America']}/32',
              'percent': map2['North America']! / 32
            },
            {
              'title': 'America Meridionale',
              'progress': '${map2['South America']}/18',
              'percent': map2['South America']! / 18
            },
            {
              'title': 'Africa',
              'progress': '${map2['Africa']}/60',
              'percent': map2['Africa']! / 60
            },
            {
              'title': 'Oceania',
              'progress': '${map2['Oceania']}/20',
              'percent': map2['Oceania']! / 20
            },
          ];

          return CustomScrollView(
            slivers: [
              SliverAppBar(
                expandedHeight: 250,
                flexibleSpace: FlexibleSpaceBar(
                  background: Container(
                    width: double.infinity,
                    decoration: BoxDecoration(
                      gradient: LinearGradient(
                        colors: [
                          Theme.of(context).primaryColor,
                          Theme.of(context).secondaryHeaderColor,
                        ],
                        begin: AlignmentDirectional(1, 1),
                        end: AlignmentDirectional(-1, -1),
                      ),
                    ),
                    child: SafeArea(
                      child: SizedBox.expand(
                        child: Padding(
                          padding: const EdgeInsets.all(16),
                          child: Column(
                            mainAxisAlignment: MainAxisAlignment.center,
                            crossAxisAlignment: CrossAxisAlignment.center,
                            children: [
                              // Title
                              Text(
                                'La Tua Mappa del Mondo',
                                textAlign: TextAlign.center,
                                style: Theme.of(context).textTheme.headlineLarge?.copyWith(
                                  fontWeight: FontWeight.bold,
                                  color: Colors.white,
                                ),
                              ),
                              const SizedBox(height: 4),

                              // Subtitle
                              Text(
                                'Scopri quanti paesi hai visitato\n'
                                    'e quali continenti hai esplorato di più',
                                textAlign: TextAlign.center,
                                style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                                  color: Colors.white.withOpacity(0.7),
                                ),
                              ),
                              const SizedBox(height: 24),

                              // Stat Row
                              Row(
                                mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                                children: [
                                  _buildStat(
                                    label: 'Paesi Visitati',
                                    value:
                                    '${map2['Europe']! + map2['Asia']! + map2['Africa']! + map2['North America']! + map2['South America']! + map2['Oceania']!}',
                                    icon: Icons.location_on,
                                    color: Colors.white,
                                    context: context,
                                  ),
                                  _buildStat(
                                    label: 'Continenti',
                                    value: '$tot',
                                    icon: Icons.flag,
                                    color: Colors.white,
                                    context: context,
                                  ),
                                ],
                              ),
                            ],
                          ),
                        ),
                      ),
                    ),
                  ),
                  /*Container(
                    width: double.infinity,
                    decoration: BoxDecoration(
                      gradient: LinearGradient(
                        colors: [
                          Theme.of(context).primaryColor,
                          Theme.of(context).secondaryHeaderColor,
                        ],
                        begin: AlignmentDirectional.bottomEnd,
                        end: AlignmentDirectional.topStart,
                      ),
                    ),
                    child: SafeArea(
                      child: Column(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: [
                          Text(
                            'La Tua Mappa del Mondo',
                            textAlign: TextAlign.center,
                            style: Theme.of(context)
                                .textTheme
                                .headlineMedium
                                ?.copyWith(
                                  color: Colors.white,
                                  fontWeight: FontWeight.bold,
                                ),
                          ),
                          const SizedBox(height: 12),
                          Text(
                            'Scopri quanti paesi hai visitato\n'
                            'e quali continenti hai esplorato di più',
                            textAlign: TextAlign.center,
                            style: Theme.of(context)
                                .textTheme
                                .bodyMedium
                                ?.copyWith(
                                  color: Colors.white.withOpacity(0.9),
                                  height: 1.4,
                                ),
                          ),
                          const SizedBox(height: 28),
                          Row(
                            mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                            children: [
                              _buildStat(
                                label: 'Paesi Visitati',
                                value:
                                    '${map2['Europe']! + map2['Asia']! + map2['Africa']! + map2['North America']! + map2['South America']! + map2['Oceania']!}',
                                icon: Icons.location_on,
                                color: Colors.white,
                                context: context,
                              ),
                              _buildStat(
                                label: 'Continenti',
                                value: '$tot',
                                icon: Icons.flag,
                                color: Colors.white,
                                context: context,
                              ),
                            ],
                          ),
                        ],
                      ),
                    ),
                  ),
                  */
                ),
              ),
              SliverToBoxAdapter(
                child: Padding(
                  padding: const EdgeInsets.only(bottom: 24),
                  child: Column(
                    children: [
                      Padding(
                        padding: const EdgeInsets.fromLTRB(16, 24, 16, 0),
                        child: Text(
                          'Mappa dei Tuoi Viaggi',
                          style: Theme.of(context).textTheme.headlineLarge,
                        ),
                      ),
                      Padding(
                        padding: const EdgeInsets.fromLTRB(16, 8, 16, 16),
                        child: SizedBox(
                          height: 300,
                          child: Card(
                            child: Padding(
                              padding: const EdgeInsets.all(8.0),
                              child: SimpleMap(
                                instructions: SMapWorld.instructions,
                                defaultColor: Colors.grey,
                                colors: _mapCountryToColors(map),
                              ),
                            ),
                          ),
                        ),
                      ),
                      Padding(
                        padding: EdgeInsets.fromLTRB(16, 8, 16, 0),
                        child: Text(
                          'Continenti Esplorati',
                          style: Theme.of(context).textTheme.headlineLarge,
                        ),
                      ),
                      Padding(
                        padding: const EdgeInsets.fromLTRB(16, 8, 16, 0),
                        child: GridView.builder(
                          padding: EdgeInsets.zero,
                          primary: false,
                          shrinkWrap: true,
                          scrollDirection: Axis.vertical,
                          gridDelegate:
                              SliverGridDelegateWithMaxCrossAxisExtent(
                            maxCrossAxisExtent:
                                ScreenSize.isTablet(context) ? 500 : 600,
                            mainAxisSpacing: 8,
                            crossAxisSpacing: 8,
                            childAspectRatio: 4,
                          ),
                          itemCount: data.length,
                          itemBuilder: (context, index) {
                            return ProgressItem(
                              title: data[index]['title'],
                              progress: data[index]['progress'],
                              percent: data[index]['percent'],
                            );
                          },
                        ),
                      ),
                    ],
                  ),
                ),
              ),
            ],
          );
        },
      ),
    );
  }

  Widget _buildStat(
      {required String label,
      required String value,
      required IconData icon,
      required Color color,
      required BuildContext context}) {
    return Column(
      children: [
        Container(
          padding: const EdgeInsets.all(8.0),
          decoration: BoxDecoration(
            color: color.withOpacity(0.1),
            borderRadius: BorderRadius.circular(16),
          ),
          child: Icon(
            icon,
            color: color,
          ),
        ),
        const SizedBox(height: 8),
        Text(
          value,
          style: Theme.of(context).textTheme.headlineMedium?.copyWith(
                color: color,
              ),
        ),
        const SizedBox(height: 4),
        Text(
          label,
          style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                color: color,
              ),
        ),
      ],
    );
  }

  Map<dynamic, dynamic> _mapCountryToColors(var map) {
    return SMapWorldColors(
      //TODO
      aD: map.containsKey('aD') ? Theme.of(context).primaryColor : Colors.grey,
      aE: map.containsKey('aE') ? Theme.of(context).primaryColor : Colors.grey,
      aF: map.containsKey('aF') ? Theme.of(context).primaryColor : Colors.grey,
      aG: map.containsKey('aG') ? Theme.of(context).primaryColor : Colors.grey,
      aI: map.containsKey('aI') ? Theme.of(context).primaryColor : Colors.grey,
      aL: map.containsKey('aL') ? Theme.of(context).primaryColor : Colors.grey,
      aM: map.containsKey('aM') ? Theme.of(context).primaryColor : Colors.grey,
      aN: map.containsKey('aN') ? Theme.of(context).primaryColor : Colors.grey,
      aO: map.containsKey('aO') ? Theme.of(context).primaryColor : Colors.grey,
      aQ: map.containsKey('aQ') ? Theme.of(context).primaryColor : Colors.grey,
      aR: map.containsKey('aR') ? Theme.of(context).primaryColor : Colors.grey,
      aS: map.containsKey('aS') ? Theme.of(context).primaryColor : Colors.grey,
      aT: map.containsKey('aT') ? Theme.of(context).primaryColor : Colors.grey,
      aU: map.containsKey('aU') ? Theme.of(context).primaryColor : Colors.grey,
      aW: map.containsKey('aW') ? Theme.of(context).primaryColor : Colors.grey,
      aX: map.containsKey('aX') ? Theme.of(context).primaryColor : Colors.grey,
      aZ: map.containsKey('aZ') ? Theme.of(context).primaryColor : Colors.grey,
      bA: map.containsKey('bA') ? Theme.of(context).primaryColor : Colors.grey,
      bB: map.containsKey('bB') ? Theme.of(context).primaryColor : Colors.grey,
      bD: map.containsKey('bD') ? Theme.of(context).primaryColor : Colors.grey,
      bE: map.containsKey('bE') ? Theme.of(context).primaryColor : Colors.grey,
      bF: map.containsKey('bF') ? Theme.of(context).primaryColor : Colors.grey,
      bG: map.containsKey('bG') ? Theme.of(context).primaryColor : Colors.grey,
      bH: map.containsKey('bH') ? Theme.of(context).primaryColor : Colors.grey,
      bI: map.containsKey('bI') ? Theme.of(context).primaryColor : Colors.grey,
      bJ: map.containsKey('bJ') ? Theme.of(context).primaryColor : Colors.grey,
      bL: map.containsKey('bL') ? Theme.of(context).primaryColor : Colors.grey,
      bM: map.containsKey('bM') ? Theme.of(context).primaryColor : Colors.grey,
      bN: map.containsKey('bN') ? Theme.of(context).primaryColor : Colors.grey,
      bO: map.containsKey('bO') ? Theme.of(context).primaryColor : Colors.grey,
      bQ: map.containsKey('bQ') ? Theme.of(context).primaryColor : Colors.grey,
      bR: map.containsKey('bR') ? Theme.of(context).primaryColor : Colors.grey,
      bS: map.containsKey('bS') ? Theme.of(context).primaryColor : Colors.grey,
      bT: map.containsKey('bT') ? Theme.of(context).primaryColor : Colors.grey,
      bV: map.containsKey('bV') ? Theme.of(context).primaryColor : Colors.grey,
      bW: map.containsKey('bW') ? Theme.of(context).primaryColor : Colors.grey,
      bY: map.containsKey('bY') ? Theme.of(context).primaryColor : Colors.grey,
      bZ: map.containsKey('bZ') ? Theme.of(context).primaryColor : Colors.grey,
      cA: map.containsKey('cA') ? Theme.of(context).primaryColor : Colors.grey,
      cC: map.containsKey('cC') ? Theme.of(context).primaryColor : Colors.grey,
      cD: map.containsKey('cD') ? Theme.of(context).primaryColor : Colors.grey,
      cF: map.containsKey('cF') ? Theme.of(context).primaryColor : Colors.grey,
      cG: map.containsKey('cG') ? Theme.of(context).primaryColor : Colors.grey,
      cH: map.containsKey('cH') ? Theme.of(context).primaryColor : Colors.grey,
      cI: map.containsKey('cI') ? Theme.of(context).primaryColor : Colors.grey,
      cK: map.containsKey('cK') ? Theme.of(context).primaryColor : Colors.grey,
      cL: map.containsKey('cL') ? Theme.of(context).primaryColor : Colors.grey,
      cM: map.containsKey('cM') ? Theme.of(context).primaryColor : Colors.grey,
      cN: map.containsKey('cN') ? Theme.of(context).primaryColor : Colors.grey,
      cO: map.containsKey('cO') ? Theme.of(context).primaryColor : Colors.grey,
      cR: map.containsKey('cR') ? Theme.of(context).primaryColor : Colors.grey,
      cU: map.containsKey('cU') ? Theme.of(context).primaryColor : Colors.grey,
      cV: map.containsKey('cV') ? Theme.of(context).primaryColor : Colors.grey,
      cW: map.containsKey('cW') ? Theme.of(context).primaryColor : Colors.grey,
      cX: map.containsKey('cX') ? Theme.of(context).primaryColor : Colors.grey,
      cY: map.containsKey('cY') ? Theme.of(context).primaryColor : Colors.grey,
      cZ: map.containsKey('cZ') ? Theme.of(context).primaryColor : Colors.grey,
      dE: map.containsKey('dE') ? Theme.of(context).primaryColor : Colors.grey,
      dJ: map.containsKey('dJ') ? Theme.of(context).primaryColor : Colors.grey,
      dK: map.containsKey('dK') ? Theme.of(context).primaryColor : Colors.grey,
      dM: map.containsKey('dM') ? Theme.of(context).primaryColor : Colors.grey,
      dO: map.containsKey('dO') ? Theme.of(context).primaryColor : Colors.grey,
      dZ: map.containsKey('dZ') ? Theme.of(context).primaryColor : Colors.grey,
      eC: map.containsKey('eC') ? Theme.of(context).primaryColor : Colors.grey,
      eE: map.containsKey('eE') ? Theme.of(context).primaryColor : Colors.grey,
      eG: map.containsKey('eG') ? Theme.of(context).primaryColor : Colors.grey,
      eH: map.containsKey('eH') ? Theme.of(context).primaryColor : Colors.grey,
      eR: map.containsKey('eR') ? Theme.of(context).primaryColor : Colors.grey,
      eS: map.containsKey('eS') ? Theme.of(context).primaryColor : Colors.grey,
      eT: map.containsKey('eT') ? Theme.of(context).primaryColor : Colors.grey,
      fI: map.containsKey('fI') ? Theme.of(context).primaryColor : Colors.grey,
      fJ: map.containsKey('fJ') ? Theme.of(context).primaryColor : Colors.grey,
      fK: map.containsKey('fK') ? Theme.of(context).primaryColor : Colors.grey,
      fM: map.containsKey('fM') ? Theme.of(context).primaryColor : Colors.grey,
      fO: map.containsKey('fO') ? Theme.of(context).primaryColor : Colors.grey,
      fR: map.containsKey('fR') ? Theme.of(context).primaryColor : Colors.grey,
      gA: map.containsKey('gA') ? Theme.of(context).primaryColor : Colors.grey,
      gB: map.containsKey('gB') ? Theme.of(context).primaryColor : Colors.grey,
      gD: map.containsKey('gD') ? Theme.of(context).primaryColor : Colors.grey,
      gE: map.containsKey('gE') ? Theme.of(context).primaryColor : Colors.grey,
      gF: map.containsKey('gF') ? Theme.of(context).primaryColor : Colors.grey,
      gG: map.containsKey('gG') ? Theme.of(context).primaryColor : Colors.grey,
      gH: map.containsKey('gH') ? Theme.of(context).primaryColor : Colors.grey,
      gI: map.containsKey('gI') ? Theme.of(context).primaryColor : Colors.grey,
      gL: map.containsKey('gL') ? Theme.of(context).primaryColor : Colors.grey,
      gM: map.containsKey('gM') ? Theme.of(context).primaryColor : Colors.grey,
      gN: map.containsKey('gN') ? Theme.of(context).primaryColor : Colors.grey,
      gP: map.containsKey('gP') ? Theme.of(context).primaryColor : Colors.grey,
      gQ: map.containsKey('gQ') ? Theme.of(context).primaryColor : Colors.grey,
      gR: map.containsKey('gR') ? Theme.of(context).primaryColor : Colors.grey,
      gS: map.containsKey('gS') ? Theme.of(context).primaryColor : Colors.grey,
      gT: map.containsKey('gT') ? Theme.of(context).primaryColor : Colors.grey,
      gU: map.containsKey('gU') ? Theme.of(context).primaryColor : Colors.grey,
      gW: map.containsKey('gW') ? Theme.of(context).primaryColor : Colors.grey,
      gY: map.containsKey('gY') ? Theme.of(context).primaryColor : Colors.grey,
      hK: map.containsKey('hK') ? Theme.of(context).primaryColor : Colors.grey,
      hM: map.containsKey('hM') ? Theme.of(context).primaryColor : Colors.grey,
      hN: map.containsKey('hN') ? Theme.of(context).primaryColor : Colors.grey,
      hR: map.containsKey('hR') ? Theme.of(context).primaryColor : Colors.grey,
      hT: map.containsKey('hT') ? Theme.of(context).primaryColor : Colors.grey,
      hU: map.containsKey('hU') ? Theme.of(context).primaryColor : Colors.grey,
      iD: map.containsKey('iD') ? Theme.of(context).primaryColor : Colors.grey,
      iE: map.containsKey('iE') ? Theme.of(context).primaryColor : Colors.grey,
      iL: map.containsKey('iL') ? Theme.of(context).primaryColor : Colors.grey,
      iM: map.containsKey('iM') ? Theme.of(context).primaryColor : Colors.grey,
      iN: map.containsKey('iN') ? Theme.of(context).primaryColor : Colors.grey,
      iO: map.containsKey('iO') ? Theme.of(context).primaryColor : Colors.grey,
      iQ: map.containsKey('iQ') ? Theme.of(context).primaryColor : Colors.grey,
      iR: map.containsKey('iR') ? Theme.of(context).primaryColor : Colors.grey,
      iS: map.containsKey('iS') ? Theme.of(context).primaryColor : Colors.grey,
      iT: map.containsKey('iT') ? Theme.of(context).primaryColor : Colors.grey,
      jE: map.containsKey('jE') ? Theme.of(context).primaryColor : Colors.grey,
      jM: map.containsKey('jM') ? Theme.of(context).primaryColor : Colors.grey,
      jO: map.containsKey('jO') ? Theme.of(context).primaryColor : Colors.grey,
      jP: map.containsKey('jP') ? Theme.of(context).primaryColor : Colors.grey,
      kE: map.containsKey('kE') ? Theme.of(context).primaryColor : Colors.grey,
      kG: map.containsKey('kG') ? Theme.of(context).primaryColor : Colors.grey,
      kH: map.containsKey('kH') ? Theme.of(context).primaryColor : Colors.grey,
      kI: map.containsKey('kI') ? Theme.of(context).primaryColor : Colors.grey,
      kM: map.containsKey('kM') ? Theme.of(context).primaryColor : Colors.grey,
      kN: map.containsKey('kN') ? Theme.of(context).primaryColor : Colors.grey,
      kP: map.containsKey('kP') ? Theme.of(context).primaryColor : Colors.grey,
      kR: map.containsKey('kR') ? Theme.of(context).primaryColor : Colors.grey,
      kW: map.containsKey('kW') ? Theme.of(context).primaryColor : Colors.grey,
      kY: map.containsKey('kY') ? Theme.of(context).primaryColor : Colors.grey,
      kZ: map.containsKey('kZ') ? Theme.of(context).primaryColor : Colors.grey,
      lA: map.containsKey('lA') ? Theme.of(context).primaryColor : Colors.grey,
      lB: map.containsKey('lB') ? Theme.of(context).primaryColor : Colors.grey,
      lC: map.containsKey('lC') ? Theme.of(context).primaryColor : Colors.grey,
      lI: map.containsKey('lI') ? Theme.of(context).primaryColor : Colors.grey,
      lK: map.containsKey('lK') ? Theme.of(context).primaryColor : Colors.grey,
      lR: map.containsKey('lR') ? Theme.of(context).primaryColor : Colors.grey,
      lS: map.containsKey('lS') ? Theme.of(context).primaryColor : Colors.grey,
      lT: map.containsKey('lT') ? Theme.of(context).primaryColor : Colors.grey,
      lU: map.containsKey('lU') ? Theme.of(context).primaryColor : Colors.grey,
      lV: map.containsKey('lV') ? Theme.of(context).primaryColor : Colors.grey,
      lY: map.containsKey('lY') ? Theme.of(context).primaryColor : Colors.grey,
      mA: map.containsKey('mA') ? Theme.of(context).primaryColor : Colors.grey,
      mC: map.containsKey('mC') ? Theme.of(context).primaryColor : Colors.grey,
      mD: map.containsKey('mD') ? Theme.of(context).primaryColor : Colors.grey,
      mE: map.containsKey('mE') ? Theme.of(context).primaryColor : Colors.grey,
      mF: map.containsKey('mF') ? Theme.of(context).primaryColor : Colors.grey,
      mG: map.containsKey('mG') ? Theme.of(context).primaryColor : Colors.grey,
      mH: map.containsKey('mH') ? Theme.of(context).primaryColor : Colors.grey,
      mK: map.containsKey('mK') ? Theme.of(context).primaryColor : Colors.grey,
      mL: map.containsKey('mL') ? Theme.of(context).primaryColor : Colors.grey,
      mM: map.containsKey('mM') ? Theme.of(context).primaryColor : Colors.grey,
      mN: map.containsKey('mN') ? Theme.of(context).primaryColor : Colors.grey,
      mO: map.containsKey('mO') ? Theme.of(context).primaryColor : Colors.grey,
      mP: map.containsKey('mP') ? Theme.of(context).primaryColor : Colors.grey,
      mQ: map.containsKey('mQ') ? Theme.of(context).primaryColor : Colors.grey,
      mR: map.containsKey('mR') ? Theme.of(context).primaryColor : Colors.grey,
      mS: map.containsKey('mS') ? Theme.of(context).primaryColor : Colors.grey,
      mT: map.containsKey('mT') ? Theme.of(context).primaryColor : Colors.grey,
      mU: map.containsKey('mU') ? Theme.of(context).primaryColor : Colors.grey,
      mV: map.containsKey('mV') ? Theme.of(context).primaryColor : Colors.grey,
      mW: map.containsKey('mW') ? Theme.of(context).primaryColor : Colors.grey,
      mX: map.containsKey('mX') ? Theme.of(context).primaryColor : Colors.grey,
      mY: map.containsKey('mY') ? Theme.of(context).primaryColor : Colors.grey,
      mZ: map.containsKey('mZ') ? Theme.of(context).primaryColor : Colors.grey,
      nA: map.containsKey('nA') ? Theme.of(context).primaryColor : Colors.grey,
      nC: map.containsKey('nC') ? Theme.of(context).primaryColor : Colors.grey,
      nE: map.containsKey('nE') ? Theme.of(context).primaryColor : Colors.grey,
      nF: map.containsKey('nF') ? Theme.of(context).primaryColor : Colors.grey,
      nG: map.containsKey('nG') ? Theme.of(context).primaryColor : Colors.grey,
      nI: map.containsKey('nI') ? Theme.of(context).primaryColor : Colors.grey,
      nL: map.containsKey('nL') ? Theme.of(context).primaryColor : Colors.grey,
      nO: map.containsKey('nO') ? Theme.of(context).primaryColor : Colors.grey,
      nP: map.containsKey('nP') ? Theme.of(context).primaryColor : Colors.grey,
      nR: map.containsKey('nR') ? Theme.of(context).primaryColor : Colors.grey,
      nU: map.containsKey('nU') ? Theme.of(context).primaryColor : Colors.grey,
      nZ: map.containsKey('nZ') ? Theme.of(context).primaryColor : Colors.grey,
      oM: map.containsKey('oM') ? Theme.of(context).primaryColor : Colors.grey,
      pA: map.containsKey('pA') ? Theme.of(context).primaryColor : Colors.grey,
      pE: map.containsKey('pE') ? Theme.of(context).primaryColor : Colors.grey,
      pF: map.containsKey('pF') ? Theme.of(context).primaryColor : Colors.grey,
      pG: map.containsKey('pG') ? Theme.of(context).primaryColor : Colors.grey,
      pH: map.containsKey('pH') ? Theme.of(context).primaryColor : Colors.grey,
      pK: map.containsKey('pK') ? Theme.of(context).primaryColor : Colors.grey,
      pL: map.containsKey('pL') ? Theme.of(context).primaryColor : Colors.grey,
      pM: map.containsKey('pM') ? Theme.of(context).primaryColor : Colors.grey,
      pN: map.containsKey('pN') ? Theme.of(context).primaryColor : Colors.grey,
      pR: map.containsKey('pR') ? Theme.of(context).primaryColor : Colors.grey,
      pS: map.containsKey('pS') ? Theme.of(context).primaryColor : Colors.grey,
      pT: map.containsKey('pT') ? Theme.of(context).primaryColor : Colors.grey,
      pW: map.containsKey('pW') ? Theme.of(context).primaryColor : Colors.grey,
      pY: map.containsKey('pY') ? Theme.of(context).primaryColor : Colors.grey,
      qA: map.containsKey('qA') ? Theme.of(context).primaryColor : Colors.grey,
      rE: map.containsKey('rE') ? Theme.of(context).primaryColor : Colors.grey,
      rO: map.containsKey('rO') ? Theme.of(context).primaryColor : Colors.grey,
      rS: map.containsKey('rS') ? Theme.of(context).primaryColor : Colors.grey,
      rU: map.containsKey('rU') ? Theme.of(context).primaryColor : Colors.grey,
      rW: map.containsKey('rW') ? Theme.of(context).primaryColor : Colors.grey,
      sA: map.containsKey('sA') ? Theme.of(context).primaryColor : Colors.grey,
      sB: map.containsKey('sB') ? Theme.of(context).primaryColor : Colors.grey,
      sC: map.containsKey('sC') ? Theme.of(context).primaryColor : Colors.grey,
      sD: map.containsKey('sD') ? Theme.of(context).primaryColor : Colors.grey,
      sE: map.containsKey('sE') ? Theme.of(context).primaryColor : Colors.grey,
      sG: map.containsKey('sG') ? Theme.of(context).primaryColor : Colors.grey,
      sH: map.containsKey('sH') ? Theme.of(context).primaryColor : Colors.grey,
      sI: map.containsKey('sI') ? Theme.of(context).primaryColor : Colors.grey,
      sJ: map.containsKey('sJ') ? Theme.of(context).primaryColor : Colors.grey,
      sK: map.containsKey('sK') ? Theme.of(context).primaryColor : Colors.grey,
      sL: map.containsKey('sL') ? Theme.of(context).primaryColor : Colors.grey,
      sM: map.containsKey('sM') ? Theme.of(context).primaryColor : Colors.grey,
      sN: map.containsKey('sN') ? Theme.of(context).primaryColor : Colors.grey,
      sO: map.containsKey('sO') ? Theme.of(context).primaryColor : Colors.grey,
      sR: map.containsKey('sR') ? Theme.of(context).primaryColor : Colors.grey,
      sS: map.containsKey('sS') ? Theme.of(context).primaryColor : Colors.grey,
      sT: map.containsKey('sT') ? Theme.of(context).primaryColor : Colors.grey,
      sV: map.containsKey('sV') ? Theme.of(context).primaryColor : Colors.grey,
      sX: map.containsKey('sX') ? Theme.of(context).primaryColor : Colors.grey,
      sY: map.containsKey('sY') ? Theme.of(context).primaryColor : Colors.grey,
      sZ: map.containsKey('sZ') ? Theme.of(context).primaryColor : Colors.grey,
      tC: map.containsKey('tC') ? Theme.of(context).primaryColor : Colors.grey,
      tD: map.containsKey('tD') ? Theme.of(context).primaryColor : Colors.grey,
      tF: map.containsKey('tF') ? Theme.of(context).primaryColor : Colors.grey,
      tG: map.containsKey('tG') ? Theme.of(context).primaryColor : Colors.grey,
      tH: map.containsKey('tH') ? Theme.of(context).primaryColor : Colors.grey,
      tJ: map.containsKey('tJ') ? Theme.of(context).primaryColor : Colors.grey,
      tK: map.containsKey('tK') ? Theme.of(context).primaryColor : Colors.grey,
      tL: map.containsKey('tL') ? Theme.of(context).primaryColor : Colors.grey,
      tM: map.containsKey('tM') ? Theme.of(context).primaryColor : Colors.grey,
      tN: map.containsKey('tN') ? Theme.of(context).primaryColor : Colors.grey,
      tO: map.containsKey('tO') ? Theme.of(context).primaryColor : Colors.grey,
      tR: map.containsKey('tR') ? Theme.of(context).primaryColor : Colors.grey,
      tT: map.containsKey('tT') ? Theme.of(context).primaryColor : Colors.grey,
      tV: map.containsKey('tV') ? Theme.of(context).primaryColor : Colors.grey,
      tW: map.containsKey('tW') ? Theme.of(context).primaryColor : Colors.grey,
      tZ: map.containsKey('tZ') ? Theme.of(context).primaryColor : Colors.grey,
      uA: map.containsKey('uA') ? Theme.of(context).primaryColor : Colors.grey,
      uG: map.containsKey('uG') ? Theme.of(context).primaryColor : Colors.grey,
      uM: map.containsKey('uM') ? Theme.of(context).primaryColor : Colors.grey,
      uS: map.containsKey('uS') ? Theme.of(context).primaryColor : Colors.grey,
      uY: map.containsKey('uY') ? Theme.of(context).primaryColor : Colors.grey,
      uZ: map.containsKey('uZ') ? Theme.of(context).primaryColor : Colors.grey,
      vA: map.containsKey('vA') ? Theme.of(context).primaryColor : Colors.grey,
      vC: map.containsKey('vC') ? Theme.of(context).primaryColor : Colors.grey,
      vE: map.containsKey('vE') ? Theme.of(context).primaryColor : Colors.grey,
      vG: map.containsKey('vG') ? Theme.of(context).primaryColor : Colors.grey,
      vI: map.containsKey('vI') ? Theme.of(context).primaryColor : Colors.grey,
      vN: map.containsKey('vN') ? Theme.of(context).primaryColor : Colors.grey,
      vU: map.containsKey('vU') ? Theme.of(context).primaryColor : Colors.grey,
      wF: map.containsKey('wF') ? Theme.of(context).primaryColor : Colors.grey,
      wS: map.containsKey('wS') ? Theme.of(context).primaryColor : Colors.grey,
      xK: map.containsKey('xK') ? Theme.of(context).primaryColor : Colors.grey,
      yE: map.containsKey('yE') ? Theme.of(context).primaryColor : Colors.grey,
      yT: map.containsKey('yT') ? Theme.of(context).primaryColor : Colors.grey,
      zA: map.containsKey('zA') ? Theme.of(context).primaryColor : Colors.grey,
      zM: map.containsKey('zM') ? Theme.of(context).primaryColor : Colors.grey,
      zW: map.containsKey('zW') ? Theme.of(context).primaryColor : Colors.grey,
    ).toMap();
  }
}
