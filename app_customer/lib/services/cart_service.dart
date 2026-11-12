import 'package:flutter/foundation.dart';

import '../models/cart_item.dart';
import '../models/product.dart';

class CartService extends ChangeNotifier {
  CartService._();

  static final CartService instance = CartService._();
  final Map<String, CartItem> _items = {};

  List<CartItem> get items => List.unmodifiable(_items.values);
  int get itemCount => _items.values.fold(0, (count, item) => count + item.quantity);
  double get total => _items.values.fold(0, (sum, item) => sum + item.subtotal);
  bool get isEmpty => _items.isEmpty;

  void add(Product product) {
    final existing = _items[product.id];
    if (existing == null) {
      _items[product.id] = CartItem(product: product, quantity: 1);
    } else if (existing.quantity < product.stock) {
      _items[product.id] = CartItem(product: product, quantity: existing.quantity + 1);
    }
    notifyListeners();
  }

  void decrease(String productId) {
    final existing = _items[productId];
    if (existing == null) return;
    if (existing.quantity <= 1) {
      _items.remove(productId);
    } else {
      _items[productId] = CartItem(product: existing.product, quantity: existing.quantity - 1);
    }
    notifyListeners();
  }

  void remove(String productId) {
    _items.remove(productId);
    notifyListeners();
  }

  void clear() {
    _items.clear();
    notifyListeners();
  }
}
