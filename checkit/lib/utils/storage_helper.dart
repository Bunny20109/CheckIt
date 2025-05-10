import 'package:shared_preferences/shared_preferences.dart';
import 'dart:convert';
import '../models/shopping_item.dart';

class StorageHelper {
  static const _key = 'shopping_items';

  static Future<void> saveItems(List<ShoppingItem> items) async {
    final prefs = await SharedPreferences.getInstance();
    final jsonList = items.map((e) => e.toJson()).toList();
    await prefs.setString(_key, json.encode(jsonList));
  }

  static Future<List<ShoppingItem>> loadItems() async {
    final prefs = await SharedPreferences.getInstance();
    final jsonString = prefs.getString(_key);
    if (jsonString == null) return [];
    final List<dynamic> decoded = json.decode(jsonString);
    return decoded.map((e) => ShoppingItem.fromJson(e)).toList();
  }
}
