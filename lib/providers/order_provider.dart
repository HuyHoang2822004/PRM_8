import 'package:flutter/material.dart';

import '../models/order.dart';
import '../models/product.dart';
import '../services/order_service.dart';

class OrderProvider extends ChangeNotifier {
  OrderProvider(this._orderService);

  final OrderService _orderService;
  final List<Order> orders = [];
  bool isSubmitting = false;
  String? errorMessage;

  Future<void> fetchOrders(List<Product> allProducts) async {
    try {
      final history = await _orderService.loadOrders(allProducts);
      orders.clear();
      orders.addAll(history);
      notifyListeners();
    } catch (_) {
      errorMessage = 'Không thể tải lịch sử đơn hàng';
    }
  }

  Future<Order?> createOrder(Order order) async {
    isSubmitting = true;
    errorMessage = null;
    notifyListeners();
    try {
      final created = await _orderService.createOrder(order);
      orders.insert(0, created);
      notifyListeners();
      return created;
    } catch (_) {
      errorMessage = 'Không thể tạo đơn hàng';
      return null;
    } finally {
      isSubmitting = false;
      notifyListeners();
    }
  }
}
