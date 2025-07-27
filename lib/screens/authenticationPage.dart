import 'package:country_picker/country_picker.dart';
import 'package:dima_project/services/authService.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';

import '../widgets/countryPickerWidget.dart';

class AuthPage extends StatefulWidget {
  late final AuthService authService;

  AuthPage({super.key, authService})
      : authService = authService ?? AuthService();

  @override
  State<AuthPage> createState() => _AuthPageState();
}

class _AuthPageState extends State<AuthPage> {
  final _formKey = GlobalKey<FormState>();
  final TextEditingController _email = TextEditingController();
  final TextEditingController _password = TextEditingController();
  final TextEditingController _name = TextEditingController();
  final TextEditingController _surname = TextEditingController();
  final TextEditingController _username = TextEditingController();
  final TextEditingController _birthDate = TextEditingController();
  final TextEditingController _nationality = TextEditingController();
  bool isLogin = true;
  DateTime? selectedBirthDate;

  @override
  Widget build(BuildContext context) {
    return Scaffold(
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
          child: ConstrainedBox(
            constraints: const BoxConstraints(
              maxWidth: 700,
            ),
            child: Card(
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(20),
              ),
              elevation: 8,
              margin: const EdgeInsets.symmetric(horizontal: 30),
              child: Padding(
                padding: const EdgeInsets.all(20.0),
                child: SingleChildScrollView(
                  child: Form(
                    key: _formKey,
                    child: Column(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        Image.asset('assets/app_logo.png',
                            width: 150, height: 150),
                        if (!isLogin) ...[
                          TextFormField(
                            key: const Key('nameField'),
                            controller: _name,
                            decoration: InputDecoration(
                              labelText: 'Nome',
                            ),
                            validator: (value) {
                              if (value == null || value.isEmpty) {
                                return "Per favore seleziona un nome";
                              }
                              return null;
                            },
                          ),
                          const SizedBox(height: 12),
                          TextFormField(
                            key: const Key('surnameField'),
                            controller: _surname,
                            decoration: const InputDecoration(
                              labelText: 'Cognome',
                            ),
                            validator: (value) {
                              if (value == null || value.isEmpty) {
                                return "Per favore seleziona un cognome";
                              }
                              return null;
                            },
                          ),
                          const SizedBox(height: 12),
                          TextFormField(
                            key: const Key('usernameField'),
                            controller: _username,
                            decoration: const InputDecoration(
                              labelText: 'Username',
                            ),
                            validator: (value) {
                              if (value == null || value.isEmpty) {
                                return "Per favore seleziona un username";
                              }
                              return null;
                            },
                          ),
                          const SizedBox(height: 12),
                          TextFormField(
                            key: const Key('birthDateField'),
                            controller: _birthDate,
                            readOnly: true,
                            onTap: () => _selectDate(context),
                            decoration: const InputDecoration(
                              labelText: 'Data di Nascita',
                              suffixIcon: Icon(Icons.calendar_today),
                            ),
                            validator: (value) {
                              if (selectedBirthDate == null) {
                                return "Per favore seleziona una data di nascita";
                              }
                              return null;
                            },
                          ),
                          const SizedBox(height: 12),
                          TextFormField(
                            key: const Key('nationalityField'),
                            controller: _nationality,
                            readOnly: true,
                            decoration: const InputDecoration(
                              labelText: 'Nazionalità',
                            ),
                            onTap: () => {_openCountryPicker()},
                            validator: (value) {
                              if (value == null || value.isEmpty) {
                                return "Per favore seleziona una nazionalità";
                              }
                              return null;
                            },
                          ),
                          const SizedBox(height: 12),
                        ],
                        TextFormField(
                          key: const Key('emailField'),
                          controller: _email,
                          keyboardType: TextInputType.emailAddress,
                          decoration: const InputDecoration(
                            labelText: 'Email',
                          ),
                          validator: (value) {
                            if (value == null || value.isEmpty) {
                              return "Per favore inserisci un indirizzo email";
                            }
                            return null;
                          },
                        ),
                        const SizedBox(height: 12),
                        TextFormField(
                          key: const Key('passwordField'),
                          controller: _password,
                          obscureText: true,
                          decoration: const InputDecoration(
                            labelText: 'Password',
                          ),
                          validator: (value) {
                            if (value == null || value.isEmpty) {
                              return "Per favore inserisci una password";
                            }
                            return null;
                          },
                        ),
                        const SizedBox(height: 20),
                        ElevatedButton(
                          key: const Key('submitButton'),
                          onPressed: () {
                            if (_formKey.currentState?.validate() ?? false) {
                              if (isLogin) {
                                signIn();
                              } else {
                                createUser();
                              }
                            }
                          },
                          style: ElevatedButton.styleFrom(
                            backgroundColor: Theme.of(context).primaryColor,
                            foregroundColor: Colors.white,
                            minimumSize: const Size(double.infinity, 50),
                            shape: RoundedRectangleBorder(
                              borderRadius: BorderRadius.circular(30),
                            ),
                          ),
                          child: Text(isLogin ? 'Accedi' : 'Registrati'),
                        ),
                        TextButton(
                          key: const Key('toggleAuthMode'),
                          onPressed: () {
                            setState(() {
                              _formKey.currentState?.reset();
                              _email.clear();
                              _password.clear();
                              isLogin = !isLogin;
                            });
                          },
                          child: Text(
                            isLogin
                                ? 'Non hai un account? Registrati'
                                : 'Hai un account? Accedi',
                            style: TextStyle(
                                color: Theme.of(context).secondaryHeaderColor),
                          ),
                        )
                      ],
                    ),
                  ),
                ),
              ),
            ),
          ),
        ),
      ),
    );
  }

  void showCredentialsError(FirebaseAuthException error) {
    String message = 'Si è verificato un errore. Riprova.';
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Row(
          children: [
            const Icon(Icons.error, color: Colors.white),
            const SizedBox(width: 10),
            Expanded(
                child: Text(
              error.message ?? message,
              softWrap: true,
            )),
          ],
        ),
        backgroundColor: Colors.red,
        action: SnackBarAction(
          label: 'OK',
          onPressed: () {},
          textColor: Colors.white,
        ),
      ),
    );
  }

  Future<void> signIn() async {
    try {
      await widget.authService.signInWithEmailAndPassword(
          email: _email.text, password: _password.text);
    } on FirebaseAuthException catch (error) {
      showCredentialsError(error);
    }
  }

  Future<void> createUser() async {
    try {
      await widget.authService.createUserWithEmailAndPassword(
          name: _name.text.trim(),
          surname: _surname.text.trim(),
          email: _email.text.trim(),
          password: _password.text.trim(),
          username: _username.text.trim(),
          birthDate: selectedBirthDate,
          nationality: _nationality.text.trim());
    } on FirebaseAuthException catch (error) {
      showCredentialsError(error);
    }
  }

  Future<void> _selectDate(BuildContext context) async {
    final DateTime? picked = await showDatePicker(
      context: context,
      initialDate: DateTime.now(),
      firstDate: DateTime(1900),
      lastDate: DateTime.now(),
    );
    if (picked != null && picked != selectedBirthDate) {
      setState(() {
        selectedBirthDate = picked;
        _birthDate.text = "${picked.day}/${picked.month}/${picked.year}";
      });
    }
  }

  void _openCountryPicker() async {
    await showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(20)),
      ),
      builder: (BuildContext context) {
        return CountryPickerWidget(
          selectedCountries: [],
          onCountriesSelected: _onCountrySelected,
          isUserNationality: true,
        );
      },
    );
  }

  void _onCountrySelected(List<Country> country) {
    _nationality.text = country.first.name;
  }
}
