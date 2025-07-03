import 'package:hive/hive.dart';

/// Service for caching recipe data using Hive.
class RecipeCacheService {
  static const String boxName = 'random_recipes_box';
  static const String key = 'random_recipes';

  /// Saves recipes to Hive cache.
  static Future<void> saveRandomRecipes(
    List<Map<String, dynamic>> recipes,
  ) async {
    final box = await Hive.openBox(boxName);
    await box.put(key, recipes);
  }

  /// Loads recipes from Hive cache.
  static Future<List<Map<String, dynamic>>> loadRandomRecipes() async {
    final box = await Hive.openBox(boxName);
    final data = box.get(key);
    if (data is List) {
      return List<Map<String, dynamic>>.from(
        data.map((e) => Map<String, dynamic>.from(e)),
      );
    }
    return [];
  }

  /// Clears the recipe cache.
  static Future<void> clearCache() async {
    final box = await Hive.openBox(boxName);
    await box.delete(key);
  }
}
