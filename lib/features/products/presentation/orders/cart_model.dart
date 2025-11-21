class CartItem {
  final String id;
  final String name;
  final String unit;
  final double price;
  final int quantity; // Make immutable for StateNotifier updates

  CartItem({
    required this.id,
    required this.name,
    required this.unit,
    required this.price,
    this.quantity = 1,
  });

  double get total => price * quantity;

  CartItem copyWith({
    String? id,
    String? name,
    String? unit,
    double? price,
    int? quantity,
  }) {
    return CartItem(
      id: id ?? this.id,
      name: name ?? this.name,
      unit: unit ?? this.unit,
      price: price ?? this.price,
      quantity: quantity ?? this.quantity,
    );
  }
}
