import 'package:connectivity_plus/connectivity_plus.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:pos_ai_sales/core/db/pos_db_service.dart';
import 'package:pos_ai_sales/core/firebase/firebase_service.dart'; // Ensure this points to your FirebaseService class

class SyncService {
  final Ref ref;

  SyncService(this.ref) {
    // Listen for connectivity changes
    Connectivity().onConnectivityChanged.listen((event) {
      // Trigger sync when network returns from 'none'
      if (event != ConnectivityResult.none) {
        // You'll need a way to pass the actual shop ID here, perhaps from another provider or a constant
        debugPrint("Network restored. Triggering sync...");
        sync("default_shop_id"); // Replace with actual logic to get shopId
      }
    });
  }
  
  Future<void> sync(String shopId) async {
    debugPrint("Syncing data for shopId: $shopId");

    // Ensure local DB is ready (if needed before Firebase interaction)
    await ref.read(posDbProvider).database;

    // Use ref.read() on the AsyncValue provider to get the current state
    final firebaseAsyncValue = ref.read(firebaseProvider);

    await firebaseAsyncValue.when(
      // When the data is available (successfully initialized FirebaseService)
      data: (FirebaseService firebaseService) async {
        debugPrint(
          "Firebase service initialized. Starting actual sync logic...",
        );

        // --- Implement actual sync logic here ---
        // Example: Push local products to Firestore
        // Example: Pull remote products from Firestore to local db

        // Replace this placeholder with your sync functions:
        // await firebaseService.pushLocalProducts(shopId);
        // await firebaseService.pullRemoteProducts(shopId);

        debugPrint("Sync completed for shopId: $shopId");
      },
      // If there's an error during Firebase initialization
      error: (error, stack) {
        debugPrint("Firebase sync error: $error");
      },
      // If Firebase is still loading
      loading: () {
        debugPrint("Firebase still initializing, sync deferred or skipped.");
      },
    );
  }
}
