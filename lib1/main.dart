import 'package:firebase_core/firebase_core.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:pos_ai_sales/firebase_options.dart';
import 'app.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();

  // await MobileAds.instance.initialize();
  await Firebase.initializeApp(options: DefaultFirebaseOptions.currentPlatform);
  // await TableService().createDefaultTables();

  // Load persisted theme
  // ....... {}
  runApp(const ProviderScope(child: MyApp()));
}

/// A FutureProvider that initializes Firebase.
/// It will be watched by the Splash screen so that the app waits
/// until Firebase initialization completes.
/// Replace with your real FirebaseService.init() later if you use one.
final firebaseInitProvider = FutureProvider<void>((ref) async {
  await Firebase.initializeApp();
  // optionally do other async startup tasks here
});

