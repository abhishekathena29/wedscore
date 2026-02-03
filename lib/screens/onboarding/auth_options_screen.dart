import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../../theme/app_theme.dart';
import '../../providers/auth_provider.dart';
import '../../utils/app_routes.dart';

class AuthOptionsScreen extends StatelessWidget {
  const AuthOptionsScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.background,
      appBar: AppBar(
        title: const Text('Get Started'),
      ),
      body: SafeArea(
        child: Padding(
          padding: const EdgeInsets.all(24.0),
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Text(
                'Choose how you\'d like to continue',
                style: Theme.of(context).textTheme.titleLarge,
                textAlign: TextAlign.center,
              ),
              const SizedBox(height: 48),
              SizedBox(
                width: double.infinity,
                child: OutlinedButton.icon(
                  onPressed: () {
                    Navigator.pushNamed(context, AppRoutes.signup);
                  },
                  icon: const Icon(Icons.email),
                  label: const Text('Sign up with Email'),
                ),
              ),
              const SizedBox(height: 16),
              Consumer<AuthProvider>(
                builder: (context, authProvider, child) {
                  return SizedBox(
                    width: double.infinity,
                    child: OutlinedButton.icon(
                      onPressed: authProvider.isLoading
                          ? null
                          : () async {
                              try {
                                await authProvider.signInWithGoogle();
                                if (context.mounted) {
                                  final completed =
                                      await authProvider.checkOnboardingStatus();
                                  if (!completed) {
                                    Navigator.pushNamedAndRemoveUntil(
                                      context,
                                      AppRoutes.profileSetup,
                                      (route) => false,
                                    );
                                  } else {
                                    Navigator.pushNamedAndRemoveUntil(
                                      context,
                                      AppRoutes.home,
                                      (route) => false,
                                    );
                                  }
                                }
                              } catch (e) {
                                if (context.mounted) {
                                  ScaffoldMessenger.of(context).showSnackBar(
                                    SnackBar(
                                      content: Text('Error: ${e.toString()}'),
                                    ),
                                  );
                                }
                              }
                            },
                      icon: const Icon(Icons.g_mobiledata),
                      label: const Text('Continue with Google'),
                    ),
                  );
                },
              ),
              const SizedBox(height: 32),
              Row(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  const Text('Already have an account? '),
                  TextButton(
                    onPressed: () {
                    Navigator.pushNamed(context, AppRoutes.login);
                  },
                    child: const Text('Sign in'),
                  ),
                ],
              ),
            ],
          ),
        ),
      ),
    );
  }
}
