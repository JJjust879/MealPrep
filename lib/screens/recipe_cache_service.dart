import 'package:hive/hive.dart';

class RecipeCacheService {
  static const String boxName = 'random_recipes_box';
  static const String key = 'random_recipes';

  // Save recipes to Hive
  static Future<void> saveRandomRecipes(
    List<Map<String, dynamic>> recipes,
  ) async {
    final box = await Hive.openBox(boxName);
    await box.put(key, recipes);
  }

  // Load recipes from Hive
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

  // Clear cache
  static Future<void> clearCache() async {
    final box = await Hive.openBox(boxName);
    await box.delete(key);
  }
}
