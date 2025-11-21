import 'package:firebase_core/firebase_core.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:pos_ai_sales/firebase_options.dart';
// import 'package:sqflite_common_ffi/sqflite_ffi.dart';
// import 'package:sqflite_common_ffi_web/sqflite_ffi_web.dart';
import 'app.dart';

void main() async {
  /* 
  WidgetsFlutterBinding.ensureInitialized();
  await Firebase.initializeApp(options: DefaultFirebaseOptions.currentPlatform);
  runApp(const ProviderScope(child: MyApp())); */
  WidgetsFlutterBinding.ensureInitialized();
  await Firebase.initializeApp(options: DefaultFirebaseOptions.currentPlatform);
 /*  if (kIsWeb) {
    databaseFactory = databaseFactoryFfiWeb; // IndexedDB for Web
  } else {
    sqfliteFfiInit(); // Desktop
    databaseFactory = databaseFactoryFfi; // Windows/Mac/Linux
  } */
  runApp(const ProviderScope(child: MyApp()));
}

final firebaseInitProvider = FutureProvider<void>((ref) async {
  await Firebase.initializeApp();
  // optionally do other async startup tasks here
});
