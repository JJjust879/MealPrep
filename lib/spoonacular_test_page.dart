import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import 'dart:convert';

class SpoonacularTestPage extends StatefulWidget {
  const SpoonacularTestPage({super.key});

  @override
  State<SpoonacularTestPage> createState() => _SpoonacularTestPageState();
}

class _SpoonacularTestPageState extends State<SpoonacularTestPage> {
  final TextEditingController _inputController = TextEditingController();
  List<Map<String, dynamic>> _recipes = [];
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
      appBar: AppBar(title: const Text('Spoonacular API Test')),
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            TextField(
              controller: _inputController,
              decoration: const InputDecoration(
                labelText: 'Recipe Title',
                border: OutlineInputBorder(),
              ),
            ),
            const SizedBox(height: 16),
            ElevatedButton(
              onPressed:
                  _loading ? null : () => analyzeRecipe(_inputController.text),
              child:
                  _loading
                      ? const SizedBox(
                        width: 20,
                        height: 20,
                        child: CircularProgressIndicator(strokeWidth: 2),
                      )
                      : const Text('Analyze Recipe'),
            ),
            const SizedBox(height: 24),
            if (_error != null)
              Text('Error: $_error', style: const TextStyle(color: Colors.red)),
            if (_recipes.isNotEmpty)
              Expanded(
                child: ListView.builder(
                  itemCount: _recipes.length,
                  itemBuilder: (context, index) {
                    final recipe = _recipes[index];
                    return Card(
                      margin: const EdgeInsets.symmetric(vertical: 8),
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
                              builder: (_) => RecipeDetailPage(recipe: recipe),
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
            return const Center(child: CircularProgressIndicator());
          }
          if (snapshot.hasError) {
            return Center(child: Text('Error: \\${snapshot.error}'));
          }
          final details = snapshot.data;
          if (details == null) {
            return const Center(child: Text('No details found.'));
          }
          return SingleChildScrollView(
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
                Text('ID: ${details['id'] ?? 'N/A'}'),
                if (details['readyInMinutes'] != null)
                  Text('Ready in: ${details['readyInMinutes']} min'),
                if (details['servings'] != null)
                  Text('Servings: ${details['servings']}'),
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
          );
        },
      ),
    );
  }
}

// Helper to parse HTML instructions into a numbered list
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

// Helper to show only the most relevant nutrients
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
