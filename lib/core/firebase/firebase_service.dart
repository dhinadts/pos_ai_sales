import 'package:firebase_core/firebase_core.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:firebase_storage/firebase_storage.dart';
import 'package:firebase_messaging/firebase_messaging.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_riverpod/legacy.dart';

class FirebaseService {
  final FirebaseApp app;
  final FirebaseAuth auth;
  final FirebaseFirestore firestore;
  final FirebaseStorage storage;
  final FirebaseMessaging messaging;

  FirebaseService._({
    required this.app,
    required this.auth,
    required this.firestore,
    required this.storage,
    required this.messaging,
  });

  factory FirebaseService._internal(FirebaseApp app) {
    return FirebaseService._(
      app: app,
      auth: FirebaseAuth.instance,
      firestore: FirebaseFirestore.instance,
      storage: FirebaseStorage.instance,
      messaging: FirebaseMessaging.instance,
    );
  }

  static Future<FirebaseService> init() async {
    final app = await Firebase.initializeApp();
    return FirebaseService._internal(app);
  }

  CollectionReference<Map<String, dynamic>> productsRef(String shopId) {
    return firestore.collection('shops').doc(shopId).collection('products');
  }
}

final firebaseReadyProvider = StateProvider<bool>((_) => false);
final firebaseProvider = FutureProvider<FirebaseService>((ref) async {
  return FirebaseService.init();
});
