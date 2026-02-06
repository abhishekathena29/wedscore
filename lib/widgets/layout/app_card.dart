import 'package:flutter/material.dart';

import '../../theme/app_theme.dart';

enum CardVariant { flat, elevated, premium, gradient }

class AppCard extends StatelessWidget {
  const AppCard({
    super.key,
    required this.child,
    this.padding = const EdgeInsets.all(18),
    this.variant = CardVariant.premium,
    this.borderRadius,
    this.onTap,
  });

  final Widget child;
  final EdgeInsets padding;
  final CardVariant variant;
  final double? borderRadius;
  final VoidCallback? onTap;

  BoxDecoration _getDecoration() {
    final radius = BorderRadius.circular(borderRadius ?? 20);

    switch (variant) {
      case CardVariant.flat:
        return BoxDecoration(
          color: AppColors.surface,
          borderRadius: radius,
          border: Border.all(color: AppColors.border),
        );
      case CardVariant.elevated:
        return BoxDecoration(
          color: AppColors.surface,
          borderRadius: radius,
          boxShadow: [
            BoxShadow(
              color: AppColors.primary.withOpacity(0.08),
              blurRadius: 24,
              offset: const Offset(0, 10),
            ),
            BoxShadow(
              color: Colors.black.withOpacity(0.04),
              blurRadius: 12,
              offset: const Offset(0, 4),
            ),
          ],
        );
      case CardVariant.premium:
        return BoxDecoration(
          color: AppColors.surface,
          borderRadius: radius,
          border: Border.all(color: AppColors.border.withOpacity(0.5)),
          boxShadow: [
            BoxShadow(
              color: AppColors.primary.withOpacity(0.04),
              blurRadius: 20,
              offset: const Offset(0, 8),
            ),
            BoxShadow(
              color: Colors.black.withOpacity(0.03),
              blurRadius: 10,
              offset: const Offset(0, 4),
            ),
          ],
        );
      case CardVariant.gradient:
        return BoxDecoration(
          gradient: AppColors.cardGradient,
          borderRadius: radius,
          border: Border.all(color: AppColors.border.withOpacity(0.3)),
          boxShadow: [
            BoxShadow(
              color: AppColors.primary.withOpacity(0.06),
              blurRadius: 16,
              offset: const Offset(0, 6),
            ),
          ],
        );
    }
  }

  @override
  Widget build(BuildContext context) {
    final container = Container(
      padding: padding,
      decoration: _getDecoration(),
      child: child,
    );

    if (onTap != null) {
      return InkWell(
        onTap: onTap,
        borderRadius: BorderRadius.circular(borderRadius ?? 20),
        child: container,
      );
    }

    return container;
  }
}
