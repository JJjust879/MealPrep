import 'package:flutter/material.dart';
import 'package:clerk_flutter/clerk_flutter.dart';
import 'screens/auth_gate.dart';
import 'screens/landing_page.dart';
import 'screens/home_page.dart';

void main() {
  runApp(MealPlanningApp());
}

class MealPlanningApp extends StatelessWidget {
  final String publishableKey = 'pk_test_bm90YWJsZS1jaGlja2VuLTEwLmNsZXJrLmFjY291bnRzLmRldiQ';

  @override
  Widget build(BuildContext context) {
    return ClerkAuth(
      config: ClerkAuthConfig(publishableKey: publishableKey),
      child: MaterialApp(
        debugShowCheckedModeBanner: false,
        title: 'Meal Planner',
        theme: ThemeData(primarySwatch: Colors.green),
        initialRoute: '/',
        routes: {
          '/': (context) => LandingPage(),
          '/auth': (context) => AuthGate(),
          '/home': (context) => HomePage(),
        },
      ),
    );
  }
}
