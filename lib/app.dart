import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:firebase_auth/firebase_auth.dart' as firebase_auth;

import 'providers/auth_provider.dart';
import 'providers/budget_provider.dart';
import 'providers/checklist_provider.dart';
import 'providers/vendor_provider.dart';
import 'providers/wedding_provider.dart';
import 'screens/onboarding/welcome_screen.dart';
import 'screens/onboarding/auth_options_screen.dart';
import 'screens/onboarding/profile_setup_screen.dart';
import 'screens/auth/login_screen.dart';
import 'screens/auth/signup_screen.dart';
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
    return MultiProvider(
      providers: [
        ChangeNotifierProvider(create: (_) => AuthProvider()),
        ChangeNotifierProvider(create: (_) => BudgetProvider()),
        ChangeNotifierProvider(create: (_) => ChecklistProvider()),
        ChangeNotifierProvider(create: (_) => VendorProvider()),
        ChangeNotifierProvider(create: (_) => WeddingProvider()),
      ],
      child: MaterialApp(
        title: 'WedScore',
        theme: AppTheme.lightTheme,
        initialRoute: AppRoutes.home,
        routes: {
          AppRoutes.welcome: (context) => const WelcomeScreen(),
          AppRoutes.onboardingAuth: (context) => const AuthOptionsScreen(),
          AppRoutes.login: (context) => const LoginScreen(),
          AppRoutes.signup: (context) => const SignUpScreen(),
          AppRoutes.profileSetup: (context) => const ProfileSetupScreen(),
          AppRoutes.home: (context) => const AuthGuard(child: HomeScreen()),
          AppRoutes.checklist: (context) => const AuthGuard(child: ChecklistScreen()),
          AppRoutes.vendors: (context) => const AuthGuard(child: VendorsScreen()),
          AppRoutes.gallery: (context) => const AuthGuard(child: GalleryScreen()),
        },
        onUnknownRoute: (settings) =>
            MaterialPageRoute(builder: (context) => const NotFoundScreen()),
      ),
    );
  }
}

class AuthGuard extends StatelessWidget {
  const AuthGuard({super.key, required this.child});

  final Widget child;

  @override
  Widget build(BuildContext context) {
    return StreamBuilder<firebase_auth.User?>(
      stream: Provider.of<AuthProvider>(context, listen: false)
          .authStateChanges,
      builder: (context, snapshot) {
        if (snapshot.connectionState == ConnectionState.waiting) {
          return const Scaffold(
            body: Center(child: CircularProgressIndicator()),
          );
        }

        if (snapshot.data == null) {
          // User not authenticated, redirect to welcome
          WidgetsBinding.instance.addPostFrameCallback((_) {
            Navigator.of(context).pushNamedAndRemoveUntil(
              AppRoutes.welcome,
              (route) => false,
            );
          });
          return const Scaffold(
            body: Center(child: CircularProgressIndicator()),
          );
        }

        // User authenticated, check onboarding
        return FutureBuilder<bool>(
          future: Provider.of<AuthProvider>(context, listen: false)
              .checkOnboardingStatus(),
          builder: (context, onboardingSnapshot) {
            if (onboardingSnapshot.connectionState ==
                ConnectionState.waiting) {
              return const Scaffold(
                body: Center(child: CircularProgressIndicator()),
              );
            }

            if (onboardingSnapshot.data == false) {
              // Onboarding not completed
              WidgetsBinding.instance.addPostFrameCallback((_) {
                Navigator.of(context).pushNamedAndRemoveUntil(
                  AppRoutes.profileSetup,
                  (route) => false,
                );
              });
              return const Scaffold(
                body: Center(child: CircularProgressIndicator()),
              );
            }

            // All checks passed, show the child
            return child;
          },
        );
      },
    );
  }
}
