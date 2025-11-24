import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:pos_ai_sales/app.dart';
import 'package:pos_ai_sales/core/db/customer/sqlite_service_riverpod.dart';
import 'package:pos_ai_sales/core/db/orders/orders_repository.dart';
import 'package:pos_ai_sales/core/db/pos_db_service.dart';
import 'package:pos_ai_sales/core/db/products/sqlite_service_riverpod.dart';
import 'package:pos_ai_sales/core/db/sales/sales_repository.dart';
import 'package:pos_ai_sales/core/firebase/firebase_orders_service.dart';
import 'package:pos_ai_sales/core/firebase/firebase_product_service.dart';
import 'package:pos_ai_sales/core/firebase/firebase_sales_service.dart';

class SplashScreen extends ConsumerStatefulWidget {
  const SplashScreen({super.key});

  @override
  ConsumerState<SplashScreen> createState() => _SplashScreenState();
}

class _SplashScreenState extends ConsumerState<SplashScreen> {
  @override
  void initState() {
    super.initState();
    _start();
  }

  Future<void> _start() async {
    // if (kIsWeb) {
    await _initializeFirebase();
    // } else {
    // await _initializeSQLite();
    // }

    if (mounted) {
      context.go('/home');
    }
  }

  // -------------------------------------------
  //  WEB → FIREBASE DATABASE INIT
  // -------------------------------------------
  Future<void> _initializeFirebase() async {
    try {
      await ref.read(firebaseInitProvider.future);

      await ref.read(firebaseCustomersServiceProvider).loadAll();
      await ref
          .read(firebaseProductsServiceProvider)
          .getProducts(); /////    ordersis pending
      await ref.read(firebaseSalesTransactionsProvider).loadAll();
      await ref.read(firebaseOrdersServiceProvider).loadAll();

      //  refresh UI providers
      // ref.invalidate(customerListProvider);
      // ref.invalidate(productListProvider);
      // ref.invalidate(salesRepoProvider);
      // ref.invalidate(ordersRepoProvider);
    } catch (e) {
      debugPrint("Firebase init failed: $e");
    }
  }

  // -------------------------------------------
  //  MOBILE / DESKTOP → SQLITE DATABASE INIT
  // -------------------------------------------
  Future<void> _initializeSQLite() async {
    try {
      // Step 1: open SQLite database
      await ref.read(posDbProvider).database;

      // Step 2: refresh local sqlite providers
      ref.invalidate(customerListProvider);
      ref.invalidate(productListProvider);
      ref.invalidate(salesRepoProvider);
      ref.invalidate(ordersRepoProvider);
    } catch (e) {
      debugPrint("SQLite init error: $e");
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: const [
            SizedBox(
              width: 160,
              height: 160,
              child: CircleAvatar(
                backgroundColor: Colors.white,
                child: Icon(Icons.point_of_sale, size: 90, color: Colors.cyan),
              ),
            ),
            SizedBox(height: 20),
            Text(
              'Smart POS',
              style: TextStyle(fontSize: 32, color: Colors.cyan),
            ),
            SizedBox(height: 20),
            CircularProgressIndicator(strokeWidth: 4),
          ],
        ),
      ),
    );
  }
}
