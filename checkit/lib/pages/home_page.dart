import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';
import '../models/shopping_item.dart';

class HomePage extends StatefulWidget {
  const HomePage({super.key});
  @override
  State<HomePage> createState() => _HomePageState();
}

class _HomePageState extends State<HomePage> {
  List<ShoppingItem> items = [];

  @override
  void initState() {
    super.initState();
    loadItems();
  }

  Future<void> loadItems() async {
    SharedPreferences prefs = await SharedPreferences.getInstance();
    String? data = prefs.getString('shopping_items');
    if (data != null) {
      List jsonData = json.decode(data);
      items = jsonData.map((e) => ShoppingItem.fromJson(e)).toList();
      setState(() {});
    }
  }

  Future<void> saveItems() async {
    SharedPreferences prefs = await SharedPreferences.getInstance();
    String data = json.encode(items.map((e) => e.toJson()).toList());
    await prefs.setString('shopping_items', data);
  }

  void addItem(String name, String category, int quantity) {
    setState(() {
      items.add(ShoppingItem(name: name, category: category, quantity: quantity));
    });
    saveItems();
  }

  void toggleCheck(int index) {
    setState(() {
      items[index].isChecked = !items[index].isChecked;
    });
    saveItems();
  }

  void reorderItems(int oldIndex, int newIndex) {
    setState(() {
      if (newIndex > oldIndex) newIndex--;
      final item = items.removeAt(oldIndex);
      items.insert(newIndex, item);
    });
    saveItems();
  }

  void showAddDialog() {
    final nameController = TextEditingController();
    final categoryController = TextEditingController();
    final quantityController = TextEditingController(text: '1');

    showDialog(
      context: context,
      builder: (_) => AlertDialog(
        title: const Text('Add Item'),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            TextField(controller: nameController, decoration: const InputDecoration(labelText: 'Item')),
            TextField(controller: categoryController, decoration: const InputDecoration(labelText: 'Category')),
            TextField(controller: quantityController, decoration: const InputDecoration(labelText: 'Quantity'), keyboardType: TextInputType.number),
          ],
        ),
        actions: [
          TextButton(
            child: const Text('Cancel'),
            onPressed: () => Navigator.pop(context),
          ),
          ElevatedButton(
            child: const Text('Add'),
            onPressed: () {
              addItem(
                nameController.text,
                categoryController.text,
                int.tryParse(quantityController.text) ?? 1,
              );
              Navigator.pop(context);
            },
          ),
        ],
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    Map<String, List<ShoppingItem>> groupedItems = {};
    for (var item in items) {
      groupedItems[item.category] = groupedItems[item.category] ?? [];
      groupedItems[item.category]!.add(item);
    }

    return Scaffold(
      appBar: AppBar(title: const Text('Shopping List')),
      floatingActionButton: FloatingActionButton(
        onPressed: showAddDialog,
        child: const Icon(Icons.add),
      ),
      body: ReorderableListView(
        onReorder: reorderItems,
        children: groupedItems.entries
            .expand((entry) {
              final category = entry.key;
              final list = entry.value;
              return [
                ListTile(
                  key: ValueKey('header_$category'),
                  title: Text(category, style: const TextStyle(fontWeight: FontWeight.bold)),
                  tileColor: Colors.grey.shade300,
                ),
                ...list.map((item) {
                  final index = items.indexOf(item);
                  return CheckboxListTile(
                    key: ValueKey(item.name + item.category),
                    title: Text('${item.name} (x${item.quantity})'),
                    value: item.isChecked,
                    onChanged: (_) => toggleCheck(index),
                  );
                }).toList()
              ];
            })
            .toList(),
      ),
    );
  }
}
