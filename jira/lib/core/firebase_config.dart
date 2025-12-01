// lib/core/utils/firebase_config.dart
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:firebase_storage/firebase_storage.dart';

class FirebaseConfig {
  static final FirebaseFirestore firestore = FirebaseFirestore.instance;
  static final FirebaseAuth auth = FirebaseAuth.instance;
  static final FirebaseStorage storage = FirebaseStorage.instance;
}
