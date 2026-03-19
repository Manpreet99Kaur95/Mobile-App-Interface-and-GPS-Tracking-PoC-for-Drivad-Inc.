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
        if (snap.connectionState == ConnectionState.waiting) {
          return const Scaffold(
            body: Center(child: CircularProgressIndicator()),
          );
        }

        final user = snap.data;

        if (user == null) {
          _roleFuture = null;
          _currentUid = null;
          return LoginPage(auth: widget.auth);
        }

        if (_currentUid != user.uid) {
          _currentUid = user.uid;

          _roleFuture = widget.auth
              .getOrCreateUserRole(user.uid)
              .timeout(const Duration(seconds: 10), onTimeout: () => 'driver');
        }

        return FutureBuilder<String>(
          future: _roleFuture,
          builder: (context, roleSnap) {
            if (roleSnap.connectionState == ConnectionState.waiting) {
              return const Scaffold(
                body: Center(child: CircularProgressIndicator()),
              );
            }

            if (roleSnap.hasError) {
              return Scaffold(
                body: Center(
                  child: Padding(
                    padding: const EdgeInsets.all(20),
                    child: Column(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        const Icon(Icons.error_outline, size: 50),
                        const SizedBox(height: 12),
                        const Text(
                          "Failed to load user role",
                          style: TextStyle(
                            fontWeight: FontWeight.bold,
                            fontSize: 16,
                          ),
                        ),
                        const SizedBox(height: 8),
                        Text(
                          roleSnap.error.toString(),
                          textAlign: TextAlign.center,
                        ),
                        const SizedBox(height: 16),
                        ElevatedButton(
                          onPressed: () => widget.auth.logout(),
                          child: const Text("Logout"),
                        ),
                      ],
                    ),
                  ),
                ),
              );
            }

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
