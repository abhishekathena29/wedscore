import 'package:flutter/material.dart';

import '../../theme/app_theme.dart';

class BottomNav extends StatelessWidget {
  const BottomNav({
    super.key,
    required this.currentIndex,
    required this.onTap,
  });

  final int currentIndex;
  final ValueChanged<int> onTap;

  @override
  Widget build(BuildContext context) {
    return BottomNavigationBar(
      currentIndex: currentIndex,
      onTap: onTap,
      type: BottomNavigationBarType.fixed,
      backgroundColor: AppColors.surface,
      selectedItemColor: AppColors.primary,
      unselectedItemColor: AppColors.textMuted,
      selectedFontSize: 11,
      unselectedFontSize: 11,
      items: const [
        BottomNavigationBarItem(
          icon: Icon(Icons.home_filled),
          label: 'Home',
        ),
        BottomNavigationBarItem(
          icon: Icon(Icons.fact_check),
          label: 'Checklist',
        ),
        BottomNavigationBarItem(
          icon: Icon(Icons.storefront),
          label: 'Vendors',
        ),
        BottomNavigationBarItem(
          icon: Icon(Icons.photo_library_outlined),
          label: 'Gallery',
        ),
      ],
    );
  }
}
