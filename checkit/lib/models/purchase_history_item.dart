import 'category.dart';

class PurchaseHistoryItem {
  DateTime date;
  List<Category> categories;

  PurchaseHistoryItem({required this.date, required this.categories});

  factory PurchaseHistoryItem.fromMap(Map<String, dynamic> map) {
    return PurchaseHistoryItem(
      date: DateTime.parse(map['date']),
      categories:
          (map['categories'] as List)
              .map((catMap) => Category.fromMap(catMap))
              .toList(),
    );
  }

  Map<String, dynamic> toMap() {
    return {
      'date': date.toIso8601String(),
      'categories': categories.map((cat) => cat.toMap()).toList(),
    };
  }
}
