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
        extendBody: true,
        appBar: AppBar(
          automaticallyImplyLeading: allowBack,
          title: showLogo
              ? Row(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    Image.asset(
                      'assets/images/wedplan_logo.png',
                      width: 32,
                      height: 32,
                    ),
                    const SizedBox(width: 10),
                    Text(
                      'WedPlan',
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
          backgroundColor: Colors.transparent,
        ),
        body: Container(
          decoration: const BoxDecoration(
            gradient: AppColors.festiveBackground,
          ),
          child: Stack(
            children: [
              Positioned(
                top: -80,
                right: -50,
                child: Container(
                  width: 220,
                  height: 220,
                  decoration: BoxDecoration(
                    shape: BoxShape.circle,
                    color: AppColors.accentGold.withOpacity(0.1),
                  ),
                ),
              ),
              Positioned(
                left: -40,
                top: 120,
                child: Container(
                  width: 140,
                  height: 140,
                  decoration: BoxDecoration(
                    shape: BoxShape.circle,
                    color: AppColors.primaryLight.withOpacity(0.2),
                  ),
                ),
              ),
              SafeArea(top: false, child: child),
            ],
          ),
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
      ),
    );
  }
}
