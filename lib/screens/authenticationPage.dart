import 'package:dima_project/services/authService.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';

class AuthPage extends StatefulWidget {
  const AuthPage({super.key});

  @override
  State<AuthPage> createState() => _AuthPageState();
}

class _AuthPageState extends State<AuthPage> {
  final TextEditingController _email = TextEditingController();
  final TextEditingController _password = TextEditingController();
  final TextEditingController _name = TextEditingController();
  final TextEditingController _surname = TextEditingController();
  final TextEditingController _username = TextEditingController();
  final TextEditingController _birthDate = TextEditingController();
  final TextEditingController _nationality = TextEditingController();
  bool isLogin = true;
  DateTime? selectedBirthDate;

  // Lista di nazionalità per il dropdown
  final List<String> countries = [
    'Italia',
    'Francia',
    'Spagna',
    'Germania',
    'Regno Unito',
    'Stati Uniti',
    'Altro'
  ];

  Future<void> signIn() async {
    try {
      await AuthService().signInWithEmailAndPassword(
          email: _email.text,
          password: _password.text
      );
    } on FirebaseAuthException catch (error) {
      String message = 'Si è verificato un errore. Riprova.';
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Row(
            children: [
              const Icon(Icons.error, color: Colors.white),
              const SizedBox(width: 10),
              Text(message),
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
  }

  final snackBar = SnackBar(
    content: const Row(
      children: [
        Icon(Icons.warning, color: Colors.white), // Aggiungi un'icona
        SizedBox(width: 10),
        Text('Compila tutti i campi obbligatori.'), // Messaggio
      ],
    ),
    backgroundColor: Colors.red, // Colore di sfondo
    action: SnackBarAction(
      label: 'OK', // Etichetta del pulsante
      onPressed: () {}, // Azione al click
      textColor: Colors.white, // Colore del testo del pulsante
    ),
  );

  Future<void> createUser() async {
    try {
      await AuthService().createUserWithEmailAndPassword(
          name: _name.text.trim(),
          surname: _surname.text.trim(),
          email: _email.text.trim(),
          password: _password.text.trim(),
          username: _username.text.trim(),
          birthDate: selectedBirthDate,
          nationality: _nationality.text.trim());
    } on FirebaseAuthException catch (error) {}
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

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Welcome'),
        centerTitle: true,
        backgroundColor: Theme.of(context).primaryColor,
        elevation: 0,
      ),
      body: Container(
        decoration: BoxDecoration(
          gradient: LinearGradient(
            colors: [Theme.of(context).primaryColor, Colors.blueAccent],
            begin: Alignment.topCenter,
            end: Alignment.bottomCenter,
          ),
        ),
        child: Center(
          child: Card(
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(20),
            ),
            elevation: 8,
            margin: const EdgeInsets.symmetric(horizontal: 30),
            child: Padding(
              padding: const EdgeInsets.all(20.0),
              child: SingleChildScrollView(
                child: Column(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    if (!isLogin) ...[
                      TextField(
                        controller: _name,
                        decoration: InputDecoration(
                          labelText: 'Nome',
                          border: OutlineInputBorder(
                            borderRadius: BorderRadius.circular(10),
                          ),
                        ),
                      ),
                      const SizedBox(height: 12),
                      TextField(
                        controller: _surname,
                        decoration: InputDecoration(
                          labelText: 'Cognome',
                          border: OutlineInputBorder(
                            borderRadius: BorderRadius.circular(10),
                          ),
                        ),
                      ),
                      const SizedBox(height: 12),
                      TextField(
                        controller: _username,
                        decoration: InputDecoration(
                          labelText: 'Username',
                          border: OutlineInputBorder(
                            borderRadius: BorderRadius.circular(10),
                          ),
                        ),
                      ),
                      const SizedBox(height: 12),
                      TextField(
                        controller: _birthDate,
                        readOnly: true,
                        onTap: () => _selectDate(context),
                        decoration: InputDecoration(
                          labelText: 'Data di Nascita',
                          border: OutlineInputBorder(
                            borderRadius: BorderRadius.circular(10),
                          ),
                          suffixIcon: const Icon(Icons.calendar_today),
                        ),
                      ),
                      const SizedBox(height: 12),
                      TextField(
                        controller: _nationality,
                        decoration: InputDecoration(
                          labelText: 'Nazionalità',
                          border: OutlineInputBorder(
                            borderRadius: BorderRadius.circular(10),
                          ),
                        ),
                      ),
                      const SizedBox(height: 12),
                    ],
                    TextField(
                      controller: _email,
                      keyboardType: TextInputType.emailAddress,
                      decoration: InputDecoration(
                        labelText: 'Email',
                        border: OutlineInputBorder(
                          borderRadius: BorderRadius.circular(10),
                        ),
                      ),
                    ),
                    const SizedBox(height: 12),
                    TextField(
                      controller: _password,
                      obscureText: true,
                      decoration: InputDecoration(
                        labelText: 'Password',
                        border: OutlineInputBorder(
                          borderRadius: BorderRadius.circular(10),
                        ),
                      ),
                    ),
                    const SizedBox(height: 20),
                    ElevatedButton(
                      onPressed: () {
                        if (isLogin) {
                          signIn();
                        } else {
                          if (_validateFields()) {
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
                      onPressed: () {
                        setState(() {
                          isLogin = !isLogin;
                        });
                      },
                      child: Text(
                        isLogin
                            ? 'Non hai un account? Registrati'
                            : 'Hai un account? Accedi',
                        style: const TextStyle(color: Colors.indigoAccent),
                      ),
                    )
                  ],
                ),
              ),
            ),
          ),
        ),
      ),
    );
  }

  bool _validateFields() {
    if (_name.text.isEmpty ||
        _surname.text.isEmpty ||
        _username.text.isEmpty ||
        selectedBirthDate == null ||
        _email.text.isEmpty ||
        _nationality.text.isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(snackBar);
      return false;
    }
    return true;
  }
}
