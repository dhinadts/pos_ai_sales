import 'package:flutter/foundation.dart' show kIsWeb;
import 'dart:io' show Platform;

import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:pos_ai_sales/core/db/customer/sqlite_service_riverpod.dart';
import 'package:pos_ai_sales/core/db/orders/orders_repository.dart';
import 'package:pos_ai_sales/core/db/pos_db_service.dart';
import 'package:pos_ai_sales/core/db/products/sqlite_service_riverpod.dart';
import 'package:pos_ai_sales/core/db/sales/sales_repository.dart';

class SplashScreen extends ConsumerStatefulWidget {
  const SplashScreen({super.key});

  @override
  ConsumerState<SplashScreen> createState() => _SplashScreenState();
}

class _SplashScreenState extends ConsumerState<SplashScreen> {
  @override
  void initState() {
    super.initState();
    if (kIsWeb) {
      // Future.microtask(() => context.go('/home'));
    } else {
      _initialize();
    }
  }

  void checkPlatform() {
    if (kIsWeb) {
      debugPrint("Running on Web");
      // return 1;
    } else if (Platform.isAndroid) {
      debugPrint("Running on Android");
      return;
    } else if (Platform.isIOS) {
      debugPrint("Running on iOS");
    } else if (Platform.isWindows) {
      debugPrint("Running on Windows");
    } else if (Platform.isMacOS) {
      debugPrint("Running on macOS");
    } else if (Platform.isLinux) {
      debugPrint("Running on Linux");
    } else {
      debugPrint("Unknown platform");
    }
  }

  Future<void> _initialize() async {
    // build DB
    await ref.read(posDbProvider).database;

    await Future.delayed(const Duration(seconds: 1));

    // invalidate provider caches one-by-one
    ref.invalidate(productListProvider);
    ref.invalidate(customerListProvider);
    ref.invalidate(salesRepoProvider);
    ref.invalidate(ordersRepoProvider);

    context.go('/home');
  }
  /*  Future<void> _initialize() async {
    // 1) open DB (if not exists it will be created)
    await ref.read(sqliteRepoProvider).db.db;

    ref.invalidate(productListProvider);
    // 4) go to home
    await Future.delayed(const Duration(seconds: 1), () {
      context.go('/home');
    });
  } */

  @override
  Widget build(BuildContext context) {
    // immediately move to home (on next microtask)
    if (kIsWeb) {
      Future.microtask(() => context.go('/home'));
    }
    // Future.microtask(() => context.go('/home'));
    return Scaffold(
      body: Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Container(
              width: 160,
              height: 160,
              decoration: BoxDecoration(
                color: Colors.white,
                shape: BoxShape.circle,
                boxShadow: [
                  BoxShadow(
                    color: Colors.black12,
                    blurRadius: 12,
                    offset: Offset(0, 6),
                  ),
                ],
              ),
              child: const Icon(
                Icons.point_of_sale,
                size: 88,
                color: Colors.cyan,
              ),
            ),
            const SizedBox(height: 28),
            const Text(
              'Smart POS',
              style: TextStyle(fontSize: 34, color: Colors.cyan),
            ),
            const SizedBox(height: 20),
            const CircularProgressIndicator(strokeWidth: 4),
          ],
        ),
      ),
    );
  }
}



/* import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:pos_ai_sales/app.dart';

class SplashPage extends ConsumerWidget {
  const SplashPage({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final asyncInit = ref.watch(firebaseInitProvider);

    Widget splashScreen() {
      return Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: <Widget>[
            // big card icon similar to your screenshot
            Container(
              width: 160,
              height: 160,
              decoration: BoxDecoration(
                color: Colors.white,
                shape: BoxShape.circle,
                boxShadow: [
                  BoxShadow(
                    color: Colors.black12,
                    blurRadius: 12,
                    offset: Offset(0, 6),
                  ),
                ],
              ),
              child: const Center(
                child: Icon(Icons.point_of_sale, size: 88, color: Colors.cyan),
              ),
            ),
            const SizedBox(height: 28),
            const Text(
              'Smart POS',
              style: TextStyle(
                fontSize: 34,
                color: Colors.cyan,
                fontWeight: FontWeight.w500,
              ),
            ),
            const SizedBox(height: 12),

            // use asyncInit here (now it is visible)
            asyncInit.when(
              data: (_) => const SizedBox(height: 28),
              loading: () => const Padding(
                padding: EdgeInsets.only(top: 18.0),
                child: CircularProgressIndicator(strokeWidth: 4),
              ),
              error: (err, st) => Padding(
                padding: const EdgeInsets.only(top: 18.0),
                child: Text(
                  'Init error: $err',
                  style: const TextStyle(color: Colors.red),
                ),
              ),
            ),
          ],
        ),
      );
    }

    return asyncInit.when(
      data: (_) {
        WidgetsBinding.instance.addPostFrameCallback((_) {
          context.go('/home');
        });
        return const Scaffold(
          body: Center(child: CircularProgressIndicator()),
        );
      },
      loading: () => Scaffold(body: splashScreen()),
      error: (err, _) => Scaffold(
        body: Center(child: Text("Firebase init failed: $err")),
      ),
    );
  }
}
 */
/* class SplashPage extends ConsumerWidget {
  const SplashPage({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final asyncInit = ref.watch(firebaseInitProvider);

    // When firebase init completes -> navigate to home
    asyncInit.whenData((_) {
      // small delay to show splash nicely
      Future.microtask(() => GoRouter.of(context).go('/home'));
    });

    return Scaffold(
      body: Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: <Widget>[
            // big card icon similar to your screenshot
            Container(
              width: 160,
              height: 160,
              decoration: BoxDecoration(
                color: Colors.white,
                shape: BoxShape.circle,
                boxShadow: [
                  BoxShadow(
                    color: Colors.black12,
                    blurRadius: 12,
                    offset: Offset(0, 6),
                  ),
                ],
              ),
              child: const Center(
                child: Icon(Icons.point_of_sale, size: 88, color: Colors.cyan),
              ),
            ),
            const SizedBox(height: 28),
            const Text(
              'Smart POS',
              style: TextStyle(
                fontSize: 34,
                color: Colors.cyan,
                fontWeight: FontWeight.w500,
              ),
            ),
            const SizedBox(height: 12),
            asyncInit.when(
              data: (_) =>
                  const SizedBox(height: 28), // hides loader if ready quickly
              loading: () => const Padding(
                padding: EdgeInsets.only(top: 18.0),
                child: CircularProgressIndicator(strokeWidth: 4),
              ),
              error: (err, st) => Padding(
                padding: const EdgeInsets.only(top: 18.0),
                child: Text(
                  'Init error: $err',
                  style: const TextStyle(color: Colors.red),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
 */