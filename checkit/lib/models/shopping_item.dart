class ShoppingItem {
  String name;
  String category;
  int quantity;
  bool isChecked;

  ShoppingItem({
    required this.name,
    required this.category,
    this.quantity = 1,
    this.isChecked = false,
  });

  factory ShoppingItem.fromJson(Map<String, dynamic> json) => ShoppingItem(
        name: json['name'],
        category: json['category'],
        quantity: json['quantity'],
        isChecked: json['isChecked'],
      );

  Map<String, dynamic> toJson() => {
        'name': name,
        'category': category,
        'quantity': quantity,
        'isChecked': isChecked,
      };
}
