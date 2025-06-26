import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_core/firebase_core.dart';
import 'homepage.dart ';

Future<void> main() async {
  runApp(const MyApp());

  await Firebase.initializeApp(
    options: FirebaseOptions(
      apiKey: 'AIzaSyDoeXAsnyHF_Ijzr1NV8ZFo1XHEjiR4_Ns',
      appId: '1:18632693175:android:c7ebbc5166637ea0e2c432',
      messagingSenderId: '18632693175',
      projectId: 'mealprep-4fc47',
    ),
  );
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});
  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Meal Planner',
      debugShowCheckedModeBanner: false,
      theme: ThemeData(fontFamily: 'Poppins'),
      home: HomePage()
    );
  }
}
