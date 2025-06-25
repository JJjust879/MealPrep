import 'package:flutter/material.dart';
import 'package:clerk_flutter/clerk_flutter.dart';

class HomePage extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('Meal Planner'),
        actions: [
          IconButton(
            icon: Icon(Icons.logout),
            onPressed: () async {
              final clerk = ClerkAuth.of(context);
              await clerk.signOut();
            },
          ),
        ],
      ),
      body: Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Text(
              'Welcome to Meal Planner!',
              style: TextStyle(fontSize: 24, fontWeight: FontWeight.bold),
            ),
            SizedBox(height: 20),
            Text('You are successfully logged in.'),
            SizedBox(height: 20),
            // Fixed user display
            ClerkAuthBuilder(
              signedInBuilder: (context, authState) {
                return Column(
                  children: [
                    Text('Hello, User!'),
                    SizedBox(height: 10),
                    Text(
                      'Status: Authenticated',
                      style: TextStyle(
                        color: Colors.green,
                        fontWeight: FontWeight.w500,
                      ),
                    ),
                  ],
                );
              },
              signedOutBuilder: (context, authState) {
                return Text('Not signed in');
              },
            ),
          ],
        ),
      ),
    );
  }
}