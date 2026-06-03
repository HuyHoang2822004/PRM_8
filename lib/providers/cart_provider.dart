import 'package:flutter/material.dart';

import '../models/cart_item.dart';
import '../models/product.dart';

class CartProvider extends ChangeNotifier {
  final List<CartItem> _items = [];

  List<CartItem> get items => List.unmodifiable(_items);

  void addToCart(Product product, {required int size, required String color}) {
    final index = _items.indexWhere(
      (item) =>
          item.product.id == product.id && item.size == size && item.color == color,
    );
    if (index >= 0) {
      _items[index].quantity++;
    } else {
      _items.add(CartItem(product: product, size: size, color: color));
    }
    notifyListeners();
  }

  void removeItem(CartItem item) {
    _items.remove(item);
    notifyListeners();
  }

  void increaseQty(CartItem item) {
    item.quantity++;
    notifyListeners();
  }

  void decreaseQty(CartItem item) {
    if (item.quantity > 1) {
      item.quantity--;
    } else {
      _items.remove(item);
    }
    notifyListeners();
  }

  void clearCart() {
    _items.clear();
    notifyListeners();
  }

  double get totalAmount =>
      _items.fold(0, (total, item) => total + item.total);
}
