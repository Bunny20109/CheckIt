import 'package:flutter/material.dart';
import 'package:checkit/models/category.dart';
import 'package:checkit/models/shopping_item.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'dart:convert';

class CategoryDetailPage extends StatefulWidget {
  final Category category;
  final Function(Category) onUpdate;

  const CategoryDetailPage({
    Key? key,
    required this.category,
    required this.onUpdate,
  }) : super(key: key);

  @override
  State<CategoryDetailPage> createState() => _CategoryDetailPageState();
}

class _CategoryDetailPageState extends State<CategoryDetailPage> {
  late Category category;

  @override
  void initState() {
    super.initState();
    category = widget.category;
  }

  void toggleItemChecked(int index) {
    setState(() {
      category.items[index].isChecked = !category.items[index].isChecked;
    });
    widget.onUpdate(category);
    saveToLocalStorage();
  }

  void saveToLocalStorage() async {
    SharedPreferences prefs = await SharedPreferences.getInstance();
    List<Category> allCategories = [];

    final String? data = prefs.getString('shopping_categories');
    if (data != null) {
      final jsonList = json.decode(data) as List;
      allCategories = jsonList.map((e) => Category.fromMap(e)).toList();
    }

    int index = allCategories.indexWhere((c) => c.name == category.name);
    if (index != -1) {
      allCategories[index] = category;
    } else {
      allCategories.add(category);
    }

    await prefs.setString(
      'shopping_categories',
      json.encode(allCategories.map((e) => e.toMap()).toList()),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: Text(category.name), backgroundColor: Colors.blue),
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          children: [
            Text(
              'Item List',
              style: const TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
            ),
            const SizedBox(height: 12),
            Expanded(
              child: ListView.builder(
                itemCount: category.items.length,
                itemBuilder: (context, index) {
                  final item = category.items[index];
                  return CheckboxListTile(
                    value: item.isChecked,
                    onChanged: (_) => toggleItemChecked(index),
                    title: Text(
                      item.name,
                      style: TextStyle(
                        decoration:
                            item.isChecked
                                ? TextDecoration.lineThrough
                                : TextDecoration.none,
                        color: item.isChecked ? Colors.grey : null,
                      ),
                    ),
                    subtitle: Text(
                      '${item.quantity} × Rp${item.price.toStringAsFixed(0)}',
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
