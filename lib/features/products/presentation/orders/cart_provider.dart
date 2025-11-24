import 'package:flutter_riverpod/legacy.dart';
import 'cart_model.dart';

class CartNotifier extends StateNotifier<Map<String, CartItem>> {
  CartNotifier() : super({});

  List<CartItem> get items => state.values.toList();

  void addToCart(CartItem item) {
    if (state.containsKey(item.id)) {
      final existingItem = state[item.id]!;
      state = {
        ...state,
        item.id: existingItem.copyWith(quantity: existingItem.quantity + 1)
      };
    } else {
      state = {...state, item.id: item.copyWith(quantity: 1)};
    }
  }

  void removeItem(String id) {
    final updated = {...state};
    updated.remove(id);
    state = updated;
  }

  void increaseQty(String id) {
    if (state.containsKey(id)) {
      final item = state[id]!;
      state = {...state, id: item.copyWith(quantity: item.quantity + 1)};
    }
  }

  void decreaseQty(String id) {
    if (state.containsKey(id)) {
      final item = state[id]!;
      if (item.quantity > 1) {
        state = {...state, id: item.copyWith(quantity: item.quantity - 1)};
      } else {
        removeItem(id);
      }
    }
  }

  int get cartCount => state.values.fold(0, (sum, item) => sum + item.quantity);

  double get subtotal =>
      state.values.fold(0.0, (sum, item) => sum + (item.price * item.quantity));

  double get taxAmount => subtotal * 0.15;

  double get finalTotal => subtotal + taxAmount;

  double get totalPrice => finalTotal;

  void clearCart() {
    state = {};
  }
}

final cartProvider = StateNotifierProvider<CartNotifier, Map<String, CartItem>>(
  (ref) => CartNotifier(),
);
