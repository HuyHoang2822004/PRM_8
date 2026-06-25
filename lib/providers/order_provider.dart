import 'package:flutter/material.dart';

import '../models/order.dart';
import '../models/product.dart';
import '../services/order_service.dart';

class OrderProvider extends ChangeNotifier {
  OrderProvider(this._orderService);

  final OrderService _orderService;
  final List<Order> orders = [];
  final List<Order> allOrders = [];
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

  Future<void> fetchAllOrders(List<Product> allProducts) async {
    try {
      final history = await _orderService.loadAllOrders(allProducts);
      allOrders.clear();
      allOrders.addAll(history);
      notifyListeners();
    } catch (_) {
      errorMessage = 'Không thể tải danh sách tất cả đơn hàng';
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

  Future<bool> updateOrderStatus(String orderId, String status, List<Product> allProducts) async {
    try {
      await _orderService.updateOrderStatus(orderId, status);
      // Reload order collections
      await fetchAllOrders(allProducts);
      await fetchOrders(allProducts);
      return true;
    } catch (_) {
      errorMessage = 'Không thể cập nhật trạng thái đơn hàng';
      return false;
    }
  }
}
