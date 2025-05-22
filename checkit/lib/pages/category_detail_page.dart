import 'package:flutter/material.dart';
import 'package:checkit/models/category.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'dart:convert';

class CategoryDetailPage extends StatefulWidget {
  final Category category;
  final Function(Category) onUpdate;

  const CategoryDetailPage({
    super.key,
    required this.category,
    required this.onUpdate,
  });

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

  void reorderItems(int oldIndex, int newIndex) {
    setState(() {
      if (newIndex > oldIndex) newIndex -= 1;
      final item = category.items.removeAt(oldIndex);
      category.items.insert(newIndex, item);
    });
    widget.onUpdate(category);
    saveToLocalStorage();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar:
          AppBar(title: Text(category.name), backgroundColor: Colors.blue),
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          children: [
            const Text(
              'Item List',
              style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
            ),
            const SizedBox(height: 12),
            Expanded(
              child: ReorderableListView(
                onReorder: reorderItems,
                buildDefaultDragHandles: false,
                children: [
                  for (int index = 0; index < category.items.length; index++)
                    Container(
                      key: ValueKey('item_$index'),
                      margin: const EdgeInsets.symmetric(vertical: 4),
                      padding: const EdgeInsets.symmetric(horizontal: 8),
                      decoration: BoxDecoration(
                        borderRadius: BorderRadius.circular(8),
                        border: Border.all(color: Colors.grey.shade300),
                      ),
                      child: Row(
                        crossAxisAlignment: CrossAxisAlignment.center,
                        children: [
                          // Expanded content on the left
                          Expanded(
                            child: Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                Text(
                                  category.items[index].name,
                                  style: TextStyle(
                                    fontSize: 16,
                                    decoration: category.items[index].isChecked
                                        ? TextDecoration.lineThrough
                                        : TextDecoration.none,
                                    color: category.items[index].isChecked
                                        ? Colors.grey
                                        : null,
                                  ),
                                ),
                                Text(
                                  '${category.items[index].quantity} × Rp${category.items[index].price.toStringAsFixed(0)}',
                                  style: const TextStyle(fontSize: 13),
                                ),
                              ],
                            ),
                          ),
                          const SizedBox(width: 12),
                          Checkbox(
                            value: category.items[index].isChecked,
                            onChanged: (_) => toggleItemChecked(index),
                          ),
                          const SizedBox(width: 8),
                          ReorderableDragStartListener(
                            index: index,
                            child: const Icon(Icons.drag_handle),
                          ),
                        ],
                      ),
                    ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }
}
