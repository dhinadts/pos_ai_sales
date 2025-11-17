import 'package:firebase_core/firebase_core.dart';
import 'package:flutter/foundation.dart' show kIsWeb;
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_riverpod/legacy.dart';
import 'package:go_router/go_router.dart';

// Screens
import 'package:pos_ai_sales/features/products/presentation/splash_screen.dart';
import 'package:pos_ai_sales/features/products/presentation/home_page.dart';
import 'package:pos_ai_sales/features/products/presentation/products/product_list_page.dart';
import 'package:pos_ai_sales/features/products/presentation/products/product_edit.dart';
import 'package:pos_ai_sales/features/products/presentation/customers/customers_list.dart';
import 'package:pos_ai_sales/features/products/presentation/customers/customer_input.dart';
import 'package:pos_ai_sales/features/products/presentation/all_sales_transactions/sales_all.dart';
import 'package:pos_ai_sales/features/products/presentation/sales_report/reports_home_screen.dart';
import 'package:pos_ai_sales/features/products/presentation/suppliers/edit_supplier_screen.dart';
import 'package:pos_ai_sales/features/products/presentation/suppliers/supplier_list_screen.dart';
import 'package:pos_ai_sales/features/products/presentation/settings/settings_screen.dart';
import 'package:pos_ai_sales/features/products/presentation/expense/expense_edit_screen.dart';
import 'package:pos_ai_sales/features/products/presentation/expense/expense_list.screen.dart';
import 'package:pos_ai_sales/features/products/presentation/orders/orders_list.dart';

import 'package:uuid/uuid.dart';

/// 🔥 GLOBAL Providers
final firebaseReadyProvider = StateProvider<bool>((ref) => false);

final firebaseInitProvider = FutureProvider<void>((ref) async {
  await Firebase.initializeApp();
  ref.read(firebaseReadyProvider.notifier).state = true;
});

/// 🔥 GoRouter instance
final _router = GoRouter(
  initialLocation: '/',
  redirect: (context, state) {
    final container = ProviderScope.containerOf(context);
    final ready = container.read(firebaseReadyProvider);

    if (!ready) return '/loading';

    return null;
  },
  routes: [
    GoRoute(path: '/loading', builder: (_, __) => const SplashScreen()),

    GoRoute(
      path: '/',
      builder: (_, __) => kIsWeb ? const HomePage() : const SplashScreen(),
    ),

    GoRoute(path: '/home', builder: (_, __) => const HomePage()),

    /// Products
    GoRoute(path: '/products', builder: (_, __) => const ProductListPage()),
    GoRoute(
      path: '/products/edit/:productId',
      builder: (context, state) {
        final id = UuidValue(state.pathParameters['productId']!);
        final mode = state.uri.queryParameters['mode'] ?? 'add';
        return ProductEditScreen(productId: id, mode: mode);
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
        final id = UuidValue(state.pathParameters['customerId']!);
        final mode = state.uri.queryParameters['mode'] ?? 'add';
        return EditCustomerScreen(customerId: id, mode: mode);
      },
    ),

    /// Suppliers
    GoRoute(
      path: '/suppliers',
      builder: (_, __) => const SuppliersListScreen(),
    ),
    GoRoute(
      path: '/suppliers/edit/:supplierId',
      builder: (context, state) {
        final id = UuidValue(state.pathParameters['supplierId']!);
        final mode = state.uri.queryParameters['mode'] ?? 'add';
        return AddSupplierScreen(supplierId: id, mode: mode);
      },
    ),

    /// Expenses
    GoRoute(path: '/expenses', builder: (_, __) => const ExpensesList()),
    GoRoute(
      path: '/expenses/edit/:expenseId',
      builder: (context, state) {
        final id = UuidValue(state.pathParameters['expenseId']!);
        final mode = state.uri.queryParameters['mode'] ?? 'add';
        return EditExpenseScreen(expenseId: id, mode: mode);
      },
    ),

    GoRoute(path: '/orders', builder: (_, __) => const OrdersList()),
    GoRoute(path: '/settings', builder: (_, __) => const SettingsScreen()),
  ],
);

void main() {
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
        home: Scaffold(body: Center(child: Text('Firebase Failed: $err'))),
      ),
      data: (_) => MaterialApp.router(
        debugShowCheckedModeBanner: false,
        routerConfig: _router,
        title: "Smart POS",
        theme: ThemeData(
          primarySwatch: Colors.cyan,
          scaffoldBackgroundColor: const Color(0xFFF7F7F7),
          fontFamily: 'Roboto',
        ),
      ),
    );
  }
}




/* import 'package:firebase_core/firebase_core.dart';
import 'package:flutter/foundation.dart' show kIsWeb;
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:pos_ai_sales/core/firebase/firebase_service.dart';
import 'package:pos_ai_sales/features/products/presentation/expense/expense_edit_screen.dart';
import 'package:pos_ai_sales/features/products/presentation/expense/expense_list.screen.dart';
import 'package:pos_ai_sales/features/products/presentation/orders/orders_list.dart';

// ✅ Screens
import 'package:pos_ai_sales/features/products/presentation/splash_screen.dart';
import 'package:pos_ai_sales/features/products/presentation/home_page.dart';
import 'package:pos_ai_sales/features/products/presentation/products/product_list_page.dart';
import 'package:pos_ai_sales/features/products/presentation/products/product_edit.dart';
import 'package:pos_ai_sales/features/products/presentation/customers/customers_list.dart';
import 'package:pos_ai_sales/features/products/presentation/customers/customer_input.dart';
import 'package:pos_ai_sales/features/products/presentation/all_sales_transactions/sales_all.dart';
import 'package:pos_ai_sales/features/products/presentation/sales_report/reports_home_screen.dart';
import 'package:pos_ai_sales/features/products/presentation/suppliers/edit_supplier_screen.dart';
import 'package:pos_ai_sales/features/products/presentation/suppliers/supplier_list_screen.dart';
import 'package:pos_ai_sales/features/products/presentation/settings/settings_screen.dart';
import 'package:uuid/uuid.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  runApp(const ProviderScope(child: MyApp()));
}

class MyApp extends ConsumerWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final firebaseInit = FutureProvider<void>((ref) async {
      await Firebase.initializeApp();
      ref.read(firebaseReadyProvider.notifier).state = true;
    });

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
  redirect: (context, state) {
    final container = ProviderScope.containerOf(context);
    final isReady = container.read(firebaseReadyProvider);

    if (!isReady) return '/loading';

    return null; // allow navigation
  },
  // initialLocation: kIsWeb ? '/home' : '/',
  routes: [
    GoRoute(path: '/loading', builder: (_, __) => const SplashScreen()),
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

    GoRoute(
      path: '/suppliers',
      builder: (_, __) => const SuppliersListScreen(),
    ),

    GoRoute(
      path: '/suppliers/edit/:supplierId',
      builder: (context, state) {
        final supplierId = UuidValue(state.pathParameters['supplierId']!);
        final mode = state.uri.queryParameters['mode'] ?? 'add';
        return AddSupplierScreen(supplierId: supplierId, mode: mode);
      },
    ),

    GoRoute(path: '/expenses', builder: (_, __) => const ExpensesList()),

    GoRoute(
      path: '/expenses/edit/:expenseId',
      builder: (context, state) {
        final expenseId = UuidValue(state.pathParameters['expenseId']!);
        final mode = state.uri.queryParameters['mode'] ?? 'add';
        return EditExpenseScreen(expenseId: expenseId, mode: mode);
      },
    ),

    GoRoute(path: '/orders', builder: (_, __) => const OrdersList()),

    GoRoute(path: '/settings', builder: (_, __) => const SettingsScreen()),
  ],
);
 */