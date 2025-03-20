import 'package:dima_project/screens/profilePage.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import '../models/userModel.dart';
import '../services/authService.dart';
import '../utils/screenSize.dart';

class AccountSettings extends StatefulWidget {
  const AccountSettings({super.key, required this.currentUserFuture});

  final Future<UserModel?> currentUserFuture;

  @override
  State<AccountSettings> createState() => _AccountSettingsState();
}

class _AccountSettingsState extends State<AccountSettings> {
  late Future<UserModel?> _currentUserFuture;
  late Function onRefresh;
  late TextEditingController _dateController;
  final _name = TextEditingController();
  final _surname = TextEditingController();
  final _username = TextEditingController();
  final _nationality = TextEditingController();
  final _email = TextEditingController();
  final _description = TextEditingController();
  DateTime? selectedBirthDate;

  @override
  void initState() {
    super.initState();
    _currentUserFuture = widget.currentUserFuture;
    _dateController = TextEditingController();
  }

  Future<void> updateUser() async {
    try {
      await AuthService().updateUserWithEmailAndPassword(
          name: _name.text.isEmpty ? null : _name.text.trim(),
          surname: _surname.text.isEmpty ? null : _surname.text.trim(),
          username: _username.text.isEmpty? null : _username.text.trim(),
          birthDate: selectedBirthDate,
          nationality: _nationality.text.isEmpty ? null : _nationality.text.trim(),
          email: _email.text.isEmpty ? null : _email.text.trim(),
          description: _description.text.isEmpty ? null : _description.text
      );
    } on FirebaseAuthException catch (error) {}
  }

  Future<void> _selectDate(BuildContext context) async {
    DateTime? pickedDate = await showDatePicker(
      context: context,
      initialDate: DateTime.now(),
      firstDate: DateTime(1900),
      lastDate: DateTime.now(),
    );

    if (pickedDate != null && pickedDate != selectedBirthDate) {
      setState(() {
        selectedBirthDate = pickedDate;
        _dateController.text = "${pickedDate.day}/${pickedDate.month}/${pickedDate.year}";
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    return FutureBuilder(
        future: _currentUserFuture,
        builder: (context, snapshot) {

          if (snapshot.connectionState == ConnectionState.waiting) {
            return const Center(child: CircularProgressIndicator());
          }

          if (snapshot.hasError) {
            return Center(child: Text('Errore: ${snapshot.error}'));
          }

          if (snapshot.data == null) {
            return const Center(child: Text('Utente non trovato'));
          }

          return Scaffold(
            appBar: AppBar(
              title: const Text('Modifica Profilo'),
              backgroundColor: Theme.of(context).primaryColor,
              elevation: 0,
            ),
            backgroundColor: const Color(0xFFF1F4F8),
            body: SingleChildScrollView(
              padding: const EdgeInsets.all(20.0),
              child: Column(
                children: [
                  Center(
                    child: Stack(
                      children: [
                        Container(
                          width: ScreenSize.screenWidth(context) * 0.35,
                          height: ScreenSize.screenHeight(context) * 0.15,
                          decoration: BoxDecoration(
                            shape: BoxShape.circle,
                            border: Border.all(
                                color: Theme.of(context).primaryColor,
                                width: 2),
                            image: DecorationImage(
                              image: snapshot.data!.profilePic == null
                                  ? const AssetImage('assets/profile.png')
                                  : NetworkImage(snapshot.data!.profilePic!),
                              fit: BoxFit.cover,
                            ),
                          ),
                        ),
                        Positioned(
                          bottom: 0,
                          right: 0,
                          child: CircleAvatar(
                            backgroundColor: Theme.of(context).primaryColor,
                            radius: 18,
                            child: const Icon(Icons.camera_alt,
                                size: 18, color: Colors.white),
                          ),
                        ),
                      ],
                    ),
                  ),
                  const SizedBox(height: 30),
                  _buildTextField(label: 'Nome', controller: _name, initialValue: '${snapshot.data!.name}'),
                  _buildTextField(label: 'Cognome', controller: _surname, initialValue: '${snapshot.data!.surname}'),
                  _buildTextField(
                      label: 'Username', controller: _username, initialValue: '${snapshot.data!.username}'),
                  TextField(
                    controller: _dateController,
                    decoration: InputDecoration(
                      labelText: 'Data di Nascita',
                      filled: true,
                      fillColor: Colors.white,
                      border: OutlineInputBorder(
                          borderRadius: BorderRadius.circular(12.0)),
                      suffixIcon: IconButton(
                        icon: const Icon(Icons.calendar_today),
                        onPressed: () => _selectDate(context),
                      ),
                      hintText: DateFormat('dd/MM/yyyy').format(snapshot.data!.birthDate!),
                    ),
                  ),
                  const SizedBox(height: 10),
                  _buildTextField(label: 'Nazionalità',controller: _nationality, initialValue: '${snapshot.data!.birthCountry}'),
                  const SizedBox(height: 10),
                  _buildTextField(
                      label: 'E-Mail', controller: _email, initialValue: '${snapshot.data!.mail}'),
                  TextField(
                    maxLines: 3,
                    decoration: InputDecoration(
                      labelText: 'Descrizione',
                      hintText: snapshot.data?.description != null ? '${snapshot.data!.description}' : 'Inserisci una descrizione del profilo...',
                      filled: true,
                      fillColor: Colors.white,
                      border: OutlineInputBorder(
                          borderRadius: BorderRadius.circular(12.0)),
                    ),
                    controller: _description,
                  ),
                  const SizedBox(height: 20),
                  ElevatedButton(
                    onPressed: () {
                      showDialog(
                        context: context,
                        builder: (context) => AlertDialog(
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(20.0),
                          ),
                          elevation: 10,
                          backgroundColor: Colors.white,
                          contentPadding: const EdgeInsets.symmetric(vertical: 20, horizontal: 24),
                          title: Column(
                            children: [
                              Icon(
                                Icons.verified_user_rounded,
                                size: 40,
                                color: Theme.of(context).primaryColor,
                              ),
                              const SizedBox(height: 15),
                              const Text(
                                'Conferma Modifiche',
                                style: TextStyle(
                                  fontSize: 22,
                                  fontWeight: FontWeight.bold,
                                  color: Colors.black87,
                                ),
                                textAlign: TextAlign.center,
                              ),
                            ],
                          ),
                          content: const Text(
                            'Sei davvero sicuro di voler salvare le modifiche?',
                            style: TextStyle(
                              fontSize: 16,
                              color: Colors.grey,
                            ),
                            textAlign: TextAlign.center,
                          ),
                          actionsAlignment: MainAxisAlignment.center,
                          actions: [
                            TextButton(
                              onPressed: () => Navigator.pop(context),
                              style: TextButton.styleFrom(
                                foregroundColor: Colors.grey,
                                padding: const EdgeInsets.symmetric(horizontal: 25, vertical: 12),
                                shape: RoundedRectangleBorder(
                                  borderRadius: BorderRadius.circular(10),
                                ),
                              ),
                              child: const Text('ANNULLA'),
                            ),
                            ElevatedButton(
                              onPressed: () {
                                updateUser();
                                Navigator.pop(context);
                                Navigator.pop(context);
                              },
                              style: ElevatedButton.styleFrom(
                                backgroundColor: Theme.of(context).primaryColor,
                                foregroundColor: Colors.white,
                                padding: const EdgeInsets.symmetric(horizontal: 30, vertical: 12),
                                shape: RoundedRectangleBorder(
                                  borderRadius: BorderRadius.circular(10),
                                ),
                                elevation: 3,
                              ),
                              child: const Text('CONFERMA'),
                            ),
                          ],
                        )
                      );
                    },
                    style: ElevatedButton.styleFrom(
                      backgroundColor: Theme.of(context).primaryColor,
                      foregroundColor: Colors.white,
                      shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(12.0)),
                      minimumSize: const Size(double.infinity, 50),
                    ),
                    child: const Text('Salva Profilo'),
                  ),
                ],
              ),
            ),
          );
        });
  }

  Widget _buildTextField({required String label, required TextEditingController controller, String? initialValue}) {

    return Padding(
      padding: const EdgeInsets.only(bottom: 10.0),
      child: TextField(
        decoration: InputDecoration(
          labelText: label,
          hintText: initialValue,
          filled: true,
          fillColor: Colors.white,
          border: OutlineInputBorder(borderRadius: BorderRadius.circular(12.0)),
        ),
        controller: controller,
      ),
    );
  }
}
