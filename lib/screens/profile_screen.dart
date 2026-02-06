import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import '../providers/wedding_provider.dart';
import '../theme/app_theme.dart';
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
      initialDate: _weddingDate ?? DateTime.now().add(const Duration(days: 180)),
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
    final weddingProvider = Provider.of<WeddingProvider>(context, listen: false);
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
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Profile updated')),
      );
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
                final weddingData = weddingProvider.currentWedding?.data()
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
                  onSave: weddingProvider.isLoading ? null : _saveWeddingChanges,
                );
              },
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
    final initials = displayName.isNotEmpty ? displayName[0].toUpperCase() : 'W';

    return AppCard(
      padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 18),
      child: Row(
        children: [
          Container(
            width: 52,
            height: 52,
            decoration: BoxDecoration(
              shape: BoxShape.circle,
              color: AppColors.primarySoft,
              border: Border.all(color: AppColors.primary, width: 2),
            ),
            alignment: Alignment.center,
            child: Text(
              initials,
              style: const TextStyle(
                fontSize: 20,
                fontWeight: FontWeight.w700,
                color: AppColors.primary,
              ),
            ),
          ),
          const SizedBox(width: 14),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  displayName,
                  style: Theme.of(context).textTheme.titleMedium,
                ),
                const SizedBox(height: 4),
                Text(
                  user?.email ?? 'No email connected',
                  style: Theme.of(context)
                      .textTheme
                      .labelSmall
                      ?.copyWith(color: AppColors.textMuted),
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
          padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 18),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                'Profile Details',
                style: Theme.of(context).textTheme.titleMedium,
              ),
              const SizedBox(height: 12),
              _InfoRow(label: 'Name', value: name),
              const SizedBox(height: 8),
              _InfoRow(label: 'Email', value: email),
              const SizedBox(height: 8),
              _InfoRow(label: 'Role', value: role),
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
      padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 18),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Text(
                'Wedding Details',
                style: Theme.of(context).textTheme.titleMedium,
              ),
              if (isLoading)
                const SizedBox(
                  width: 18,
                  height: 18,
                  child: CircularProgressIndicator(strokeWidth: 2),
                ),
            ],
          ),
          const SizedBox(height: 16),
          TextField(
            controller: weddingNameController,
            decoration: const InputDecoration(
              labelText: 'Wedding Name',
            ),
          ),
          const SizedBox(height: 12),
          TextField(
            controller: cityController,
            decoration: const InputDecoration(
              labelText: 'City',
            ),
          ),
          const SizedBox(height: 12),
          InkWell(
            onTap: onPickDate,
            child: InputDecorator(
              decoration: const InputDecoration(
                labelText: 'Wedding Date',
                suffixIcon: Icon(Icons.calendar_today),
              ),
              child: Text(
                weddingDate == null
                    ? 'Select date'
                    : '${weddingDate!.day}/${weddingDate!.month}/${weddingDate!.year}',
                style: TextStyle(
                  color: weddingDate == null
                      ? AppColors.textMuted
                      : AppColors.textPrimary,
                ),
              ),
            ),
          ),
          const SizedBox(height: 12),
          TextField(
            controller: bookedController,
            keyboardType: TextInputType.number,
            decoration: const InputDecoration(
              labelText: 'Booked Vendors',
              hintText: '0',
            ),
          ),
          const SizedBox(height: 20),
          SizedBox(
            width: double.infinity,
            child: ElevatedButton(
              onPressed: onSave,
              child: const Text('Save Changes'),
            ),
          ),
        ],
      ),
    );
  }
}

class _InfoRow extends StatelessWidget {
  const _InfoRow({required this.label, required this.value});

  final String label;
  final String value;

  @override
  Widget build(BuildContext context) {
    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceBetween,
      children: [
        Text(
          label,
          style: Theme.of(context)
              .textTheme
              .labelSmall
              ?.copyWith(color: AppColors.textMuted),
        ),
        Flexible(
          child: Text(
            value,
            textAlign: TextAlign.right,
            style: const TextStyle(fontWeight: FontWeight.w600),
          ),
        ),
      ],
    );
  }
}
