import 'dart:convert';
import 'package:checkit/pages/history_page.dart' show HistoryPage;
import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';
import '../models/shopping_item.dart';
import '../models/category.dart';
import './settings_page.dart';
import '../models/purchase_history_item.dart';

class HomePage extends StatefulWidget {
  const HomePage({super.key});

  @override
  State<HomePage> createState() => _HomePageState();
}

class _HomePageState extends State<HomePage> {
  List<Category> categories = [];
  int _selectedIndex = 0;

  @override
  void initState() {
    super.initState();
    loadItems();
  }

  Future<void> loadItems() async {
    SharedPreferences prefs = await SharedPreferences.getInstance();
    String? data = prefs.getString('shopping_categories');
    if (data != null) {
      List jsonData = json.decode(data);
      categories = jsonData.map((e) => Category.fromMap(e)).toList();
      setState(() {});
    }
  }

  Future<void> saveItems() async {
    SharedPreferences prefs = await SharedPreferences.getInstance();
    String data = json.encode(categories.map((e) => e.toMap()).toList());
    await prefs.setString('shopping_categories', data);
  }

  Future<void> saveToHistory() async {
    SharedPreferences prefs = await SharedPreferences.getInstance();
    String? historyData = prefs.getString('purchase_history');
    List<PurchaseHistoryItem> history = [];

    if (historyData != null) {
      List jsonHistory = json.decode(historyData);
      history = jsonHistory.map((e) => PurchaseHistoryItem.fromMap(e)).toList();
    }

    // Buat salinan kategori, tapi hanya dengan item yang dicentang
    List<Category> checkedCategories = [];
    for (var category in categories) {
      List<ShoppingItem> checkedItems =
          category.items
              .where((item) => item.isChecked)
              .map((item) => item.copy())
              .toList();

      if (checkedItems.isNotEmpty) {
        checkedCategories.add(
          Category(name: category.name, items: checkedItems),
        );
      }
    }

    if (checkedCategories.isEmpty) return; // tidak simpan kalau kosong

    final newHistory = PurchaseHistoryItem(
      date: DateTime.now(),
      categories: checkedCategories,
    );

    history.add(newHistory);

    await prefs.setString(
      'purchase_history',
      json.encode(history.map((e) => e.toMap()).toList()),
    );
  }

  void addItem(String name, String categoryName, int quantity, double price) {
    setState(() {
      final existingCategory = categories.firstWhere(
        (c) => c.name.toLowerCase() == categoryName.toLowerCase(),
        orElse: () {
          final newCat = Category(name: categoryName, items: []);
          categories.add(newCat);
          return newCat;
        },
      );

      existingCategory.items.add(
        ShoppingItem(
          name: name,
          category: categoryName,
          quantity: quantity,
          price: price,
        ),
      );
    });
    saveItems();
  }

  void toggleCheck(Category category, int itemIndex) {
    setState(() {
      category.items[itemIndex].isChecked =
          !category.items[itemIndex].isChecked;
    });
    saveItems();
  }

  void removeItem(Category category, int itemIndex) {
    setState(() {
      category.items.removeAt(itemIndex);
      if (category.items.isEmpty) {
        categories.remove(category);
      }
    });
    saveItems();
  }

  double getTotalPrice(Category category) {
    double total = 0;
    for (var item in category.items) {
      if (item.isChecked) {
        total += item.price * item.quantity;
      }
    }
    return total;
  }

  void showAddDialog() {
    final nameController = TextEditingController();
    final categoryController = TextEditingController();
    final quantityController = TextEditingController(text: '1');
    final priceController = TextEditingController(text: '0');

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
                TextField(
                  controller: priceController,
                  decoration: const InputDecoration(
                    labelText: 'Harga per item',
                  ),
                  keyboardType: TextInputType.numberWithOptions(decimal: true),
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
                    double.tryParse(priceController.text) ?? 0,
                  );
                  Navigator.pop(context);
                },
              ),
            ],
          ),
    );
  }

  Widget buildShoppingList() {
    return ListView.builder(
      itemCount: categories.length,
      itemBuilder: (context, categoryIndex) {
        final category = categories[categoryIndex];
        return ExpansionTile(
          title: Text(
            '${category.name} - Total: Rp ${getTotalPrice(category).toStringAsFixed(0)}',
            style: const TextStyle(fontWeight: FontWeight.bold),
          ),
          backgroundColor: Colors.deepPurple.shade50,
          children: [
            ReorderableListView(
              shrinkWrap: true,
              physics: const NeverScrollableScrollPhysics(),
              buildDefaultDragHandles: false,
              onReorder: (oldIndex, newIndex) {
                setState(() {
                  if (newIndex > oldIndex) newIndex -= 1;
                  final item = category.items.removeAt(oldIndex);
                  category.items.insert(newIndex, item);
                });
                saveItems();
              },
              children: List.generate(category.items.length, (itemIndex) {
                final item = category.items[itemIndex];
                return ListTile(
                  key: ValueKey('${category.name}_$itemIndex'),
                  leading: Checkbox(
                    value: item.isChecked,
                    onChanged: (_) => toggleCheck(category, itemIndex),
                  ),
                  title: Text(
                    '${item.name} (x${item.quantity}) - Rp ${item.price.toStringAsFixed(0)}',
                  ),
                  trailing: Row(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      IconButton(
                        icon: const Icon(Icons.delete, color: Colors.red),
                        onPressed: () => removeItem(category, itemIndex),
                      ),
                      ReorderableDragStartListener(
                        index: itemIndex,
                        child: const Icon(Icons.drag_handle),
                      ),
                    ],
                  ),
                );
              }),
            ),
          ],
        );
      },
    );
  }

  Widget buildPageContent() {
    if (_selectedIndex == 0) {
      return buildShoppingList();
    } else if (_selectedIndex == 1) {
      return const HistoryPage();
    } else {
      return const SettingsPage();
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
              ? Column(
                mainAxisSize: MainAxisSize.min,
                children: [
                  FloatingActionButton(
                    heroTag: 'add',
                    onPressed: showAddDialog,
                    backgroundColor: Colors.deepPurple,
                    child: const Icon(Icons.add),
                  ),
                  const SizedBox(height: 10),
                  FloatingActionButton.extended(
                    heroTag: 'done',
                    onPressed: () async {
                      await saveToHistory();
                      setState(() {
                        categories.clear();
                      });
                      await saveItems();
                      ScaffoldMessenger.of(context).showSnackBar(
                        const SnackBar(
                          content: Text(
                            'Belanjaan berhasil disimpan ke riwayat!',
                          ),
                        ),
                      );
                    },
                    backgroundColor: Colors.green,
                    label: const Text("Selesai Belanja"),
                    icon: const Icon(Icons.check),
                  ),
                ],
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
