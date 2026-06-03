import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:provider/provider.dart';

import '../../core/constants/app_constants.dart';
import '../../models/product.dart';
import '../../providers/product_provider.dart';
import '../../widgets/common/loading_widget.dart';
import '../../widgets/product/brand_chip.dart';
import '../../widgets/product/product_grid.dart';

class ProductListScreen extends StatefulWidget {
  const ProductListScreen({super.key});

  @override
  State<ProductListScreen> createState() => _ProductListScreenState();
}

class _ProductListScreenState extends State<ProductListScreen> {
  final _searchController = TextEditingController();

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      context.read<ProductProvider>().loadProducts();
    });
  }

  @override
  void dispose() {
    _searchController.dispose();
    super.dispose();
  }

  void _openDetail(Product product) {
    context.push('/product-detail', extra: product);
  }

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.all(12),
      child: Column(
        children: [
          TextField(
            controller: _searchController,
            decoration: const InputDecoration(
              hintText: 'Search product',
              prefixIcon: Icon(Icons.search),
            ),
            onChanged: context.read<ProductProvider>().searchProducts,
          ),
          const SizedBox(height: 12),
          SizedBox(
            height: 40,
            child: Consumer<ProductProvider>(
              builder: (_, provider, __) => ListView.separated(
                scrollDirection: Axis.horizontal,
                itemCount: AppConstants.brands.length,
                separatorBuilder: (_, __) => const SizedBox(width: 8),
                itemBuilder: (_, index) {
                  final brand = AppConstants.brands[index];
                  return BrandChip(
                    label: brand,
                    selected: provider.selectedBrand == brand,
                    onTap: () => provider.filterByBrand(brand),
                  );
                },
              ),
            ),
          ),
          const SizedBox(height: 12),
          Expanded(
            child: Consumer<ProductProvider>(
              builder: (_, provider, __) {
                if (provider.isLoading) return const LoadingWidget();
                if (provider.errorMessage != null) {
                  return Center(child: Text(provider.errorMessage!));
                }
                if (provider.products.isEmpty) {
                  return const Center(child: Text('Không có sản phẩm'));
                }
                return ProductGrid(products: provider.products, onTap: _openDetail);
              },
            ),
          ),
        ],
      ),
    );
  }
}
