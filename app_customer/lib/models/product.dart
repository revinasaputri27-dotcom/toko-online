class Product {
  const Product({
    required this.id,
    required this.name,
    required this.description,
    required this.price,
    required this.category,
    required this.image,
    required this.stock,
  });

  final String id;
  final String name;
  final String description;
  final double price;
  final String category;
  final String image;
  final int stock;

  factory Product.fromJson(Map<String, dynamic> json) {
    return Product(
      id: json['id']?.toString() ?? '',
      name: json['name']?.toString() ?? '',
      description: json['description']?.toString() ?? '',
      price: (json['price'] as num?)?.toDouble() ?? 0,
      category: json['category']?.toString() ?? '',
      image: json['image']?.toString() ?? '',
      stock: (json['stock'] as num?)?.toInt() ?? 0,
    );
  }
}
