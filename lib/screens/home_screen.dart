import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import '../models/app_role.dart';
import '../providers/auth_provider.dart';
import '../providers/budget_provider.dart';
import '../providers/checklist_provider.dart';
import '../providers/vendor_provider.dart';
import '../providers/wedding_provider.dart';
import '../theme/app_theme.dart';
import '../utils/app_routes.dart';
import '../widgets/collaboration/invite_button.dart';
import '../widgets/collaboration/member_chip.dart';
import '../widgets/dashboard/budget_overview.dart';
import '../widgets/dashboard/checklist_preview.dart';
import '../widgets/dashboard/city_selector.dart';
import '../widgets/dashboard/vendor_preview.dart';
import '../widgets/layout/app_card.dart';
import '../widgets/layout/mobile_scaffold.dart';

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
      context.read<VendorProvider>().loadIfNeeded();
    });
  }

  @override
  Widget build(BuildContext context) {
    final authProvider = context.watch<AuthProvider>();
    final weddingProvider = context.watch<WeddingProvider>();
    final budgetProvider = context.watch<BudgetProvider>();
    final checklistProvider = context.watch<ChecklistProvider>();

    final weddingData = weddingProvider.currentWedding?.data() ?? {};
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
    final role = authProvider.appRole;
    final workspaceName = (weddingData['name'] ?? 'Wedding Workspace')
        .toString();
    final clientName = (weddingData['clientName'] ?? 'Your client').toString();
    final plannerName =
        (weddingData['plannerName'] ??
                authProvider.user?.displayName ??
                'Planner')
            .toString();

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
              borderRadius: BorderRadius.circular(12),
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
            _RoleHeroCard(
              role: role,
              workspaceName: workspaceName,
              clientName: clientName,
              plannerName: plannerName,
              selectedCity: selectedCity,
              onCityChange: (city) => setState(() => selectedCity = city),
            ),
            if (role == AppRole.weddingPlanner) ...[
              const SizedBox(height: 16),
              _PlannerWorkspaceManager(
                weddingProvider: weddingProvider,
                onCreateWorkspace: () => _showCreateWorkspaceDialog(context),
              ),
            ] else if (weddingProvider.workspaces.length > 1) ...[
              const SizedBox(height: 16),
              AppCard(
                padding: const EdgeInsets.all(18),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      'Switch Wedding Workspace',
                      style: Theme.of(context).textTheme.titleMedium,
                    ),
                    const SizedBox(height: 12),
                    DropdownButtonFormField<String>(
                      initialValue: weddingProvider.activeWeddingId,
                      items: weddingProvider.workspaces.map((workspace) {
                        return DropdownMenuItem<String>(
                          value: workspace.id,
                          child: Text(
                            weddingProvider.workspaceLabel(workspace),
                          ),
                        );
                      }).toList(),
                      onChanged: (value) {
                        if (value == null) return;
                        weddingProvider.switchWedding(value);
                      },
                      decoration: const InputDecoration(
                        labelText: 'Active workspace',
                        prefixIcon: Icon(Icons.swap_horiz_rounded),
                      ),
                    ),
                  ],
                ),
              ),
            ],
            const SizedBox(height: 18),
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
                        label: 'Days To Wedding',
                        value: daysRemaining.toString(),
                        icon: Icons.calendar_month_rounded,
                        color: AppColors.primary,
                      ),
                    ),
                    SizedBox(
                      width: tileWidth,
                      child: _StatTile(
                        label: role == AppRole.weddingPlanner
                            ? 'Clients View'
                            : 'Planner Updates',
                        value: role == AppRole.weddingPlanner
                            ? clientName
                            : plannerName,
                        icon: Icons.group_rounded,
                        color: AppColors.accent,
                      ),
                    ),
                    SizedBox(
                      width: tileWidth,
                      child: _StatTile(
                        label: 'Budget Used',
                        value: '$budgetPercent%',
                        icon: Icons.account_balance_wallet_rounded,
                        color: AppColors.vermillion,
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
            const SizedBox(height: 18),
            AppCard(
              padding: const EdgeInsets.all(18),
              child: Row(
                children: [
                  Container(
                    padding: const EdgeInsets.all(10),
                    decoration: BoxDecoration(
                      gradient: AppColors.accentGradient,
                      borderRadius: BorderRadius.circular(12),
                    ),
                    child: const Icon(
                      Icons.storefront_rounded,
                      color: Colors.white,
                    ),
                  ),
                  const SizedBox(width: 12),
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          role == AppRole.weddingPlanner
                              ? 'Planner workspace is live for $clientName'
                              : 'Your planner is managing this wedding workspace',
                          style: Theme.of(context).textTheme.titleSmall,
                        ),
                        const SizedBox(height: 4),
                        Text(
                          '$bookedCount vendors booked across the current plan.',
                          style: Theme.of(context).textTheme.bodyMedium,
                        ),
                      ],
                    ),
                  ),
                ],
              ),
            ),
            if (role == AppRole.weddingPlanner) ...[
              const SizedBox(height: 16),
              AppCard(
                padding: const EdgeInsets.all(18),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Row(
                      children: [
                        Container(
                          padding: const EdgeInsets.all(10),
                          decoration: BoxDecoration(
                            color: AppColors.primarySoft,
                            borderRadius: BorderRadius.circular(12),
                          ),
                          child: const Icon(
                            Icons.mark_email_unread_rounded,
                            color: AppColors.primary,
                          ),
                        ),
                        const SizedBox(width: 12),
                        Expanded(
                          child: Text(
                            'Client Access Request',
                            style: Theme.of(context).textTheme.titleSmall,
                          ),
                        ),
                        TextButton(
                          onPressed: () => _showClientInviteDialog(
                            context,
                            weddingProvider,
                            initialName: weddingData['clientName']?.toString(),
                            initialEmail: weddingData['clientEmail']
                                ?.toString(),
                          ),
                          child: const Text('Send Request'),
                        ),
                      ],
                    ),
                    const SizedBox(height: 12),
                    Text(
                      (weddingData['clientEmail'] as String?)?.isNotEmpty ==
                              true
                          ? 'Active client: ${weddingData['clientName'] ?? 'Client'} • ${weddingData['clientEmail']}'
                          : 'No client email assigned yet for this workspace.',
                      style: Theme.of(context).textTheme.bodyMedium,
                    ),
                    const SizedBox(height: 6),
                    Text(
                      'Status: ${(weddingData['clientInviteStatus'] ?? 'draft').toString()}',
                      style: Theme.of(context).textTheme.labelMedium,
                    ),
                  ],
                ),
              ),
            ],
            const SizedBox(height: 16),
            if (weddingProvider.hasWedding &&
                weddingProvider.members.isNotEmpty)
              Column(
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
                                    Icons.people_alt_rounded,
                                    size: 18,
                                    color: AppColors.primary,
                                  ),
                                ),
                                const SizedBox(width: 12),
                                Text(
                                  role == AppRole.weddingPlanner
                                      ? 'Assigned Access'
                                      : 'Wedding Team',
                                  style: Theme.of(
                                    context,
                                  ).textTheme.titleMedium,
                                ),
                              ],
                            ),
                            if (role == AppRole.weddingPlanner)
                              InviteButton(
                                onPressed: () =>
                                    _showInviteDialog(context, weddingProvider),
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
                              isOwner: member['role'] == 'planner',
                            );
                          }).toList(),
                        ),
                      ],
                    ),
                  ),
                  const SizedBox(height: 16),
                ],
              ),
            BudgetOverview(canEdit: role == AppRole.weddingPlanner),
            const SizedBox(height: 16),
            ChecklistPreview(canEdit: role == AppRole.weddingPlanner),
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
    String selectedRole = 'viewer';

    showDialog(
      context: context,
      builder: (context) => StatefulBuilder(
        builder: (context, setState) => AlertDialog(
          title: const Text('Invite Collaborator'),
          content: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              TextField(
                controller: emailController,
                decoration: const InputDecoration(
                  labelText: 'Email',
                  hintText: 'guest@email.com',
                  prefixIcon: Icon(Icons.email_outlined),
                ),
                keyboardType: TextInputType.emailAddress,
              ),
              const SizedBox(height: 20),
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
                onSelectionChanged: (selection) {
                  setState(() => selectedRole = selection.first);
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
                if (emailController.text.trim().isEmpty) return;
                await weddingProvider.inviteMember(
                  email: emailController.text.trim().toLowerCase(),
                  role: selectedRole,
                );
                if (context.mounted) {
                  Navigator.pop(context);
                  ScaffoldMessenger.of(context).showSnackBar(
                    const SnackBar(content: Text('Invitation sent')),
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

  void _showClientInviteDialog(
    BuildContext context,
    WeddingProvider weddingProvider, {
    String? initialName,
    String? initialEmail,
  }) {
    final nameController = TextEditingController(text: initialName ?? '');
    final emailController = TextEditingController(text: initialEmail ?? '');

    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Send Client Access'),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            TextField(
              controller: nameController,
              decoration: const InputDecoration(
                labelText: 'Client name',
                prefixIcon: Icon(Icons.person_outline_rounded),
              ),
            ),
            const SizedBox(height: 16),
            TextField(
              controller: emailController,
              keyboardType: TextInputType.emailAddress,
              decoration: const InputDecoration(
                labelText: 'Client email',
                prefixIcon: Icon(Icons.email_outlined),
              ),
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
              final email = emailController.text.trim().toLowerCase();
              if (email.isEmpty || !email.contains('@')) return;

              await weddingProvider.inviteClient(
                clientEmail: email,
                clientName: nameController.text.trim().isEmpty
                    ? null
                    : nameController.text.trim(),
              );

              if (context.mounted) {
                Navigator.pop(context);
                ScaffoldMessenger.of(context).showSnackBar(
                  const SnackBar(content: Text('Client request sent')),
                );
              }
            },
            child: const Text('Send'),
          ),
        ],
      ),
    );
  }

  void _showCreateWorkspaceDialog(BuildContext context) {
    final weddingNameController = TextEditingController();
    final cityController = TextEditingController(text: selectedCity);
    final clientNameController = TextEditingController();
    final clientEmailController = TextEditingController();
    DateTime? weddingDate = DateTime.now().add(const Duration(days: 180));

    showDialog(
      context: context,
      builder: (context) => StatefulBuilder(
        builder: (context, setState) => AlertDialog(
          title: const Text('Create Client Workspace'),
          content: SingleChildScrollView(
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                TextField(
                  controller: weddingNameController,
                  decoration: const InputDecoration(
                    labelText: 'Workspace name',
                    prefixIcon: Icon(Icons.celebration_rounded),
                  ),
                ),
                const SizedBox(height: 16),
                TextField(
                  controller: cityController,
                  decoration: const InputDecoration(
                    labelText: 'Wedding city',
                    prefixIcon: Icon(Icons.location_city_rounded),
                  ),
                ),
                const SizedBox(height: 16),
                InkWell(
                  onTap: () async {
                    final picked = await showDatePicker(
                      context: context,
                      initialDate: weddingDate ?? DateTime.now(),
                      firstDate: DateTime.now(),
                      lastDate: DateTime.now().add(
                        const Duration(days: 365 * 3),
                      ),
                    );
                    if (picked != null) {
                      setState(() => weddingDate = picked);
                    }
                  },
                  child: InputDecorator(
                    decoration: const InputDecoration(
                      labelText: 'Wedding date',
                      suffixIcon: Icon(Icons.calendar_today_rounded),
                    ),
                    child: Text(
                      weddingDate == null
                          ? 'Select date'
                          : '${weddingDate!.day}/${weddingDate!.month}/${weddingDate!.year}',
                    ),
                  ),
                ),
                const SizedBox(height: 16),
                TextField(
                  controller: clientNameController,
                  decoration: const InputDecoration(
                    labelText: 'Client name',
                    prefixIcon: Icon(Icons.person_outline_rounded),
                  ),
                ),
                const SizedBox(height: 16),
                TextField(
                  controller: clientEmailController,
                  keyboardType: TextInputType.emailAddress,
                  decoration: const InputDecoration(
                    labelText: 'Client email',
                    prefixIcon: Icon(Icons.email_outlined),
                  ),
                ),
              ],
            ),
          ),
          actions: [
            TextButton(
              onPressed: () => Navigator.pop(context),
              child: const Text('Cancel'),
            ),
            ElevatedButton(
              onPressed: () async {
                final weddingName = weddingNameController.text.trim();
                final city = cityController.text.trim();
                final clientEmail = clientEmailController.text
                    .trim()
                    .toLowerCase();
                if (weddingName.isEmpty ||
                    city.isEmpty ||
                    weddingDate == null ||
                    clientEmail.isEmpty ||
                    !clientEmail.contains('@')) {
                  return;
                }

                final authProvider = context.read<AuthProvider>();
                await context.read<WeddingProvider>().createWedding(
                  name: weddingName,
                  city: city,
                  weddingDate: weddingDate!,
                  plannerName:
                      (authProvider.profile?['name'] ??
                              authProvider.user?.displayName ??
                              'Planner')
                          .toString(),
                  clientName: clientNameController.text.trim().isEmpty
                      ? null
                      : clientNameController.text.trim(),
                  clientEmail: clientEmail,
                );

                if (context.mounted) {
                  Navigator.pop(context);
                  ScaffoldMessenger.of(context).showSnackBar(
                    const SnackBar(
                      content: Text('New client workspace created'),
                    ),
                  );
                }
              },
              child: const Text('Create'),
            ),
          ],
        ),
      ),
    );
  }
}

class _PlannerWorkspaceManager extends StatelessWidget {
  const _PlannerWorkspaceManager({
    required this.weddingProvider,
    required this.onCreateWorkspace,
  });

  final WeddingProvider weddingProvider;
  final VoidCallback onCreateWorkspace;

  @override
  Widget build(BuildContext context) {
    return AppCard(
      padding: const EdgeInsets.all(18),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Container(
                padding: const EdgeInsets.all(10),
                decoration: BoxDecoration(
                  gradient: AppColors.accentGradient,
                  borderRadius: BorderRadius.circular(12),
                ),
                child: const Icon(Icons.hub_rounded, color: Colors.white),
              ),
              const SizedBox(width: 12),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      'Client Portfolio',
                      style: Theme.of(context).textTheme.titleMedium,
                    ),
                    const SizedBox(height: 2),
                    Text(
                      '${weddingProvider.workspaces.length} client workspace${weddingProvider.workspaces.length == 1 ? '' : 's'}',
                      style: Theme.of(context).textTheme.labelMedium,
                    ),
                  ],
                ),
              ),
              ElevatedButton.icon(
                onPressed: onCreateWorkspace,
                icon: const Icon(Icons.add_rounded, size: 18),
                label: const Text('New'),
              ),
            ],
          ),
          const SizedBox(height: 14),
          DropdownButtonFormField<String>(
            initialValue: weddingProvider.activeWeddingId,
            items: weddingProvider.workspaces.map((workspace) {
              return DropdownMenuItem<String>(
                value: workspace.id,
                child: Text(weddingProvider.workspaceLabel(workspace)),
              );
            }).toList(),
            onChanged: (value) {
              if (value == null) return;
              weddingProvider.switchWedding(value);
            },
            decoration: const InputDecoration(
              labelText: 'Active client workspace',
              prefixIcon: Icon(Icons.swap_horiz_rounded),
            ),
          ),
          const SizedBox(height: 14),
          if (weddingProvider.workspaces.isEmpty)
            Container(
              padding: const EdgeInsets.all(16),
              decoration: BoxDecoration(
                color: AppColors.primarySoft,
                borderRadius: BorderRadius.circular(16),
              ),
              child: Text(
                'Create your first client workspace to start planning budgets, tasks, and vendors.',
                style: Theme.of(context).textTheme.bodyMedium,
              ),
            )
          else
            SizedBox(
              height: 132,
              child: ListView.separated(
                scrollDirection: Axis.horizontal,
                itemCount: weddingProvider.workspaces.length,
                separatorBuilder: (_, _) => const SizedBox(width: 12),
                itemBuilder: (context, index) {
                  final workspace = weddingProvider.workspaces[index];
                  final data = workspace.data() ?? {};
                  final isActive =
                      workspace.id == weddingProvider.activeWeddingId;
                  final clientName = (data['clientName'] ?? 'Unassigned Client')
                      .toString();
                  final weddingName = (data['name'] ?? 'Wedding Workspace')
                      .toString();
                  final city = (data['city'] ?? 'City pending').toString();
                  final status = (data['clientInviteStatus'] ?? 'draft')
                      .toString();

                  return InkWell(
                    onTap: () => weddingProvider.switchWedding(workspace.id),
                    borderRadius: BorderRadius.circular(20),
                    child: AnimatedContainer(
                      duration: const Duration(milliseconds: 200),
                      width: 220,
                      padding: const EdgeInsets.all(16),
                      decoration: BoxDecoration(
                        gradient: isActive
                            ? AppColors.primaryGradient
                            : AppColors.cardGradient,
                        borderRadius: BorderRadius.circular(20),
                        border: Border.all(
                          color: isActive
                              ? Colors.transparent
                              : AppColors.border.withOpacity(0.8),
                        ),
                      ),
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Row(
                            children: [
                              Expanded(
                                child: Text(
                                  clientName,
                                  maxLines: 1,
                                  overflow: TextOverflow.ellipsis,
                                  style: Theme.of(context).textTheme.titleSmall
                                      ?.copyWith(
                                        color: isActive
                                            ? Colors.white
                                            : AppColors.textPrimary,
                                      ),
                                ),
                              ),
                              if (isActive)
                                const Icon(
                                  Icons.check_circle_rounded,
                                  color: Colors.white,
                                  size: 18,
                                ),
                            ],
                          ),
                          const SizedBox(height: 6),
                          Text(
                            weddingName,
                            maxLines: 2,
                            overflow: TextOverflow.ellipsis,
                            style: Theme.of(context).textTheme.bodyMedium
                                ?.copyWith(
                                  color: isActive
                                      ? Colors.white.withOpacity(0.92)
                                      : AppColors.textSecondary,
                                ),
                          ),
                          const Spacer(),
                          Text(
                            city,
                            style: Theme.of(context).textTheme.labelMedium
                                ?.copyWith(
                                  color: isActive
                                      ? Colors.white
                                      : AppColors.textMuted,
                                ),
                          ),
                          const SizedBox(height: 4),
                          Text(
                            'Access $status',
                            style: Theme.of(context).textTheme.labelSmall
                                ?.copyWith(
                                  color: isActive
                                      ? Colors.white
                                      : AppColors.primary,
                                ),
                          ),
                        ],
                      ),
                    ),
                  );
                },
              ),
            ),
        ],
      ),
    );
  }
}

class _RoleHeroCard extends StatelessWidget {
  const _RoleHeroCard({
    required this.role,
    required this.workspaceName,
    required this.clientName,
    required this.plannerName,
    required this.selectedCity,
    required this.onCityChange,
  });

  final AppRole role;
  final String workspaceName;
  final String clientName;
  final String plannerName;
  final String selectedCity;
  final ValueChanged<String> onCityChange;

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(24),
      decoration: BoxDecoration(
        gradient: AppColors.primaryGradient,
        borderRadius: BorderRadius.circular(28),
        boxShadow: [
          BoxShadow(
            color: AppColors.primary.withOpacity(0.26),
            blurRadius: 22,
            offset: const Offset(0, 12),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Container(
                padding: const EdgeInsets.all(12),
                decoration: BoxDecoration(
                  color: Colors.white.withOpacity(0.16),
                  borderRadius: BorderRadius.circular(16),
                ),
                child: Image.asset(
                  'assets/images/wedplan_logo.png',
                  width: 28,
                  height: 28,
                ),
              ),
              const Spacer(),
              Container(
                padding: const EdgeInsets.symmetric(
                  horizontal: 14,
                  vertical: 8,
                ),
                decoration: BoxDecoration(
                  color: Colors.white.withOpacity(0.18),
                  borderRadius: BorderRadius.circular(30),
                ),
                child: Text(
                  role.shortLabel,
                  style: Theme.of(
                    context,
                  ).textTheme.labelLarge?.copyWith(color: Colors.white),
                ),
              ),
            ],
          ),
          const SizedBox(height: 18),
          Text(
            workspaceName,
            style: Theme.of(
              context,
            ).textTheme.headlineSmall?.copyWith(color: Colors.white),
          ),
          const SizedBox(height: 8),
          Text(
            role == AppRole.weddingPlanner
                ? 'Manage the full wedding journey for $clientName. Budgets, tasks, and vendors stay visible to your client in real time.'
                : '$plannerName is planning your wedding here. Track every major update, budget decision, and checklist milestone from one place.',
            style: Theme.of(context).textTheme.bodyMedium?.copyWith(
              color: Colors.white.withOpacity(0.95),
            ),
          ),
          const SizedBox(height: 18),
          Container(
            padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 10),
            decoration: BoxDecoration(
              color: Colors.white.withOpacity(0.16),
              borderRadius: BorderRadius.circular(24),
            ),
            child: Row(
              mainAxisSize: MainAxisSize.min,
              children: [
                const Icon(
                  Icons.location_on_rounded,
                  color: Colors.white,
                  size: 16,
                ),
                const SizedBox(width: 8),
                Text(
                  'Celebration city',
                  style: Theme.of(
                    context,
                  ).textTheme.labelSmall?.copyWith(color: Colors.white),
                ),
                const SizedBox(width: 10),
                CitySelector(
                  selectedCity: selectedCity,
                  onCityChange: onCityChange,
                  isLight: true,
                ),
              ],
            ),
          ),
        ],
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
        gradient: AppColors.cardGradient,
        borderRadius: BorderRadius.circular(20),
        border: Border.all(color: AppColors.border.withOpacity(0.8)),
        boxShadow: [
          BoxShadow(
            color: color.withOpacity(0.08),
            blurRadius: 14,
            offset: const Offset(0, 6),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Container(
            padding: const EdgeInsets.all(9),
            decoration: BoxDecoration(
              color: color.withOpacity(0.12),
              borderRadius: BorderRadius.circular(12),
            ),
            child: Icon(icon, size: 18, color: color),
          ),
          const SizedBox(height: 12),
          Text(
            value,
            style: Theme.of(
              context,
            ).textTheme.titleMedium?.copyWith(color: AppColors.textPrimary),
            maxLines: 2,
            overflow: TextOverflow.ellipsis,
          ),
          const SizedBox(height: 4),
          Text(label, style: Theme.of(context).textTheme.labelSmall),
        ],
      ),
    );
  }
}
