import 'package:flutter/material.dart';
import 'package:firebase_core/firebase_core.dart';
import 'package:clerk_flutter/clerk_flutter.dart';
import 'screens/auth_gate.dart';
import 'screens/homepage.dart';
import 'screens/landing_page.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  await Firebase.initializeApp();

  runApp(const MealPlanningApp());
}

class MealPlanningApp extends StatelessWidget {
  const MealPlanningApp({super.key});

  final String publishableKey = 'pk_test_bm90YWJsZS1jaGlja2VuLTEwLmNsZXJrLmFjY291bnRzLmRldiQ';

  @override
  Widget build(BuildContext context) {
    return ClerkAuth(
      config: ClerkAuthConfig(publishableKey: publishableKey),
      child: MaterialApp(
        debugShowCheckedModeBanner: false,
        title: 'Meal Planner',
        theme: ThemeData(primarySwatch: Colors.green),
        initialRoute: '/landing',
        routes: {
          '/auth': (context) =>  AuthGate(),
          '/home': (context) => HomePage(),
          '/landing': (context) => LandingPage(),
        },
      ),
    );
  }
}
