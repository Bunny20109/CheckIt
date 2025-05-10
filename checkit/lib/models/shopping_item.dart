class ShoppingItem {
  String name;
  String category;
  bool isChecked;

  ShoppingItem({
    required this.name,
    required this.category,
    this.isChecked = false,
  });

  Map<String, dynamic> toJson() => {
    'name': name,
    'category': category,
    'isChecked': isChecked,
  };

  static ShoppingItem fromJson(Map<String, dynamic> json) => ShoppingItem(
    name: json['name'],
    category: json['category'],
    isChecked: json['isChecked'],
  );
}
