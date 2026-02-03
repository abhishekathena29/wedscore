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
        ? 0
        : (totalSpent / totalAllocated).clamp(0, 1);

    return AppCard(
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 18),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Text(
                'Budget Overview',
                style: Theme.of(context).textTheme.titleLarge,
              ),
              TextButton.icon(
                onPressed: () => _openAddCategory(context),
                icon: const Icon(Icons.add, size: 18),
                label: const Text('Add'),
              ),
            ],
          ),
          const SizedBox(height: 16),
          Center(
            child: SizedBox(
              width: 120,
              height: 120,
              child: Stack(
                alignment: Alignment.center,
                children: [
                  CircularProgressIndicator(
                    value: percentUsed.toDouble(),
                    strokeWidth: 10,
                    strokeCap: StrokeCap.round,
                    backgroundColor: AppColors.primarySoft,
                    color: AppColors.primary,
                  ),
                  Column(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      Text(
                        '${(percentUsed * 100).round()}%',
                        style: Theme.of(context).textTheme.headlineSmall,
                      ),
                      const SizedBox(height: 4),
                      Text(
                        'Used',
                        style: Theme.of(context).textTheme.labelSmall,
                      ),
                    ],
                  ),
                ],
              ),
            ),
          ),
          const SizedBox(height: 16),
          Row(
            children: [
              Expanded(
                child: _SummaryTile(
                  label: 'Total',
                  value: formatRupees(totalAllocated),
                ),
              ),
              const SizedBox(width: 12),
              Expanded(
                child: _SummaryTile(
                  label: 'Spent',
                  value: formatRupees(totalSpent),
                ),
              ),
            ],
          ),
          const SizedBox(height: 16),
          Text('By Category', style: Theme.of(context).textTheme.labelSmall),
          const SizedBox(height: 8),
          ...categories.map((category) {
            final percent = category.allocated == 0
                ? 0
                : (category.spent / category.allocated).clamp(0, 1);
            return Padding(
              padding: const EdgeInsets.only(bottom: 12),
              child: Column(
                children: [
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      Row(
                        children: [
                          Icon(
                            category.icon,
                            size: 16,
                            color: AppColors.textMuted,
                          ),
                          const SizedBox(width: 6),
                          Text(
                            category.name,
                            style: const TextStyle(fontSize: 12),
                          ),
                        ],
                      ),
                      Row(
                        children: [
                          Text(
                            formatRupees(category.spent),
                            style: const TextStyle(
                              fontSize: 11,
                              color: AppColors.textMuted,
                            ),
                          ),
                          IconButton(
                            onPressed: () => _openEditCategory(
                              context,
                              category,
                            ),
                            icon: const Icon(Icons.edit, size: 16),
                            visualDensity: VisualDensity.compact,
                          ),
                        ],
                      ),
                    ],
                  ),
                  const SizedBox(height: 6),
                  LinearProgressIndicator(
                    value: percent.toDouble(),
                    minHeight: 6,
                    backgroundColor: AppColors.primarySoft,
                    color: AppColors.primary,
                    borderRadius: BorderRadius.circular(999),
                  ),
                ],
              ),
            );
          }),
          if (categories.isEmpty)
            Padding(
              padding: const EdgeInsets.only(top: 8),
              child: Text(
                'No budget categories yet',
                style: Theme.of(context).textTheme.labelSmall,
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
    final allocatedController =
        TextEditingController(text: category.allocated.toString());
    final spentController = TextEditingController(text: category.spent.toString());

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
              decoration: const InputDecoration(labelText: 'Allocated'),
            ),
            const SizedBox(height: 12),
            TextField(
              controller: spentController,
              keyboardType: TextInputType.number,
              decoration: const InputDecoration(labelText: 'Spent'),
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
              await Provider.of<BudgetProvider>(context, listen: false)
                  .updateCategory(
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
            const SizedBox(height: 12),
            TextField(
              controller: allocatedController,
              keyboardType: TextInputType.number,
              decoration: const InputDecoration(labelText: 'Allocated'),
            ),
            const SizedBox(height: 12),
            TextField(
              controller: spentController,
              keyboardType: TextInputType.number,
              decoration: const InputDecoration(labelText: 'Spent'),
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
              await Provider.of<BudgetProvider>(context, listen: false)
                  .upsertCategory(
                name: name,
                allocated: allocated,
                spent: spent,
              );
              if (context.mounted) Navigator.pop(context);
            },
            child: const Text('Add'),
          ),
        ],
      ),
    );
  }
}

class _SummaryTile extends StatelessWidget {
  const _SummaryTile({required this.label, required this.value});

  final String label;
  final String value;

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 10),
      decoration: BoxDecoration(
        color: AppColors.primarySoft,
        borderRadius: BorderRadius.circular(12),
      ),
      child: Column(
        children: [
          Text(
            label.toUpperCase(),
            style: Theme.of(context).textTheme.labelSmall,
          ),
          const SizedBox(height: 4),
          Text(
            value,
            style: const TextStyle(fontSize: 16, fontWeight: FontWeight.w600),
          ),
        ],
      ),
    );
  }
}
