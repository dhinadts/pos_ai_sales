import 'package:flutter/material.dart';
import 'package:flutter/foundation.dart' show kIsWeb;
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:pos_ai_sales/core/utilits/responsive_design.dart';

class HomePage extends ConsumerWidget {
  const HomePage({super.key});

  List<_HomeTile> get tiles => [
        _HomeTile('Customers', Icons.people_alt, '/customers'),
        _HomeTile('Suppliers', Icons.handshake, '/suppliers'),
        _HomeTile('Products', Icons.inventory_2, '/products'),
        _HomeTile('Sales', Icons.point_of_sale, '/sales'),
        _HomeTile('Sales Report', Icons.bar_chart, '/sales/report'),
        _HomeTile('Expense', Icons.account_balance_wallet, '/expenses'),
        _HomeTile('All Orders', Icons.receipt_long, '/orders'),
        _HomeTile('Settings', Icons.settings, '/settings'),
      ];

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    WidgetsBinding.instance.addPostFrameCallback((_) {
      ref.read(responsiveProvider.notifier).updateFromContext(context);
    });
    final responsive = ref.watch(responsiveProvider);

    final width = responsive.screenWidth;
    final bool isWeb = kIsWeb;

    final crossAxisCount = width > 1200
        ? 4
        : width > 900
            ? 4
            : width > 700
                ? 3
                : 2;

    return Scaffold(
      backgroundColor: Colors.white,
      body: SafeArea(
        child: Column(
          children: [
            _Header(),
            Expanded(
              child: ConstrainedBox(
                constraints: const BoxConstraints(maxWidth: 1200),
                child: Padding(
                  padding: EdgeInsets.symmetric(
                    horizontal: responsive.width(16),
                    vertical: responsive.height(8),
                  ),
                  child: GridView.builder(
                    physics: const BouncingScrollPhysics(),
                    gridDelegate: SliverGridDelegateWithFixedCrossAxisCount(
                      crossAxisCount: crossAxisCount,
                      mainAxisSpacing: responsive.height(10),
                      crossAxisSpacing: responsive.width(10),
                      childAspectRatio: isWeb ? 1.5 : 1.4,
                    ),
                    itemCount: tiles.length,
                    itemBuilder: (context, index) =>
                        _HomeTileWidget(tile: tiles[index]),
                  ),
                ),
              ),
            ),
            !isWeb
                ? Container(
                    color: Colors.white,
                    padding: const EdgeInsets.symmetric(vertical: 8),
                    child: Center(
                      child: Container(
                        width: 320,
                        height: 50,
                        decoration: BoxDecoration(
                          border: Border.all(color: Colors.grey.shade300),
                          color: Colors.white,
                        ),
                        child: const Center(
                          child: Text(
                            'Test Ad — 320x50',
                            style: TextStyle(color: Colors.black54),
                          ),
                        ),
                      ),
                    ),
                  )
                : SizedBox.shrink(),
          ],
        ),
      ),
    );
  }
}

class _Header extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return Stack(
      children: [
        Container(
          height: 200,
          decoration: const BoxDecoration(
            gradient: LinearGradient(
              colors: [Color(0xFF00C6A7), Color(0xFF00B0FF)],
              begin: Alignment.topLeft,
              end: Alignment.bottomRight,
            ),
          ),
          child: Padding(
            padding: const EdgeInsets.only(left: 16.0, right: 8.0, top: 18),
            child: Row(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                const Icon(Icons.point_of_sale, size: 44, color: Colors.white),
                const SizedBox(width: 12),
                const Expanded(
                  child: Text(
                    'HELLO! WELCOME',
                    style: TextStyle(
                      fontSize: 24,
                      color: Colors.white,
                      fontWeight: FontWeight.bold,
                      letterSpacing: 1.1,
                    ),
                  ),
                ),
                const _LangButton(),
              ],
            ),
          ),
        ),
        Positioned(
          left: 0,
          right: 0,
          top: 150,
          child: Container(
            height: 60,
            decoration: const BoxDecoration(
              color: Colors.white,
              borderRadius: BorderRadius.vertical(top: Radius.circular(36)),
            ),
          ),
        ),
      ],
    );
  }
}

class _HomeTile {
  final String title;
  final IconData icon;
  final String route;
  _HomeTile(this.title, this.icon, this.route);
}

class _HomeTileWidget extends StatefulWidget {
  final _HomeTile tile;
  const _HomeTileWidget({required this.tile});

  @override
  State<_HomeTileWidget> createState() => _HomeTileWidgetState();
}

class _HomeTileWidgetState extends State<_HomeTileWidget> {
  bool _hovering = false;

  @override
  Widget build(BuildContext context) {
    return MouseRegion(
      onEnter: (_) => setState(() => _hovering = true),
      onExit: (_) => setState(() => _hovering = false),
      child: InkWell(
        onTap: () => GoRouter.of(context).go(widget.tile.route),
        borderRadius: BorderRadius.circular(12),
        child: AnimatedContainer(
          duration: const Duration(milliseconds: 200),
          decoration: BoxDecoration(
            color: Colors.white,
            borderRadius: BorderRadius.circular(14),
            boxShadow: [
              BoxShadow(
                color:
                    _hovering ? Colors.cyan.withOpacity(0.3) : Colors.black12,
                blurRadius: _hovering ? 14 : 8,
                offset: const Offset(0, 4),
              ),
            ],
          ),
          padding: const EdgeInsets.all(12),
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              CircleAvatar(
                radius: 30,
                backgroundColor: Colors.cyan.shade50,
                child: Icon(
                  widget.tile.icon,
                  color: Colors.cyan,
                  size: _hovering ? 42 : 36,
                ),
              ),
              const SizedBox(height: 14),
              Text(
                widget.tile.title.toUpperCase(),
                textAlign: TextAlign.center,
                style: TextStyle(
                  color: Colors.grey.shade700,
                  fontSize: 16,
                  fontWeight: FontWeight.w600,
                  letterSpacing: 0.5,
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}

class _LangButton extends StatelessWidget {
  const _LangButton();

  @override
  Widget build(BuildContext context) {
    return IconButton(
      icon: const Icon(Icons.language, color: Colors.white),
      onPressed: () async {
        final RenderBox overlay =
            Overlay.of(context).context.findRenderObject() as RenderBox;

        final selected = await showMenu<String>(
          context: context,
          position: RelativeRect.fromSize(
            Rect.fromLTWH(
              MediaQuery.of(context).size.width - 200,
              80,
              200,
              300,
            ),
            overlay.size,
          ),
          items: const [
            PopupMenuItem(value: 'fr', child: Text('🇫🇷  French')),
            PopupMenuItem(value: 'en', child: Text('🇺🇸  English')),
            PopupMenuItem(value: 'bn', child: Text('🇧🇩  বাংলা')),
            PopupMenuItem(value: 'es', child: Text('🇪🇸  Spanish')),
            PopupMenuItem(value: 'hi', child: Text('🇮🇳  हिन्दी')),
          ],
        );

        if (selected != null) {
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(content: Text('Language selected: $selected')),
          );
        }
      },
    );
  }
}
