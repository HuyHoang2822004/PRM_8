import 'dart:async';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';

import '../models/cart_item.dart';
import '../models/product.dart';

class CartProvider extends ChangeNotifier {
  CartProvider() {
    // Listen to authentication state changes to link the cart to the correct Firestore user doc
    _authSubscription = FirebaseAuth.instance.authStateChanges().listen((user) {
      _setupCartListener(user?.uid);
    });
  }

  final List<CartItem> _items = [];
  StreamSubscription<DocumentSnapshot>? _cartSubscription;
  StreamSubscription<User?>? _authSubscription;
  String? _currentUid;
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;

  List<CartItem> get items => List.unmodifiable(_items);

  @override
  void dispose() {
    _cartSubscription?.cancel();
    _authSubscription?.cancel();
    super.dispose();
  }

  void _setupCartListener(String? uid) {
    _cartSubscription?.cancel();
    _currentUid = uid;

    if (uid == null) {
      _items.clear();
      notifyListeners();
      return;
    }

    _cartSubscription = _firestore
        .collection('carts')
        .doc(uid)
        .snapshots()
        .listen((snapshot) {
      if (snapshot.exists && snapshot.data() != null) {
        final data = snapshot.data()!;
        final list = data['items'] as List<dynamic>?;
        _items.clear();
        if (list != null) {
          for (final item in list) {
            try {
              _items.add(CartItem.fromJson(item as Map<String, dynamic>));
            } catch (e) {
              debugPrint('Error parsing cart item: $e');
            }
          }
        }
      } else {
        _items.clear();
      }
      notifyListeners();
    });
  }

  Future<void> _updateFirestoreCart() async {
    final uid = _currentUid;
    if (uid == null) return;

    try {
      await _firestore.collection('carts').doc(uid).set({
        'items': _items.map((item) => item.toJson()).toList(),
        'updatedAt': FieldValue.serverTimestamp(),
      });
    } catch (e) {
      debugPrint('Error saving cart to Firestore: $e');
    }
  }

  Future<void> addToCart(
    Product product, {
    required String strap,
    required String color,
    int quantity = 1,
  }) async {
    if (quantity <= 0) return;
    final index = _items.indexWhere(
      (item) =>
          item.product.id == product.id && item.strap == strap && item.color == color,
    );
    if (index >= 0) {
      _items[index].quantity += quantity;
    } else {
      _items.add(
        CartItem(
          product: product,
          strap: strap,
          color: color,
          quantity: quantity,
        ),
      );
    }
    notifyListeners();
    await _updateFirestoreCart();
  }

  Future<void> removeItem(CartItem item) async {
    _items.remove(item);
    notifyListeners();
    await _updateFirestoreCart();
  }

  Future<void> increaseQty(CartItem item) async {
    item.quantity++;
    notifyListeners();
    await _updateFirestoreCart();
  }

  Future<void> decreaseQty(CartItem item) async {
    if (item.quantity > 1) {
      item.quantity--;
    } else {
      _items.remove(item);
    }
    notifyListeners();
    await _updateFirestoreCart();
  }

  Future<void> clearCart() async {
    _items.clear();
    notifyListeners();
    await _updateFirestoreCart();
  }

  double get totalAmount =>
      _items.fold(0, (total, item) => total + item.total);

  int get totalQuantity =>
      _items.fold(0, (total, item) => total + item.quantity);
}
