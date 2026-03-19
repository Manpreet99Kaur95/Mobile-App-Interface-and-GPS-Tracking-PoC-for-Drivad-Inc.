import 'package:flutter/material.dart';
import '../../auth/auth_service.dart';
import '../../auth/login_page.dart';

class AuthScreen extends StatelessWidget {
  final AuthService auth;

  const AuthScreen({super.key, required this.auth});

  @override
  Widget build(BuildContext context) {
    // ✅ Use the new auth flow (Login/Register pages handle role)
    return LoginPage(auth: auth);
  }
}
