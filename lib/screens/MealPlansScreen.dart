import 'package:flutter/material.dart';
import 'package:flutter/foundation.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:http/http.dart' as http;
import 'dart:convert';

import 'package:intl/intl.dart';
import 'package:clerk_flutter/clerk_flutter.dart';
import 'scheduling.dart';
import 'RecipePage.dart';
import 'nutrition_line_chart.dart';
import 'recipe_cache_service.dart';

/// Screen that displays user's scheduled meal plans with nutrition analytics.
class MealPlansScreen extends StatefulWidget {
  const MealPlansScreen({super.key});

  @override
  State<MealPlansScreen> createState() => _MealPlansScreenState();
}

class _MealPlansScreenState extends State<MealPlansScreen> {
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;
  String? _userId;
  Future<Map<String, dynamic>>? _nutritionFuture;
  List<QueryDocumentSnapshot>? _lastPlans;

  /// Calculates nutrition data aggregated by day from meal plans.
  Future<Map<String, dynamic>> _calculateNutritionByDay(
    List<QueryDocumentSnapshot> plans,
  ) async {
    try {
      const wantedNutrients = [
        'Calories',
        'Protein',
        'Carbohydrates',
        'Fat',
        'Fiber',
        'Sugar',
        'Saturated Fat',
        'Cholesterol',
        'Sodium',
      ];

      final now = DateTime.now();
      final days = List.generate(7, (i) => now.subtract(Duration(days: 6 - i)));
      final dayLabels = days.map((d) => DateFormat('E').format(d)).toList();
      final Map<String, List<double>> nutritionByDay = {
        for (final nutrient in wantedNutrients) nutrient: List.filled(7, 0.0),
      };

      final cachedRecipes = await RecipeCacheService.loadRandomRecipes();
      final Map<int, Map<String, dynamic>> recipeMap = {
        for (final recipe in cachedRecipes)
          if (recipe['id'] != null) recipe['id'] as int: recipe,
      };

      for (final meal in plans) {
        final data = meal.data() as Map<String, dynamic>;
        final mealId = int.tryParse(data['MealId']?.toString() ?? '');
        if (mealId == null) continue;

        Map<String, dynamic>? recipe = recipeMap[mealId];
        if (recipe == null) {
          try {
            const apiKey = '3e348a8e7fe04eafbb6fa2ccf05e5bae';
            final url = Uri.parse(
              'https://api.spoonacular.com/recipes/$mealId/information?apiKey=$apiKey&includeNutrition=true',
            );
            final response = await http.get(url);
            if (response.statusCode == 200) {
              recipe = jsonDecode(response.body) as Map<String, dynamic>;
              cachedRecipes.add(recipe);
              await RecipeCacheService.saveRandomRecipes(cachedRecipes);
            }
          } catch (e) {
            continue;
          }
        }
        if (recipe == null) continue;

        if (recipe['nutrition'] != null &&
            recipe['nutrition']['nutrients'] != null) {
          final nutrients = recipe['nutrition']['nutrients'] as List<dynamic>;
          final date = (data['DateTime'] as Timestamp).toDate();
          final dayIndex = days.indexWhere(
            (day) =>
                day.year == date.year &&
                day.month == date.month &&
                day.day == date.day,
          );

          if (dayIndex == -1) continue;

          for (final nutrient in nutrients) {
            final nutrientName = nutrient['name'] as String?;
            if (nutrientName != null &&
                nutritionByDay.containsKey(nutrientName)) {
              final amount =
                  (nutrient['amount'] is num
                      ? (nutrient['amount'] as num).toDouble()
                      : 0.0);
              nutritionByDay[nutrientName]![dayIndex] += amount;
            }
          }
        }
      }

      return {'nutritionByDay': nutritionByDay, 'dayLabels': dayLabels};
    } catch (e, stackTrace) {
      assert(() {
        debugPrint('Error in _calculateNutritionByDay: $e');
        debugPrint('Stack trace: $stackTrace');
        return true;
      }());
      rethrow;
    }
  }

  void _updateNutritionFuture(List<QueryDocumentSnapshot> plans) {
    if (_lastPlans == null ||
        _lastPlans!.length != plans.length ||
        !_plansEqual(_lastPlans!, plans)) {
      _lastPlans = plans;
      _nutritionFuture = _calculateNutritionByDay(plans);
    }
  }

  bool _plansEqual(
    List<QueryDocumentSnapshot> planListA,
    List<QueryDocumentSnapshot> planListB,
  ) {
    if (planListA.length != planListB.length) return false;
    for (int i = 0; i < planListA.length; i++) {
      if (planListA[i].id != planListB[i].id) return false;
    }
    return true;
  }

  @override
  void didChangeDependencies() {
    super.didChangeDependencies();
    final auth = ClerkAuth.of(context);
    _userId = auth.user?.id;
  }

  Future<void> _editMeal(DocumentSnapshot doc) async {
    final data = doc.data() as Map<String, dynamic>;

    await Navigator.push(
      context,
      MaterialPageRoute(
        builder:
            (context) => SchedulingScreen(
              editDocId: doc.id,
              initialMealId: data['MealId'],
              initialMealName: data['Meal'],
              initialType: data['Type'],
              initialDateTime: (data['DateTime'] as Timestamp).toDate(),
            ),
      ),
    );

    setState(() {
      _nutritionFuture = null;
      _lastPlans = null;
    });
  }

  @override
  Widget build(BuildContext context) {
    if (_userId == null) {
      return const Scaffold(body: Center(child: Text('User not signed in')));
    }

    return Scaffold(
      appBar: AppBar(title: const Text('My Meal Plans')),
      body: StreamBuilder<QuerySnapshot>(
        stream:
            _firestore
                .collection('Scheduling')
                .where('User', isEqualTo: _firestore.doc('/user/$_userId'))
                .orderBy('DateTime')
                .snapshots(),
        builder: (context, snapshot) {
          if (snapshot.connectionState == ConnectionState.waiting) {
            return const Center(
              child: CircularProgressIndicator(color: Colors.green),
            );
          }
          if (!snapshot.hasData || snapshot.data!.docs.isEmpty) {
            return const Center(child: Text('No scheduled meals found.'));
          }
          final plans = snapshot.data!.docs;

          _updateNutritionFuture(plans);
          _nutritionFuture ??= _calculateNutritionByDay(plans);

          return FutureBuilder<Map<String, dynamic>>(
            future: _nutritionFuture,
            builder: (context, nutritionSnapshot) {
              return CustomScrollView(
                slivers: [
                  if (nutritionSnapshot.connectionState ==
                      ConnectionState.waiting)
                    const SliverToBoxAdapter(
                      child: Padding(
                        padding: EdgeInsets.all(16.0),
                        child: LinearProgressIndicator(color: Colors.green),
                      ),
                    )
                  else if (nutritionSnapshot.hasError)
                    SliverToBoxAdapter(
                      child: Padding(
                        padding: const EdgeInsets.all(16.0),
                        child: Card(
                          child: Padding(
                            padding: const EdgeInsets.all(16.0),
                            child: Column(
                              children: [
                                const Icon(Icons.error, color: Colors.red),
                                const SizedBox(height: 8),
                                Text(
                                  'Error loading nutrition data: ${nutritionSnapshot.error}',
                                ),
                              ],
                            ),
                          ),
                        ),
                      ),
                    )
                  else if (nutritionSnapshot.hasData)
                    SliverToBoxAdapter(
                      child: NutritionLineChart(
                        nutritionByDay:
                            nutritionSnapshot.data!['nutritionByDay']
                                as Map<String, List<double>>,
                        days:
                            nutritionSnapshot.data!['dayLabels']
                                as List<String>,
                      ),
                    )
                  else
                    const SliverToBoxAdapter(
                      child: Padding(
                        padding: EdgeInsets.all(16.0),
                        child: Card(
                          child: Padding(
                            padding: EdgeInsets.all(16.0),
                            child: Text('No nutrition data available'),
                          ),
                        ),
                      ),
                    ),
                  SliverList(
                    delegate: SliverChildBuilderDelegate((context, index) {
                      final meal = plans[index];
                      final data = meal.data() as Map<String, dynamic>;
                      final dateTime = (data['DateTime'] as Timestamp).toDate();
                      final formattedDate = DateFormat.yMMMd().add_jm().format(
                        dateTime,
                      );

                      return Card(
                        margin: const EdgeInsets.symmetric(
                          horizontal: 16,
                          vertical: 8,
                        ),
                        elevation: 0,
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(8),
                          side: BorderSide(color: Colors.grey[300]!, width: 1),
                        ),
                        child: ListTile(
                          leading: const Icon(Icons.restaurant_menu),
                          title: Text(data['Meal'] ?? 'Unknown Meal'),
                          subtitle: Text('${data['Type']} • $formattedDate'),
                          onTap: () {
                            if (data['MealId'] != null) {
                              final recipe = {
                                'id':
                                    int.tryParse(data['MealId'].toString()) ??
                                    0,
                                'title': data['Meal'],
                              };
                              Navigator.push(
                                context,
                                MaterialPageRoute(
                                  builder:
                                      (context) =>
                                          RecipeDetailPage(recipe: recipe),
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
                    }, childCount: plans.length),
                  ),

                  SliverToBoxAdapter(child: const SizedBox(height: 16)),
                ],
              );
            },
          );
        },
      ),
    );
  }
}
