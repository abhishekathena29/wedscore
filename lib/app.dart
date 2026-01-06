import 'package:flutter/material.dart';

import 'screens/checklist_screen.dart';
import 'screens/gallery_screen.dart';
import 'screens/home_screen.dart';
import 'screens/not_found_screen.dart';
import 'screens/vendors_screen.dart';
import 'theme/app_theme.dart';
import 'utils/app_routes.dart';

class WedScoreApp extends StatelessWidget {
  const WedScoreApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'WedScore',
      theme: AppTheme.lightTheme,
      initialRoute: AppRoutes.home,
      routes: {
        AppRoutes.home: (context) => const HomeScreen(),
        AppRoutes.checklist: (context) => const ChecklistScreen(),
        AppRoutes.vendors: (context) => const VendorsScreen(),
        AppRoutes.gallery: (context) => const GalleryScreen(),
      },
      onUnknownRoute: (settings) =>
          MaterialPageRoute(builder: (context) => const NotFoundScreen()),
    );
  }
}
