import 'package:cloud_firestore/cloud_firestore.dart';

import 'authService.dart';

class DatabaseService {
  final db = FirebaseFirestore.instance;
  final String? currentUserId = AuthService().currentUser?.uid;
}