import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:dima_project/services/authService.dart';
import 'package:dima_project/services/databaseService.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:mockito/annotations.dart';

@GenerateMocks([
  DatabaseService,
  AuthService,
  User,
  DocumentSnapshot,
])

void main() {}