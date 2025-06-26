import 'package:flutter/material.dart';
import 'recipemodel.dart';
import 'greeting_card.dart';
import 'recipe_carousel.dart';

class HomePage extends StatelessWidget {
  HomePage({super.key});

  final String userName = 'User';


  final List<RecipeModel> recommendedRecipes = [
    RecipeModel(name: 'Protein Pancakes', time: '15 min', calories: 320),
    RecipeModel(name: 'Chicken Stir Fry', time: '20 min', calories: 410),
    RecipeModel(name: 'Greek Yogurt Parfait', time: '5 min', calories: 180),
  ];

  final List<RecipeModel> savedRecipes = [
    RecipeModel(name: 'Egg White Omelette', time: '10 min', calories: 150),
    RecipeModel(name: 'Tuna Salad', time: '8 min', calories: 220),
    RecipeModel(name: 'Grilled Tofu Bowl', time: '18 min', calories: 300),
  ];

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
          RecipeCarousel(
            recipes: recommendedRecipes,
            title: 'Recommended For You',
            titleStyle: const TextStyle(
              fontSize: 18,
              fontWeight: FontWeight.bold,
            ),
          ),
          const Padding(
            padding: EdgeInsets.fromLTRB(16, 24, 16, 8),
            child: Text(
              'Your Saved Recipes',
              style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
            ),
          ),
          ...savedRecipes.map(
            (recipe) => Padding(
              padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 6),
              child: Card(
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(12),
                ),
                elevation: 2,
                child: ListTile(
                  title: Text(recipe.name),
                  subtitle: Row(
                    children: [
                      Icon(Icons.access_time, size: 14),
                      const SizedBox(width: 3),
                      Text(recipe.time, style: const TextStyle(fontSize: 12)),
                      const SizedBox(width: 10),
                      Icon(
                        Icons.local_fire_department,
                        size: 14,
                        color: Colors.redAccent,
                      ),
                      const SizedBox(width: 3),
                      Text(
                        recipe.calories != null
                            ? '${recipe.calories} kcal'
                            : '-- kcal',
                        style: const TextStyle(fontSize: 12),
                      ),
                    ],
                  ),
                ),
              ),
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
                      // TODO: Navigate to Recipes
                    },
                  ),
                  _NavBarItem(
                    icon: Icons.shopping_cart,
                    label: 'Grocery List',
                    onTap: () {
                      // TODO: Navigate to Shopping
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
                    label: 'View Plans',
                    onTap: () {
                      // TODO: Navigate to View
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
