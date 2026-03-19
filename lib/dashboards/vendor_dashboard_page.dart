import 'package:flutter/material.dart';
import '../auth/auth_service.dart';

class VendorDashboardPage extends StatelessWidget {
  final AuthService auth;
  const VendorDashboardPage({super.key, required this.auth});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text("Vendor Dashboard")),
      drawer: Drawer(
        child: ListView(
          children: [
            const DrawerHeader(child: Text("Vendor")),
            ListTile(
              leading: const Icon(Icons.logout, color: Colors.red),
              title: const Text("Logout"),
              onTap: () async => auth.logout(),
            ),
          ],
        ),
      ),
      body: const Center(child: Text("Vendor features go here")),
    );
  }
}
