import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:intl/intl.dart';
import 'package:clerk_flutter/clerk_flutter.dart';

import 'scheduling.dart';
import 'RecipePage.dart'; // For RecipeDetailPage

class MealPlansScreen extends StatefulWidget {
  const MealPlansScreen({super.key});

  @override
  State<MealPlansScreen> createState() => _MealPlansScreenState();
}

class _MealPlansScreenState extends State<MealPlansScreen> {
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;
  String? _userId;

  @override
  void didChangeDependencies() {
    super.didChangeDependencies();
    final auth = ClerkAuth.of(context);
    _userId = auth.user?.id;
  }

  void _editMeal(DocumentSnapshot doc) async {
    final data = doc.data() as Map<String, dynamic>;

    await Navigator.push(
      context,
      MaterialPageRoute(
        builder: (_) => SchedulingScreen(
          editDocId: doc.id,
          initialMealId: data['MealId'],
          initialMealName: data['Meal'],
          initialType: data['Type'],
          initialDateTime: (data['DateTime'] as Timestamp).toDate(),
        ),
      ),
    );

    // Refresh the list when coming back
    setState(() {});
  }

  @override
  Widget build(BuildContext context) {
    if (_userId == null) {
      return const Scaffold(
        body: Center(child: Text('User not signed in')),
      );
    }

    return Scaffold(
      appBar: AppBar(title: const Text('My Meal Plans')),
      body: StreamBuilder<QuerySnapshot>(
        stream: _firestore
            .collection('Scheduling')
            .where('User', isEqualTo: _firestore.doc('/user/$_userId'))
            .orderBy('DateTime')
            .snapshots(),
        builder: (context, snapshot) {
          if (snapshot.connectionState == ConnectionState.waiting) {
            return const Center(child: CircularProgressIndicator());
          }

          if (!snapshot.hasData || snapshot.data!.docs.isEmpty) {
            return const Center(child: Text('No scheduled meals found.'));
          }

          final plans = snapshot.data!.docs;

          return ListView.builder(
            itemCount: plans.length,
            itemBuilder: (context, index) {
              final meal = plans[index];
              final data = meal.data() as Map<String, dynamic>;
              final dateTime = (data['DateTime'] as Timestamp).toDate();
              final formattedDate = DateFormat.yMMMd().add_jm().format(dateTime);

              return Card(
                margin: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
                child: ListTile(
                  leading: const Icon(Icons.restaurant_menu),
                  title: Text(data['Meal'] ?? 'Unknown Meal'),
                  subtitle: Text('${data['Type']} • $formattedDate'),
                  onTap: () {
                    if (data['MealId'] != null) {
                      final recipe = {
                        'id': int.tryParse(data['MealId'].toString()) ?? 0,
                        'title': data['Meal'],
                      };
                      Navigator.push(
                        context,
                        MaterialPageRoute(
                          builder: (_) => RecipeDetailPage(recipe: recipe),
                        ),
                      );
                    }
                  },
                  trailing: IconButton(
                    icon: const Icon(Icons.edit),
                    onPressed: () => _editMeal(meal),
                  ),
                ),
              );
            },
          );
        },
      ),
    );
  }
}
