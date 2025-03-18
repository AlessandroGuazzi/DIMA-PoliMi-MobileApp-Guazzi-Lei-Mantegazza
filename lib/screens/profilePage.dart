import 'package:flutter/material.dart';
import 'package:dima_project/services/authService.dart';

class ProfilePage extends StatefulWidget {
  const ProfilePage({super.key});

  @override
  State<ProfilePage> createState() => _ProfilePageState();
}

class _ProfilePageState extends State<ProfilePage> {

  Future<void> signOut() async{
    await AuthService().signOut();
  }

  /* Widget build(BuildContext context) {
    return Scaffold(
      body: SafeArea(
        top: true,
        child: Container(
          padding: const EdgeInsets.all(40),
          child: Align(
            alignment: const AlignmentDirectional(1, 0),
            child: Column(
              mainAxisSize: MainAxisSize.max,
              children: [
                Row(
                  mainAxisSize: MainAxisSize.max,
                  children: [
                    Expanded(
                      child: Container(
                        width: 200,
                        height: 200,
                        clipBehavior: Clip.antiAlias,
                        decoration: const BoxDecoration(
                          shape: BoxShape.circle,
                        ),
                        child: Image.network(
                          'https://picsum.photos/seed/65/600',
                          fit: BoxFit.cover,
                        ),
                      ),
                    ),
                  ],
                ),
                
                Container(
                  padding: EdgeInsets.all(20),
                  child: Column(
                    children: [
                      Text(
                        'Ciao User, Bentornato!',
                        style: TextStyle(
                          decoration: TextDecoration.underline,
                          fontSize: 30
                        ),
                      ),
                      ListView(
                        padding: EdgeInsets.zero,
                        shrinkWrap: true,
                        scrollDirection: Axis.vertical,
                        children: [
                          ListTile(
                            title: Text(
                              'Title',
                            )
                          ),
                          TextButton.icon(
                              onPressed: (){},
                              icon: const Icon(Icons.person_2_outlined),
                              label: Text('Personal Details')
                          ),
                          TextButton.icon(
                              onPressed: (){},
                              icon: const Icon(Icons.add_business_rounded),
                              label: Text('Saved')
                          ),
                          TextButton.icon(
                              onPressed: (){},
                              icon: const Icon(Icons.settings_outlined),
                              label: Text('Settings')
                          ),
                          TextButton.icon(
                              onPressed: (){},
                              icon: const Icon(Icons.logout_outlined),
                              label: Text('Log Out')
                          )
                        ],
                      ),
                    ]
                  )
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }*/
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: SafeArea(
        top: true,
        child: Container(
          padding: const EdgeInsets.all(40),
          child: Align(
            alignment: const AlignmentDirectional(1, 0),
            child: Column(
              mainAxisSize: MainAxisSize.max,
              children: [
                // Immagine Profilo
                Row(
                  mainAxisSize: MainAxisSize.max,
                  children: [
                    Expanded(
                      child: Container(
                        width: 200,
                        height: 200,
                        clipBehavior: Clip.antiAlias,
                        decoration: const BoxDecoration(
                          shape: BoxShape.circle,
                        ),
                        child: Image.network(
                          'https://picsum.photos/seed/65/600',
                          fit: BoxFit.cover,
                        ),
                      ),
                    ),
                  ],
                ),

                // Informazioni Utente
                Container(
                  padding: const EdgeInsets.all(20),
                  child: Column(
                    children: [
                      // Saluto Utente
                      const Text(
                        'Ciao User, Bentornato!',
                        style: TextStyle(
                            fontSize: 30
                        ),
                      ),

                      // Spazio tra saluto e lista
                      const SizedBox(height: 20),

                      // Lista Opzioni
                      ListView(
                        padding: EdgeInsets.zero,
                        shrinkWrap: true,
                        scrollDirection: Axis.vertical,
                        children: [
                          // Opzioni Utente
                          TextButton(
                            onPressed: () {},
                            style: TextButton.styleFrom(
                              backgroundColor: Theme.of(context).primaryColor, // Sfondo blu
                              shape: RoundedRectangleBorder( // Bordi arrotondati
                                borderRadius: BorderRadius.circular(15),
                              ),
                              padding: const EdgeInsets.all(20), // Spaziatura interna
                            ),
                            child: const Row(
                              children: [
                                Icon(Icons.person_2_outlined, color: Colors.white), // Icona bianca
                                SizedBox(width: 16), // Spazio tra icona e testo
                                Expanded(
                                  child: Text(
                                    'Personal Details',
                                    style: TextStyle(color: Colors.white), // Testo bianco
                                  ),
                                ),
                                Icon(Icons.arrow_forward_ios_rounded, color: Colors.white)
                              ],
                            ),
                          ),
                          const SizedBox(height: 10), // Spazio tra bottoni
                          TextButton(
                            onPressed: () {},
                            style: TextButton.styleFrom(
                              backgroundColor: Theme.of(context).primaryColor, // Sfondo blu
                              shape: RoundedRectangleBorder( // Bordi arrotondati
                                borderRadius: BorderRadius.circular(15),
                              ),
                              padding: const EdgeInsets.all(20), // Spaziatura interna
                            ),
                            child: const Row(
                              children: [
                                Icon(Icons.favorite, color: Colors.white), // Icona bianca
                                SizedBox(width: 16), // Spazio tra icona e testo
                                Expanded(
                                  child: Text(
                                    'Saved',
                                    style: TextStyle(color: Colors.white), // Testo bianco
                                  ),
                                ),
                                Icon(Icons.arrow_forward_ios_rounded, color: Colors.white)
                              ],
                            ),
                          ),
                          const SizedBox(height: 10), // Spazio tra bottoni
                          TextButton(
                            onPressed: () {},
                            style: TextButton.styleFrom(
                              backgroundColor: Theme.of(context).primaryColor, // Sfondo blu
                              shape: RoundedRectangleBorder( // Bordi arrotondati
                                borderRadius: BorderRadius.circular(15),
                              ),
                              padding: const EdgeInsets.all(20), // Spaziatura interna
                            ),
                            child: const Row(
                              children: [
                                Icon(Icons.settings_outlined, color: Colors.white), // Icona bianca
                                SizedBox(width: 16), // Spazio tra icona e testo
                                Expanded(
                                  child: Text(
                                    'Settings',
                                    style: TextStyle(color: Colors.white), // Testo bianco
                                  ),
                                ),
                                Icon(Icons.arrow_forward_ios_rounded, color: Colors.white)
                              ],
                            ),
                          ),
                          const SizedBox(height: 10), // Spazio tra bottoni
                          TextButton(
                            onPressed: () {
                              signOut();
                            },
                            style: TextButton.styleFrom(
                              backgroundColor: Theme.of(context).primaryColor, // Sfondo blu
                              shape: RoundedRectangleBorder( // Bordi arrotondati
                                borderRadius: BorderRadius.circular(15),
                              ),
                              padding: const EdgeInsets.all(20), // Spaziatura interna
                            ),
                            child: const Row(
                              children: [
                                Icon(Icons.logout_outlined, color: Colors.white), // Icona bianca
                                SizedBox(width: 16), // Spazio tra icona e testo
                                Expanded(
                                  child: Text(
                                    'Log Out',
                                    style: TextStyle(color: Colors.white), // Testo bianco
                                  ),
                                ),
                                Icon(Icons.arrow_forward_ios_rounded, color: Colors.white)
                              ],
                            ),
                          ),
                        ],
                      ),
                    ],
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }

}