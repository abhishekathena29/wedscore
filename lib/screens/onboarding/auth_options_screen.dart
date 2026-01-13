import 'package:flutter/material.dart';
import 'package:flutter/foundation.dart' show kIsWeb;
import 'package:provider/provider.dart';
import '../../theme/app_theme.dart';
import '../../providers/auth_provider.dart';
import '../auth/login_screen.dart';
import '../auth/signup_screen.dart';

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
                    Navigator.push(
                      context,
                      MaterialPageRoute(
                        builder: (context) => const SignUpScreen(),
                      ),
                    );
                  },
                  icon: const Icon(Icons.email),
                  label: const Text('Sign up with Email'),
                  style: OutlinedButton.styleFrom(
                    padding: const EdgeInsets.symmetric(vertical: 16),
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(12),
                    ),
                  ),
                ),
              ),
              // if (!kIsWeb) ...[
              //   const SizedBox(height: 16),
              //   SizedBox(
              //     width: double.infinity,
              //     child: OutlinedButton.icon(
              //       onPressed: () async {
              //         // Handle Google sign in (mobile/desktop only)
              //         final authProvider = Provider.of<AuthProvider>(
              //           context,
              //           listen: false,
              //         );
              //         try {
              //           await authProvider.signInWithGoogle();
              //           if (context.mounted) {
              //             final completed =
              //                 await authProvider.checkOnboardingStatus();
              //             if (!completed) {
              //               Navigator.pushReplacementNamed(
              //                   context, '/profile-setup');
              //             } else {
              //               Navigator.pushReplacementNamed(context, '/');
              //             }
              //           }
              //         } catch (e) {
              //           if (context.mounted) {
              //             ScaffoldMessenger.of(context).showSnackBar(
              //               SnackBar(content: Text('Error: ${e.toString()}')),
              //             );
              //           }
              //         }
              //       },
              //       icon: const Icon(Icons.g_mobiledata),
              //       label: const Text('Continue with Google'),
              //       style: OutlinedButton.styleFrom(
              //         padding: const EdgeInsets.symmetric(vertical: 16),
              //         shape: RoundedRectangleBorder(
              //           borderRadius: BorderRadius.circular(12),
              //         ),
              //       ),
              //     ),
              //   ),
              // ],
              const SizedBox(height: 32),
              Row(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  const Text('Already have an account? '),
                  TextButton(
                    onPressed: () {
                      Navigator.push(
                        context,
                        MaterialPageRoute(
                          builder: (context) => const LoginScreen(),
                        ),
                      );
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
