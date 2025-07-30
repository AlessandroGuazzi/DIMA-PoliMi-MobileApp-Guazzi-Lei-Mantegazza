import 'package:dima_project/utils/responsive.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import '../models/userModel.dart';
import '../services/authService.dart';
import '../utils/screenSize.dart';
import '../widgets/components/myConfirmDialog.dart';
import 'avatarSelectionPage.dart';


class AccountSettings extends StatefulWidget {
  final Future<UserModel?>? currentUserFuture;
  final AuthService authService;

  AccountSettings({super.key, required this.currentUserFuture, authService})
      : authService = authService ?? AuthService();

  @override
  State<AccountSettings> createState() => _AccountSettingsState();
}

class _AccountSettingsState extends State<AccountSettings> {
  late Future<UserModel?>? _currentUserFuture;
  late Function onRefresh;
  late TextEditingController _dateController;
  final _name = TextEditingController();
  final _surname = TextEditingController();
  final _username = TextEditingController();
  final _description = TextEditingController();
  DateTime? selectedBirthDate;
  String? _selectedAvatarPath;

  @override
  void initState() {
    super.initState();
    _currentUserFuture = widget.currentUserFuture;
    _dateController = TextEditingController();
  }

  Future<void> updateUser() async {
    try {
      await widget.authService.updateUserWithEmailAndPassword(
          name: _name.text.isEmpty ? null : _name.text.trim(),
          surname: _surname.text.isEmpty ? null : _surname.text.trim(),
          username: _username.text.isEmpty ? null : _username.text.trim(),
          birthDate: selectedBirthDate,
          description: _description.text.isEmpty ? null : _description.text,
          profilePic: _selectedAvatarPath);
    } on FirebaseAuthException catch (error) {
      if (context.mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text(error.message ?? 'Errore nella modifica del profilo'),
            backgroundColor: Colors.red,
          ),
        );
      }
    }
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
        _dateController.text =
            "${pickedDate.day}/${pickedDate.month}/${pickedDate.year}";
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    //
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

          final user = snapshot.data!;
          //executes only the first time the widget is built
          _selectedAvatarPath ??= user.profilePic;

          return Scaffold(
              appBar: AppBar(
                title: const Text('Modifica Profilo'),
                backgroundColor: Theme.of(context).primaryColor,
                elevation: 0,
              ),
              body: Container(
                decoration: BoxDecoration(
                  gradient: LinearGradient(
                    colors: [
                      Theme.of(context).primaryColor,
                      Theme.of(context).secondaryHeaderColor
                    ],
                    begin: Alignment.topCenter,
                    end: Alignment.bottomCenter,
                  ),
                ),
                child: Center(
                  child: Card(
                    margin: const EdgeInsets.symmetric(
                        vertical: 40, horizontal: 20),
                    elevation: 8,
                    child: ResponsiveLayout(
                        mobileLayout: _buildMobileLayout(user),
                        tabletLayout: _buildTabletLayout(user)),
                  ),
                ),
              ));
        });
  }

  Widget _buildMobileLayout(UserModel user) {
    return SingleChildScrollView(
      padding: const EdgeInsets.all(20.0),
      child: Column(
        children: [
          Center(
            child: Stack(
              children: [
                GestureDetector(
                    onTap: () {
                      _openAvatarSelectionPage();
                    },
                    child: CircleAvatar(
                      minRadius: 60,
                      maxRadius: 70,
                      child: _selectedAvatarPath == null
                          ? Image.asset(
                              'assets/profile.png',
                              fit: BoxFit.cover,
                            )
                          : Image.asset(
                              _selectedAvatarPath!,
                              fit: BoxFit.cover,
                            ),
                    )),
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
          _buildTextField(
            key: const Key('nameField'),
            label: 'Nome',
            controller: _name,
            initialValue: '${user.name}',
          ),
          _buildTextField(
            key: const Key('surnameField'),
            label: 'Cognome',
            controller: _surname,
            initialValue: '${user.surname}',
          ),
          _buildTextField(
            key: const Key('usernameField'),
            label: 'Username',
            controller: _username,
            initialValue: '${user.username}',
          ),
          TextField(
            controller: _dateController,
            decoration: InputDecoration(
              labelText: 'Data di Nascita',
              suffixIcon: IconButton(
                icon: const Icon(Icons.calendar_today),
                onPressed: () => _selectDate(context),
              ),
              hintText: DateFormat('dd/MM/yyyy').format(user.birthDate ?? DateTime.now()),
            ),
          ),
          const SizedBox(height: 10),
          TextField(
            maxLines: 3,
            decoration: InputDecoration(
              labelText: 'Descrizione',
              hintText: user.description != null
                  ? '${user.description}'
                  : 'Inserisci una descrizione del profilo...',
              border:
                  OutlineInputBorder(borderRadius: BorderRadius.circular(12.0)),
            ),
            controller: _description,
          ),
          const SizedBox(height: 20),
          ElevatedButton(
            key: Key('saveButton'),
            onPressed: () {
              showDialog(
                context: context,
                builder: (_) => MyConfirmDialog(
                  icon: Icons.verified_user_rounded,
                  iconColor: Theme.of(context).primaryColor,
                  title: 'Conferma Modifiche',
                  message: 'Sei davvero sicuro di voler salvare le modifiche?',
                  confirmText: 'Conferma',
                  cancelText: 'Annulla',
                  onConfirm: () {
                    updateUser();
                    Navigator.pop(context);
                    Navigator.pop(context);
                  },
                ),
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
    );
  }

  Widget _buildTabletLayout(UserModel user) {
    return Row(
      children: [
        Expanded(
            flex: 2,
            child: Padding(
              padding: const EdgeInsets.all(10.0),
              child: _buildMobileLayout(user),
            )),
        Expanded(
            flex: 3,
            child: Center(
                child: SizedBox(
                    height: ScreenSize.screenHeight(context) * 0.8,
                    width: ScreenSize.screenHeight(context) * 0.8,
                    child: Image.asset('assets/account_illustration.png')))),
      ],
    );
  }

  Widget _buildTextField({
    required String label,
    required TextEditingController controller,
    String? initialValue,
    Key? key, // aggiunto parametro opzionale
  }) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 10.0),
      child: TextField(
        key: key, // assegnata la key
        decoration: InputDecoration(
          labelText: label,
          hintText: initialValue,
        ),
        controller: controller,
      ),
    );
  }

  void _openAvatarSelectionPage() async {
    final selectedAvatar = await Navigator.push<String>(
      context,
      MaterialPageRoute(
        builder: (context) => AvatarSelectionPage(
          avatarPaths: List.generate(
            6,
            (index) => 'assets/avatars/avatar_$index.png',
          ),
          onAvatarSelected: (path) {
            Navigator.pop(context, path);
          },
        ),
      ),
    );

    if (selectedAvatar != null) {
      setState(() {
        _selectedAvatarPath = selectedAvatar;
      });
    }
  }
}
