import 'package:flutter/material.dart';
import 'greeting_card.dart';
import 'recipepage.dart';
import 'shoppinglist.dart';

class HomePage extends StatelessWidget {
  HomePage({super.key});

  final String userName = 'User';

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Meal Planner'),
        actions: [
          IconButton(
            icon: const Icon(Icons.account_circle),
            onPressed: () {
              // TODO: Integrate Clerk user button
            },
            tooltip: 'User',
          ),
        ],
      ),
      body: ListView(
        children: [
          GreetingCard(userName: userName),
          const Padding(
            padding: EdgeInsets.fromLTRB(16, 24, 16, 8),
            child: Text(
              'Your Saved Recipes',
              style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
            ),
          ),
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
            child: Text(
              'Add recipes to your meal plan',
              style: TextStyle(fontSize: 15, color: Colors.grey),
              textAlign: TextAlign.center,
            ),
          ),
          const SizedBox(height: 80), // For bottom nav bar spacing
        ],
      ),
      // Use Stack to overlay the Home FAB on the BottomAppBar
      bottomNavigationBar: Stack(
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
                  const SizedBox(width: 48), // Space for FAB
                  _NavBarItem(
                    icon: Icons.add_box,
                    label: 'Create Plan',
                    onTap: () {
                      // TODO: Navigate to Create
                    },
                  ),
                  _NavBarItem(
                    icon: Icons.description, // Changed to paper-like icon
                    label: 'Plans',
                    onTap: () {
                      // TODO: Navigate to Plans
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
              color: Theme.of(context).colorScheme.primary,
              child: InkWell(
                customBorder: const CircleBorder(),
                onTap: () {
                  // TODO: Home action
                },
                child: SizedBox(
                  height: 56,
                  width: 56,
                  child: Icon(Icons.home, color: Colors.white, size: 32),
                ),
              ),
            ),
          ),
        ],
      ),
      floatingActionButton: null, // Remove default FAB
      floatingActionButtonLocation: null,
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
          padding: const EdgeInsets.symmetric(vertical: 2), // Reduced padding
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              Icon(icon, size: 24), // Slightly smaller icon
              const SizedBox(height: 1),
              Text(label, style: const TextStyle(fontSize: 11)),
            ],
          ),
        ),
      ),
    );
  }
}
