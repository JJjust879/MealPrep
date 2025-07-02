import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import 'dart:convert';

class MealSelectionPage extends StatefulWidget {
  const MealSelectionPage({super.key});

  @override
  State<MealSelectionPage> createState() => _MealSelectionPageState();
}

class _MealSelectionPageState extends State<MealSelectionPage> {
  final TextEditingController _searchController = TextEditingController();
  List<Map<String, dynamic>> _meals = [];
  Map<String, dynamic>? _selectedMeal;
  bool _loading = false;

  Future<void> _searchMeals(String query) async {
    setState(() {
      _loading = true;
      _meals = [];
    });

    try {
      final apiKey = '3e348a8e7fe04eafbb6fa2ccf05e5bae';
      final url = Uri.parse(
        'https://api.spoonacular.com/recipes/complexSearch?apiKey=$apiKey&query=${Uri.encodeComponent(query)}',
      );
      final response = await http.get(url);

      if (response.statusCode == 200) {
        final data = jsonDecode(response.body);
        final results = data['results'] as List<dynamic>?;
        setState(() {
          _meals =
              results != null
                  ? results.map((e) => Map<String, dynamic>.from(e)).toList()
                  : [];
        });
      } else {
        setState(() => _meals = []);
      }
    } catch (e) {
      setState(() => _meals = []);
    } finally {
      setState(() => _loading = false);
    }
  }

  void _confirmSelection() {
    if (_selectedMeal != null) {
      Navigator.pop<Map<String, String>>(context, {
        'id': _selectedMeal!['id'].toString(),
        'name': _selectedMeal!['title'] ?? 'No title',
      });
    } else {
      ScaffoldMessenger.of(
        context,
      ).showSnackBar(const SnackBar(content: Text('Please select a meal')));
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Select Meal'),
        actions: [
          IconButton(
            icon: const Icon(Icons.check),
            onPressed: _confirmSelection,
          ),
        ],
      ),
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          children: [
            Row(
              children: [
                Expanded(
                  child: TextField(
                    controller: _searchController,
                    decoration: const InputDecoration(
                      labelText: 'Search meals',
                      border: OutlineInputBorder(),
                    ),
                    onSubmitted: _searchMeals,
                  ),
                ),
                const SizedBox(width: 8),
                ElevatedButton(
                  onPressed: () => _searchMeals(_searchController.text),
                  style: ElevatedButton.styleFrom(
                    foregroundColor: Colors.green[700],
                  ),
                  child: const Icon(Icons.search),
                ),
              ],
            ),
            const SizedBox(height: 16),
            Expanded(
              child:
                  _loading
                      ? const Center(
                        child: CircularProgressIndicator(color: Colors.green),
                      )
                      : _meals.isEmpty
                      ? const Center(child: Text('No meals found.'))
                      : ListView.builder(
                        itemCount: _meals.length,
                        itemBuilder: (context, index) {
                          final meal = _meals[index];
                          final isSelected = _selectedMeal?['id'] == meal['id'];
                          return ListTile(
                            leading:
                                meal['image'] != null
                                    ? Image.network(
                                      meal['image'],
                                      width: 60,
                                      height: 60,
                                      fit: BoxFit.cover,
                                    )
                                    : const Icon(Icons.fastfood),
                            title: Text(meal['title'] ?? 'No title'),
                            trailing:
                                isSelected
                                    ? const Icon(
                                      Icons.check_circle,
                                      color: Colors.greenAccent,
                                    )
                                    : const Icon(Icons.check_circle_outline),
                            onTap: () {
                              setState(() {
                                _selectedMeal = meal;
                              });
                            },
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
