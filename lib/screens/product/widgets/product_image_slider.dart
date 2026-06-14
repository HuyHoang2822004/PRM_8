import 'package:cached_network_image/cached_network_image.dart';
import 'package:flutter/material.dart';
import '../../../core/constants/app_colors.dart';
import '../../../core/constants/app_sizes.dart';

class ProductImageSlider extends StatefulWidget {
  final String imageUrl;
  final int productId;

  const ProductImageSlider({
    super.key,
    required this.imageUrl,
    required this.productId,
  });

  @override
  State<ProductImageSlider> createState() => _ProductImageSliderState();
}

class _ProductImageSliderState extends State<ProductImageSlider> {
  int _activeImageIndex = 0;

  @override
  Widget build(BuildContext context) {
    return Container(
      color: Colors.white,
      height: 320,
      width: double.infinity,
      child: Stack(
        children: [
          PageView.builder(
            onPageChanged: (idx) => setState(() => _activeImageIndex = idx),
            itemCount: 2,
            itemBuilder: (context, index) {
              final imageWidget = CachedNetworkImage(
                imageUrl: widget.imageUrl,
                fit: BoxFit.contain,
                placeholder: (_, __) => const Center(
                  child: CircularProgressIndicator(color: AppColors.primary),
                ),
                errorWidget: (_, __, ___) => const Icon(Icons.image_not_supported, size: 64),
              );
              
              if (index == 0) {
                return Hero(
                  tag: 'product_image_${widget.productId}',
                  child: Material(
                    color: Colors.transparent,
                    child: imageWidget,
                  ),
                );
              }
              return imageWidget;
            },
          ),
          Positioned(
            bottom: AppSizes.paddingMedium,
            left: 0,
            right: 0,
            child: Row(
              mainAxisAlignment: MainAxisAlignment.center,
              children: List.generate(
                2,
                (index) => Container(
                  margin: const EdgeInsets.symmetric(horizontal: 4),
                  width: 8,
                  height: 8,
                  decoration: BoxDecoration(
                    shape: BoxShape.circle,
                    color: _activeImageIndex == index
                        ? AppColors.primary
                        : AppColors.border,
                  ),
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }
}
