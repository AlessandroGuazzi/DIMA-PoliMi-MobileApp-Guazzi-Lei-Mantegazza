import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:country_picker/country_picker.dart';
import 'package:dima_project/services/CurrencyService.dart';
import 'package:dima_project/services/authService.dart';
import 'package:dima_project/services/databaseService.dart';
import 'package:dima_project/services/googlePlacesService.dart';
import 'package:dima_project/services/unsplashService.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/cupertino.dart';
import 'package:mockito/annotations.dart';
import 'package:mockito/mockito.dart';

class MockNavigatorObserver extends Mock implements NavigatorObserver {}

@GenerateMocks([
  DatabaseService,
  AuthService,
  User,
  DocumentSnapshot,
  GooglePlacesService,
  CountryService,
  CurrencyService,
  UnsplashService,
])

void main() {}