import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import '../models/userModel.dart';
import '../utils/screenSize.dart';

class AccountSettings extends StatefulWidget {
  const AccountSettings({super.key, required this.currentUserFuture});

  final Future<UserModel?> currentUserFuture;

  @override
  State<AccountSettings> createState() => _AccountSettingsState();
}

class _AccountSettingsState extends State<AccountSettings> {
  late Future<UserModel?> _currentUserFuture;
  late TextEditingController _dateController;

  @override
  void initState() {
    super.initState();
    _currentUserFuture = widget.currentUserFuture;
    _dateController = TextEditingController();
  }

  Future<void> _selectDate(BuildContext context) async {
    DateTime? pickedDate = await showDatePicker(
      context: context,
      initialDate: DateTime.now(),
      firstDate: DateTime(1900),
      lastDate: DateTime.now(),
    );

    if (pickedDate != null) {
      setState(() {
        _dateController.text = "${pickedDate.day.toString().padLeft(2, '0')}/"
            "${pickedDate.month.toString().padLeft(2, '0')}/"
            "${pickedDate.year}";
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

          _dateController.text = DateFormat('dd/MM/yyyy').format(snapshot.data!.birthDate!);


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
                  _buildTextField(label: 'Nome', initialValue: '${snapshot.data!.name}'),
                  _buildTextField(label: 'Cognome', initialValue: '${snapshot.data!.surname}'),
                  _buildTextField(
                      label: 'Username', initialValue: '${snapshot.data!.username}'),
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
                    ),
                  ),
                  const SizedBox(height: 10),
                  _buildTextField(label: 'Nazionalità', initialValue: '${snapshot.data!.birthCountry}'),
                  const SizedBox(height: 10),
                  _buildTextField(
                      label: 'E-Mail', initialValue: '${snapshot.data!.mail}'),
                  TextField(
                    maxLines: 3,
                    decoration: InputDecoration(
                      labelText: 'Descrizione',
                      hintText:
                          'Ciao, sono Marco! Mi piace viaggiare e scoprire nuovi posti.',
                      filled: true,
                      fillColor: Colors.white,
                      border: OutlineInputBorder(
                          borderRadius: BorderRadius.circular(12.0)),
                    ),
                  ),
                  const SizedBox(height: 20),
                  ElevatedButton(
                    onPressed: () {},
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

  Widget _buildTextField({required String label, String? initialValue}) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 10.0),
      child: TextField(
        decoration: InputDecoration(
          labelText: label,
          filled: true,
          fillColor: Colors.white,
          border: OutlineInputBorder(borderRadius: BorderRadius.circular(12.0)),
        ),
        controller: TextEditingController(text: initialValue),
      ),
    );
  }
}
