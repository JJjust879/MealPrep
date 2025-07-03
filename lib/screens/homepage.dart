import 'package:flutter/material.dart';
import 'package:clerk_flutter/clerk_flutter.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'weekly_calendar.dart';
import 'recipepage.dart';
import 'shoppinglist.dart';
import 'scheduling.dart';
import 'MealPlansScreen.dart';

/// Main home screen displaying the meal planner interface.
class HomePage extends StatelessWidget {
  const HomePage({super.key});

  @override
  Widget build(BuildContext context) {
    return ClerkAuthBuilder(
      signedInBuilder: (context, authState) {
        final user = authState.user;

        return Scaffold(
          appBar: AppBar(
            title: const Text('Meal Planner'),
            actions: [
              IconButton(
                icon: const Icon(Icons.logout),
                onPressed: () async {
                  await authState.signOut();
                  Navigator.pushReplacementNamed(context, '/landing');
                },
                tooltip: 'Logout',
              ),
            ],
          ),
          body: ListView(
            children: [
              WeeklyCalendar(userId: user?.id),
              const Padding(
                padding: EdgeInsets.fromLTRB(16, 24, 16, 8),
                child: Text(
                  'Your Created Meals',
                  style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
                ),
              ),
              StreamBuilder<QuerySnapshot>(
                stream:
                    FirebaseFirestore.instance
                        .collection('Scheduling')
                        .where(
                          'User',
                          isEqualTo: FirebaseFirestore.instance.doc(
                            '/user/${user?.id}',
                          ),
                        )
                        .orderBy('DateTime')
                        .limit(3)
                        .snapshots(),
                builder: (context, snapshot) {
                  if (snapshot.connectionState == ConnectionState.waiting) {
                    return const Padding(
                      padding: EdgeInsets.all(16),
                      child: Center(
                        child: CircularProgressIndicator(color: Colors.green),
                      ),
                    );
                  }

                  if (snapshot.hasError) {
                    return const Padding(
                      padding: EdgeInsets.all(16),
                      child: Text('Error loading meals'),
                    );
                  }

                  final docs = snapshot.data?.docs ?? [];

                  if (docs.isEmpty) {
                    return const Padding(
                      padding: EdgeInsets.all(16),
                      child: Text('No upcoming meals found.'),
                    );
                  }

                  return Column(
                    children:
                        docs.map((doc) {
                          final data = doc.data() as Map<String, dynamic>;
                          final mealName = data['Meal'] ?? 'Unknown';
                          final type = data['Type'] ?? '';
                          final time = (data['DateTime'] as Timestamp).toDate();

                          return ListTile(
                            leading: const Icon(Icons.fastfood),
                            title: Text(mealName),
                            subtitle: Text('$type • ${time.toLocal()}'),
                            onTap: () {
                              final mealId = data['MealId'];
                              final mealTitle = data['Meal'];

                              if (mealId != null) {
                                Navigator.push(
                                  context,
                                  MaterialPageRoute(
                                    builder:
                                        (context) => RecipeDetailPage(
                                          recipe: {
                                            'id': int.tryParse(mealId) ?? 0,
                                            'title': mealTitle,
                                          },
                                        ),
                                  ),
                                );
                              }
                            },
                          );
                        }).toList(),
                  );
                },
              ),
              const SizedBox(height: 80),
            ],
          ),

          bottomNavigationBar: _buildBottomNavigationBar(context),
        );
      },
      signedOutBuilder: (context, _) => const ClerkAuthentication(),
    );
  }

  Widget _buildBottomNavigationBar(BuildContext context) {
    return Stack(
      alignment: Alignment.bottomCenter,
      children: [
        BottomAppBar(
          elevation: 0,
          child: Padding(
            padding: const EdgeInsets.symmetric(horizontal: 8.0),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              crossAxisAlignment: CrossAxisAlignment.end,
              children: [
                _NavBarItem(
                  icon: Icons.book,
                  label: 'Recipes',
                  onTap: () {
                    Navigator.push(
                      context,
                      MaterialPageRoute(
                        builder: (context) => const RecipePage(),
                      ),
                    );
                  },
                ),
                _NavBarItem(
                  icon: Icons.shopping_cart,
                  label: 'Grocery List',
                  onTap: () {
                    Navigator.push(
                      context,
                      MaterialPageRoute(
                        builder: (context) => const ShoppingListPage(),
                      ),
                    );
                  },
                ),
                const SizedBox(width: 48),
                _NavBarItem(
                  icon: Icons.add_box,
                  label: 'Create Plan',
                  onTap: () {
                    Navigator.push(
                      context,
                      MaterialPageRoute(
                        builder: (context) => const SchedulingScreen(),
                      ),
                    );
                  },
                ),
                _NavBarItem(
                  icon: Icons.description,
                  label: 'Plans',
                  onTap: () {
                    Navigator.push(
                      context,
                      MaterialPageRoute(
                        builder: (context) => const MealPlansScreen(),
                      ),
                    );
                  },
                ),
              ],
            ),
          ),
        ),
        Positioned(
          bottom: 35,
          child: Container(
            height: 56,
            width: 56,
            decoration: BoxDecoration(
              shape: BoxShape.circle,
              color: Colors.green[700],
              border: Border.all(color: Colors.green[300]!, width: 2),
            ),
            child: GestureDetector(
              onTap: () {},
              child: const Icon(Icons.home, color: Colors.white, size: 32),
            ),
          ),
        ),
      ],
    );
  }
}

class _NavBarItem extends StatelessWidget {
  final IconData icon;
  final String label;
  final VoidCallback onTap;

  const _NavBarItem({
    required this.icon,
    required this.label,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    return Flexible(
      child: GestureDetector(
        onTap: onTap,
        child: Padding(
          padding: const EdgeInsets.symmetric(vertical: 2),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              Icon(icon, size: 24),
              const SizedBox(height: 1),
              Text(label, style: const TextStyle(fontSize: 11)),
            ],
          ),
        ),
      ),
    );
  }
}
