import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';

class SettingsScreen extends StatelessWidget {
  const SettingsScreen({super.key});

  Widget item(BuildContext context, String title, IconData icon) {
    return InkWell(
      onTap: () {
        ScaffoldMessenger.of(
          context,
        ).showSnackBar(SnackBar(content: Text('Working on progress')));
      },
      child: Container(
        margin: const EdgeInsets.only(bottom: 20),
        padding: const EdgeInsets.all(20),
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(14),
          boxShadow: const [
            BoxShadow(color: Colors.black12, blurRadius: 8, spreadRadius: 2),
          ],
        ),
        child: Row(
          mainAxisAlignment: MainAxisAlignment.start,
          children: [
            Icon(icon),
            // Image.asset(asset, height: 60),
            const SizedBox(width: 20),
            Text(
              title,
              style: const TextStyle(fontSize: 20, fontWeight: FontWeight.w600),
            ),
          ],
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return WillPopScope(
      onWillPop: () async {
        context.go('/home');
        return false;
      },
      child: Scaffold(
        appBar: AppBar(
          title: const Text("Settings"),
          backgroundColor: const Color(0xff00B4F0),
          leading: IconButton(
            onPressed: () => context.go('/home'),
            icon: Icon(Icons.arrow_back_ios),
          ),
        ),
        body: Padding(
          padding: const EdgeInsets.all(16),
          child: ListView(
            children: [
              item(context, 'Shop Information', Icons.shop),
              item(context, "Categories", Icons.category),
              item(context, "Payment Methods", Icons.payment),
              item(context, "Order Type", Icons.card_membership),
              item(context, "Unit", Icons.ac_unit),
              item(context, "Data Backup", Icons.dataset_linked),
            ],
          ),
        ),
      ),
    );
  }
}
