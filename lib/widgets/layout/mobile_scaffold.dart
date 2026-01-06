import 'package:flutter/material.dart';

import '../../theme/app_theme.dart';
import '../../utils/app_routes.dart';
import '../navigation/bottom_nav.dart';

class MobileScaffold extends StatelessWidget {
  const MobileScaffold({
    super.key,
    required this.child,
    required this.currentIndex,
    this.title,
    this.showLogo = true,
    this.floatingActionButton,
  });

  final Widget child;
  final int currentIndex;
  final String? title;
  final bool showLogo;
  final Widget? floatingActionButton;

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: showLogo
            ? Row(
                mainAxisSize: MainAxisSize.min,
                children: [
                  const Icon(Icons.favorite, color: AppColors.primary, size: 20),
                  const SizedBox(width: 6),
                  Text(
                    'WedPlan',
                    style: Theme.of(context).textTheme.titleLarge,
                  ),
                ],
              )
            : Text(
                title ?? '',
                style: Theme.of(context).textTheme.titleLarge,
              ),
      ),
      body: SafeArea(
        top: false,
        child: child,
      ),
      floatingActionButton: floatingActionButton,
      floatingActionButtonLocation: FloatingActionButtonLocation.endFloat,
      bottomNavigationBar: BottomNav(
        currentIndex: currentIndex,
        onTap: (index) {
          final route = AppRoutes.routeForIndex(index);
          if (ModalRoute.of(context)?.settings.name != route) {
            Navigator.of(context).pushReplacementNamed(route);
          }
        },
      ),
    );
  }
}
