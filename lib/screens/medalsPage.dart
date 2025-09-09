import 'package:dima_project/models/tripModel.dart';
import 'package:dima_project/models/userModel.dart';
import 'package:flutter/material.dart';
import 'package:dima_project/services/databaseService.dart';

import '../utils/responsive.dart';

//TODO: if we keep it like this fetching the current user from db is not necessary
class MedalsPage extends StatefulWidget {
  late final DatabaseService databaseService;

  MedalsPage(
      {super.key,
      required this.username,
      required this.userId,
      databaseService})
      : databaseService = databaseService ?? DatabaseService();

  final String username;
  final String userId;

  @override
  State<MedalsPage> createState() => _MedalsPageState();
}

class _MedalsPageState extends State<MedalsPage> {
  late Future<UserModel?> _user;
  late Future<List<TripModel>> _completedTrips;
  late Future<List<dynamic>> _combinedFuture;

  @visibleForTesting
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

  final Map<String, int> totalCountriesMap = {
    'Mondo': 251,
    'Europa': 51,
    'Asia': 70,
    'America Settentrionale': 32,
    'America Meridionale': 18,
    'Africa': 60,
    'Oceania': 20,
  };

  Map<String, int> countCountriesByContinent(List<String> countryCodes) {
    Map<String, List<String>> continents = {
      'Europa': [
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
      'America Settentrionale': [
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
      'America Meridionale': [
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
      'Mondo': countryCodes.length,
      'Europa': 0,
      'Asia': 0,
      'America Settentrionale': 0,
      'America Meridionale': 0,
      'Africa': 0,
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

  List<T> removeDuplicates<T>(List<T> list) {
    return list.toSet().toList();
  }

  @override
  void initState() {
    super.initState();

    _user = widget.databaseService.getUserByUid(widget.userId);
    _completedTrips = widget.databaseService.getCompletedTrips(widget.userId);

    _combinedFuture = Future.wait([_user, _completedTrips]);
  }

  @override
  Widget build(BuildContext context) {
    return FutureBuilder<List<dynamic>>(
        future: _combinedFuture,
        builder: (context, snapshot) {
          if (snapshot.connectionState == ConnectionState.waiting) {
            return const Center(child: CircularProgressIndicator());
          }

          if (snapshot.hasError) {
            return Center(child: Text('Errore: ${snapshot.error}'));
          }

          if (!snapshot.hasData || snapshot.data == null) {
            return const Center(child: Text('Nessun dato disponibile'));
          }

          final user = snapshot.data![0];
          var completedTrips = snapshot.data![1];
          var listCountry = extractCountryCodes(completedTrips);
          listCountry = removeDuplicates(listCountry);
          var continentInfo = countCountriesByContinent(listCountry);

          if (user == null) {
            return const Center(child: Text('Utente non trovato'));
          }

          var countriesVisited = listCountry.length;
          var levelList = [
            "Esploratore Novizio",
            "Viaggiatore Avventuroso",
            "Globetrotter Esperto",
            "Maestro del Viaggio",
            "Leggenda del Mondo"
          ];
          double percentage = listCountry.length / 251;
          String level;

          if (percentage < 0.25) {
            level = levelList[0];
          } else if (percentage < 0.5) {
            level = levelList[1];
          } else if (percentage < 0.75) {
            level = levelList[2];
          } else if (percentage < 1) {
            level = levelList[3];
          } else {
            level = levelList[4];
          }

          final continents = [
            'Mondo',
            'Europa',
            'Asia',
            'America Settentrionale',
            'America Meridionale',
            'Africa',
            'Oceania',
          ];

          return Scaffold(
            body: CustomScrollView(
              slivers: [
                SliverAppBar(
                  expandedHeight: 250,
                  pinned: true,
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
                                  'Statistiche di Viaggio',
                                  textAlign: TextAlign.center,
                                  style: Theme.of(context).textTheme.headlineLarge?.copyWith(
                                    fontWeight: FontWeight.bold,
                                    color: Colors.white,
                                  ),
                                ),
                                const SizedBox(height: 4),

                                // Subtitle
                                Text(
                                  'Ecco un riepilogo dei tuoi progressi',
                                  textAlign: TextAlign.center,
                                  style: Theme.of(context).textTheme.bodySmall?.copyWith(
                                    color: Colors.white70,
                                  ),
                                ),
                                const SizedBox(height: 24),

                                // Stat Row
                                Row(
                                  mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                                  children: [
                                    _buildStat(
                                      'Paesi',
                                      '$countriesVisited',
                                      Icons.flag,
                                      Colors.white,
                                      context,
                                    ),
                                    _buildStat(
                                      'Livello',
                                      level,
                                      Icons.emoji_events,
                                      Colors.white,
                                      context,
                                    ),
                                  ],
                                ),
                              ],
                            ),
                          ),
                        ),
                      ),
                    ),
                  ),
                ),
                SliverToBoxAdapter(
                  child: ResponsiveLayout(
                    mobileLayout: Column(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        const SizedBox(height: 30),
                        ...continents.map((continent) => _buildMedalsSection(
                              continent,
                              continentInfo[continent] ?? 0,
                              totalCountriesMap[continent] ?? 1,
                            )),
                        const SizedBox(height: 24),
                      ],
                    ),
                    tabletLayout: Padding(
                      padding: const EdgeInsets.symmetric(
                          horizontal: 16, vertical: 24),
                      child: Wrap(
                        alignment: WrapAlignment.center,
                        spacing: 16,
                        runSpacing: 16,
                        children: continents
                            .map(
                              (continent) => SizedBox(
                                width:
                                    (MediaQuery.of(context).size.width - 64) /
                                        2, // 2 per row
                                child: _buildMedalsSection(
                                  continent,
                                  continentInfo[continent] ?? 0,
                                  totalCountriesMap[continent] ?? 1,
                                ),
                              ),
                            )
                            .toList(),
                      ),
                    ),
                  ),
                )
              ],
            ),
          );
        });
  }

  Widget _buildMedalsSection(
      String continent, int visitedCount, int totalCount) {
    return Card(
      margin: const EdgeInsets.symmetric(horizontal: 20, vertical: 10),
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
      elevation: 6,
      child: Padding(
        padding: const EdgeInsets.all(18),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              continent,
              style: Theme.of(context).textTheme.headlineMedium,
            ),
            const SizedBox(height: 20),
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceAround,
              children: List.generate(5, (index) {
                double percentage = (visitedCount / totalCount) * 100;

                bool isAchieved;
                switch (index) {
                  case 0:
                    isAchieved = visitedCount >= 1;
                    break;
                  case 1:
                    isAchieved = percentage >= 25;
                    break;
                  case 2:
                    isAchieved = percentage >= 50;
                    break;
                  case 3:
                    isAchieved = percentage >= 75;
                    break;
                  case 4:
                    isAchieved = percentage >= 100;
                    break;
                  default:
                    isAchieved = false;
                }

                return Column(
                  children: [
                    AnimatedContainer(
                      duration: const Duration(milliseconds: 800),
                      curve: Curves.elasticOut,
                      decoration: BoxDecoration(
                        shape: BoxShape.circle,
                        gradient: isAchieved
                            ? LinearGradient(
                                colors: [
                                  Colors.amber.shade700,
                                  Colors.orange.shade400
                                ],
                                begin: Alignment.topLeft,
                                end: Alignment.bottomRight,
                              )
                            : LinearGradient(
                                colors: [
                                  Colors.grey.shade300,
                                  Colors.grey.shade100
                                ],
                                begin: Alignment.topLeft,
                                end: Alignment.bottomRight,
                              ),
                        boxShadow: isAchieved
                            ? [
                                BoxShadow(
                                  color: Colors.amber.withOpacity(0.6),
                                  blurRadius: 12,
                                  offset: const Offset(0, 6),
                                ),
                              ]
                            : [],
                      ),
                      width: isAchieved ? 50 : 40,
                      height: isAchieved ? 50 : 40,
                      child: Icon(
                        Icons.emoji_events,
                        color: isAchieved ? Colors.white : Colors.grey.shade500,
                        size: isAchieved ? 30 : 24,
                      ),
                    ),
                    const SizedBox(height: 8),
                    Text(
                      ['1 paese', '25%', '50%', '75%', '100%'][index],
                      style: TextStyle(
                        fontSize: 13,
                        fontWeight:
                            isAchieved ? FontWeight.w600 : FontWeight.normal,
                        color: isAchieved ? Colors.amber : Colors.grey,
                      ),
                    ),
                  ],
                );
              }),
            ),
            const SizedBox(height: 12),
          ],
        ),
      ),
    );
  }

  Widget _buildStat(String label, String value, IconData icon, Color color,
      BuildContext context) {
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
}
