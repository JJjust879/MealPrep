import 'package:flutter/material.dart';
import 'package:clerk_flutter/clerk_flutter.dart';
import 'package:cloud_firestore/cloud_firestore.dart';

/// Authentication gate that handles user sign-in/sign-out flow.
class AuthGate extends StatefulWidget {
  const AuthGate({super.key});

  @override
  State<AuthGate> createState() => _AuthGateState();
}

class _AuthGateState extends State<AuthGate> {
  bool _navigated = false;

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: SafeArea(
        child: ClerkErrorListener(
          child: ClerkAuthBuilder(
            signedInBuilder: (context, authState) {
              final user = authState.user;

              if (!_navigated && user != null) {
                _navigated = true;
                saveUserToFirestore(user);
                WidgetsBinding.instance.addPostFrameCallback((_) {
                  Navigator.pushReplacementNamed(context, '/home');
                });
              }

              return const Center(
                child: CircularProgressIndicator(color: Colors.green),
              );
            },
            signedOutBuilder: (context, _) {
              return const ClerkAuthentication();
            },
          ),
        ),
      ),
    );
  }

  Future<void> saveUserToFirestore(dynamic user) async {
    final firestore = FirebaseFirestore.instance;
    final userDoc = firestore.collection('users').doc(user.id);

    final docSnapshot = await userDoc.get();

    if (!docSnapshot.exists) {
      final email =
          user.emailAddresses != null && user.emailAddresses.isNotEmpty
              ? user.emailAddresses.first.emailAddress
              : 'no-email@example.com';

      await userDoc.set({
        'id': user.id,
        'email': email,
        'createdAt': FieldValue.serverTimestamp(),
      });

      assert(() {
        debugPrint('User saved to Firestore.');
        return true;
      }());
    } else {
      assert(() {
        debugPrint('User already exists in Firestore.');
        return true;
      }());
    }
  }
}
