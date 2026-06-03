import 'package:flutter/material.dart';

import '../models/product.dart';
import '../services/product_service.dart';

class ProductProvider extends ChangeNotifier {
  ProductProvider(this._productService);

  final ProductService _productService;
  List<Product> _allProducts = [];
  List<Product> products = [];
  bool isLoading = false;
  String? errorMessage;
  String selectedBrand = 'All';

  Future<void> loadProducts() async {
    isLoading = true;
    errorMessage = null;
    notifyListeners();
    try {
      _allProducts = await _productService.loadProducts();
      products = List.of(_allProducts);
    } catch (_) {
      errorMessage = 'Không thể tải sản phẩm';
    } finally {
      isLoading = false;
      notifyListeners();
    }
  }

  void searchProducts(String query) {
    final q = query.toLowerCase().trim();
    products = _allProducts.where((p) {
      final brandMatch = selectedBrand == 'All' || p.brand == selectedBrand;
      final searchMatch = q.isEmpty || p.name.toLowerCase().contains(q);
      return brandMatch && searchMatch;
    }).toList();
    notifyListeners();
  }

  void filterByBrand(String brand) {
    selectedBrand = brand;
    searchProducts('');
  }
}
