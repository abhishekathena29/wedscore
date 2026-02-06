import 'dart:math' as math;
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import '../../models/budget_category.dart';
import '../../providers/budget_provider.dart';
import '../../theme/app_theme.dart';
import '../../utils/formatters.dart';
import '../layout/app_card.dart';

class BudgetOverview extends StatelessWidget {
  const BudgetOverview({super.key});

  @override
  Widget build(BuildContext context) {
    final budgetProvider = Provider.of<BudgetProvider>(context);
    final categories = budgetProvider.categories;
    final totalAllocated = budgetProvider.totalAllocated;
    final totalSpent = budgetProvider.totalSpent;
    final percentUsed = totalAllocated == 0
        ? 0.0
        : (totalSpent / totalAllocated).clamp(0.0, 1.0);

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
                      Icons.account_balance_wallet_rounded,
                      color: Colors.white,
                      size: 18,
                    ),
                  ),
                  const SizedBox(width: 12),
                  Text(
                    'Budget Overview',
                    style: Theme.of(context).textTheme.titleMedium,
                  ),
                ],
              ),
              TextButton.icon(
                onPressed: () => _openAddCategory(context),
                icon: const Icon(Icons.add_rounded, size: 18),
                label: const Text('Add'),
                style: TextButton.styleFrom(
                  foregroundColor: AppColors.primary,
                  padding: const EdgeInsets.symmetric(
                    horizontal: 12,
                    vertical: 8,
                  ),
                ),
              ),
            ],
          ),
          const SizedBox(height: 24),
          // Redesigned Budget Ring - Fixed overlapping issue
          Center(
            child: SizedBox(
              width: 160,
              height: 160,
              child: Stack(
                alignment: Alignment.center,
                children: [
                  // Background ring
                  SizedBox(
                    width: 160,
                    height: 160,
                    child: CircularProgressIndicator(
                      value: 1,
                      strokeWidth: 14,
                      strokeCap: StrokeCap.round,
                      backgroundColor: Colors.transparent,
                      color: AppColors.primarySoft,
                    ),
                  ),
                  // Animated progress ring with gradient effect
                  SizedBox(
                    width: 160,
                    height: 160,
                    child: CustomPaint(
                      painter: _GradientCircularProgressPainter(
                        progress: percentUsed,
                        strokeWidth: 14,
                        gradient: AppColors.primaryGradient,
                      ),
                    ),
                  ),
                  // Center content with proper sizing
                  Container(
                    width: 110,
                    height: 110,
                    decoration: BoxDecoration(
                      color: AppColors.surface,
                      shape: BoxShape.circle,
                      boxShadow: [
                        BoxShadow(
                          color: AppColors.primary.withOpacity(0.1),
                          blurRadius: 20,
                          offset: const Offset(0, 4),
                        ),
                      ],
                    ),
                    child: Column(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        Text(
                          '${(percentUsed * 100).round()}%',
                          style: Theme.of(context).textTheme.headlineSmall
                              ?.copyWith(
                                fontWeight: FontWeight.w700,
                                color: AppColors.primary,
                              ),
                        ),
                        const SizedBox(height: 2),
                        Text(
                          'Used',
                          style: Theme.of(context).textTheme.labelSmall
                              ?.copyWith(color: AppColors.textMuted),
                        ),
                      ],
                    ),
                  ),
                ],
              ),
            ),
          ),
          const SizedBox(height: 24),
          // Summary tiles with gradient background
          Container(
            padding: const EdgeInsets.all(16),
            decoration: BoxDecoration(
              gradient: LinearGradient(
                begin: Alignment.topLeft,
                end: Alignment.bottomRight,
                colors: [
                  AppColors.primarySoft,
                  AppColors.primaryLight.withOpacity(0.5),
                ],
              ),
              borderRadius: BorderRadius.circular(16),
            ),
            child: Row(
              children: [
                Expanded(
                  child: _SummaryTile(
                    label: 'Total Budget',
                    value: formatRupees(totalAllocated),
                    icon: Icons.savings_rounded,
                  ),
                ),
                Container(width: 1, height: 40, color: AppColors.border),
                Expanded(
                  child: _SummaryTile(
                    label: 'Spent',
                    value: formatRupees(totalSpent),
                    icon: Icons.receipt_long_rounded,
                  ),
                ),
              ],
            ),
          ),
          const SizedBox(height: 20),
          Row(
            children: [
              Text(
                'By Category',
                style: Theme.of(context).textTheme.labelLarge,
              ),
              const Spacer(),
              Text(
                '${categories.length} categories',
                style: Theme.of(context).textTheme.labelSmall,
              ),
            ],
          ),
          const SizedBox(height: 12),
          ...categories.asMap().entries.map((entry) {
            final index = entry.key;
            final category = entry.value;
            final percent = category.allocated == 0
                ? 0.0
                : (category.spent / category.allocated).clamp(0.0, 1.0);
            final isOverBudget = percent > 1.0;

            return Padding(
              padding: EdgeInsets.only(
                bottom: index < categories.length - 1 ? 14 : 0,
              ),
              child: _CategoryItem(
                category: category,
                percent: percent,
                isOverBudget: isOverBudget,
                onEdit: () => _openEditCategory(context, category),
              ),
            );
          }),
          if (categories.isEmpty)
            Container(
              padding: const EdgeInsets.symmetric(vertical: 24),
              alignment: Alignment.center,
              child: Column(
                children: [
                  Icon(
                    Icons.pie_chart_outline_rounded,
                    size: 40,
                    color: AppColors.textMuted.withOpacity(0.5),
                  ),
                  const SizedBox(height: 8),
                  Text(
                    'No budget categories yet',
                    style: Theme.of(context).textTheme.labelSmall,
                  ),
                  const SizedBox(height: 4),
                  Text(
                    'Tap "Add" to create your first category',
                    style: Theme.of(context).textTheme.labelSmall?.copyWith(
                      color: AppColors.textMuted.withOpacity(0.7),
                    ),
                  ),
                ],
              ),
            ),
        ],
      ),
    );
  }

  Future<void> _openEditCategory(
    BuildContext context,
    BudgetCategory category,
  ) async {
    final allocatedController = TextEditingController(
      text: category.allocated.toString(),
    );
    final spentController = TextEditingController(
      text: category.spent.toString(),
    );

    await showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: Text('Edit ${category.name}'),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            TextField(
              controller: allocatedController,
              keyboardType: TextInputType.number,
              decoration: const InputDecoration(
                labelText: 'Allocated Budget',
                prefixText: '₹ ',
              ),
            ),
            const SizedBox(height: 16),
            TextField(
              controller: spentController,
              keyboardType: TextInputType.number,
              decoration: const InputDecoration(
                labelText: 'Amount Spent',
                prefixText: '₹ ',
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
              final allocated = int.tryParse(allocatedController.text) ?? 0;
              final spent = int.tryParse(spentController.text) ?? 0;
              await Provider.of<BudgetProvider>(
                context,
                listen: false,
              ).updateCategory(
                id: category.id,
                allocated: allocated,
                spent: spent,
              );
              if (context.mounted) Navigator.pop(context);
            },
            child: const Text('Save'),
          ),
        ],
      ),
    );
  }

  Future<void> _openAddCategory(BuildContext context) async {
    final nameController = TextEditingController();
    final allocatedController = TextEditingController();
    final spentController = TextEditingController();

    await showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Add Category'),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            TextField(
              controller: nameController,
              decoration: const InputDecoration(labelText: 'Category name'),
            ),
            const SizedBox(height: 16),
            TextField(
              controller: allocatedController,
              keyboardType: TextInputType.number,
              decoration: const InputDecoration(
                labelText: 'Budget Amount',
                prefixText: '₹ ',
              ),
            ),
            const SizedBox(height: 16),
            TextField(
              controller: spentController,
              keyboardType: TextInputType.number,
              decoration: const InputDecoration(
                labelText: 'Already Spent',
                prefixText: '₹ ',
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
              final name = nameController.text.trim();
              if (name.isEmpty) return;
              final allocated = int.tryParse(allocatedController.text) ?? 0;
              final spent = int.tryParse(spentController.text) ?? 0;
              await Provider.of<BudgetProvider>(
                context,
                listen: false,
              ).upsertCategory(name: name, allocated: allocated, spent: spent);
              if (context.mounted) Navigator.pop(context);
            },
            child: const Text('Add'),
          ),
        ],
      ),
    );
  }
}

class _CategoryItem extends StatelessWidget {
  const _CategoryItem({
    required this.category,
    required this.percent,
    required this.isOverBudget,
    required this.onEdit,
  });

  final BudgetCategory category;
  final double percent;
  final bool isOverBudget;
  final VoidCallback onEdit;

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(14),
      decoration: BoxDecoration(
        color: AppColors.background,
        borderRadius: BorderRadius.circular(14),
        border: Border.all(color: AppColors.border.withOpacity(0.5)),
      ),
      child: Column(
        children: [
          Row(
            children: [
              Container(
                padding: const EdgeInsets.all(8),
                decoration: BoxDecoration(
                  color: AppColors.primarySoft,
                  borderRadius: BorderRadius.circular(8),
                ),
                child: Icon(category.icon, size: 16, color: AppColors.primary),
              ),
              const SizedBox(width: 12),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      category.name,
                      style: Theme.of(context).textTheme.titleSmall,
                    ),
                    const SizedBox(height: 2),
                    Text(
                      '${formatRupees(category.spent)} / ${formatRupees(category.allocated)}',
                      style: Theme.of(context).textTheme.labelSmall,
                    ),
                  ],
                ),
              ),
              Container(
                padding: const EdgeInsets.symmetric(
                  horizontal: 10,
                  vertical: 4,
                ),
                decoration: BoxDecoration(
                  color: isOverBudget
                      ? AppColors.warning.withOpacity(0.15)
                      : AppColors.primarySoft,
                  borderRadius: BorderRadius.circular(20),
                ),
                child: Text(
                  '${(percent * 100).round()}%',
                  style: TextStyle(
                    fontSize: 12,
                    fontWeight: FontWeight.w600,
                    color: isOverBudget ? AppColors.warning : AppColors.primary,
                  ),
                ),
              ),
              const SizedBox(width: 8),
              IconButton(
                onPressed: onEdit,
                icon: const Icon(Icons.edit_rounded, size: 18),
                visualDensity: VisualDensity.compact,
                color: AppColors.textMuted,
              ),
            ],
          ),
          const SizedBox(height: 10),
          ClipRRect(
            borderRadius: BorderRadius.circular(6),
            child: LinearProgressIndicator(
              value: percent.clamp(0.0, 1.0),
              minHeight: 6,
              backgroundColor: AppColors.border.withOpacity(0.5),
              color: isOverBudget ? AppColors.warning : AppColors.primary,
            ),
          ),
        ],
      ),
    );
  }
}

class _SummaryTile extends StatelessWidget {
  const _SummaryTile({
    required this.label,
    required this.value,
    required this.icon,
  });

  final String label;
  final String value;
  final IconData icon;

  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        Icon(icon, size: 20, color: AppColors.primary),
        const SizedBox(height: 6),
        Text(label, style: Theme.of(context).textTheme.labelSmall),
        const SizedBox(height: 2),
        Text(
          value,
          style: Theme.of(context).textTheme.titleSmall?.copyWith(
            fontWeight: FontWeight.w700,
            color: AppColors.textPrimary,
          ),
        ),
      ],
    );
  }
}

// Custom painter for gradient circular progress
class _GradientCircularProgressPainter extends CustomPainter {
  _GradientCircularProgressPainter({
    required this.progress,
    required this.strokeWidth,
    required this.gradient,
  });

  final double progress;
  final double strokeWidth;
  final LinearGradient gradient;

  @override
  void paint(Canvas canvas, Size size) {
    final center = Offset(size.width / 2, size.height / 2);
    final radius = (size.width - strokeWidth) / 2;
    final rect = Rect.fromCircle(center: center, radius: radius);

    final paint = Paint()
      ..shader = gradient.createShader(rect)
      ..style = PaintingStyle.stroke
      ..strokeWidth = strokeWidth
      ..strokeCap = StrokeCap.round;

    final sweepAngle = 2 * math.pi * progress;
    canvas.drawArc(rect, -math.pi / 2, sweepAngle, false, paint);
  }

  @override
  bool shouldRepaint(covariant _GradientCircularProgressPainter oldDelegate) {
    return oldDelegate.progress != progress;
  }
}
