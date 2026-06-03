import 'package:flutter/material.dart';

import '../models/order.dart';
import '../services/order_service.dart';

class OrderProvider extends ChangeNotifier {
  OrderProvider(this._orderService);

  final OrderService _orderService;
  bool isSubmitting = false;
  String? errorMessage;

  Future<Order?> createOrder(Order order) async {
    isSubmitting = true;
    errorMessage = null;
    notifyListeners();
    try {
      final created = await _orderService.createOrder(order);
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
