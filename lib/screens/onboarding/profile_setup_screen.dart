import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import '../../models/app_role.dart';
import '../../providers/auth_provider.dart';
import '../../providers/wedding_provider.dart';
import '../../theme/app_theme.dart';
import '../../utils/app_routes.dart';
import '../../widgets/auth/auth_button.dart';
import '../../widgets/auth/auth_text_field.dart';

class ProfileSetupScreen extends StatefulWidget {
  const ProfileSetupScreen({super.key});

  @override
  State<ProfileSetupScreen> createState() => _ProfileSetupScreenState();
}

class _ProfileSetupScreenState extends State<ProfileSetupScreen> {
  final _formKey = GlobalKey<FormState>();
  final _weddingNameController = TextEditingController();
  final _cityController = TextEditingController();
  final _clientNameController = TextEditingController();
  final _clientEmailController = TextEditingController();
  DateTime? _weddingDate;

  Future<void> _selectDate() async {
    final picked = await showDatePicker(
      context: context,
      initialDate: DateTime.now().add(const Duration(days: 180)),
      firstDate: DateTime.now(),
      lastDate: DateTime.now().add(const Duration(days: 365 * 2)),
    );
    if (picked != null) {
      setState(() => _weddingDate = picked);
    }
  }

  Future<void> _completePlannerSetup() async {
    if (!_formKey.currentState!.validate()) return;
    if (_weddingDate == null) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Please select a wedding date')),
      );
      return;
    }

    final authProvider = context.read<AuthProvider>();
    final weddingProvider = context.read<WeddingProvider>();

    try {
      await weddingProvider.createWedding(
        name: _weddingNameController.text.trim(),
        city: _cityController.text.trim(),
        weddingDate: _weddingDate!,
        plannerName:
            (authProvider.profile?['name'] ??
                    authProvider.user?.displayName ??
                    '')
                .toString(),
        clientName: _clientNameController.text.trim().isEmpty
            ? null
            : _clientNameController.text.trim(),
        clientEmail: _clientEmailController.text.trim().isEmpty
            ? null
            : _clientEmailController.text.trim().toLowerCase(),
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
        ScaffoldMessenger.of(
          context,
        ).showSnackBar(SnackBar(content: Text('Error: ${e.toString()}')));
      }
    }
  }

  Future<void> _refreshClientAssignment() async {
    final authProvider = context.read<AuthProvider>();
    final completed = await authProvider.checkOnboardingStatus();
    if (!mounted) return;

    if (completed) {
      Navigator.pushNamedAndRemoveUntil(
        context,
        AppRoutes.home,
        (route) => false,
      );
      return;
    }

    ScaffoldMessenger.of(context).showSnackBar(
      const SnackBar(
        content: Text(
          'No planner assignment found yet. Ask your planner to invite this email.',
        ),
      ),
    );
  }

  @override
  void dispose() {
    _weddingNameController.dispose();
    _cityController.dispose();
    _clientNameController.dispose();
    _clientEmailController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final authProvider = context.watch<AuthProvider>();
    final role = authProvider.appRole;

    return Scaffold(
      backgroundColor: AppColors.background,
      appBar: AppBar(
        title: Text(
          role == AppRole.weddingPlanner
              ? 'Create Client Workspace'
              : 'Await Planner Assignment',
        ),
      ),
      body: SafeArea(
        child: SingleChildScrollView(
          padding: const EdgeInsets.all(24),
          child: role == AppRole.weddingPlanner
              ? _PlannerSetupForm(
                  formKey: _formKey,
                  weddingNameController: _weddingNameController,
                  cityController: _cityController,
                  clientNameController: _clientNameController,
                  clientEmailController: _clientEmailController,
                  weddingDate: _weddingDate,
                  onPickDate: _selectDate,
                  onSubmit: _completePlannerSetup,
                )
              : _ClientWaitingView(
                  email: authProvider.user?.email ?? '',
                  onRefresh: _refreshClientAssignment,
                  isLoading: authProvider.isLoading,
                ),
        ),
      ),
    );
  }
}

class _PlannerSetupForm extends StatelessWidget {
  const _PlannerSetupForm({
    required this.formKey,
    required this.weddingNameController,
    required this.cityController,
    required this.clientNameController,
    required this.clientEmailController,
    required this.weddingDate,
    required this.onPickDate,
    required this.onSubmit,
  });

  final GlobalKey<FormState> formKey;
  final TextEditingController weddingNameController;
  final TextEditingController cityController;
  final TextEditingController clientNameController;
  final TextEditingController clientEmailController;
  final DateTime? weddingDate;
  final VoidCallback onPickDate;
  final VoidCallback onSubmit;

  @override
  Widget build(BuildContext context) {
    return Form(
      key: formKey,
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          Container(
            padding: const EdgeInsets.all(20),
            decoration: BoxDecoration(
              gradient: AppColors.primaryGradient,
              borderRadius: BorderRadius.circular(24),
            ),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  'Design a wedding planning space',
                  style: Theme.of(
                    context,
                  ).textTheme.headlineSmall?.copyWith(color: Colors.white),
                ),
                const SizedBox(height: 8),
                Text(
                  'Create one shared workspace for your client. Budget plans, checklist progress, and wedding details will stay synced for both planner and client.',
                  style: Theme.of(
                    context,
                  ).textTheme.bodyMedium?.copyWith(color: Colors.white),
                ),
              ],
            ),
          ),
          const SizedBox(height: 24),
          AuthTextField(
            controller: weddingNameController,
            label: 'Wedding Workspace Name',
            hint: 'e.g., Aditi & Rohan Wedding',
            validator: (value) {
              if (value == null || value.trim().isEmpty) {
                return 'Please enter a wedding workspace name';
              }
              return null;
            },
          ),
          const SizedBox(height: 16),
          AuthTextField(
            controller: cityController,
            label: 'Wedding City',
            hint: 'e.g., Jaipur',
            validator: (value) {
              if (value == null || value.trim().isEmpty) {
                return 'Please enter a wedding city';
              }
              return null;
            },
          ),
          const SizedBox(height: 16),
          InkWell(
            onTap: onPickDate,
            child: InputDecorator(
              decoration: const InputDecoration(
                labelText: 'Wedding Date',
                suffixIcon: Icon(Icons.calendar_today_rounded),
              ),
              child: Text(
                weddingDate == null
                    ? 'Select wedding date'
                    : '${weddingDate!.day}/${weddingDate!.month}/${weddingDate!.year}',
                style: TextStyle(
                  color: weddingDate == null
                      ? AppColors.textMuted
                      : AppColors.textPrimary,
                ),
              ),
            ),
          ),
          const SizedBox(height: 24),
          Text('Assign Client', style: Theme.of(context).textTheme.titleMedium),
          const SizedBox(height: 8),
          Text(
            'Use the client email they will sign in with. They will be able to view the dashboard as soon as they accept or sign in with that invitation.',
            style: Theme.of(
              context,
            ).textTheme.bodyMedium?.copyWith(color: AppColors.textMuted),
          ),
          const SizedBox(height: 16),
          AuthTextField(
            controller: clientNameController,
            label: 'Client Name',
            hint: 'e.g., Aditi Sharma',
          ),
          const SizedBox(height: 16),
          AuthTextField(
            controller: clientEmailController,
            label: 'Client Email',
            hint: 'client@email.com',
            keyboardType: TextInputType.emailAddress,
            validator: (value) {
              if (value == null || value.trim().isEmpty) {
                return 'Please enter a client email';
              }
              if (!value.contains('@')) {
                return 'Please enter a valid client email';
              }
              return null;
            },
          ),
          const SizedBox(height: 32),
          Consumer<WeddingProvider>(
            builder: (context, weddingProvider, child) {
              return AuthButton(
                text: 'Create Planner Workspace',
                onPressed: weddingProvider.isLoading ? null : onSubmit,
                isLoading: weddingProvider.isLoading,
              );
            },
          ),
        ],
      ),
    );
  }
}

class _ClientWaitingView extends StatelessWidget {
  const _ClientWaitingView({
    required this.email,
    required this.onRefresh,
    required this.isLoading,
  });

  final String email;
  final VoidCallback onRefresh;
  final bool isLoading;

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: [
        Container(
          padding: const EdgeInsets.all(22),
          decoration: BoxDecoration(
            gradient: AppColors.primaryGradient,
            borderRadius: BorderRadius.circular(24),
          ),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                'Your planner will unlock this workspace',
                style: Theme.of(
                  context,
                ).textTheme.headlineSmall?.copyWith(color: Colors.white),
              ),
              const SizedBox(height: 10),
              Text(
                'Share this email with your wedding planner so they can attach you to the right wedding dashboard.',
                style: Theme.of(
                  context,
                ).textTheme.bodyMedium?.copyWith(color: Colors.white),
              ),
            ],
          ),
        ),
        const SizedBox(height: 24),
        Container(
          padding: const EdgeInsets.all(18),
          decoration: BoxDecoration(
            color: AppColors.surface,
            borderRadius: BorderRadius.circular(20),
            border: Border.all(color: AppColors.border),
          ),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                'Assigned Client Email',
                style: Theme.of(context).textTheme.labelLarge,
              ),
              const SizedBox(height: 8),
              SelectableText(
                email,
                style: Theme.of(context).textTheme.titleMedium,
              ),
              const SizedBox(height: 12),
              Text(
                'Once your planner invites this email, your dashboard will automatically connect to the shared wedding workspace.',
                style: Theme.of(
                  context,
                ).textTheme.bodyMedium?.copyWith(color: AppColors.textMuted),
              ),
            ],
          ),
        ),
        const SizedBox(height: 24),
        AuthButton(
          text: 'Check Assignment',
          onPressed: isLoading ? null : onRefresh,
          isLoading: isLoading,
        ),
      ],
    );
  }
}
