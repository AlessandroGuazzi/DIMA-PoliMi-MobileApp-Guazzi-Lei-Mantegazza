import 'package:dima_project/screens/authenticationPage.dart';
import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:mockito/mockito.dart';
import 'package:firebase_auth/firebase_auth.dart';

import 'mocks.mocks.dart';

class MockUserCredential extends Mock implements UserCredential {}

void main() {
  late MockAuthService mockAuthService;
  late MockUserCredential mockUserCredential;

  setUp(() {
    mockAuthService = MockAuthService();
    mockUserCredential = MockUserCredential();
  });

  Future<void> pumpTestableWidget(WidgetTester tester) async {
    await tester.pumpWidget(MaterialApp(
        home: Scaffold(
          body: AuthPage(
            authService: mockAuthService,
          ),
        )));
  }

  group('UI State Management Tests', () {

    testWidgets('should start in login mode by default', (tester) async {
      await pumpTestableWidget(tester);

      expect(find.text('Accedi'), findsOneWidget);
      expect(find.text('Registrati'), findsNothing);
      expect(find.text('Non hai un account? Registrati'), findsOneWidget);

      expect(find.byType(TextFormField), findsNWidgets(2));

      // registration-only fields are not present
      expect(find.text('Nome'), findsNothing);
      expect(find.text('Cognome'), findsNothing);
      expect(find.text('Username'), findsNothing);
      expect(find.text('Data di Nascita'), findsNothing);
      expect(find.text('Nazionalità'), findsNothing);
    });

    testWidgets('should switch to registration mode when toggle is tapped', (tester) async {
      await pumpTestableWidget(tester);

      expect(find.text('Accedi'), findsOneWidget);


      final toggleButton = find.text('Non hai un account? Registrati');
      tester.ensureVisible(toggleButton);
      expect(toggleButton, findsOneWidget);
      await tester.tap(toggleButton);
      await tester.pumpAndSettle();

      expect(find.text('Registrati'), findsOneWidget);
      expect(find.text('Accedi'), findsNothing);
      expect(find.text('Hai un account? Accedi'), findsOneWidget);

      expect(find.byType(TextFormField), findsNWidgets(7));

      expect(find.text('Nome'), findsOneWidget);
      expect(find.text('Cognome'), findsOneWidget);
      expect(find.text('Username'), findsOneWidget);
      expect(find.text('Data di Nascita'), findsOneWidget);
      expect(find.text('Nazionalità'), findsOneWidget);

      // Switch back to login mode
      final newToggleButton = find.text('Hai un account? Accedi');
      tester.ensureVisible(newToggleButton);
      expect(newToggleButton, findsOneWidget);

      await tester.tap(newToggleButton);
      await tester.pumpAndSettle();

      // Verify we're back in login mode
      expect(find.text('Accedi'), findsOneWidget);
      expect(find.text('Registrati'), findsNothing);
      expect(find.text('Non hai un account? Registrati'), findsOneWidget);
    });

    testWidgets('should reset form when switching from login to registration', (tester) async {
      await pumpTestableWidget(tester);

      // Fill login form
      final emailField = find.widgetWithText(TextFormField, 'Email');
      final passwordField = find.widgetWithText(TextFormField, 'Password');

      await tester.enterText(emailField, 'test@example.com');
      await tester.enterText(passwordField, 'password123');

      expect(find.text('test@example.com'), findsOneWidget);
      expect(find.text('password123'), findsOneWidget);

      // Switch to registration mode
      await tester.tap(find.text('Non hai un account? Registrati'));
      await tester.pumpAndSettle();

      final newEmailField = find.widgetWithText(TextFormField, 'Email');
      final emailWidget = tester.widget<TextFormField>(newEmailField);
      expect(emailWidget.controller?.text, isEmpty);

      final newPasswordField = find.widgetWithText(TextFormField, 'Password');
      final passwordWidget = tester.widget<TextFormField>(newPasswordField);
      expect(passwordWidget.controller?.text, isEmpty);
    });
  });

  group('Form Validation Tests', () {
    testWidgets('should show error when email field is empty on login', (tester) async {
      await pumpTestableWidget(tester);

      expect(find.text('Accedi'), findsOneWidget);

      await tester.tap(find.text('Accedi'));
      await tester.pumpAndSettle();

      expect(find.text('Per favore inserisci un indirizzo email'), findsOneWidget);
      expect(find.text('Per favore inserisci una password'), findsOneWidget);
    });

    testWidgets('should show error when fields are empty on registration', (tester) async {
      await pumpTestableWidget(tester);

      // Switch to registration mode
      await tester.tap(find.text('Non hai un account? Registrati'));
      await tester.pumpAndSettle();

      final registrationButton = find.widgetWithText(ElevatedButton, 'Registrati');
      tester.ensureVisible(registrationButton);
      expect(registrationButton, findsOneWidget);

      await tester.tap(find.text('Registrati'));

      await tester.pumpAndSettle();

      expect(find.text('Per favore seleziona un nome'), findsOneWidget);
      expect(find.text('Per favore seleziona un cognome'), findsOneWidget);
      expect(find.text('Per favore seleziona un username'), findsOneWidget);
      expect(find.text('Per favore seleziona una data di nascita'), findsOneWidget);
      expect(find.text('Per favore seleziona una nazionalità'), findsOneWidget);
      expect(find.text('Per favore inserisci un indirizzo email'), findsOneWidget);
      expect(find.text('Per favore inserisci una password'), findsOneWidget);

    });

    testWidgets('should not show validation errors when all fields are filled correctly', (tester) async {
      await pumpTestableWidget(tester);

      // Fill email and password for login
      final textFields = find.byType(TextFormField);
      await tester.enterText(textFields.at(0), 'test@example.com'); // email
      await tester.enterText(textFields.at(1), 'password123');      // password

      // Mock successful login
      when(mockAuthService.signInWithEmailAndPassword(
        email: anyNamed('email'),
        password: anyNamed('password'),
      )).thenAnswer((_) async => MockUserCredential());

      // Tap login button
      await tester.tap(find.text('Accedi'));
      await tester.pumpAndSettle();

      // Verify no validation error messages appear
      expect(find.text('Per favore inserisci un indirizzo email'), findsNothing);
      expect(find.text('Per favore inserisci una password'), findsNothing);

    });
  });

  group('Authentication Flow Tests', () {

    Future<DateTime> fillRegistrationForm(WidgetTester tester) async {

      // Fill registration form
      final nameField = find.widgetWithText(TextFormField, 'Nome');
      await tester.ensureVisible(nameField);
      final surnameField = find.widgetWithText(TextFormField, 'Cognome');
      await tester.ensureVisible(surnameField);
      final usernameField = find.widgetWithText(TextFormField, 'Username');
      await tester.ensureVisible(usernameField);

      await tester.enterText(nameField, 'Nick');
      await tester.enterText(surnameField, 'Fury');
      await tester.enterText(usernameField, 'nickfuryy');

      // Scroll down to reveal more fields
      await tester.drag(find.byType(SingleChildScrollView), const Offset(0, -200));
      await tester.pumpAndSettle();

      final birthField = find.widgetWithText(TextFormField, 'Data di Nascita');
      await tester.ensureVisible(birthField);
      final nationalityField = find.widgetWithText(TextFormField, 'Nazionalità');
      await tester.ensureVisible(nationalityField);
      final emailField = find.widgetWithText(TextFormField, 'Email');
      await tester.ensureVisible(emailField);
      final passwordField = find.widgetWithText(TextFormField, 'Password');
      await tester.ensureVisible(passwordField);


      await tester.tap(birthField);
      await tester.pumpAndSettle();

      //tap on first of the month to ensure that is clickable
      await tester.tap(find.text('1'));
      await tester.pumpAndSettle();

      await tester.tap(find.text('OK'));
      await tester.pumpAndSettle();

      final birthDate = DateTime(DateTime.now().year,DateTime.now().month, 1);


      //nationality
      await tester.tap(nationalityField);
      await tester.pumpAndSettle();
      //tap first country (Afghanistan)
      await tester.tap(find.text('Afghanistan'));
      await tester.pumpAndSettle();

      await tester.enterText(emailField, 'test@example.com');
      await tester.enterText(passwordField, 'password123');

      return birthDate;
    }

    testWidgets('should call signInWithEmailAndPassword on successful login', (tester) async {
      await pumpTestableWidget(tester);

      when(mockAuthService.signInWithEmailAndPassword(
        email: anyNamed('email'),
        password: anyNamed('password'),
      )).thenAnswer((_) async => mockUserCredential);

      final textFields = find.byType(TextFormField);
      await tester.enterText(textFields.at(0), 'test@example.com'); // email
      await tester.enterText(textFields.at(1), 'password123');      // password

      await tester.tap(find.text('Accedi'));
      await tester.pumpAndSettle();

      verify(mockAuthService.signInWithEmailAndPassword(
        email: 'test@example.com',
        password: 'password123',
      )).called(1);
    });

    testWidgets('should call createUserWithEmailAndPassword on successful registration', (tester) async {
      await pumpTestableWidget(tester);

      await tester.tap(find.text('Non hai un account? Registrati'));
      await tester.pumpAndSettle();

      when(mockAuthService.createUserWithEmailAndPassword(
        name: anyNamed('name'),
        surname: anyNamed('surname'),
        email: anyNamed('email'),
        password: anyNamed('password'),
        username: anyNamed('username'),
        birthDate: anyNamed('birthDate'),
        nationality: anyNamed('nationality'),
      )).thenAnswer((_) async => mockUserCredential);

      final birthDate = await fillRegistrationForm(tester);

      await tester.tap(find.text('Registrati'));
      await tester.pumpAndSettle();

      // Verify the method was called with correct parameters
      verify(mockAuthService.createUserWithEmailAndPassword(
        name: 'Nick',
        surname: 'Fury',
        email: 'test@example.com',
        password: 'password123',
        username: 'nickfuryy',
        birthDate: birthDate,
        nationality: 'Afghanistan',
      )).called(1);
    });

    testWidgets('should handle FirebaseAuthException on login failure', (tester) async {
      await pumpTestableWidget(tester);

      // Mock login failure
      final authException = FirebaseAuthException(
        code: 'user-not-found',
        message: 'No user found for that email.',
      );

      when(mockAuthService.signInWithEmailAndPassword(
        email: anyNamed('email'),
        password: anyNamed('password'),
      )).thenThrow(authException);

      // Fill login form
      final textFields = find.byType(TextFormField);
      await tester.enterText(textFields.at(0), 'test@example.com');
      await tester.enterText(textFields.at(1), 'wrongPassword');

      // Tap login button
      await tester.tap(find.text('Accedi'));
      await tester.pumpAndSettle();

      // Verify error SnackBar is shown
      expect(find.byType(SnackBar), findsOneWidget);
      expect(find.text('No user found for that email.'), findsOneWidget);
      expect(find.byIcon(Icons.error), findsOneWidget);
    });

    testWidgets('should handle FirebaseAuthException on registration failure', (tester) async {
      await pumpTestableWidget(tester);

      await tester.tap(find.text('Non hai un account? Registrati'));
      await tester.pumpAndSettle();

      final authException = FirebaseAuthException(
        code: 'email-already-in-use',
        message: 'The account already exists for that email.',
      );

      when(mockAuthService.createUserWithEmailAndPassword(
        name: anyNamed('name'),
        surname: anyNamed('surname'),
        email: anyNamed('email'),
        password: anyNamed('password'),
        username: anyNamed('username'),
        birthDate: anyNamed('birthDate'),
        nationality: anyNamed('nationality'),
      )).thenThrow(authException);

      final birthDate = await fillRegistrationForm(tester);

      // Tap register button
      await tester.tap(find.text('Registrati'));
      await tester.pumpAndSettle();

      // Verify error SnackBar is shown
      expect(find.byType(SnackBar), findsOneWidget);
      expect(find.text('The account already exists for that email.'), findsOneWidget);
      expect(find.byIcon(Icons.error), findsOneWidget);
    });

  });


}