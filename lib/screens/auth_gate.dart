import 'package:flutter/material.dart';
import 'package:clerk_flutter/clerk_flutter.dart';

class AuthGate extends StatelessWidget {
  const AuthGate({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: SafeArea(
        child: ClerkErrorListener(
          child: ClerkAuthBuilder(
            signedInBuilder: (context, authState) {
              // Redirect to /home once signed in
              Future.microtask(() {
                Navigator.pushReplacementNamed(context, '/home');
              });
              return const Center(child: CircularProgressIndicator());
            },
            signedOutBuilder: (context, authState) {
              // Show Clerk's built-in Login/Register UI
              return const ClerkAuthentication();
            },
          ),
        ),
      ),
    );
  }
}
