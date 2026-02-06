import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import '../providers/auth_provider.dart' as auth;
import '../providers/wedding_provider.dart';
import '../theme/app_theme.dart';
import '../utils/app_routes.dart';
import '../widgets/layout/app_card.dart';
import '../widgets/layout/mobile_scaffold.dart';

class ProfileScreen extends StatefulWidget {
  const ProfileScreen({super.key});

  @override
  State<ProfileScreen> createState() => _ProfileScreenState();
}

class _ProfileScreenState extends State<ProfileScreen> {
  final _weddingNameController = TextEditingController();
  final _cityController = TextEditingController();
  final _bookedController = TextEditingController();
  DateTime? _weddingDate;
  bool _didLoadWedding = false;

  Future<void> _selectDate() async {
    final picked = await showDatePicker(
      context: context,
      initialDate:
          _weddingDate ?? DateTime.now().add(const Duration(days: 180)),
      firstDate: DateTime.now().subtract(const Duration(days: 1)),
      lastDate: DateTime.now().add(const Duration(days: 365 * 5)),
    );
    if (picked != null) {
      setState(() {
        _weddingDate = picked;
      });
    }
  }

  void _syncWeddingFields(Map<String, dynamic> data) {
    if (_didLoadWedding) return;
    _didLoadWedding = true;
    _weddingNameController.text = (data['name'] ?? '').toString();
    _cityController.text = (data['city'] ?? '').toString();
    final booked = (data['bookedCount'] as num?)?.toInt() ?? 0;
    _bookedController.text = booked.toString();
    final date = data['weddingDate'];
    if (date is Timestamp) {
      _weddingDate = date.toDate();
    }
  }

  Future<void> _saveWeddingChanges() async {
    final weddingProvider = Provider.of<WeddingProvider>(
      context,
      listen: false,
    );
    if (!weddingProvider.hasWedding) return;

    final name = _weddingNameController.text.trim();
    final city = _cityController.text.trim();
    final booked = int.tryParse(_bookedController.text.trim());

    await weddingProvider.updateWedding(
      name: name.isEmpty ? null : name,
      city: city.isEmpty ? null : city,
      weddingDate: _weddingDate,
      bookedCount: booked,
    );

    if (mounted) {
      ScaffoldMessenger.of(
        context,
      ).showSnackBar(const SnackBar(content: Text('Profile updated')));
    }
  }

  Future<void> _handleSignOut() async {
    final confirmed = await showDialog<bool>(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Sign Out'),
        content: const Text('Are you sure you want to sign out?'),
        actions: [
          TextButton(
            onPressed: () => Navigator.of(context).pop(false),
            child: const Text('Cancel'),
          ),
          TextButton(
            onPressed: () => Navigator.of(context).pop(true),
            style: TextButton.styleFrom(foregroundColor: Colors.red),
            child: const Text('Sign Out'),
          ),
        ],
      ),
    );

    if (confirmed == true && mounted) {
      await Provider.of<auth.AuthProvider>(context, listen: false).signOut();
      if (mounted) {
        Navigator.of(
          context,
        ).pushNamedAndRemoveUntil(AppRoutes.welcome, (route) => false);
      }
    }
  }

  @override
  void dispose() {
    _weddingNameController.dispose();
    _cityController.dispose();
    _bookedController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final user = FirebaseAuth.instance.currentUser;

    return MobileScaffold(
      currentIndex: 0,
      showLogo: false,
      title: 'Profile',
      child: SingleChildScrollView(
        padding: const EdgeInsets.fromLTRB(16, 20, 16, 32),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            _ProfileHeader(user: user),
            const SizedBox(height: 16),
            _ProfileDetailsCard(user: user),
            const SizedBox(height: 16),
            Consumer<WeddingProvider>(
              builder: (context, weddingProvider, child) {
                final weddingData =
                    weddingProvider.currentWedding?.data()
                        as Map<String, dynamic>? ??
                    {};
                if (weddingData.isNotEmpty) {
                  _syncWeddingFields(weddingData);
                }
                return _WeddingDetailsCard(
                  isLoading: weddingProvider.isLoading,
                  weddingNameController: _weddingNameController,
                  cityController: _cityController,
                  bookedController: _bookedController,
                  weddingDate: _weddingDate,
                  onPickDate: _selectDate,
                  onSave: weddingProvider.isLoading
                      ? null
                      : _saveWeddingChanges,
                );
              },
            ),
            const SizedBox(height: 24),
            // Sign Out Button
            AppCard(
              child: Column(
                children: [
                  ListTile(
                    leading: Container(
                      padding: const EdgeInsets.all(8),
                      decoration: BoxDecoration(
                        color: Colors.red.withOpacity(0.1),
                        borderRadius: BorderRadius.circular(10),
                      ),
                      child: const Icon(
                        Icons.logout_rounded,
                        color: Colors.red,
                        size: 22,
                      ),
                    ),
                    title: const Text(
                      'Sign Out',
                      style: TextStyle(
                        fontWeight: FontWeight.w600,
                        color: Colors.red,
                      ),
                    ),
                    subtitle: const Text('Sign out of your account'),
                    trailing: const Icon(
                      Icons.chevron_right_rounded,
                      color: Colors.red,
                    ),
                    onTap: _handleSignOut,
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class _ProfileHeader extends StatelessWidget {
  const _ProfileHeader({required this.user});

  final User? user;

  @override
  Widget build(BuildContext context) {
    final displayName = user?.displayName ?? 'Wedding Planner';
    final initials = displayName.isNotEmpty
        ? displayName[0].toUpperCase()
        : 'W';

    return Container(
      padding: const EdgeInsets.all(24),
      decoration: BoxDecoration(
        gradient: AppColors.primaryGradient,
        borderRadius: BorderRadius.circular(24),
        boxShadow: [
          BoxShadow(
            color: AppColors.primary.withOpacity(0.3),
            blurRadius: 20,
            offset: const Offset(0, 10),
          ),
        ],
      ),
      child: Row(
        children: [
          Container(
            width: 64,
            height: 64,
            decoration: BoxDecoration(
              color: Colors.white.withOpacity(0.25),
              shape: BoxShape.circle,
              border: Border.all(
                color: Colors.white.withOpacity(0.5),
                width: 2,
              ),
            ),
            alignment: Alignment.center,
            child: Text(
              initials,
              style: const TextStyle(
                fontSize: 26,
                fontWeight: FontWeight.w700,
                color: Colors.white,
              ),
            ),
          ),
          const SizedBox(width: 18),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  displayName,
                  style: Theme.of(context).textTheme.titleLarge?.copyWith(
                    color: Colors.white,
                    fontWeight: FontWeight.w600,
                  ),
                ),
                const SizedBox(height: 6),
                Container(
                  padding: const EdgeInsets.symmetric(
                    horizontal: 10,
                    vertical: 4,
                  ),
                  decoration: BoxDecoration(
                    color: Colors.white.withOpacity(0.2),
                    borderRadius: BorderRadius.circular(20),
                  ),
                  child: Text(
                    user?.email ?? 'No email connected',
                    style: TextStyle(
                      fontSize: 12,
                      fontWeight: FontWeight.w500,
                      color: Colors.white.withOpacity(0.95),
                    ),
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}

class _ProfileDetailsCard extends StatelessWidget {
  const _ProfileDetailsCard({required this.user});

  final User? user;

  @override
  Widget build(BuildContext context) {
    if (user == null) {
      return const SizedBox.shrink();
    }

    return StreamBuilder<DocumentSnapshot<Map<String, dynamic>>>(
      stream: FirebaseFirestore.instance
          .collection('users')
          .doc(user!.uid)
          .snapshots(),
      builder: (context, snapshot) {
        final data = snapshot.data?.data() ?? {};
        final name = (data['name'] ?? user?.displayName ?? 'Wedding Planner')
            .toString();
        final email = (data['email'] ?? user?.email ?? '').toString();
        final role = (data['role'] ?? 'couple').toString();

        return AppCard(
          padding: const EdgeInsets.all(20),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Row(
                children: [
                  Container(
                    padding: const EdgeInsets.all(8),
                    decoration: BoxDecoration(
                      color: AppColors.primarySoft,
                      borderRadius: BorderRadius.circular(10),
                    ),
                    child: const Icon(
                      Icons.person_rounded,
                      size: 18,
                      color: AppColors.primary,
                    ),
                  ),
                  const SizedBox(width: 12),
                  Text(
                    'Profile Details',
                    style: Theme.of(context).textTheme.titleMedium,
                  ),
                ],
              ),
              const SizedBox(height: 20),
              _InfoRow(icon: Icons.badge_rounded, label: 'Name', value: name),
              const Divider(height: 24),
              _InfoRow(icon: Icons.email_rounded, label: 'Email', value: email),
              const Divider(height: 24),
              _InfoRow(icon: Icons.group_rounded, label: 'Role', value: role),
            ],
          ),
        );
      },
    );
  }
}

class _WeddingDetailsCard extends StatelessWidget {
  const _WeddingDetailsCard({
    required this.isLoading,
    required this.weddingNameController,
    required this.cityController,
    required this.bookedController,
    required this.weddingDate,
    required this.onPickDate,
    required this.onSave,
  });

  final bool isLoading;
  final TextEditingController weddingNameController;
  final TextEditingController cityController;
  final TextEditingController bookedController;
  final DateTime? weddingDate;
  final VoidCallback onPickDate;
  final VoidCallback? onSave;

  @override
  Widget build(BuildContext context) {
    return AppCard(
      padding: const EdgeInsets.all(20),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Row(
                children: [
                  Container(
                    padding: const EdgeInsets.all(8),
                    decoration: BoxDecoration(
                      gradient: AppColors.primaryGradient,
                      borderRadius: BorderRadius.circular(10),
                    ),
                    child: const Icon(
                      Icons.favorite_rounded,
                      size: 18,
                      color: Colors.white,
                    ),
                  ),
                  const SizedBox(width: 12),
                  Text(
                    'Wedding Details',
                    style: Theme.of(context).textTheme.titleMedium,
                  ),
                ],
              ),
              if (isLoading)
                const SizedBox(
                  width: 20,
                  height: 20,
                  child: CircularProgressIndicator(strokeWidth: 2),
                ),
            ],
          ),
          const SizedBox(height: 24),
          TextField(
            controller: weddingNameController,
            decoration: const InputDecoration(
              labelText: 'Wedding Name',
              prefixIcon: Icon(Icons.celebration_rounded, size: 20),
            ),
          ),
          const SizedBox(height: 16),
          TextField(
            controller: cityController,
            decoration: const InputDecoration(
              labelText: 'City',
              prefixIcon: Icon(Icons.location_city_rounded, size: 20),
            ),
          ),
          const SizedBox(height: 16),
          InkWell(
            onTap: onPickDate,
            borderRadius: BorderRadius.circular(14),
            child: InputDecorator(
              decoration: const InputDecoration(
                labelText: 'Wedding Date',
                prefixIcon: Icon(Icons.calendar_month_rounded, size: 20),
                suffixIcon: Icon(Icons.keyboard_arrow_down_rounded),
              ),
              child: Text(
                weddingDate == null
                    ? 'Select date'
                    : '${weddingDate!.day}/${weddingDate!.month}/${weddingDate!.year}',
                style: TextStyle(
                  color: weddingDate == null
                      ? AppColors.textMuted
                      : AppColors.textPrimary,
                  fontWeight: FontWeight.w500,
                ),
              ),
            ),
          ),
          const SizedBox(height: 16),
          TextField(
            controller: bookedController,
            keyboardType: TextInputType.number,
            decoration: const InputDecoration(
              labelText: 'Booked Vendors',
              prefixIcon: Icon(Icons.storefront_rounded, size: 20),
              hintText: '0',
            ),
          ),
          const SizedBox(height: 24),
          SizedBox(
            width: double.infinity,
            child: Container(
              decoration: BoxDecoration(
                gradient: AppColors.primaryGradient,
                borderRadius: BorderRadius.circular(14),
                boxShadow: [
                  BoxShadow(
                    color: AppColors.primary.withOpacity(0.25),
                    blurRadius: 10,
                    offset: const Offset(0, 4),
                  ),
                ],
              ),
              child: ElevatedButton.icon(
                onPressed: onSave,
                style: ElevatedButton.styleFrom(
                  backgroundColor: Colors.transparent,
                  shadowColor: Colors.transparent,
                  padding: const EdgeInsets.symmetric(vertical: 14),
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(14),
                  ),
                ),
                icon: const Icon(Icons.save_rounded, size: 20),
                label: const Text('Save Changes'),
              ),
            ),
          ),
        ],
      ),
    );
  }
}

class _InfoRow extends StatelessWidget {
  const _InfoRow({
    required this.icon,
    required this.label,
    required this.value,
  });

  final IconData icon;
  final String label;
  final String value;

  @override
  Widget build(BuildContext context) {
    return Row(
      children: [
        Icon(icon, size: 18, color: AppColors.textMuted),
        const SizedBox(width: 12),
        Expanded(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(label, style: Theme.of(context).textTheme.labelSmall),
              const SizedBox(height: 2),
              Text(value, style: Theme.of(context).textTheme.titleSmall),
            ],
          ),
        ),
      ],
    );
  }
}
