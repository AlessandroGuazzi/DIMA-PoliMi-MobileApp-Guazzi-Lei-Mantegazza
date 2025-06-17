import 'dart:async';

import 'package:dima_project/models/userModel.dart';
import 'package:dima_project/screens/accountSettings.dart';
import 'package:dima_project/screens/avatarSelectionPage.dart';
import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:mockito/mockito.dart';

import 'mocks.mocks.dart';

class MockNavigatorObserver extends Mock implements NavigatorObserver {}

void main() {
  late MockAuthService mockAuthService;
  late MockNavigatorObserver mockNavigatorObserver;

  setUp(() {
    mockAuthService = MockAuthService();
    mockNavigatorObserver = MockNavigatorObserver();
  });

  Future<void> pumpTestableWidget(
      WidgetTester tester, Future<UserModel?> currentUserFuture) async {
    await tester.pumpWidget(MaterialApp(
      home: Scaffold(
          body: AccountSettings(
              currentUserFuture: currentUserFuture,
              authService: mockAuthService)),
      navigatorObservers: [mockNavigatorObserver],
    ));
  }

  group('FutureBuilder states', () {
    final testUser = UserModel(
      name: 'Mario',
      surname: 'Rossi',
      username: 'mariorossi',
      birthDate: DateTime(1990, 1, 1),
      description: 'Test user',
    );

    testWidgets('displays loading indicator while waiting',
        (WidgetTester tester) async {
      final completer = Completer<UserModel?>();

      await pumpTestableWidget(tester, completer.future);

      expect(find.byType(CircularProgressIndicator), findsOneWidget);
    });

    testWidgets('displays error message on error', (tester) async {
      final completer = Completer<UserModel?>();

      await pumpTestableWidget(tester, completer.future);
      completer.completeError('Test error');
      await tester.pumpAndSettle();

      expect(find.textContaining('Errore:'), findsOneWidget);
    });

    testWidgets('displays "Utente non trovato" on null data',
        (WidgetTester tester) async {
      final future = Future.value(null);

      await pumpTestableWidget(tester, future);
      await tester.pumpAndSettle();

      expect(find.text('Utente non trovato'), findsOneWidget);
    });

    testWidgets('displays user UI on valid data', (WidgetTester tester) async {
      final future = Future.value(testUser);

      await pumpTestableWidget(tester, future);
      await tester.pumpAndSettle();

      expect(find.text('Modifica Profilo'), findsOneWidget);
      expect(find.text('Nome'), findsOneWidget);
      expect(find.text('Cognome'), findsOneWidget);
      expect(find.text('Username'), findsOneWidget);
    });
  });

  group('Form fields', () {
    final testUser = UserModel(
      id: '1',
      name: 'InitialName',
      surname: 'InitialSurname',
      username: 'initialuser',
      birthDate: DateTime(1990, 2, 2),
      description: 'Initial description',
      mail: 'test@example.com',
      profilePic: null,
    );

    testWidgets('Name field displays initial value and accepts input',
        (WidgetTester tester) async {
      await pumpTestableWidget(tester, Future.value(testUser));
      await tester.pumpAndSettle();

      final nameField = find.byWidgetPredicate(
        (widget) =>
            widget is TextField && widget.decoration?.labelText == 'Nome',
      );

      expect(nameField, findsOneWidget);
      expect(find.text('InitialName'), findsOneWidget);

      await tester.enterText(nameField, 'NewName');
      expect(find.text('NewName'), findsOneWidget);
    });

    testWidgets('Surname field displays initial value and accepts input',
        (WidgetTester tester) async {
      await pumpTestableWidget(tester, Future.value(testUser));
      await tester.pumpAndSettle();

      final surnameField = find.byWidgetPredicate(
        (widget) =>
            widget is TextField && widget.decoration?.labelText == 'Cognome',
      );

      expect(surnameField, findsOneWidget);
      expect(find.text('InitialSurname'), findsOneWidget);

      await tester.enterText(surnameField, 'NewSurname');
      expect(find.text('NewSurname'), findsOneWidget);
    });

    testWidgets('Username field displays initial value and accepts input',
        (WidgetTester tester) async {
      await pumpTestableWidget(tester, Future.value(testUser));
      await tester.pumpAndSettle();

      final usernameField = find.byWidgetPredicate(
        (widget) =>
            widget is TextField && widget.decoration?.labelText == 'Username',
      );

      expect(usernameField, findsOneWidget);
      expect(find.text('initialuser'), findsOneWidget);

      await tester.enterText(usernameField, 'newusername');
      expect(find.text('newusername'), findsOneWidget);
    });

    testWidgets('Description field displays initial value and accepts input',
        (WidgetTester tester) async {
      await pumpTestableWidget(tester, Future.value(testUser));
      await tester.pumpAndSettle();

      final descriptionField = find.byWidgetPredicate(
        (widget) =>
            widget is TextField &&
            widget.decoration?.labelText == 'Descrizione',
      );

      expect(descriptionField, findsOneWidget);
      expect(find.text('Initial description'), findsOneWidget);

      await tester.enterText(descriptionField, 'Updated description');
      expect(find.text('Updated description'), findsOneWidget);
    });

    testWidgets(
        'Birth date field displays initial hint and updates on date pick',
        (WidgetTester tester) async {
      await pumpTestableWidget(tester, Future.value(testUser));
      await tester.pumpAndSettle();

      final birthDateField = find.byWidgetPredicate(
        (widget) =>
            widget is TextField &&
            widget.decoration?.labelText == 'Data di Nascita',
      );

      expect(birthDateField, findsOneWidget);
      expect(find.text('02/02/1990'), findsOneWidget);

      final calendarIcon = find.byIcon(Icons.calendar_today);
      expect(calendarIcon, findsOneWidget);
      await tester.tap(calendarIcon);
      await tester.pumpAndSettle();

      // Select a new date
      await tester.tap(find.text('1'));
      await tester.tap(find.text('OK'));
      await tester.pumpAndSettle();

      final month = DateTime.now().month;
      final year = DateTime.now().year;
      final dateString = '1/$month/$year';

      expect(find.textContaining(dateString), findsOneWidget);
    });
  });

  testWidgets('Clicking avatar opens AvatarSelectionPage and updates avatar preview', (WidgetTester tester) async {
    final testUser = UserModel(
      id: '1',
      name: 'InitialName',
      surname: 'InitialSurname',
      username: 'initialuser',
      birthDate: DateTime(1990, 2, 2),
      description: 'Initial description',
      mail: 'test@example.com',
      profilePic: 'assets/avatars/avatar_1.png',
    );

    await pumpTestableWidget(tester, Future.value(testUser));
    await tester.pumpAndSettle();

    // Verify initial avatar is displayed
    final circleAvatar = find.byType(CircleAvatar).first;
    expect(circleAvatar, findsWidgets);
    expect(find.byWidgetPredicate((widget) =>
    widget is Image &&
        widget.image is AssetImage &&
        (widget.image as AssetImage).assetName == testUser.profilePic), findsOneWidget);

    // Tap on the avatar to trigger navigation
    await tester.tap(circleAvatar);
    await tester.pumpAndSettle();

    // Verify AvatarSelectionPage is displayed
    expect(find.byType(AvatarSelectionPage), findsOneWidget);

    //simulate return from the page with a new avatar path
    const newAvatarPath = 'assets/avatars/avatar_3.png';
    final NavigatorState nav = tester.state(find.byType(Navigator));
    nav.pop<String>(newAvatarPath);
    await tester.pumpAndSettle();

    expect(find.byWidgetPredicate((widget) =>
    widget is Image &&
        widget.image is AssetImage &&
        (widget.image as AssetImage).assetName == newAvatarPath), findsOneWidget);
  });

  testWidgets('Save button opens confirmation dialog and handles cancel/confirm', (WidgetTester tester) async {
    final testUser = UserModel(
      name: 'Mario',
      surname: 'Rossi',
      username: 'mariorossi',
      birthDate: DateTime(1990, 1, 1),
      description: 'Test user',
    );

    await pumpTestableWidget(tester, Future.value(testUser));
    await tester.pumpAndSettle();

    final saveButton = find.widgetWithText(ElevatedButton, 'Salva Profilo');
    await tester.ensureVisible(saveButton);
    await tester.pumpAndSettle();
    expect(saveButton, findsOneWidget);

    await tester.tap(saveButton);
    await tester.pumpAndSettle();


    expect(find.text('Conferma Modifiche'), findsOneWidget);
    expect(find.text('Sei davvero sicuro di voler salvare le modifiche?'), findsOneWidget);

    //Cancel closes dialog
    final cancelButton = find.widgetWithText(TextButton, 'ANNULLA');
    expect(cancelButton, findsOneWidget);
    await tester.tap(cancelButton);
    await tester.pumpAndSettle();
    expect(find.text('Conferma Modifiche'), findsNothing);

    await tester.tap(saveButton);
    await tester.pumpAndSettle();

    // Confirm calls updateUser
    when(mockAuthService.updateUserWithEmailAndPassword(
      name: anyNamed('name'),
      surname: anyNamed('surname'),
      username: anyNamed('username'),
      birthDate: anyNamed('birthDate'),
      description: anyNamed('description'),
      profilePic: anyNamed('profilePic'),
    )).thenAnswer((_) async {});

    final confirmButton = find.widgetWithText(ElevatedButton, 'CONFERMA');
    await tester.tap(confirmButton);
    await tester.pumpAndSettle();

    // Verify updateUser called
    verify(mockAuthService.updateUserWithEmailAndPassword(
      name: anyNamed('name'),
      surname: anyNamed('surname'),
      username: anyNamed('username'),
      birthDate: anyNamed('birthDate'),
      description: anyNamed('description'),
      profilePic: anyNamed('profilePic'),
    )).called(1);
  });
}
