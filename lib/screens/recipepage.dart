import 'package:flutter/material.dart';
import 'package:clerk_flutter/clerk_flutter.dart';
import 'package:http/http.dart' as http;
import 'dart:convert';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:hive/hive.dart';
import 'package:path_provider/path_provider.dart';
import 'recipe_cache_service.dart';

class RecipePage extends StatefulWidget {
  const RecipePage({super.key});

  @override
  State<RecipePage> createState() => _RecipePageState();
}

class _RecipePageState extends State<RecipePage> {
  final TextEditingController _inputController = TextEditingController();
  List<Map<String, dynamic>> _recipes = [];
  List<Map<String, dynamic>> _randomRecipes = [];
  bool _loadingRandom = false;
  @override
  void initState() {
    super.initState();
    _initHiveAndLoadCache();
  }

  Future<void> _initHiveAndLoadCache() async {
    final dir = await getApplicationDocumentsDirectory();
    Hive.init(dir.path);
    final cached = await RecipeCacheService.loadRandomRecipes();
    if (cached.isNotEmpty) {
      setState(() {
        _randomRecipes = cached;
      });
    } else {
      _fetchRandomRecipes();
    }
  }

  Future<void> _fetchRandomRecipes() async {
    setState(() {
      _loadingRandom = true;
      _randomRecipes = [];
    });
    await Future.delayed(const Duration(milliseconds: 1000));
    try {
      final apiKey = '3e348a8e7fe04eafbb6fa2ccf05e5bae';
      final url = Uri.parse(
        'https://api.spoonacular.com/recipes/random?apiKey=$apiKey&number=5&tags=main+course&includeNutrition=true',
      );
      final response = await http.get(url);
      if (response.statusCode == 200) {
        final data = jsonDecode(response.body);
        final results = data['recipes'] as List<dynamic>?;
        final recipes =
            results != null
                ? results.map((e) => Map<String, dynamic>.from(e)).toList()
                : <Map<String, dynamic>>[];
        setState(() {
          _randomRecipes = recipes;
        });
        await RecipeCacheService.saveRandomRecipes(
          List<Map<String, dynamic>>.from(recipes),
        );
      } else {
        setState(() {
          _randomRecipes = [];
        });
      }
    } catch (e) {
      setState(() {
        _randomRecipes = [];
      });
    } finally {
      setState(() {
        _loadingRandom = false;
      });
    }
  }

  bool _loading = false;
  String? _error;

  Future<void> analyzeRecipe(String recipeText) async {
    setState(() {
      _loading = true;
      _error = null;
      _recipes = [];
    });
    try {
      final apiKey = '3e348a8e7fe04eafbb6fa2ccf05e5bae';
      final url = Uri.parse(
        'https://api.spoonacular.com/recipes/complexSearch?apiKey=$apiKey&query=${Uri.encodeComponent(recipeText)}',
      );
      final response = await http.get(url);
      if (response.statusCode == 200) {
        final data = response.body;
        final json = data.isNotEmpty ? (await Future.value(data)) : '{}';
        final decoded = jsonDecode(json);
        final results = decoded['results'] as List<dynamic>?;
        setState(() {
          _recipes =
              results != null
                  ? results.map((e) => Map<String, dynamic>.from(e)).toList()
                  : [];
        });
      } else {
        setState(() {
          _error = 'Error: ${response.statusCode}\n${response.body}';
        });
      }
    } catch (e) {
      setState(() {
        _error = e.toString();
      });
    } finally {
      setState(() {
        _loading = false;
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Find Recipes Here')),
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            Row(
              children: [
                Expanded(
                  flex: 7,
                  child: SizedBox(
                    height: 48,
                    child: TextField(
                      controller: _inputController,
                      decoration: const InputDecoration(
                        labelText: 'Search Recipes',
                        border: OutlineInputBorder(),
                        isDense: true,
                        contentPadding: EdgeInsets.symmetric(
                          vertical: 12,
                          horizontal: 12,
                        ),
                      ),
                    ),
                  ),
                ),
                const SizedBox(width: 8),
                SizedBox(
                  height: 48,
                  width: 48,
                  child: ElevatedButton(
                    style: ElevatedButton.styleFrom(
                      padding: EdgeInsets.zero,
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(8),
                      ),
                    ),
                    onPressed:
                        _loading
                            ? null
                            : () => analyzeRecipe(_inputController.text),
                    child:
                        _loading
                            ? const SizedBox(
                              width: 20,
                              height: 20,
                              child: CircularProgressIndicator(
                                strokeWidth: 2,
                                color: Colors.green,
                              ),
                            )
                            : const Icon(
                              Icons.search,
                              color: Color.fromARGB(255, 28, 67, 30),
                            ),
                  ),
                ),
              ],
            ),
            const SizedBox(height: 20),
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                const Text(
                  "Can't Decide? Try These Out",
                  style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
                ),
                IconButton(
                  icon: const Icon(Icons.refresh),
                  tooltip: 'Refresh',
                  onPressed: _loadingRandom ? null : _fetchRandomRecipes,
                ),
              ],
            ),
            SizedBox(
              height: 210,
              child:
                  _loadingRandom
                      ? const Center(
                        child: CircularProgressIndicator(color: Colors.green),
                      )
                      : _randomRecipes.isEmpty
                      ? const Center(child: Text('No recommendations.'))
                      : ListView.separated(
                        scrollDirection: Axis.horizontal,
                        itemCount: _randomRecipes.length,
                        separatorBuilder: (_, __) => const SizedBox(width: 12),
                        itemBuilder: (context, index) {
                          final recipe = _randomRecipes[index];
                          return GestureDetector(
                            onTap: () {
                              Navigator.of(context).push(
                                MaterialPageRoute(
                                  builder:
                                      (_) => RecipeDetailPage(recipe: recipe),
                                ),
                              );
                            },
                            child: SizedBox(
                              width: 170,
                              child: Card(
                                shape: RoundedRectangleBorder(
                                  borderRadius: BorderRadius.circular(16),
                                ),
                                elevation: 0,
                                child: Column(
                                  crossAxisAlignment:
                                      CrossAxisAlignment.stretch,
                                  children: [
                                    ClipRRect(
                                      borderRadius: const BorderRadius.vertical(
                                        top: Radius.circular(16),
                                      ),
                                      child:
                                          recipe['image'] != null
                                              ? Image.network(
                                                recipe['image'],
                                                height: 100,
                                                width: double.infinity,
                                                fit: BoxFit.cover,
                                              )
                                              : Container(
                                                height: 100,
                                                color: Colors.green[50],
                                                child: const Icon(
                                                  Icons.fastfood,
                                                  size: 40,
                                                ),
                                              ),
                                    ),
                                    Padding(
                                      padding: const EdgeInsets.all(8.0),
                                      child: Column(
                                        crossAxisAlignment:
                                            CrossAxisAlignment.start,
                                        children: [
                                          Text(
                                            recipe['title'] ?? '',
                                            maxLines: 2,
                                            overflow: TextOverflow.ellipsis,
                                            style: const TextStyle(
                                              fontWeight: FontWeight.bold,
                                            ),
                                          ),
                                          const SizedBox(height: 4),
                                          Row(
                                            children: [
                                              const Icon(Icons.timer, size: 16),
                                              const SizedBox(width: 4),
                                              Text(
                                                recipe['readyInMinutes'] != null
                                                    ? '${recipe['readyInMinutes']} min'
                                                    : 'N/A',
                                                style: const TextStyle(
                                                  fontSize: 13,
                                                ),
                                              ),
                                            ],
                                          ),
                                          const SizedBox(height: 4),
                                          Row(
                                            children: [
                                              const Icon(
                                                Icons.local_fire_department,
                                                size: 16,
                                                color: Colors.orange,
                                              ),
                                              const SizedBox(width: 4),
                                              Text(
                                                _getCalories(recipe),
                                                style: const TextStyle(
                                                  fontSize: 13,
                                                ),
                                              ),
                                            ],
                                          ),
                                        ],
                                      ),
                                    ),
                                  ],
                                ),
                              ),
                            ),
                          );
                        },
                      ),
            ),
            const SizedBox(height: 24),
            if (_error != null)
              Text('Error: $_error', style: TextStyle(color: Colors.green)),
            Expanded(
              child:
                  _recipes.isEmpty
                      ? const Center(child: Text('No search results.'))
                      : ListView.builder(
                        itemCount: _recipes.length,
                        itemBuilder: (context, index) {
                          final recipe = _recipes[index];
                          return Card(
                            margin: const EdgeInsets.symmetric(vertical: 8),
                            elevation: 0,
                            child: ListTile(
                              leading:
                                  recipe['image'] != null
                                      ? Image.network(
                                        recipe['image'],
                                        width: 60,
                                        height: 60,
                                        fit: BoxFit.cover,
                                      )
                                      : const Icon(Icons.fastfood),
                              title: Text(recipe['title'] ?? 'No title'),
                              onTap: () {
                                Navigator.of(context).push(
                                  MaterialPageRoute(
                                    builder:
                                        (_) => RecipeDetailPage(recipe: recipe),
                                  ),
                                );
                              },
                            ),
                          );
                        },
                      ),
            ),
          ],
        ),
      ),
    );
  }

  /// Gets calories from recipe nutrition data.
  String _getCalories(Map<String, dynamic> recipe) {
    if (recipe['nutrition'] != null &&
        recipe['nutrition']['nutrients'] != null) {
      final nutrients = recipe['nutrition']['nutrients'] as List<dynamic>;
      final cal = nutrients.firstWhere(
        (n) => n['name'] == 'Calories',
        orElse: () => null,
      );
      if (cal != null) {
        return '${cal['amount'].toStringAsFixed(0)} kcal';
      }
    }
    return 'N/A';
  }
}

class RecipeDetailPage extends StatelessWidget {
  final Map<String, dynamic> recipe;
  const RecipeDetailPage({super.key, required this.recipe});

  Future<Map<String, dynamic>?> fetchRecipeDetails(int id) async {
    final apiKey = '3e348a8e7fe04eafbb6fa2ccf05e5bae';
    final url = Uri.parse(
      'https://api.spoonacular.com/recipes/$id/information?apiKey=$apiKey&includeNutrition=true',
    );
    final response = await http.get(url);
    if (response.statusCode == 200) {
      return jsonDecode(response.body) as Map<String, dynamic>;
    }
    return null;
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: Text(recipe['title'] ?? 'Recipe Detail')),
      body: FutureBuilder<Map<String, dynamic>?>(
        future: fetchRecipeDetails(recipe['id']),
        builder: (context, snapshot) {
          if (snapshot.connectionState == ConnectionState.waiting) {
            return const Center(
              child: CircularProgressIndicator(color: Colors.green),
            );
          }
          if (snapshot.hasError) {
            return Center(child: Text('Error: \\${snapshot.error}'));
          }
          final details = snapshot.data;
          if (details == null) {
            return const Center(child: Text('No details found.'));
          }
          return SingleChildScrollView(
            child: Padding(
              padding: const EdgeInsets.symmetric(horizontal: 18.0),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.stretch,
                children: [
                  if (details['image'] != null)
                    ClipRRect(
                      borderRadius: BorderRadius.circular(16),
                      child: Image.network(
                        details['image'],
                        height: 280,
                        width: double.infinity,
                        fit: BoxFit.cover,
                      ),
                    ),
                  const SizedBox(height: 16),
                  Text(
                    details['title'] ?? '',
                    style: Theme.of(context).textTheme.titleLarge,
                  ),
                  const SizedBox(height: 8),
                  Text('ID: \\${details['id'] ?? 'N/A'}'),
                  if (details['readyInMinutes'] != null)
                    Text('Ready in: \\${details['readyInMinutes']} min'),
                  if (details['servings'] != null)
                    Text('Servings: \\${details['servings']}'),
                  const SizedBox(height: 16),
                  if (details['nutrition'] != null &&
                      details['nutrition']['nutrients'] != null)
                    Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          'Nutrition:',
                          style: Theme.of(context).textTheme.titleMedium,
                        ),
                        ..._buildNutritionList(
                          details['nutrition']['nutrients'] as List<dynamic>,
                        ),
                      ],
                    ),
                  const SizedBox(height: 16),
                  if (details['extendedIngredients'] != null)
                    Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          'Ingredients:',
                          style: Theme.of(context).textTheme.titleMedium,
                        ),
                        ...List<Widget>.from(
                          (details['extendedIngredients'] as List).map(
                            (i) => Text('- ${i['original']}'),
                          ),
                        ),
                        const SizedBox(height: 12),
                        ClerkAuthBuilder(
                          signedInBuilder: (context, authState) {
                            final user = authState.user;
                            return TextButton(
                              style: TextButton.styleFrom(
                                side: const BorderSide(
                                  color: Colors.green,
                                  width: 1.5,
                                ),
                                shape: RoundedRectangleBorder(
                                  borderRadius: BorderRadius.circular(8),
                                ),
                                foregroundColor: Colors.green,
                                padding: const EdgeInsets.symmetric(
                                  vertical: 10,
                                  horizontal: 16,
                                ),
                              ),
                              onPressed:
                                  user == null
                                      ? null
                                      : () async {
                                        final userId = user.id;
                                        final recipeName =
                                            details['title'] ?? 'Recipe';
                                        final List<String> ingredients =
                                            (details['extendedIngredients']
                                                    as List)
                                                .map<String>(
                                                  (i) =>
                                                      i['original'].toString(),
                                                )
                                                .toList();
                                        await FirebaseFirestore.instance
                                            .collection('Shopping')
                                            .doc(recipeName)
                                            .set({
                                              'List': ingredients,
                                              'userid': FirebaseFirestore
                                                  .instance
                                                  .doc('/user/$userId'),
                                            });
                                        if (context.mounted) {
                                          ScaffoldMessenger.of(
                                            context,
                                          ).showSnackBar(
                                            SnackBar(
                                              content: Text(
                                                'Added to shopping list!',
                                              ),
                                              backgroundColor:
                                                  Colors.green[700],
                                            ),
                                          );
                                        }
                                      },
                              child: const Text(
                                'Add To Shopping List',
                                style: TextStyle(
                                  color: Colors.green,
                                  fontWeight: FontWeight.bold,
                                  fontSize: 16,
                                ),
                              ),
                            );
                          },
                          signedOutBuilder:
                              (context, _) => const SizedBox.shrink(),
                        ),
                      ],
                    ),
                  const SizedBox(height: 16),
                  if (details['instructions'] != null)
                    Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          'Instructions:',
                          style: Theme.of(context).textTheme.titleMedium,
                        ),
                        ..._parseInstructions(details['instructions'] ?? ''),
                      ],
                    ),
                ],
              ),
            ),
          );
        },
      ),
    );
  }
}

/// Parses HTML instructions into a numbered list.
List<Widget> _parseInstructions(String html) {
  String cleaned = html
      .replaceAll(RegExp(r'<(\/)?(ol|ul|p)>'), '')
      .replaceAll(RegExp(r'<\/li>'), '')
      .replaceAll(RegExp(r'\n'), '');
  final steps =
      cleaned.split(RegExp(r'<li>')).where((s) => s.trim().isNotEmpty).toList();
  if (steps.isEmpty) {
    return [Text(html.replaceAll(RegExp(r'<[^>]+>'), '').trim())];
  }
  return steps
      .asMap()
      .entries
      .map(
        (entry) => Padding(
          padding: const EdgeInsets.symmetric(vertical: 2.0),
          child: Text('${entry.key + 1}. ${entry.value.trim()}'),
        ),
      )
      .toList();
}

/// Builds a list of relevant nutrition information widgets.
List<Widget> _buildNutritionList(List<dynamic> nutrients) {
  const wanted = [
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
  final filtered = nutrients.where((n) => wanted.contains(n['name'])).toList();
  filtered.sort(
    (a, b) => wanted.indexOf(a['name']).compareTo(wanted.indexOf(b['name'])),
  );
  return filtered
      .map<Widget>((n) => Text('${n['name']}: ${n['amount']} ${n['unit']}'))
      .toList();
}
