import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../../providers/auth_provider.dart';
import '../../providers/wedding_provider.dart';
import '../../theme/app_theme.dart';
import '../../utils/app_routes.dart';
import '../../widgets/auth/auth_text_field.dart';
import '../../widgets/auth/auth_button.dart';

class ProfileSetupScreen extends StatefulWidget {
  const ProfileSetupScreen({super.key});

  @override
  State<ProfileSetupScreen> createState() => _ProfileSetupScreenState();
}

class _ProfileSetupScreenState extends State<ProfileSetupScreen> {
  final _formKey = GlobalKey<FormState>();
  final _weddingNameController = TextEditingController();
  final _cityController = TextEditingController();
  DateTime? _weddingDate;

  Future<void> _selectDate() async {
    final picked = await showDatePicker(
      context: context,
      initialDate: DateTime.now().add(const Duration(days: 180)),
      firstDate: DateTime.now(),
      lastDate: DateTime.now().add(const Duration(days: 365 * 2)),
    );
    if (picked != null) {
      setState(() {
        _weddingDate = picked;
      });
    }
  }

  Future<void> _completeSetup() async {
    if (!_formKey.currentState!.validate()) return;
    if (_weddingDate == null) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Please select a wedding date')),
      );
      return;
    }

    final authProvider = Provider.of<AuthProvider>(context, listen: false);
    final weddingProvider = Provider.of<WeddingProvider>(context, listen: false);

    try {
      await weddingProvider.createWedding(
        name: _weddingNameController.text.trim(),
        city: _cityController.text.trim(),
        weddingDate: _weddingDate!,
      );

      await authProvider.completeOnboarding();

      if (mounted) {
        Navigator.pushNamedAndRemoveUntil(
          context,
          AppRoutes.home,
          (route) => false,
        );
      }
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Error: ${e.toString()}')),
        );
      }
    }
  }

  @override
  void dispose() {
    _weddingNameController.dispose();
    _cityController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.background,
      appBar: AppBar(
        title: const Text('Setup Your Wedding'),
      ),
      body: SafeArea(
        child: SingleChildScrollView(
          padding: const EdgeInsets.all(24.0),
          child: Form(
            key: _formKey,
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.stretch,
              children: [
                const SizedBox(height: 32),
                Text(
                  'Let\'s set up your wedding',
                  style: Theme.of(context).textTheme.headlineSmall,
                ),
                const SizedBox(height: 8),
                Text(
                  'We\'ll use this to personalize your experience',
                  style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                        color: AppColors.textMuted,
                      ),
                ),
                const SizedBox(height: 32),
                AuthTextField(
                  controller: _weddingNameController,
                  label: 'Wedding Name',
                  hint: 'e.g., Sarah & John\'s Wedding',
                  validator: (value) {
                    if (value == null || value.isEmpty) {
                      return 'Please enter a wedding name';
                    }
                    return null;
                  },
                ),
                const SizedBox(height: 16),
                AuthTextField(
                  controller: _cityController,
                  label: 'City',
                  hint: 'e.g., Jaipur',
                  validator: (value) {
                    if (value == null || value.isEmpty) {
                      return 'Please enter a city';
                    }
                    return null;
                  },
                ),
                const SizedBox(height: 16),
                InkWell(
                  onTap: _selectDate,
                  child: InputDecorator(
                    decoration: InputDecoration(
                      labelText: 'Wedding Date',
                      hintText: 'Select date',
                      suffixIcon: const Icon(Icons.calendar_today),
                    ),
                    child: Text(
                      _weddingDate == null
                          ? 'Select date'
                          : '${_weddingDate!.day}/${_weddingDate!.month}/${_weddingDate!.year}',
                      style: TextStyle(
                        color: _weddingDate == null
                            ? AppColors.textMuted
                            : AppColors.textPrimary,
                      ),
                    ),
                  ),
                ),
                const SizedBox(height: 32),
                Consumer<WeddingProvider>(
                  builder: (context, weddingProvider, child) {
                    return AuthButton(
                      text: 'Complete Setup',
                      onPressed: weddingProvider.isLoading
                          ? null
                          : _completeSetup,
                      isLoading: weddingProvider.isLoading,
                    );
                  },
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}
