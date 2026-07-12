import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:provider/provider.dart';

import '../../core/constants/app_colors.dart';
import '../../core/constants/app_routes.dart';
import '../../core/constants/app_strings.dart';
import '../../models/product.dart';
import '../../providers/cart_provider.dart';
import '../../widgets/common/custom_button.dart';
import 'widgets/color_selector.dart';
import 'widgets/product_image_slider.dart';
import 'widgets/product_info_section.dart';
import 'widgets/quantity_selector.dart';
import 'widgets/specs_table.dart';
import 'widgets/strap_selector.dart';

class ProductDetailScreen extends StatefulWidget {
  const ProductDetailScreen({super.key, required this.product});

  final Product product;

  @override
  State<ProductDetailScreen> createState() => _ProductDetailScreenState();
}

class _ProductDetailScreenState extends State<ProductDetailScreen> {
  String? selectedStrap;
  String? selectedColor;
  int quantity = 1;
  int activeImageIndex = 0;

  @override
  void initState() {
    super.initState();
    if (widget.product.straps.isNotEmpty) {
      selectedStrap = widget.product.straps.first;
    }
    if (widget.product.colors.isNotEmpty) {
      selectedColor = widget.product.colors.first;
      final idx = widget.product.colors.indexOf(selectedColor!);
      activeImageIndex = idx >= 0 ? idx : 0;
    }
  }

  void _addToCart() {
    final cart = context.read<CartProvider>();
    cart.addToCart(
      widget.product,
      strap: selectedStrap ?? 'Mặc định',
      color: selectedColor ?? 'Mặc định',
      quantity: quantity,
    );
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Row(
          children: [
            const Icon(Icons.check_circle_rounded, color: Colors.white, size: 22),
            const SizedBox(width: 10),
            Expanded(
              child: Text(
                'Đã thêm $quantity chiếc ${widget.product.name} vào giỏ hàng!',
                style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 13),
              ),
            ),
          ],
        ),
        action: SnackBarAction(
          label: 'XEM GIỎ HÀNG',
          textColor: Colors.white,
          onPressed: () {
            context.go('${AppRoutes.home}?tab=1');
          },
        ),
        backgroundColor: Colors.green.shade600,
        behavior: SnackBarBehavior.floating,
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
        duration: const Duration(seconds: 3),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final isOutOfStock = widget.product.stock == 0;
    
    return Scaffold(
      backgroundColor: AppColors.background,
      appBar: AppBar(
        title: const Text(AppStrings.productDetailTitle),
        leading: IconButton(
          icon: const Icon(Icons.arrow_back_ios_new, size: 18),
          onPressed: () => context.pop(),
        ),
        actions: [
          IconButton(
            icon: Stack(
              clipBehavior: Clip.none,
              children: [
                const Icon(Icons.shopping_bag_outlined),
                Consumer<CartProvider>(
                  builder: (context, cart, child) {
                    if (cart.totalQuantity == 0) return const SizedBox();
                    return Positioned(
                      right: -6,
                      top: -6,
                      child: Container(
                        padding: const EdgeInsets.all(4),
                        decoration: const BoxDecoration(
                          color: AppColors.accent,
                          shape: BoxShape.circle,
                        ),
                        constraints: const BoxConstraints(
                          minWidth: 16,
                          minHeight: 16,
                        ),
                        child: Text(
                          '${cart.totalQuantity}',
                          style: const TextStyle(
                            color: Colors.white,
                            fontSize: 8,
                            fontWeight: FontWeight.bold,
                          ),
                          textAlign: TextAlign.center,
                        ),
                      ),
                    );
                  },
                ),
              ],
            ),
            onPressed: () => context.go('${AppRoutes.home}?tab=1'),
          ),
          const SizedBox(width: 8),
        ],
      ),
      body: SingleChildScrollView(
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            ProductImageSlider(
              images: widget.product.images ?? [widget.product.image],
              productId: widget.product.id,
              selectedIndex: activeImageIndex,
            ),
            const Divider(height: 1, color: AppColors.border),
            Padding(
              padding: const EdgeInsets.all(16),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  ProductInfoSection(
                    brand: widget.product.brand,
                    name: widget.product.name,
                    price: widget.product.price,
                    salePrice: widget.product.salePrice,
                    description: widget.product.description,
                  ),
                  StrapSelector(
                    straps: widget.product.straps,
                    selectedStrap: selectedStrap,
                    onSelected: (strap) {
                      setState(() {
                        selectedStrap = strap;
                        final idx = widget.product.straps.indexOf(strap);
                        if (idx >= 0 && idx < (widget.product.images?.length ?? 0)) {
                          activeImageIndex = idx;
                        }
                      });
                    },
                  ),
                  ColorSelector(
                    colors: widget.product.colors,
                    selectedColor: selectedColor,
                    onSelected: (color) {
                      setState(() {
                        selectedColor = color;
                        final idx = widget.product.colors.indexOf(color);
                        if (idx >= 0 && idx < (widget.product.images?.length ?? 0)) {
                          activeImageIndex = idx;
                        }
                      });
                    },
                  ),
                  QuantitySelector(
                    quantity: quantity,
                    stock: widget.product.stock,
                    onIncrease: () => setState(() => quantity++),
                    onDecrease: () => setState(() => quantity--),
                  ),
                  SpecsTable(
                    brand: widget.product.brand,
                    movement: widget.product.movement,
                    strapMaterial: widget.product.strapMaterial,
                    waterResistance: widget.product.waterResistance,
                    warranty: widget.product.warranty,
                    stock: widget.product.stock,
                    colors: widget.product.colors,
                    straps: widget.product.straps,
                    customSpecs: widget.product.customSpecs,
                  ),
                  const SizedBox(height: 32),
                  CustomButton(
                    onPressed: isOutOfStock ? null : _addToCart,
                    label: isOutOfStock ? AppStrings.outOfStockButton : AppStrings.addToCartButton,
                  ),
                  const SizedBox(height: 20),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }
}
