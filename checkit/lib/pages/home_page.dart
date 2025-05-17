import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';
import '../models/shopping_item.dart';
import '../models/category.dart';
import '../models/purchase_history_item.dart';
import './settings_page.dart';
import './history_page.dart';
import './category_detail_page.dart';

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

    if (checkedCategories.isEmpty) return;

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
                  keyboardType: const TextInputType.numberWithOptions(
                    decimal: true,
                  ),
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

  double getTotalPrice(Category category) {
    double total = 0;
    for (var item in category.items) {
      if (item.isChecked) {
        total += item.price * item.quantity;
      }
    }
    return total;
  }

  Widget buildShoppingList() {
    if (categories.isEmpty) {
      return const Center(
        child: Text('Belum ada kategori. Tambahkan barang terlebih dahulu.'),
      );
    }

    return ListView.builder(
      padding: const EdgeInsets.all(8),
      itemCount: categories.length,
      itemBuilder: (context, index) {
        final category = categories[index];
        final checked = category.items.where((i) => i.isChecked).length;
        final total = category.items.length;

        return GestureDetector(
          onTap: () {
            Navigator.of(context).push(
              PageRouteBuilder(
                pageBuilder:
                    (_, __, ___) => CategoryDetailPage(
                      category: category,
                      onUpdate: (updatedCategory) {
                        setState(() {
                          categories[index] = updatedCategory;
                        });
                        saveItems();
                      },
                    ),
                transitionsBuilder: (context, animation, _, child) {
                  final tween = Tween(
                    begin: const Offset(1, 0),
                    end: Offset.zero,
                  ).chain(CurveTween(curve: Curves.ease));
                  return SlideTransition(
                    position: animation.drive(tween),
                    child: child,
                  );
                },
              ),
            );
          },
          child: Card(
            margin: const EdgeInsets.symmetric(vertical: 6, horizontal: 12),
            color: Colors.deepPurple.shade50,
            child: ListTile(
              title: Text(
                category.name,
                style: const TextStyle(fontWeight: FontWeight.bold),
              ),
              subtitle: Text('$checked dari $total item selesai'),
              trailing: const Icon(Icons.chevron_right),
            ),
          ),
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
