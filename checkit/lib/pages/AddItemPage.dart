import 'package:flutter/material.dart';
import '../models/shopping_item.dart';
import '../utils/storage_helper.dart';

class AddItemPage extends StatefulWidget {
  @override
  State<AddItemPage> createState() => _AddItemPageState();
}

class _AddItemPageState extends State<AddItemPage> {
  final _nameController = TextEditingController();
  String _selectedCategory = 'Umum';
  final List<String> _categories = [
    'Umum',
    'Makanan',
    'Minuman',
    'Kebutuhan Rumah',
  ];

  void _addItem() async {
    if (_nameController.text.isEmpty) return;

    final newItem = ShoppingItem(
      name: _nameController.text,
      category: _selectedCategory,
    );

    final items = await StorageHelper.loadItems();
    items.add(newItem);
    await StorageHelper.saveItems(items);

    ScaffoldMessenger.of(
      context,
    ).showSnackBar(SnackBar(content: Text("Item ditambahkan")));
    _nameController.clear();
  }

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.all(16.0),
      child: Column(
        children: [
          TextField(
            controller: _nameController,
            decoration: InputDecoration(labelText: 'Nama Item'),
          ),
          DropdownButtonFormField<String>(
            value: _selectedCategory,
            items:
                _categories
                    .map(
                      (cat) => DropdownMenuItem(child: Text(cat), value: cat),
                    )
                    .toList(),
            onChanged: (value) {
              if (value != null) setState(() => _selectedCategory = value);
            },
            decoration: InputDecoration(labelText: 'Kategori'),
          ),
          SizedBox(height: 20),
          ElevatedButton(onPressed: _addItem, child: Text("Tambah")),
        ],
      ),
    );
  }
}
