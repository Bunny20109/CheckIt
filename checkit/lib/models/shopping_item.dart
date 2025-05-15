import 'package:checkit/models/category.dart';

class ShoppingItem {
  String name;
  String category;
  int quantity;
  double price;
  bool isChecked;

  ShoppingItem({
    required this.name,
    required this.category,
    required this.quantity,
    required this.price,
    this.isChecked = false,
  });

  Map<String, dynamic> toMap() {
    return {
      'name': name,
      'category': category,
      'quantity': quantity,
      'price': price,
      'isChecked': isChecked,
    };
  }

  factory ShoppingItem.fromMap(Map<String, dynamic> map) {
    return ShoppingItem(
      name: map['name'],
      category: map['category'],
      quantity: map['quantity'],
      price: map['price'].toDouble(),
      isChecked: map['isChecked'] ?? false,
    );
  }

  ShoppingItem copy() {
    return ShoppingItem(
      name: name,
      category: category,
      quantity: quantity,
      price: price,
      isChecked: isChecked,
    );
  }
}
