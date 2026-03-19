import 'package:flutter/material.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'auth/auth_service.dart';

class DashboardPage extends StatelessWidget {
  final AuthService auth;

  const DashboardPage({super.key, required this.auth});

  @override
  Widget build(BuildContext context) {
    final user = FirebaseAuth.instance.currentUser;

    return Scaffold(
      appBar: AppBar(title: const Text("DrivAd Dashboard"), centerTitle: true),

      drawer: Drawer(
        child: Column(
          children: [
            UserAccountsDrawerHeader(
              accountName: const Text("Logged In User"),
              accountEmail: Text(user?.email ?? "No email"),
              currentAccountPicture: const CircleAvatar(
                child: Icon(Icons.person),
              ),
            ),

            ListTile(
              leading: const Icon(Icons.dashboard),
              title: const Text("Dashboard"),
              onTap: () {
                Navigator.pop(context);
              },
            ),

            ListTile(
              leading: const Icon(Icons.campaign),
              title: const Text("Campaigns"),
              onTap: () {
                Navigator.pop(context);
                Navigator.pushNamed(context, '/campaigns');
              },
            ),

            ListTile(
              leading: const Icon(Icons.assignment),
              title: const Text("Applications"),
              onTap: () {
                Navigator.pop(context);
                Navigator.pushNamed(context, '/applications');
              },
            ),

            ListTile(
              leading: const Icon(Icons.attach_money),
              title: const Text("Earnings"),
              onTap: () {
                Navigator.pop(context);
                Navigator.pushNamed(context, '/earnings');
              },
            ),

            ListTile(
              leading: const Icon(Icons.analytics),
              title: const Text("Analytics"),
              onTap: () {
                Navigator.pop(context);
                Navigator.pushNamed(context, '/analytics');
              },
            ),

            const Spacer(),

            const Divider(),

            ListTile(
              leading: const Icon(Icons.logout, color: Colors.red),
              title: const Text("Logout"),
              onTap: () async {
                await auth.logout();
              },
            ),
          ],
        ),
      ),

      body: SingleChildScrollView(
        padding: const EdgeInsets.all(20),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              "Welcome back 👋",
              style: Theme.of(context).textTheme.headlineSmall,
            ),
            const SizedBox(height: 8),

            Text(
              user?.email ?? "",
              style: Theme.of(context).textTheme.bodyMedium,
            ),

            const SizedBox(height: 30),

            Row(
              children: [
                _DashboardCard(
                  title: "Active Campaigns",
                  value: "3",
                  icon: Icons.campaign,
                  color: Colors.blue,
                ),
                const SizedBox(width: 12),
                _DashboardCard(
                  title: "Applications",
                  value: "12",
                  icon: Icons.assignment,
                  color: Colors.orange,
                ),
              ],
            ),

            const SizedBox(height: 12),

            Row(
              children: [
                _DashboardCard(
                  title: "Earnings",
                  value: "\$1,250",
                  icon: Icons.attach_money,
                  color: Colors.green,
                ),
                const SizedBox(width: 12),
                _DashboardCard(
                  title: "Analytics",
                  value: "24k Views",
                  icon: Icons.analytics,
                  color: Colors.purple,
                ),
              ],
            ),

            const SizedBox(height: 30),

            const Text(
              "Map Overview (MVP Placeholder)",
              style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
            ),

            const SizedBox(height: 12),

            Container(
              height: 220,
              decoration: BoxDecoration(
                borderRadius: BorderRadius.circular(16),
                color: Colors.grey.shade200,
              ),
              child: const Center(
                child: Column(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    Icon(Icons.map, size: 50),
                    SizedBox(height: 8),
                    Text("Map Placeholder"),
                  ],
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class _DashboardCard extends StatelessWidget {
  final String title;
  final String value;
  final IconData icon;
  final Color color;

  const _DashboardCard({
    required this.title,
    required this.value,
    required this.icon,
    required this.color,
  });

  @override
  Widget build(BuildContext context) {
    return Expanded(
      child: Container(
        padding: const EdgeInsets.all(16),
        decoration: BoxDecoration(
          borderRadius: BorderRadius.circular(16),
          color: color.withOpacity(0.1),
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Icon(icon, color: color),
            const SizedBox(height: 12),
            Text(
              value,
              style: const TextStyle(fontSize: 22, fontWeight: FontWeight.bold),
            ),
            const SizedBox(height: 4),
            Text(title),
          ],
        ),
      ),
    );
  }
}
