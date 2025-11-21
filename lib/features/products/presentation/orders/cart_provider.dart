import 'package:flutter_riverpod/legacy.dart';
import 'package:pos_ai_sales/features/products/presentation/orders/cart_model.dart';

class CartProvider extends StateNotifier<Map<String, CartItem>> {
  CartProvider() : super({});

  Map<String, CartItem> get items => state;

  double get totalPrice {
    double total = 0;
    state.forEach((key, item) {
      total += item.price * item.quantity;
    });
    return total;
  }

  void addItem(CartItem item) {
    if (state.containsKey(item.id)) {
      state = {
        ...state,
        item.id: state[item.id]!.copyWith(
          quantity: state[item.id]!.quantity + 1,
        )
      };
    } else {
      state = {...state, item.id: item};
    }
  }

  void removeItem(String id) {
    state = {...state}..remove(id);
  }

  void increaseQty(String id) {
    state = {
      ...state,
      id: state[id]!.copyWith(quantity: state[id]!.quantity + 1)
    };
  }

  void decreaseQty(String id) {
    final currentQty = state[id]!.quantity;
    if (currentQty > 1) {
      state = {...state, id: state[id]!.copyWith(quantity: currentQty - 1)};
    }
  }
}

/* // Riverpod Provider
final cartProvider = StateNotifierProvider<CartProvider, Map<String, CartItem>>(
  (ref) => CartProvider(),
); */
// In your cart_provider.dart, add these calculated properties:
extension CartCalculator on CartNotifier {
  double get subtotal {
    return state.values
        .fold(0.0, (sum, item) => sum + (item.price * item.quantity));
  }

  double get taxAmount {
    return subtotal * 0.15; // 15% tax
  }

  double get finalTotal {
    return subtotal + taxAmount;
  }

  double get totalPrice => finalTotal; // Keep this for backward compatibility
}

class CartNotifier extends StateNotifier<Map<String, CartItem>> {
  CartNotifier() : super({});

  void addToCart(CartItem item) {
    if (state.containsKey(item.id)) {
      increaseQty(item.id);
      return;
    }
    state = {...state, item.id: item};
  }

  void removeItem(String id) {
    final newState = {...state};
    newState.remove(id);
    state = newState;
  }

  void increaseQty(String id) {
    final item = state[id]!;
    state = {
      ...state,
      id: item.copyWith(quantity: item.quantity + 1),
    };
  }

  void decreaseQty(String id) {
    final item = state[id]!;
    if (item.quantity > 1) {
      state = {
        ...state,
        id: item.copyWith(quantity: item.quantity - 1),
      };
    } else {
      removeItem(id);
    }
  }

  int get cartCount => state.values.fold(0, (sum, item) => sum + item.quantity);

  double get totalPrice =>
      state.values.fold(0, (sum, item) => sum + item.total);
}

final cartProvider = StateNotifierProvider<CartNotifier, Map<String, CartItem>>(
  (ref) => CartNotifier(),
);
