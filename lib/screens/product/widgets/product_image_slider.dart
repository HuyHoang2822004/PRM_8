import 'package:cached_network_image/cached_network_image.dart';
import 'package:flutter/material.dart';
import '../../../core/constants/app_colors.dart';
import '../../../core/constants/app_sizes.dart';

class ProductImageSlider extends StatefulWidget {
  final List<String> images;
  final int productId;
  final int selectedIndex;

  const ProductImageSlider({
    super.key,
    required this.images,
    required this.productId,
    this.selectedIndex = 0,
  });

  @override
  State<ProductImageSlider> createState() => _ProductImageSliderState();
}

class _ProductImageSliderState extends State<ProductImageSlider> {
  late PageController _pageController;
  int _activeImageIndex = 0;

  @override
  void initState() {
    super.initState();
    _activeImageIndex = widget.selectedIndex;
    _pageController = PageController(initialPage: widget.selectedIndex);
  }

  @override
  void didUpdateWidget(covariant ProductImageSlider oldWidget) {
    super.didUpdateWidget(oldWidget);
    if (widget.selectedIndex != oldWidget.selectedIndex) {
      if (widget.selectedIndex >= 0 && widget.selectedIndex < widget.images.length) {
        setState(() {
          _activeImageIndex = widget.selectedIndex;
        });
        _pageController.animateToPage(
          widget.selectedIndex,
          duration: const Duration(milliseconds: 300),
          curve: Curves.easeInOut,
        );
      }
    }
  }

  @override
  void dispose() {
    _pageController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Container(
      color: Colors.white,
      height: 320,
      width: double.infinity,
      child: Stack(
        children: [
          PageView.builder(
            controller: _pageController,
            onPageChanged: (idx) => setState(() => _activeImageIndex = idx),
            itemCount: widget.images.length,
            itemBuilder: (context, index) {
              final imageWidget = CachedNetworkImage(
                imageUrl: widget.images[index],
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
          if (widget.images.length > 1)
            Positioned(
              bottom: AppSizes.paddingMedium,
              left: 0,
              right: 0,
              child: Row(
                mainAxisAlignment: MainAxisAlignment.center,
                children: List.generate(
                  widget.images.length,
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
