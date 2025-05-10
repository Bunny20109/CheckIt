import 'package:flutter/material.dart';
import '../models/shopping_item.dart';
import '../utils/storage_helper.dart';

class ShoppingListPage extends StatefulWidget {
  @override
  State<ShoppingListPage> createState() => _ShoppingListPageState();
}

class _ShoppingListPageState extends State<ShoppingListPage> {
  List<ShoppingItem> _items = [];

  @override
  void initState() {
    super.initState();
    _load();
  }

  Future<void> _load() async {
    final items = await StorageHelper.loadItems();
    setState(() {
      _items = items;
    });
  }

  Future<void> _toggleCheck(int index) async {
    setState(() {
      _items[index].isChecked = !_items[index].isChecked;
    });
    await StorageHelper.saveItems(_items);
  }

  Future<void> _onReorder(int oldIndex, int newIndex) async {
    setState(() {
      if (newIndex > oldIndex) newIndex -= 1;
      final item = _items.removeAt(oldIndex);
      _items.insert(newIndex, item);
    });
    await StorageHelper.saveItems(_items);
  }

  Future<void> _deleteItem(int index) async {
    setState(() {
      _items.removeAt(index);
    });
    await StorageHelper.saveItems(_items);
  }

  @override
  Widget build(BuildContext context) {
    Map<String, List<ShoppingItem>> grouped = {};
    for (var item in _items) {
      grouped.putIfAbsent(item.category, () => []).add(item);
    }

    return _items.isEmpty
        ? Center(child: Text("Belum ada item. Tambahkan sekarang!"))
        : ReorderableListView(
          onReorder: _onReorder,
          padding: const EdgeInsets.all(16),
          children: [
            for (var cat in grouped.keys)
              Column(
                key: ValueKey(cat),
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Padding(
                    padding: const EdgeInsets.symmetric(vertical: 8.0),
                    child: Text(
                      cat,
                      style: TextStyle(
                        fontWeight: FontWeight.bold,
                        fontSize: 16,
                      ),
                    ),
                  ),
                  ...grouped[cat]!.map((item) {
                    final index = _items.indexOf(item);
                    return ListTile(
                      key: ValueKey(item.name),
                      leading: Checkbox(
                        value: item.isChecked,
                        onChanged: (_) => _toggleCheck(index),
                      ),
                      title: Text(
                        item.name,
                        style: TextStyle(
                          decoration:
                              item.isChecked
                                  ? TextDecoration.lineThrough
                                  : null,
                        ),
                      ),
                      trailing: IconButton(
                        icon: Icon(Icons.delete, color: Colors.redAccent),
                        onPressed: () => _deleteItem(index),
                      ),
                    );
                  }).toList(),
                ],
              ),
          ],
        );
  }
}
