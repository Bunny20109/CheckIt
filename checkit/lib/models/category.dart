import 'shopping_item.dart';

class Category {
  String name;
  List<ShoppingItem> items;

  Category({required this.name, required this.items});

  factory Category.fromMap(Map<String, dynamic> map) {
    return Category(
      name: map['name'],
      items: List<ShoppingItem>.from(
        (map['items'] as List).map((x) => ShoppingItem.fromMap(x)),
      ),
    );
  }

  Map<String, dynamic> toMap() {
    return {'name': name, 'items': items.map((x) => x.toMap()).toList()};
  }
}
