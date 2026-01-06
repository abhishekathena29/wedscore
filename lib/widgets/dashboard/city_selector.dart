import 'package:flutter/material.dart';

import '../../data/mock_data.dart';
import '../../theme/app_theme.dart';

class CitySelector extends StatelessWidget {
  const CitySelector({
    super.key,
    required this.selectedCity,
    required this.onCityChange,
  });

  final String selectedCity;
  final ValueChanged<String> onCityChange;

  @override
  Widget build(BuildContext context) {
    return PopupMenuButton<String>(
      onSelected: onCityChange,
      itemBuilder: (context) => cities
          .map(
            (city) => PopupMenuItem<String>(
              value: city,
              child: Row(
                children: [
                  const Icon(Icons.location_on, size: 14, color: AppColors.primary),
                  const SizedBox(width: 6),
                  Text(city),
                ],
              ),
            ),
          )
          .toList(),
      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
        decoration: BoxDecoration(
          color: AppColors.surface,
          borderRadius: BorderRadius.circular(999),
          border: Border.all(color: AppColors.border),
        ),
        child: Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            const Icon(Icons.location_on, size: 14, color: AppColors.primary),
            const SizedBox(width: 4),
            Text(
              selectedCity,
              style: const TextStyle(fontWeight: FontWeight.w600, fontSize: 12),
            ),
            const SizedBox(width: 4),
            const Icon(Icons.keyboard_arrow_down, size: 16, color: AppColors.textMuted),
          ],
        ),
      ),
    );
  }
}
