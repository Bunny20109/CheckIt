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
  int _selectedIndex = 0;

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
      items.add(
        ShoppingItem(name: name, category: category, quantity: quantity),
      );
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
      builder:
          (_) => AlertDialog(
            title: const Text('Tambah Barang'),
            content: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                TextField(
                  controller: nameController,
                  decoration: const InputDecoration(labelText: 'Nama Barang'),
                ),
                TextField(
                  controller: categoryController,
                  decoration: const InputDecoration(labelText: 'Kategori'),
                ),
                TextField(
                  controller: quantityController,
                  decoration: const InputDecoration(labelText: 'Jumlah'),
                  keyboardType: TextInputType.number,
                ),
              ],
            ),
            actions: [
              TextButton(
                child: const Text('Batal'),
                onPressed: () => Navigator.pop(context),
              ),
              ElevatedButton(
                child: const Text('Tambah'),
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

  Widget buildShoppingList() {
    Map<String, List<ShoppingItem>> groupedItems = {};
    for (var item in items) {
      groupedItems[item.category] = groupedItems[item.category] ?? [];
      groupedItems[item.category]!.add(item);
    }

    return ReorderableListView(
      onReorder: reorderItems,
      padding: const EdgeInsets.only(bottom: 80),
      children:
          groupedItems.entries.expand((entry) {
            final category = entry.key;
            final list = entry.value;
            return [
              ListTile(
                key: ValueKey('header_$category'),
                title: Text(
                  category,
                  style: const TextStyle(fontWeight: FontWeight.bold),
                ),
                tileColor: Colors.deepPurple.shade100,
              ),
              ...list.map((item) {
                final index = items.indexOf(item);
                return CheckboxListTile(
                  key: ValueKey(item.name + item.category),
                  title: Text('${item.name} (x${item.quantity})'),
                  value: item.isChecked,
                  onChanged: (_) => toggleCheck(index),
                  secondary: const Icon(Icons.check_box_outlined),
                );
              }).toList(),
            ];
          }).toList(),
    );
  }

  Widget buildPageContent() {
    if (_selectedIndex == 0) {
      return buildShoppingList();
    } else if (_selectedIndex == 1) {
      return const Center(child: Text("Riwayat Belanja (dalam pengembangan)"));
    } else {
      return const Center(
        child: Text("Pengaturan Aplikasi (dalam pengembangan)"),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('🛒 Daftar Belanja'),
        backgroundColor: Colors.deepPurple,
        centerTitle: true,
      ),
      body: buildPageContent(),
      floatingActionButton:
          _selectedIndex == 0
              ? FloatingActionButton(
                onPressed: showAddDialog,
                backgroundColor: Colors.deepPurple,
                child: const Icon(Icons.add),
              )
              : null,
      bottomNavigationBar: BottomNavigationBar(
        currentIndex: _selectedIndex,
        selectedItemColor: Colors.deepPurple,
        onTap: (index) => setState(() => _selectedIndex = index),
        items: const [
          BottomNavigationBarItem(icon: Icon(Icons.list_alt), label: 'Belanja'),
          BottomNavigationBarItem(icon: Icon(Icons.history), label: 'Riwayat'),
          BottomNavigationBarItem(
            icon: Icon(Icons.settings),
            label: 'Pengaturan',
          ),
        ],
      ),
    );
  }
}
