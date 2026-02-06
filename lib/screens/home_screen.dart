import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import '../theme/app_theme.dart';
import '../providers/budget_provider.dart';
import '../providers/checklist_provider.dart';
import '../providers/vendor_provider.dart';
import '../providers/wedding_provider.dart';
import '../utils/app_routes.dart';
import '../widgets/dashboard/budget_overview.dart';
import '../widgets/dashboard/checklist_preview.dart';
import '../widgets/dashboard/city_selector.dart';
import '../widgets/dashboard/vendor_preview.dart';
import '../widgets/layout/mobile_scaffold.dart';
import '../widgets/layout/app_card.dart';
import '../widgets/collaboration/member_chip.dart';
import '../widgets/collaboration/invite_button.dart';

class HomeScreen extends StatefulWidget {
  const HomeScreen({super.key});

  @override
  State<HomeScreen> createState() => _HomeScreenState();
}

class _HomeScreenState extends State<HomeScreen> {
  String selectedCity = 'Jaipur';

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      if (!mounted) return;
      Provider.of<VendorProvider>(context, listen: false).loadIfNeeded();
    });
  }

  @override
  Widget build(BuildContext context) {
    final weddingProvider = context.watch<WeddingProvider>();
    final budgetProvider = context.watch<BudgetProvider>();
    final checklistProvider = context.watch<ChecklistProvider>();

    final weddingData =
        weddingProvider.currentWedding?.data() as Map<String, dynamic>? ?? {};
    final weddingTimestamp = weddingData['weddingDate'] as Timestamp?;
    final weddingDate = weddingTimestamp?.toDate();
    final now = DateTime.now();
    final daysRemaining = weddingDate == null
        ? 0
        : weddingDate
              .difference(DateTime(now.year, now.month, now.day))
              .inDays
              .clamp(0, 99999)
              .toInt();

    final totalAllocated = budgetProvider.totalAllocated;
    final totalSpent = budgetProvider.totalSpent;
    final budgetPercent = totalAllocated == 0
        ? 0
        : ((totalSpent / totalAllocated) * 100).round();

    final bookedCount = (weddingData['bookedCount'] as num?)?.toInt() ?? 0;
    final completedTasks = checklistProvider.tasks
        .where((t) => t.completed)
        .length;
    final totalTasks = checklistProvider.tasks.length;

    return MobileScaffold(
      currentIndex: 0,
      allowBack: false,
      actions: [
        IconButton(
          onPressed: () => Navigator.of(context).pushNamed(AppRoutes.profile),
          icon: Container(
            padding: const EdgeInsets.all(8),
            decoration: BoxDecoration(
              color: AppColors.primarySoft,
              borderRadius: BorderRadius.circular(10),
            ),
            child: const Icon(
              Icons.person_rounded,
              color: AppColors.primary,
              size: 20,
            ),
          ),
          tooltip: 'Profile',
        ),
      ],
      child: SingleChildScrollView(
        padding: const EdgeInsets.fromLTRB(16, 16, 16, 24),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            // Hero Card
            Container(
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
              child: Column(
                children: [
                  const Icon(
                    Icons.favorite_rounded,
                    color: Colors.white,
                    size: 32,
                  ),
                  const SizedBox(height: 12),
                  Text(
                    'Your Wedding Journey',
                    style: Theme.of(context).textTheme.titleLarge?.copyWith(
                      color: Colors.white,
                      fontWeight: FontWeight.w600,
                    ),
                    textAlign: TextAlign.center,
                  ),
                  const SizedBox(height: 6),
                  Text(
                    'Plan your perfect day with ease',
                    style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                      color: Colors.white.withOpacity(0.9),
                    ),
                    textAlign: TextAlign.center,
                  ),
                  const SizedBox(height: 16),
                  Container(
                    padding: const EdgeInsets.symmetric(
                      horizontal: 16,
                      vertical: 10,
                    ),
                    decoration: BoxDecoration(
                      color: Colors.white.withOpacity(0.2),
                      borderRadius: BorderRadius.circular(30),
                    ),
                    child: Row(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        const Icon(
                          Icons.location_on_rounded,
                          color: Colors.white,
                          size: 16,
                        ),
                        const SizedBox(width: 6),
                        Text(
                          'Planning in',
                          style: Theme.of(context).textTheme.labelSmall
                              ?.copyWith(color: Colors.white.withOpacity(0.9)),
                        ),
                        const SizedBox(width: 8),
                        CitySelector(
                          selectedCity: selectedCity,
                          onCityChange: (city) =>
                              setState(() => selectedCity = city),
                          isLight: true,
                        ),
                      ],
                    ),
                  ),
                ],
              ),
            ),
            const SizedBox(height: 20),
            // Stat tiles grid
            LayoutBuilder(
              builder: (context, constraints) {
                final tileWidth = (constraints.maxWidth - 12) / 2;
                return Wrap(
                  spacing: 12,
                  runSpacing: 12,
                  children: [
                    SizedBox(
                      width: tileWidth,
                      child: _StatTile(
                        label: 'Days Left',
                        value: daysRemaining.toString(),
                        icon: Icons.calendar_today_rounded,
                        color: AppColors.primary,
                      ),
                    ),
                    SizedBox(
                      width: tileWidth,
                      child: _StatTile(
                        label: 'Vendors Booked',
                        value: bookedCount.toString(),
                        icon: Icons.storefront_rounded,
                        color: AppColors.accent,
                      ),
                    ),
                    SizedBox(
                      width: tileWidth,
                      child: _StatTile(
                        label: 'Budget Used',
                        value: '$budgetPercent%',
                        icon: Icons.account_balance_wallet_rounded,
                        color: AppColors.accentGold,
                      ),
                    ),
                    SizedBox(
                      width: tileWidth,
                      child: _StatTile(
                        label: 'Tasks Done',
                        value: '$completedTasks/$totalTasks',
                        icon: Icons.check_circle_rounded,
                        color: AppColors.success,
                      ),
                    ),
                  ],
                );
              },
            ),
            const SizedBox(height: 20),
            // Team members section
            Consumer<WeddingProvider>(
              builder: (context, weddingProvider, child) {
                if (weddingProvider.hasWedding &&
                    weddingProvider.members.isNotEmpty) {
                  return Column(
                    children: [
                      AppCard(
                        padding: const EdgeInsets.all(18),
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
                                        color: AppColors.primarySoft,
                                        borderRadius: BorderRadius.circular(10),
                                      ),
                                      child: const Icon(
                                        Icons.people_rounded,
                                        size: 18,
                                        color: AppColors.primary,
                                      ),
                                    ),
                                    const SizedBox(width: 12),
                                    Text(
                                      'Team Members',
                                      style: Theme.of(
                                        context,
                                      ).textTheme.titleMedium,
                                    ),
                                  ],
                                ),
                                InviteButton(
                                  onPressed: () {
                                    _showInviteDialog(context, weddingProvider);
                                  },
                                ),
                              ],
                            ),
                            const SizedBox(height: 16),
                            Wrap(
                              spacing: 8,
                              runSpacing: 8,
                              children: weddingProvider.members.map((member) {
                                return MemberChip(
                                  name: member['name'] ?? 'Unknown',
                                  role: member['role'] ?? 'viewer',
                                  isOwner: member['role'] == 'owner',
                                );
                              }).toList(),
                            ),
                          ],
                        ),
                      ),
                      const SizedBox(height: 16),
                    ],
                  );
                }
                return const SizedBox.shrink();
              },
            ),
            const BudgetOverview(),
            const SizedBox(height: 16),
            const ChecklistPreview(),
            const SizedBox(height: 16),
            const VendorPreview(),
          ],
        ),
      ),
    );
  }

  void _showInviteDialog(
    BuildContext context,
    WeddingProvider weddingProvider,
  ) {
    final emailController = TextEditingController();
    String selectedRole = 'editor';

    showDialog(
      context: context,
      builder: (context) => StatefulBuilder(
        builder: (context, setState) => AlertDialog(
          title: const Text('Invite Family Member'),
          content: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              TextField(
                controller: emailController,
                decoration: const InputDecoration(
                  labelText: 'Email',
                  hintText: 'family@example.com',
                  prefixIcon: Icon(Icons.email_outlined),
                ),
                keyboardType: TextInputType.emailAddress,
              ),
              const SizedBox(height: 20),
              Text('Role', style: Theme.of(context).textTheme.labelMedium),
              const SizedBox(height: 10),
              SegmentedButton<String>(
                segments: const [
                  ButtonSegment(
                    value: 'editor',
                    label: Text('Editor'),
                    icon: Icon(Icons.edit_rounded, size: 16),
                  ),
                  ButtonSegment(
                    value: 'viewer',
                    label: Text('Viewer'),
                    icon: Icon(Icons.visibility_rounded, size: 16),
                  ),
                ],
                selected: {selectedRole},
                onSelectionChanged: (Set<String> newSelection) {
                  setState(() {
                    selectedRole = newSelection.first;
                  });
                },
              ),
            ],
          ),
          actions: [
            TextButton(
              onPressed: () => Navigator.pop(context),
              child: const Text('Cancel'),
            ),
            ElevatedButton(
              onPressed: () async {
                if (emailController.text.trim().isEmpty) {
                  ScaffoldMessenger.of(context).showSnackBar(
                    const SnackBar(content: Text('Please enter an email')),
                  );
                  return;
                }
                await weddingProvider.inviteMember(
                  email: emailController.text.trim(),
                  role: selectedRole,
                );
                if (context.mounted) {
                  Navigator.pop(context);
                  ScaffoldMessenger.of(context).showSnackBar(
                    const SnackBar(content: Text('Invitation sent!')),
                  );
                }
              },
              child: const Text('Send Invite'),
            ),
          ],
        ),
      ),
    );
  }
}

class _StatTile extends StatelessWidget {
  const _StatTile({
    required this.label,
    required this.value,
    required this.icon,
    required this.color,
  });

  final String label;
  final String value;
  final IconData icon;
  final Color color;

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: AppColors.surface,
        borderRadius: BorderRadius.circular(18),
        border: Border.all(color: AppColors.border.withOpacity(0.5)),
        boxShadow: [
          BoxShadow(
            color: color.withOpacity(0.08),
            blurRadius: 12,
            offset: const Offset(0, 4),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Container(
            padding: const EdgeInsets.all(8),
            decoration: BoxDecoration(
              color: color.withOpacity(0.12),
              borderRadius: BorderRadius.circular(10),
            ),
            child: Icon(icon, size: 18, color: color),
          ),
          const SizedBox(height: 12),
          Text(
            value,
            style: Theme.of(context).textTheme.headlineSmall?.copyWith(
              fontWeight: FontWeight.w700,
              color: AppColors.textPrimary,
            ),
          ),
          const SizedBox(height: 4),
          Text(label, style: Theme.of(context).textTheme.labelSmall),
        ],
      ),
    );
  }
}
