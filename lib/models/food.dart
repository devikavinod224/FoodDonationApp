class Food {
  final String id;
  final String name;
  final String category;
  final int quantity;
  final String image;
  final String description;
  final String ingredients;
  final String shopName;
  final String shopId;

  Food({
    required this.id,
    required this.name,
    required this.category,
    required this.quantity,
    required this.image,
    required this.description,
    required this.ingredients,
    required this.shopName,
    required this.shopId,
  });

  Food copyWith({
    String? name,
    String? category,
    int? quantity,
    String? image,
    String? description,
    String? ingredients,
    String? shopName,
    String? shopId,
  }) {
    return Food(
      id: this.id,
      name: name ?? this.name,
      category: category ?? this.category,
      quantity: quantity ?? this.quantity,
      image: image ?? this.image,
      description: description ?? this.description,
      ingredients: ingredients ?? this.ingredients,
      shopName: shopName ?? this.shopName,
      shopId: shopId ?? this.shopId,
    );
  }

  factory Food.fromJson(Map<String, dynamic> json) {
    return Food(
      id: json['_id'] ?? json['id'],
      name: json['name'],
      category: json['category'],
      quantity: json['quantity'],
      image: json['imageUrl'] ?? json['image'],
      description: json['description'] ?? '',
      ingredients: json['ingredients'] ?? '',
      shopName: json['shopName'] ?? '',
      shopId: json['shopId'] ?? '',
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'name': name,
      'category': category,
      'quantity': quantity,
      'imageUrl': image,
      'description': description,
      'ingredients': ingredients,
    };
  }
}
