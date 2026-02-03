import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import '../theme/app_theme.dart';
import '../providers/vendor_provider.dart';
import '../providers/wedding_provider.dart';
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
    return MobileScaffold(
      currentIndex: 0,
      allowBack: false,
      child: SingleChildScrollView(
        padding: const EdgeInsets.fromLTRB(16, 20, 16, 24),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            AppCard(
              child: Column(
                children: [
                  Text(
                    'Your Wedding Journey',
                    style: Theme.of(context).textTheme.titleLarge,
                    textAlign: TextAlign.center,
                  ),
                  const SizedBox(height: 6),
                  Text(
                    'Plan your perfect day with ease',
                    style: Theme.of(context).textTheme.labelSmall,
                    textAlign: TextAlign.center,
                  ),
                  const SizedBox(height: 12),
                  Row(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      Text(
                        'Planning in',
                        style: Theme.of(context).textTheme.labelSmall,
                      ),
                      const SizedBox(width: 6),
                      CitySelector(
                        selectedCity: selectedCity,
                        onCityChange: (city) => setState(() => selectedCity = city),
                      ),
                    ],
                  ),
                ],
              ),
            ),
            const SizedBox(height: 16),
            LayoutBuilder(
              builder: (context, constraints) {
                final tileWidth =
                    (constraints.maxWidth - 8) / 2;
                return Wrap(
                  spacing: 8,
                  runSpacing: 8,
                  children: [
                    SizedBox(
                      width: tileWidth,
                      child: const _StatTile(label: 'Days', value: '120'),
                    ),
                    SizedBox(
                      width: tileWidth,
                      child: const _StatTile(label: 'Booked', value: '8'),
                    ),
                    SizedBox(
                      width: tileWidth,
                      child: const _StatTile(label: 'Budget', value: '65%'),
                    ),
                    SizedBox(
                      width: tileWidth,
                      child: const _StatTile(label: 'Tasks', value: '12'),
                    ),
                  ],
                );
              },
            ),
            const SizedBox(height: 20),
            Consumer<WeddingProvider>(
              builder: (context, weddingProvider, child) {
                if (weddingProvider.hasWedding &&
                    weddingProvider.members.isNotEmpty) {
                  return Column(
                    children: [
                      Card(
                        child: Padding(
                          padding: const EdgeInsets.all(16.0),
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Row(
                                mainAxisAlignment:
                                    MainAxisAlignment.spaceBetween,
                                children: [
                                  Text(
                                    'Team Members',
                                    style: Theme.of(context)
                                        .textTheme
                                        .titleMedium,
                                  ),
                                  InviteButton(
                                    onPressed: () {
                                      _showInviteDialog(
                                          context, weddingProvider);
                                    },
                                  ),
                                ],
                              ),
                              const SizedBox(height: 12),
                              Wrap(
                                spacing: 8,
                                runSpacing: 8,
                                children: weddingProvider.members
                                    .map((member) {
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
      BuildContext context, WeddingProvider weddingProvider) {
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
                ),
                keyboardType: TextInputType.emailAddress,
              ),
              const SizedBox(height: 16),
              const Text('Role'),
              const SizedBox(height: 8),
              SegmentedButton<String>(
                segments: const [
                  ButtonSegment(value: 'editor', label: Text('Editor')),
                  ButtonSegment(value: 'viewer', label: Text('Viewer')),
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
  const _StatTile({required this.label, required this.value});

  final String label;
  final String value;

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(vertical: 12),
      decoration: BoxDecoration(
        color: AppColors.surface,
        borderRadius: BorderRadius.circular(14),
        border: Border.all(color: AppColors.border),
      ),
      child: Column(
        children: [
          Text(
            value,
            style: const TextStyle(
              fontSize: 18,
              fontWeight: FontWeight.w700,
              color: AppColors.primary,
            ),
          ),
          const SizedBox(height: 4),
          Text(
            label,
            style: const TextStyle(fontSize: 10, color: AppColors.textMuted),
          ),
        ],
      ),
    );
  }
}
