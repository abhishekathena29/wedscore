import 'package:flutter/material.dart';

import '../theme/app_theme.dart';
import '../utils/app_routes.dart';

class NotFoundScreen extends StatelessWidget {
  const NotFoundScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.background,
      body: Center(
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            const Text(
              '404',
              style: TextStyle(fontSize: 36, fontWeight: FontWeight.bold),
            ),
            const SizedBox(height: 8),
            Text(
              'Oops! Page not found',
              style: Theme.of(context).textTheme.labelSmall,
            ),
            const SizedBox(height: 12),
            TextButton(
              onPressed: () =>
                  Navigator.of(context).pushReplacementNamed(AppRoutes.home),
              child: const Text('Return to Home'),
            ),
          ],
        ),
      ),
    );
  }
}
