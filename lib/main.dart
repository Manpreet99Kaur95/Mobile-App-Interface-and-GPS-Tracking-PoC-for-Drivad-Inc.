import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:provider/provider.dart';
import 'package:firebase_core/firebase_core.dart';
import 'package:mapbox_maps_flutter/mapbox_maps_flutter.dart';

import 'firebase_options.dart';
import 'language_provider.dart';

import 'auth/auth_gate.dart';
import 'auth/auth_service.dart';

// Pages
import 'campaigns_page.dart';
import 'applications_page.dart';
import 'earnings_page.dart';
import 'analytics_page.dart';
import 'profile_page.dart';

Future<void> main() async {
  WidgetsFlutterBinding.ensureInitialized();

  // Map box token
  MapboxOptions.setAccessToken('pk.eyJ1IjoiY2Fwc3RvbmUyMDI2IiwiYSI6ImNtbXd3MGVzdjJ2NjEycXB0ZnZ4M2hwMGQifQ.iat--fExYPGF9CHPkoKW3w');

  // Enable Edge-to-Edge mode
  SystemChrome.setSystemUIOverlayStyle(
    const SystemUiOverlayStyle(
      statusBarColor: Colors.transparent,
      systemNavigationBarColor: Colors.transparent,
      statusBarIconBrightness:
          Brightness.dark, // Dark icons for light background
      systemNavigationBarIconBrightness: Brightness.dark,
    ),
  );
  SystemChrome.setEnabledSystemUIMode(SystemUiMode.edgeToEdge);

  await Firebase.initializeApp(options: DefaultFirebaseOptions.currentPlatform);

  runApp(
    MultiProvider(
      providers: [ChangeNotifierProvider(create: (_) => LanguageProvider())],
      child: const MyApp(),
    ),
  );
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  static final AuthService _auth = AuthService();

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: () {
        FocusScopeNode currentFocus = FocusScope.of(context);
        if (!currentFocus.hasPrimaryFocus &&
            currentFocus.focusedChild != null) {
          FocusManager.instance.primaryFocus?.unfocus();
        }
      },
      child: MaterialApp(
        title: 'DrivAd',
        debugShowCheckedModeBanner: false,
        theme: ThemeData(
          colorScheme: ColorScheme.fromSeed(seedColor: Colors.blue),
          useMaterial3: true,
          fontFamily: 'Inter',
        ),
        home: AuthGate(auth: _auth),
        routes: {
          '/home': (_) => AuthGate(auth: _auth),
          '/dashboard': (_) => AuthGate(auth: _auth),
          '/campaigns': (_) => CampaignsPage(auth: _auth),
          '/applications': (_) => ApplicationsPage(auth: _auth),
          '/earnings': (_) => EarningsPage(auth: _auth),
          '/analytics': (_) => AnalyticsPage(auth: _auth),
          '/profile': (_) => ProfilePage(auth: _auth),
        },
      ),
    );
  }
}
