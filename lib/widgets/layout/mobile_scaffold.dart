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
    this.actions,
    this.allowBack = true,
  });

  final Widget child;
  final int currentIndex;
  final String? title;
  final bool showLogo;
  final Widget? floatingActionButton;
  final List<Widget>? actions;
  final bool allowBack;

  @override
  Widget build(BuildContext context) {
    return PopScope(
      canPop: allowBack,
      child: Scaffold(
        appBar: AppBar(
          automaticallyImplyLeading: allowBack,
          title: showLogo
              ? Row(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    Container(
                      padding: const EdgeInsets.all(6),
                      decoration: BoxDecoration(
                        gradient: AppColors.primaryGradient,
                        borderRadius: BorderRadius.circular(8),
                      ),
                      child: const Icon(
                        Icons.favorite_rounded,
                        color: Colors.white,
                        size: 16,
                      ),
                    ),
                    const SizedBox(width: 10),
                    Text(
                      'WedScore',
                      style: Theme.of(context).textTheme.titleLarge?.copyWith(
                        fontWeight: FontWeight.w700,
                      ),
                    ),
                  ],
                )
              : Text(
                  title ?? '',
                  style: Theme.of(context).textTheme.titleLarge,
                ),
          actions: actions,
          elevation: 0,
          scrolledUnderElevation: 0,
          backgroundColor: AppColors.surface,
        ),
        body: SafeArea(top: false, child: child),
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
      ),
    );
  }
}
