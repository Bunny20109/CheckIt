import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';
import '../models/purchase_history_item.dart';

class HistoryPage extends StatefulWidget {
  const HistoryPage({super.key});

  @override
  State<HistoryPage> createState() => _HistoryPageState();
}

class _HistoryPageState extends State<HistoryPage> {
  List<PurchaseHistoryItem> history = [];

  @override
  void initState() {
    super.initState();
    loadHistory();
  }

  Future<void> loadHistory() async {
    final prefs = await SharedPreferences.getInstance();
    final String? savedHistory = prefs.getString('purchase_history');

    if (savedHistory != null) {
      final List<dynamic> jsonData = json.decode(savedHistory);
      setState(() {
        history = jsonData.map((e) => PurchaseHistoryItem.fromMap(e)).toList();
      });
    }
  }

  String formatDate(DateTime date) {
    return "${date.day}/${date.month}/${date.year} ${date.hour}:${date.minute.toString().padLeft(2, '0')}";
  }

  @override
  Widget build(BuildContext context) {
    if (history.isEmpty) {
      return const Center(child: Text('Belum ada riwayat belanja'));
    }

    return ListView.builder(
      itemCount: history.length,
      itemBuilder: (context, index) {
        final item = history[index];

        double totalPrice = 0;
        for (var category in item.categories) {
          totalPrice += category.items.fold<double>(
            0,
            (sum, shoppingItem) =>
                sum + shoppingItem.price * shoppingItem.quantity,
          );
        }

        return Card(
          margin: const EdgeInsets.all(8),
          child: ExpansionTile(
            title: Text('Tanggal: ${formatDate(item.date)}'),
            subtitle: Text('Total: Rp ${totalPrice.toStringAsFixed(0)}'),
            children:
                item.categories.expand((category) {
                  return category.items.map((shoppingItem) {
                    return ListTile(
                      title: Text(
                        '${shoppingItem.name} (x${shoppingItem.quantity})',
                      ),
                      trailing: Text(
                        'Rp ${(shoppingItem.price * shoppingItem.quantity).toStringAsFixed(0)}',
                      ),
                    );
                  });
                }).toList(),
          ),
        );
      },
    );
  }
}
