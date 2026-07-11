import 'dart:convert';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/services.dart';

import '../core/constants/app_assets.dart';
import '../models/product.dart';

class ProductService {
  ProductService({FirebaseFirestore? firestore}) : _firestoreInstance = firestore;

  final FirebaseFirestore? _firestoreInstance;
  FirebaseFirestore get _firestore => _firestoreInstance ?? FirebaseFirestore.instance;

  Future<List<Product>> loadProducts() async {
    try {
      // 1. Fetch from Firestore
      final snapshot = await _firestore.collection('products').get();

      // 2. Auto-seed if database is empty or missing expanded catalog
      if (snapshot.docs.length < 10) {
        final jsonString = await rootBundle.loadString(AppAssets.productsJson);
        final data = json.decode(jsonString) as List<dynamic>;
        final List<Product> localProducts = data
            .map((e) => Product.fromJson(e as Map<String, dynamic>))
            .toList();

        final batch = _firestore.batch();
        for (final product in localProducts) {
          final docRef = _firestore.collection('products').doc(product.id.toString());
          batch.set(docRef, product.toJson());
        }
        await batch.commit();

        return localProducts;
      }

      // 3. Parse and return products from Firestore
      return snapshot.docs.map((doc) {
        try {
          final data = doc.data();
          return Product.fromJson(data);
        } catch (e) {
          // Log parsing error for this specific document but don't crash the entire list
          print('Error parsing product ID ${doc.id}: $e');
          return null;
        }
      }).whereType<Product>().toList();
    } catch (_) {
      // Fallback in case of database connectivity or permission issue
      final jsonString = await rootBundle.loadString(AppAssets.productsJson);
      final data = json.decode(jsonString) as List<dynamic>;
      return data
          .map((e) => Product.fromJson(e as Map<String, dynamic>))
          .toList();
    }
  }

  Future<void> addProduct(Product product) async {
    await _firestore.collection('products').doc(product.id.toString()).set(product.toJson());
  }

  Future<void> updateProduct(Product product) async {
    await _firestore.collection('products').doc(product.id.toString()).update(product.toJson());
  }

  Future<void> deleteProduct(int id) async {
    await _firestore.collection('products').doc(id.toString()).delete();
  }

  Stream<List<Product>> getProductsStream() {
    return _firestore.collection('products').snapshots().map((snapshot) {
      return snapshot.docs.map((doc) {
        try {
          return Product.fromJson(doc.data());
        } catch (e) {
          print('Error parsing product ID ${doc.id}: $e');
          return null;
        }
      }).whereType<Product>().toList();
    });
  }
}
