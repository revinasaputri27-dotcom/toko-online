class OrderItem {
  const OrderItem({
    required this.productId,
    required this.name,
    required this.price,
    required this.quantity,
    this.image = '',
  });

  final String productId;
  final String name;
  final double price;
  final int quantity;
  final String image;

  factory OrderItem.fromJson(Map<String, dynamic> json) {
    return OrderItem(
      productId: json['productId']?.toString() ?? '',
      name: json['name']?.toString() ?? '',
      price: (json['price'] as num?)?.toDouble() ?? 0,
      quantity: (json['quantity'] as num?)?.toInt() ?? 0,
      image: json['image']?.toString() ?? '',
    );
  }
}

class Order {
  const Order({
    required this.id,
    required this.total,
    required this.status,
    required this.createdAt,
    required this.items,
    required this.address,
    required this.phone,
    this.notes = '',
  });

  final String id;
  final double total;
  final String status;
  final DateTime? createdAt;
  final List<OrderItem> items;
  final String address;
  final String phone;
  final String notes;

  factory Order.fromJson(Map<String, dynamic> json) {
    final rawItems = json['items'] as List<dynamic>? ?? const [];
    return Order(
      id: json['id']?.toString() ?? '',
      total: (json['total'] as num?)?.toDouble() ?? 0,
      status: json['status']?.toString() ?? 'Diproses',
      createdAt: DateTime.tryParse(json['createdAt']?.toString() ?? ''),
      items: rawItems
          .whereType<Map<String, dynamic>>()
          .map(OrderItem.fromJson)
          .toList(growable: false),
      address: json['address']?.toString() ?? '',
      phone: json['phone']?.toString() ?? '',
      notes: json['notes']?.toString() ?? '',
    );
  }
}
