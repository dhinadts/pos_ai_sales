import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:pos_ai_sales/features/products/presentation/orders/cart_provider.dart';

class CustomAppBar extends ConsumerWidget implements PreferredSizeWidget {
  final String title;
  final double? fontSize;
  final Widget? trailingPage;
  final bool showCart;
  final Color bgColor;

  const CustomAppBar({
    super.key,
    required this.title,
    this.fontSize,
    this.trailingPage,
    this.showCart = true,
    this.bgColor = Colors.cyan,
  });

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final cart = ref.watch(cartProvider);
    final cartCount = ref.read(cartProvider.notifier).cartCount;

    return AppBar(
      backgroundColor: bgColor,
      elevation: 0,
      centerTitle: true,

      // BACK BUTTON
      leading: IconButton(
        icon: const Icon(Icons.arrow_back_ios, color: Colors.white),
        onPressed: () => context.go('/home'),
      ),

      // TITLE
      title: Text(
        title,
        style: TextStyle(
          fontSize: fontSize ?? 20,
          fontWeight: FontWeight.bold,
          color: Colors.white,
        ),
      ),

      // CART ICON WITH BADGE
      actions: [
        if (showCart)
          Stack(
            children: [
              IconButton(
                icon: Icon(Icons.shopping_cart_outlined, size: fontSize ?? 26),
                onPressed: () {
                  if (trailingPage != null) {
                    Navigator.push(
                      context,
                      MaterialPageRoute(builder: (_) => trailingPage!),
                    );
                  }
                },
              ),
              if (cartCount > 0)
                Positioned(
                  right: 6,
                  top: 6,
                  child: Container(
                    padding: const EdgeInsets.all(4),
                    decoration: const BoxDecoration(
                      color: Colors.red,
                      shape: BoxShape.circle,
                    ),
                    child: Text(
                      cartCount.toString(),
                      style: TextStyle(
                        color: Colors.white,
                        fontSize: (fontSize ?? 20) * 0.55,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                  ),
                ),
            ],
          ),
      ],
    );
  }

  @override
  Size get preferredSize => const Size.fromHeight(kToolbarHeight);
}
