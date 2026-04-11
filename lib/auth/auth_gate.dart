import 'package:flutter/material.dart';
import 'package:firebase_auth/firebase_auth.dart';

import 'auth_service.dart';
import 'login_page.dart';

import '../dashboards/driver_dashboard_page.dart';
import '../dashboards/advertiser_dashboard_page.dart';
import '../dashboards/vendor_dashboard_page.dart';

class AuthGate extends StatefulWidget {
  final AuthService auth;

  const AuthGate({super.key, required this.auth});

  @override
  State<AuthGate> createState() => _AuthGateState();
}

class _AuthGateState extends State<AuthGate> {
  Future<String>? _roleFuture;
  String? _currentUid;

  @override
  Widget build(BuildContext context) {
    return StreamBuilder<User?>(
      stream: widget.auth.authStateChanges,
      builder: (context, snap) {
        // 1. Check Auth State
        if (snap.connectionState == ConnectionState.waiting) {
          return const Scaffold(
            body: Center(child: CircularProgressIndicator()),
          );
        }

        final user = snap.data;

        // 2. If not logged in, show Login
        if (user == null) {
          _roleFuture = null;
          _currentUid = null;
          return LoginPage(auth: widget.auth);
        }

        // 3. If logged in, fetch Role
        if (_currentUid != user.uid) {
          _currentUid = user.uid;
          _roleFuture = widget.auth.getOrCreateUserRole(user.uid).timeout(
            const Duration(seconds: 7),
            onTimeout: () => throw 'Connection timeout. Check your internet.',
          );
        }

        return FutureBuilder<String>(
          future: _roleFuture,
          builder: (context, roleSnap) {
            if (roleSnap.connectionState == ConnectionState.waiting) {
              return const Scaffold(
                body: Center(child: CircularProgressIndicator()),
              );
            }

            // 4. Handle Errors (like timeout or No Internet)
            if (roleSnap.hasError) {
              return Scaffold(
                body: Center(
                  child: Padding(
                    padding: const EdgeInsets.all(24),
                    child: Column(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        const Icon(Icons.wifi_off, size: 64, color: Colors.red),
                        const SizedBox(height: 16),
                        const Text(
                          "Connection Issue",
                          style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold),
                        ),
                        const SizedBox(height: 8),
                        Text(
                          roleSnap.error.toString(),
                          textAlign: TextAlign.center,
                          style: const TextStyle(color: Colors.grey),
                        ),
                        const SizedBox(height: 24),
                        ElevatedButton(
                          onPressed: () {
                            setState(() {
                              _currentUid = null; // Force retry
                            });
                          },
                          child: const Text("Retry"),
                        ),
                        TextButton(
                          onPressed: () => widget.auth.logout(),
                          child: const Text("Back to Login"),
                        ),
                      ],
                    ),
                  ),
                ),
              );
            }

            // 5. Success -> Show Dashboard
            final role = (roleSnap.data ?? 'driver').toLowerCase();

            switch (role) {
              case 'advertiser':
                return AdvertiserDashboardPage(auth: widget.auth);
              case 'vendor':
                return VendorDashboardPage(auth: widget.auth);
              case 'driver':
              default:
                return DriverDashboardPage(auth: widget.auth);
            }
          },
        );
      },
    );
  }
}
