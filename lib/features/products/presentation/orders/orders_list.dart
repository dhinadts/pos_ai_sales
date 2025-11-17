import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';

class OrdersList extends ConsumerStatefulWidget {
  const OrdersList({super.key});

  @override
  ConsumerState<ConsumerStatefulWidget> createState() => _OrdersListState();
}

class _OrdersListState extends ConsumerState<OrdersList> {
  @override
  Widget build(BuildContext context) {
    return WillPopScope(
      onWillPop: () async {
        context.go('/home');
        return false;
      },
      child: Scaffold(
        appBar: AppBar(
          title: Text("Orders"),
          leading: IconButton(
            onPressed: () => context.go('/home'),
            icon: Icon(Icons.arrow_back_ios),
          ),
        ),
        body: Center(child: Text('Working on this module')),
        floatingActionButton: FloatingActionButton.extended(
          onPressed: () {},
          label: Text("Sync Order"),
        ),
      ),
    );
  }
}
