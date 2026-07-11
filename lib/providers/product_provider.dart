import 'dart:async';
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
  String searchQuery = '';
  bool onlyDiscount = false;
  bool onlyInStock = false;
  double? maxPriceLimit;

  StreamSubscription<List<Product>>? _productsSubscription;

  void listenToProducts() {
    _productsSubscription?.cancel();
    isLoading = true;
    errorMessage = null;
    notifyListeners();

    _productsSubscription = _productService.getProductsStream().listen((list) async {
      isLoading = false;
      if (list.length < 10) {
        await loadProducts();
        return;
      }
      _allProducts = list;
      _applyFilters();
    }, onError: (_) {
      isLoading = false;
      errorMessage = 'Không thể tải danh sách đồng hồ';
      notifyListeners();
    });
  }

  @override
  void dispose() {
    _productsSubscription?.cancel();
    super.dispose();
  }

  Future<void> loadProducts() async {
    isLoading = true;
    errorMessage = null;
    notifyListeners();
    try {
      _allProducts = await _productService.loadProducts();
      _applyFilters();
    } catch (_) {
      errorMessage = 'Không thể tải danh sách đồng hồ';
    } finally {
      isLoading = false;
      notifyListeners();
    }
  }

  Product? getProductById(int id) {
    try {
      return _allProducts.firstWhere((p) => p.id == id);
    } catch (_) {
      return null;
    }
  }

  void searchProducts(String query) {
    searchQuery = query;
    _applyFilters();
  }

  void filterByBrand(String brand) {
    selectedBrand = brand;
    _applyFilters();
  }

  void toggleDiscountFilter(bool value) {
    onlyDiscount = value;
    _applyFilters();
  }

  void toggleInStockFilter(bool value) {
    onlyInStock = value;
    _applyFilters();
  }

  void setMaxPrice(double? price) {
    maxPriceLimit = price;
    _applyFilters();
  }

  void resetFilters() {
    selectedBrand = 'All';
    searchQuery = '';
    onlyDiscount = false;
    onlyInStock = false;
    maxPriceLimit = null;
    _applyFilters();
  }

  void _applyFilters() {
    final q = searchQuery.toLowerCase().trim();
    products = _allProducts.where((p) {
      final brandMatch = selectedBrand == 'All' || p.brand == selectedBrand;
      final searchMatch = q.isEmpty ||
          p.name.toLowerCase().contains(q) ||
          p.brand.toLowerCase().contains(q);
      final discountMatch = !onlyDiscount || p.hasDiscount;
      final stockMatch = !onlyInStock || p.stock > 0;
      final priceMatch = maxPriceLimit == null || p.activePrice <= maxPriceLimit!;
      
      return brandMatch && searchMatch && discountMatch && stockMatch && priceMatch;
    }).toList();
    notifyListeners();
  }

  Future<bool> addProduct(Product product) async {
    try {
      await _productService.addProduct(product);
      await loadProducts();
      return true;
    } catch (_) {
      return false;
    }
  }

  Future<bool> updateProduct(Product product) async {
    try {
      await _productService.updateProduct(product);
      await loadProducts();
      return true;
    } catch (_) {
      return false;
    }
  }

  Future<bool> deleteProduct(int id) async {
    try {
      await _productService.deleteProduct(id);
      await loadProducts();
      return true;
    } catch (_) {
      return false;
    }
  }
}
