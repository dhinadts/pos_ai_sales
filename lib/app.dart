import 'package:firebase_core/firebase_core.dart';
import 'package:flutter/foundation.dart' show kIsWeb;
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:uuid/uuid.dart';

// ✅ Screens
import 'package:pos_ai_sales/features/products/presentation/splash_screen.dart';
import 'package:pos_ai_sales/features/products/presentation/home_page.dart';
import 'package:pos_ai_sales/features/products/presentation/products/product_list_page.dart';
import 'package:pos_ai_sales/features/products/presentation/products/product_edit.dart';
import 'package:pos_ai_sales/features/products/presentation/customers/customers_list.dart';
import 'package:pos_ai_sales/features/products/presentation/customers/customer_input.dart';
import 'package:pos_ai_sales/features/products/presentation/all_sales_transactions/sales_all.dart';
import 'package:pos_ai_sales/features/products/presentation/sales_report/reports_home_screen.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  runApp(const ProviderScope(child: MyApp()));
}

class MyApp extends ConsumerWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final firebaseInit = ref.watch(firebaseInitProvider);

    return firebaseInit.when(
      loading: () => const MaterialApp(
        home: Scaffold(body: Center(child: CircularProgressIndicator())),
      ),
      error: (err, _) => MaterialApp(
        home: Scaffold(
          body: Center(child: Text('❌ Firebase init failed: $err')),
        ),
      ),
      data: (_) {
        return MaterialApp.router(
          title: 'Smart POS',
          debugShowCheckedModeBanner: false,
          routerConfig: _router,
          theme: ThemeData(
            primarySwatch: Colors.cyan,
            scaffoldBackgroundColor: const Color(0xFFF7F7F7),
            fontFamily: 'Roboto',
          ),
        );
      },
    );
  }
}

/// ✅ Firebase init provider (works for web & mobile)
final firebaseInitProvider = FutureProvider<void>((ref) async {
  await Firebase.initializeApp();
});

/// ✅ Router setup (GoRouter)
final _router = GoRouter(
  initialLocation: kIsWeb ? '/home' : '/',
  routes: [
    GoRoute(
      path: '/',
      builder: (_, __) =>
          kIsWeb ? const HomePage() : const SplashScreen(), // better logic
    ),
    GoRoute(path: '/home', builder: (_, __) => const HomePage()),

    /// Products
    GoRoute(path: '/products', builder: (_, __) => const ProductListPage()),
    GoRoute(
      path: '/products/edit/:productId',
      builder: (context, state) {
        final productId = UuidValue(state.pathParameters['productId']!);
        final mode = state.uri.queryParameters['mode'] ?? 'add';
        return ProductEditScreen(productId: productId, mode: mode);
      },
    ),

    /// Sales
    GoRoute(path: '/sales', builder: (_, __) => const SalesAll()),
    GoRoute(
      path: '/sales/report',
      builder: (_, __) => const ReportsHomeScreen(),
    ),

    /// Customers
    GoRoute(path: '/customers', builder: (_, __) => const CustomersList()),
    GoRoute(
      path: '/customers/edit/:customerId',
      builder: (context, state) {
        final customerId = UuidValue(state.pathParameters['customerId']!);
        final mode = state.uri.queryParameters['mode'] ?? 'add';
        return EditCustomerScreen(customerId: customerId, mode: mode);
      },
    ),
  ],
);
