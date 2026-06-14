import 'package:cached_network_image/cached_network_image.dart';
import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:provider/provider.dart';

import '../../core/constants/app_constants.dart';
import '../../core/constants/app_colors.dart';
import '../../core/constants/app_routes.dart';
import '../../core/constants/app_strings.dart';
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
  bool _showFilters = false;

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
    context.push(AppRoutes.productDetail, extra: product);
  }

  @override
  Widget build(BuildContext context) {
    final provider = context.watch<ProductProvider>();

    return Scaffold(
      backgroundColor: AppColors.background,
      body: RefreshIndicator(
        onRefresh: () => context.read<ProductProvider>().loadProducts(),
        color: AppColors.primary,
        child: SingleChildScrollView(
          physics: const AlwaysScrollableScrollPhysics(),
          padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Container(
                height: 180,
                width: double.infinity,
                decoration: BoxDecoration(
                  borderRadius: BorderRadius.circular(8),
                  color: AppColors.primary,
                ),
                clipBehavior: Clip.antiAlias,
                child: Stack(
                  children: [
                    Positioned.fill(
                      child: Opacity(
                        opacity: 0.55,
                        child: CachedNetworkImage(
                          imageUrl: 'https://images.unsplash.com/photo-1523275335684-37898b6baf30?w=1200',
                          fit: BoxFit.cover,
                          errorWidget: (_, __, ___) => const SizedBox(),
                        ),
                      ),
                    ),
                    Positioned.fill(
                      child: Container(
                        decoration: BoxDecoration(
                          gradient: LinearGradient(
                            colors: [
                              Colors.black.withOpacity(0.8),
                              Colors.black.withOpacity(0.2)
                            ],
                            begin: Alignment.bottomLeft,
                            end: Alignment.topRight,
                          ),
                        ),
                      ),
                    ),
                    Padding(
                      padding: const EdgeInsets.all(20),
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: [
                          Container(
                            padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                            decoration: BoxDecoration(
                              border: Border.all(color: AppColors.accent, width: 1),
                              borderRadius: BorderRadius.circular(4),
                            ),
                            child: const Text(
                              AppStrings.collectionTitle,
                              style: TextStyle(
                                color: AppColors.accent,
                                fontSize: 9,
                                fontWeight: FontWeight.bold,
                                letterSpacing: 1.5,
                              ),
                            ),
                          ),
                          const SizedBox(height: 10),
                          const Text(
                            AppStrings.bannerTitle,
                            style: TextStyle(
                              color: Colors.white,
                              fontSize: 20,
                              fontWeight: FontWeight.w900,
                              letterSpacing: 2.0,
                            ),
                          ),
                          const SizedBox(height: 4),
                          const Text(
                            AppStrings.bannerSubtitle,
                            style: TextStyle(
                              color: Colors.grey,
                              fontSize: 11,
                            ),
                          ),
                        ],
                      ),
                    ),
                  ],
                ),
              ),
              const SizedBox(height: 20),
              
              Row(
                children: [
                  Expanded(
                    child: SizedBox(
                      height: 48,
                      child: TextField(
                        controller: _searchController,
                        onChanged: provider.searchProducts,
                        decoration: InputDecoration(
                          hintText: AppStrings.searchPhone,
                          prefixIcon: const Icon(Icons.search, size: 20, color: AppColors.textSecondary),
                          suffixIcon: _searchController.text.isNotEmpty
                              ? IconButton(
                                  icon: const Icon(Icons.clear, size: 18),
                                  onPressed: () {
                                    _searchController.clear();
                                    provider.searchProducts('');
                                  },
                                )
                              : null,
                        ),
                      ),
                    ),
                  ),
                  const SizedBox(width: 10),
                  GestureDetector(
                    onTap: () => setState(() => _showFilters = !_showFilters),
                    child: Container(
                      height: 48,
                      width: 48,
                      decoration: BoxDecoration(
                        color: _showFilters ? AppColors.primary : Colors.white,
                        border: Border.all(color: _showFilters ? AppColors.primary : AppColors.border),
                        borderRadius: BorderRadius.circular(8),
                      ),
                      child: Icon(
                        Icons.tune,
                        color: _showFilters ? Colors.white : AppColors.textPrimary,
                        size: 20,
                      ),
                    ),
                  ),
                ],
              ),
              
              AnimatedCrossFade(
                firstChild: const SizedBox.shrink(),
                secondChild: Container(
                  margin: const EdgeInsets.only(top: 12),
                  padding: const EdgeInsets.all(16),
                  decoration: BoxDecoration(
                    color: Colors.white,
                    borderRadius: BorderRadius.circular(8),
                    border: Border.all(color: AppColors.border),
                  ),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      const Text(
                        AppStrings.advancedFilters,
                        style: TextStyle(fontWeight: FontWeight.bold, fontSize: 14),
                      ),
                      const SizedBox(height: 14),
                      Row(
                        children: [
                          Expanded(
                            child: FilterChip(
                              label: const Text(AppStrings.onlyDiscount),
                              selected: provider.onlyDiscount,
                              onSelected: provider.toggleDiscountFilter,
                              selectedColor: AppColors.primary.withOpacity(0.08),
                              checkmarkColor: AppColors.primary,
                            ),
                          ),
                          const SizedBox(width: 10),
                          Expanded(
                            child: FilterChip(
                              label: const Text(AppStrings.onlyInStock),
                              selected: provider.onlyInStock,
                              onSelected: provider.toggleInStockFilter,
                              selectedColor: AppColors.primary.withOpacity(0.08),
                              checkmarkColor: AppColors.primary,
                            ),
                          ),
                        ],
                      ),
                      const SizedBox(height: 12),
                      Text(
                        '${AppStrings.maxPrice}: ${provider.maxPriceLimit == null ? "Không giới hạn" : "${(provider.maxPriceLimit! / 1000000).toStringAsFixed(1)} triệuđ"}',
                        style: const TextStyle(fontSize: 13, color: AppColors.textPrimary),
                      ),
                      Slider(
                        value: provider.maxPriceLimit ?? 400000000,
                        min: 1000000,
                        max: 400000000,
                        divisions: 40,
                        activeColor: AppColors.primary,
                        inactiveColor: AppColors.border,
                        onChanged: (val) {
                          provider.setMaxPrice(val == 400000000 ? null : val);
                        },
                      ),
                      const SizedBox(height: 6),
                      Align(
                        alignment: Alignment.centerRight,
                        child: TextButton(
                          onPressed: () {
                            provider.resetFilters();
                            _searchController.clear();
                          },
                          child: const Text(AppStrings.resetFiltersButton),
                        ),
                      ),
                    ],
                  ),
                ),
                crossFadeState: _showFilters ? CrossFadeState.showSecond : CrossFadeState.showFirst,
                duration: const Duration(milliseconds: 200),
              ),
              const SizedBox(height: 16),
              
              const Text(
                AppStrings.brandTitle,
                style: TextStyle(fontSize: 14, fontWeight: FontWeight.bold, letterSpacing: 0.5),
              ),
              const SizedBox(height: 8),
              SizedBox(
                height: 38,
                child: ListView.separated(
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
              const SizedBox(height: 18),
              
              if (provider.products.isNotEmpty)
                Padding(
                  padding: const EdgeInsets.only(bottom: 12),
                  child: Text(
                    '${AppStrings.searchFound} ${provider.products.length} ${AppStrings.productsText}',
                    style: const TextStyle(fontSize: 12, color: AppColors.textSecondary),
                  ),
                ),

              if (provider.isLoading)
                const Padding(
                  padding: EdgeInsets.symmetric(vertical: 50),
                  child: LoadingWidget(),
                )
              else if (provider.errorMessage != null)
                Center(
                  child: Padding(
                    padding: const EdgeInsets.symmetric(vertical: 40),
                    child: Text(provider.errorMessage!, style: const TextStyle(color: Colors.red)),
                  ),
                )
              else if (provider.products.isEmpty)
                const Center(
                  child: Padding(
                    padding: EdgeInsets.symmetric(vertical: 60),
                    child: Column(
                      children: [
                        Icon(Icons.watch_off, size: 48, color: Colors.grey),
                        SizedBox(height: 12),
                        Text(
                          AppStrings.noProductsFound,
                          style: TextStyle(color: AppColors.textSecondary),
                        ),
                      ],
                    ),
                  ),
                )
              else
                ProductGrid(products: provider.products, onTap: _openDetail),
            ],
          ),
        ),
      ),
    );
  }
}
