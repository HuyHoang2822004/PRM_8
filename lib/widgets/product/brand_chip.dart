import 'package:flutter/material.dart';
import '../../core/theme/app_colors.dart';

class BrandChip extends StatefulWidget {
  const BrandChip({
    super.key,
    required this.label,
    required this.selected,
    required this.onTap,
  });

  final String label;
  final bool selected;
  final VoidCallback onTap;

  @override
  State<BrandChip> createState() => _BrandChipState();
}

class _BrandChipState extends State<BrandChip> with SingleTickerProviderStateMixin {
  late AnimationController _controller;
  late Animation<double> _scaleAnimation;

  @override
  void initState() {
    super.initState();
    _controller = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 80),
    );
    _scaleAnimation = Tween<double>(begin: 1.0, end: 0.93).animate(
      CurvedAnimation(parent: _controller, curve: Curves.easeOut),
    );
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return ScaleTransition(
      scale: _scaleAnimation,
      child: GestureDetector(
        onTapDown: (_) => _controller.forward(),
        onTapUp: (_) {
          _controller.reverse();
          widget.onTap();
        },
        onTapCancel: () => _controller.reverse(),
        child: AnimatedContainer(
          duration: const Duration(milliseconds: 200),
          padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 8),
          decoration: BoxDecoration(
            color: widget.selected ? AppColors.primary : Colors.white,
            border: Border.all(
              color: widget.selected ? AppColors.primary : AppColors.border,
              width: 1,
            ),
            borderRadius: BorderRadius.circular(20),
            boxShadow: widget.selected
                ? [
                    BoxShadow(
                      color: AppColors.primary.withOpacity(0.15),
                      blurRadius: 6,
                      offset: const Offset(0, 3),
                    )
                  ]
                : null,
          ),
          child: Center(
            child: Text(
              widget.label,
              style: TextStyle(
                color: widget.selected ? Colors.white : AppColors.textPrimary,
                fontWeight: widget.selected ? FontWeight.w600 : FontWeight.w500,
                fontSize: 13,
                letterSpacing: 0.3,
              ),
            ),
          ),
        ),
      ),
    );
  }
}
