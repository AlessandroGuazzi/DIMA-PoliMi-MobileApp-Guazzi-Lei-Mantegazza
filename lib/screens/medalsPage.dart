import 'package:dima_project/models/tripModel.dart';
import 'package:dima_project/models/userModel.dart';
import 'package:flutter/material.dart';
import 'package:dima_project/services/databaseService.dart';

class MedalsPage extends StatefulWidget {
  const MedalsPage({super.key, required this.username, required this.userId});

  final String username;
  final String userId;

  @override
  State<MedalsPage> createState() => _MedalsPageState();
}

class _MedalsPageState extends State<MedalsPage> {

  late Future<UserModel?> _user;
  late Future<List<TripModel>> _completedTrips;
  late Future<List<dynamic>> _combinedFuture;

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
      'Europa': ['aD', 'aL', 'aT', 'aX', 'bA', 'bE', 'bG', 'bV', 'cH', 'cY', 'cZ', 'dE', 'dK', 'eE', 'eS', 'fI', 'fO', 'fR', 'gB', 'gE', 'gG', 'gI', 'gR', 'hR', 'hU', 'iE', 'iM', 'iS', 'iT', 'jE', 'lI', 'lT', 'lU', 'lV', 'mC', 'mD', 'mE', 'mF', 'mK', 'mT', 'nL', 'nO', 'pL', 'pT', 'rO', 'rS', 'sE', 'sI', 'sJ', 'sK', 'sM', 'tF', 'vA', 'bY', 'rU', 'xK', 'uA'],
      'Asia': ['aE', 'aF', 'aM', 'aZ', 'bD', 'bH', 'bN', 'bT', 'cN', 'hK', 'iD', 'iL', 'iN', 'iQ', 'iO', 'iR', 'jO', 'jP', 'kG', 'kH', 'kP', 'kR', 'kW', 'kZ', 'lA', 'lB', 'lK', 'mM', 'mN', 'mO', 'mY', 'mV', 'oM', 'pH', 'pK', 'pS', 'qA', 'sA', 'sG', 'sY', 'tH', 'tJ', 'tL', 'tM', 'tR', 'tW', 'uZ', 'vN', 'yE', 'nP', 'sS'],
      'Africa': ['aO', 'bF', 'bL', 'bM', 'bI', 'yT', 'bJ', 'bW', 'cD', 'cF', 'cG', 'cI', 'cM', 'cV', 'dJ', 'dZ', 'eG', 'eH', 'eR', 'eT', 'gA', 'gH', 'gM', 'gN', 'gQ', 'gW', 'kE', 'kM', 'lR', 'lS', 'lY', 'mA', 'mG', 'mL', 'mR', 'mU', 'mW', 'mZ', 'nA', 'nE', 'nG', 'rE', 'rW', 'sC', 'sD', 'sH', 'sL', 'sN', 'sO', 'sT', 'sZ', 'tD', 'tG', 'tN', 'tZ', 'uG', 'zA', 'zM', 'zW'],
      'America Settentrionale': ['aI', 'aG', 'aW', 'bB', 'bS', 'cA', 'cR', 'cU', 'dM', 'dO', 'gD', 'gT', 'hN', 'hT', 'jM', 'kN', 'kY', 'lC', 'mX', 'nI', 'pA', 'pM', 'pR', 'sV', 'sX', 'tC', 'tT', 'uS', 'vC', 'vG', 'vI', 'bZ', 'gL', 'gP', 'gU', 'mS', 'mQ', 'uM'],
      'America Meridionale': ['aR', 'bO', 'bR', 'cL', 'cO', 'eC', 'fK', 'gF', 'gY', 'pE', 'pY', 'sR', 'uY', 'vE', 'cW', 'bQ'],
      'Oceania': ['aS', 'aU', 'cK', 'cX', 'fJ', 'fM', 'gS', 'kI', 'mH', 'mP', 'nF', 'nU', 'nZ', 'pF', 'pG', 'pN', 'pW', 'sB', 'tK', 'tO', 'tV', 'vU', 'wF', 'wS', 'cC', 'hM', 'nR', 'nC']
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
    _user = DatabaseService().getUserByUid(widget.userId);
    _completedTrips = DatabaseService().getCompletedTrips(widget.userId);

    _combinedFuture = Future.wait([_user, _completedTrips]);
  }



  @override
  Widget build(BuildContext context) {

    return FutureBuilder<List<dynamic>>(
        future: _combinedFuture,
        builder: (context, snapshot) {
          // Gestione degli stati
          if (snapshot.connectionState == ConnectionState.waiting) {
            return const Center(child: CircularProgressIndicator());
          }

          if (snapshot.hasError) {
            return Center(child: Text('Errore: ${snapshot.error}'));
          }

          var user = snapshot.data![0];
          var completedTrips = snapshot.data![1];
          var listCountry = extractCountryCodes(completedTrips);
          listCountry = removeDuplicates(listCountry);
          var continentInfo = countCountriesByContinent(listCountry);

          if (user == null) {
            return const Center(child: Text('Utente non trovato'));
          }

          var playerName = user.username!;
          var country = user.birthCountry ?? 'unknow';
          var countriesVisited = listCountry.length;
          var levelList = ["Esploratore Novizio", "Viaggiatore Avventuroso", "Globetrotter Esperto", "Maestro del Viaggio", "Leggenda del Mondo"];
          double percentuale = listCountry.length / 251;
          String level;

          if (percentuale < 0.25) {
            level = levelList[0];
          } else if (percentuale < 0.5) {
            level = levelList[1];
          } else if (percentuale < 0.75) {
            level = levelList[2];
          } else if (percentuale < 1) {
            level = levelList[3];
          } else {
            level = levelList[4];
          }
          const profileImageUrl = 'assets/profile.png';
          const coverImageUrl =
              'https://images.unsplash.com/photo-1506744038136-46273834b3fb?auto=format&fit=crop&w=800&q=1';

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
          backgroundColor: Colors.grey[100],
          body: CustomScrollView(
            slivers: [
              SliverAppBar(
                expandedHeight: 220,
                pinned: true,
                flexibleSpace: FlexibleSpaceBar(
                  background: Stack(
                    fit: StackFit.expand,
                    children: [
                      Image.network(
                        coverImageUrl,
                        fit: BoxFit.cover,
                      ),
                      Container(
                        decoration: BoxDecoration(
                          gradient: LinearGradient(
                            colors: [
                              Colors.black.withOpacity(0.4),
                              Colors.transparent,
                            ],
                            begin: Alignment.bottomCenter,
                            end: Alignment.topCenter,
                          ),
                        ),
                      ),
                      Align(
                        alignment: Alignment.bottomCenter,
                        child: Padding(
                          padding: const EdgeInsets.only(bottom: 10.0),
                          child: Container(
                            decoration: const BoxDecoration(
                              shape: BoxShape.circle,
                              boxShadow: [
                                BoxShadow(
                                  color: Colors.black26,
                                  blurRadius: 10,
                                  offset: Offset(0, 4),
                                ),
                              ],
                            ),
                            child: const CircleAvatar(
                              radius: 55,
                              backgroundColor: Colors.white,
                              child: CircleAvatar(
                                radius: 50,
                                backgroundImage: AssetImage(profileImageUrl),
                              ),
                            ),
                          ),
                        ),
                      ),
                    ],
                  ),
                ),
              ),
              SliverList(
                delegate: SliverChildListDelegate([
                  const SizedBox(height: 60),
                  ProfileCard(
                      playerName: playerName,
                      country: country,
                      countriesVisited: countriesVisited,
                      level: level),
                  const SizedBox(height: 24),
                  ...continents.map((continent) => _buildMedalsSection(
                    continent,
                    continentInfo[continent]?? 0,
                    totalCountriesMap[continent] ?? 1,
                  )),
                  const SizedBox(height: 24),
                ]),
              ),
            ],
          ),
        );
      }
    );
  }

  Widget _buildMedalsSection(String continent, int visitedCount, int totalCount) {
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
              style: const TextStyle(fontSize: 20, fontWeight: FontWeight.bold),
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
                          colors: [Colors.grey.shade300, Colors.grey.shade100],
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
                        color: isAchieved ? Colors.black87 : Colors.grey,
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
}

class ProfileCard extends StatelessWidget {
  const ProfileCard({
    super.key,
    required this.playerName,
    required this.country,
    required this.countriesVisited,
    required this.level,
  });

  final String playerName;
  final String country;
  final int countriesVisited;
  final String level;

  @override
  Widget build(BuildContext context) {
    return Card(
      margin: const EdgeInsets.symmetric(horizontal: 20),
      elevation: 8,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
      child: Padding(
        padding: const EdgeInsets.symmetric(vertical: 24, horizontal: 18),
        child: Column(
          children: [
            Text(
              playerName,
              style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 24),
            ),
            const SizedBox(height: 8),
            Row(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                Icon(Icons.location_on,
                    color: Theme.of(context).primaryColor, size: 20),
                const SizedBox(width: 6),
                Text(country, style: const TextStyle(fontSize: 16)),
              ],
            ),
            const SizedBox(height: 18),
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceEvenly,
              children: [
                _buildStat('Paesi', '$countriesVisited',
                    color: Theme.of(context).primaryColor),
                Container(width: 1, height: 28, color: Colors.grey[300]),
                _buildStat('Livello', level,
                    color: Theme.of(context).primaryColor),
              ],
            ),
            const SizedBox(height: 14),
          ],
        ),
      ),
    );
  }

  Widget _buildStat(String label, String value, {Color color = Colors.blueAccent}) {
    return Column(
      children: [
        Text(
          value,
          style: TextStyle(
            fontSize: 22,
            fontWeight: FontWeight.bold,
            color: color,
          ),
        ),
        const SizedBox(height: 4),
        Text(label, style: const TextStyle(color: Colors.grey, fontSize: 14)),
      ],
    );
  }
}
