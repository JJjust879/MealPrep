import 'package:flutter/material.dart';
import 'package:clerk_flutter/clerk_flutter.dart';
import 'greeting_card.dart';
import 'recipepage.dart';
import 'shoppinglist.dart';
import 'scheduling.dart';
import 'MealPlansScreen.dart';
import 'package:cloud_firestore/cloud_firestore.dart';

class HomePage extends StatelessWidget {
  const HomePage({super.key});

  @override
  Widget build(BuildContext context) {
    return ClerkAuthBuilder(
      signedInBuilder: (context, authState) {
        final user = authState.user;
        final userName = user?.firstName ?? 'User';

        return Scaffold(
          appBar: AppBar(
            title: const Text('Meal Planner'),
            actions: [
              IconButton(
                icon: const Icon(Icons.logout),
                onPressed: () async {
                  await authState.signOut(); // Sign out using Clerk
                  Navigator.pushReplacementNamed(context, '/landing');
                },
                tooltip: 'Logout',
              ),
            ],
          ),
          body: ListView(
            children: [
              GreetingCard(userName: userName),

              const Padding(
                padding: EdgeInsets.fromLTRB(16, 24, 16, 8),
                child: Text(
                  'Your Upcoming Meals',
                  style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
                ),
              ),

              FutureBuilder<QuerySnapshot>(
                future: FirebaseFirestore.instance
                    .collection('Scheduling')
                    .where('User', isEqualTo: FirebaseFirestore.instance.doc('/user/${user?.id}'))
                    .orderBy('DateTime')
                    .limit(3)
                    .get(),
                builder: (context, snapshot) {
                  if (snapshot.connectionState == ConnectionState.waiting) {
                    return const Padding(
                      padding: EdgeInsets.all(16),
                      child: Center(child: CircularProgressIndicator()),
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
                    children: docs.map((doc) {
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
                                builder: (_) => RecipeDetailPage(
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

              const Padding(
                padding: EdgeInsets.fromLTRB(16, 24, 16, 8),
                child: Text(
                  'Your Saved Recipes',
                  style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
                ),
              ),

              Padding(
                padding: const EdgeInsets.symmetric(
                  horizontal: 16,
                  vertical: 12,
                ),
                child: Text(
                  'Add recipes to your meal plan',
                  style: TextStyle(fontSize: 15, color: Colors.grey[600]),
                  textAlign: TextAlign.center,
                ),
              ),

              const SizedBox(height: 80),
            ],
          ),

          bottomNavigationBar: _buildBottomNavigationBar(context),
          floatingActionButton: null,
          floatingActionButtonLocation: null,
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
          shape: const CircularNotchedRectangle(),
          notchMargin: 8.0,
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
                        builder: (context) => SchedulingScreen(),
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
                        builder: (context) => MealPlansScreen(),
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
          child: Material(
            elevation: 10,
            shape: const CircleBorder(),
            color: Colors.green[700],
            child: InkWell(
              customBorder: const CircleBorder(),
              onTap: () {
                // TODO: Home action
              },
              child: const SizedBox(
                height: 56,
                width: 56,
                child: Icon(
                  Icons.home,
                  color: Colors.white,
                  size: 32,
                ), // keep white for icon, matches landing page
              ),
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
      child: InkWell(
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
