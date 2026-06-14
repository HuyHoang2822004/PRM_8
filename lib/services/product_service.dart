import 'dart:convert';

import 'package:flutter/services.dart';

import '../core/constants/app_assets.dart';
import '../models/product.dart';

class ProductService {
  Future<List<Product>> loadProducts() async {
    await Future.delayed(const Duration(milliseconds: 400));
    final jsonString = await rootBundle.loadString(AppAssets.productsJson);
    final data = json.decode(jsonString) as List<dynamic>;
    return data
        .map((e) => Product.fromJson(e as Map<String, dynamic>))
        .toList();
  }
}
