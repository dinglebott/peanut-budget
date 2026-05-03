import 'package:shared_preferences/shared_preferences.dart';

class CategoryStore {
  static const _key = 'categories';
  static const _defaults = ['Meals', 'Transport', 'Leisure'];

  Future<List<String>> load() async {
    final prefs = await SharedPreferences.getInstance();
    return prefs.getStringList(_key) ?? List.of(_defaults);
  }

  Future<void> save(List<String> categories) async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.setStringList(_key, categories);
  }
}
