import 'package:flutter/material.dart';

import '../../theme/app_theme.dart';

class CitySelector extends StatelessWidget {
  const CitySelector({
    super.key,
    required this.selectedCity,
    required this.onCityChange,
    this.isLight = false,
  });

  final String selectedCity;
  final ValueChanged<String> onCityChange;
  final bool isLight;

  static const List<String> cities = [
    'Jaipur',
    'Delhi',
    'Mumbai',
    'Bangalore',
    'Udaipur',
    'Goa',
    'Chennai',
    'Hyderabad',
    'Kolkata',
  ];

  @override
  Widget build(BuildContext context) {
    return PopupMenuButton<String>(
      onSelected: onCityChange,
      offset: const Offset(0, 36),
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(14)),
      color: AppColors.surface,
      elevation: 8,
      shadowColor: AppColors.primary.withOpacity(0.15),
      itemBuilder: (context) => cities.map((city) {
        final isSelected = city == selectedCity;
        return PopupMenuItem(
          value: city,
          child: Row(
            children: [
              Icon(
                Icons.location_on_rounded,
                size: 16,
                color: isSelected ? AppColors.primary : AppColors.textMuted,
              ),
              const SizedBox(width: 10),
              Text(
                city,
                style: TextStyle(
                  fontSize: 14,
                  fontWeight: isSelected ? FontWeight.w600 : FontWeight.w500,
                  color: isSelected ? AppColors.primary : AppColors.textPrimary,
                ),
              ),
              if (isSelected) ...[
                const Spacer(),
                const Icon(
                  Icons.check_rounded,
                  size: 16,
                  color: AppColors.primary,
                ),
              ],
            ],
          ),
        );
      }).toList(),
      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
        decoration: BoxDecoration(
          color: isLight
              ? Colors.white.withOpacity(0.25)
              : AppColors.primarySoft,
          borderRadius: BorderRadius.circular(20),
          border: isLight
              ? null
              : Border.all(color: AppColors.border.withOpacity(0.5)),
        ),
        child: Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            Text(
              selectedCity,
              style: TextStyle(
                fontSize: 13,
                fontWeight: FontWeight.w600,
                color: isLight ? Colors.white : AppColors.primary,
              ),
            ),
            const SizedBox(width: 4),
            Icon(
              Icons.keyboard_arrow_down_rounded,
              size: 18,
              color: isLight ? Colors.white : AppColors.primary,
            ),
          ],
        ),
      ),
    );
  }
}
