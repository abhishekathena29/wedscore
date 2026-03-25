import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import '../models/budget_category.dart';
import '../providers/budget_provider.dart';
import '../theme/app_theme.dart';
import '../utils/formatters.dart';

class BudgetPlanningScreen extends StatelessWidget {
  const BudgetPlanningScreen({super.key, required this.canEdit});

  final bool canEdit;

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.background,
      appBar: AppBar(
        title: const Text('Plan Budget'),
        leading: IconButton(
          icon: const Icon(Icons.arrow_back),
          onPressed: () => Navigator.of(context).pop(),
        ),
        actions: [
          if (canEdit)
            IconButton(
              onPressed: () => _openAddCategory(context),
              icon: const Icon(Icons.add),
            ),
        ],
      ),
      body: Consumer<BudgetProvider>(
        builder: (context, budgetProvider, child) {
          final categories = budgetProvider.categories;
          if (categories.isEmpty) {
            return Center(
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Icon(
                    Icons.pie_chart_outline_rounded,
                    size: 64,
                    color: AppColors.textMuted.withOpacity(0.5),
                  ),
                  const SizedBox(height: 16),
                  Text(
                    'No budget categories yet',
                    style: Theme.of(context).textTheme.titleMedium,
                  ),
                  const SizedBox(height: 8),
                  if (canEdit)
                    ElevatedButton(
                      onPressed: () => _openAddCategory(context),
                      child: const Text('Add Category'),
                    ),
                ],
              ),
            );
          }

          return ListView.separated(
            padding: const EdgeInsets.all(16),
            itemCount: categories.length,
            separatorBuilder: (_, __) => const SizedBox(height: 12),
            itemBuilder: (context, index) {
              final category = categories[index];
              return _BudgetCategoryTile(category: category, canEdit: canEdit);
            },
          );
        },
      ),
      floatingActionButton: canEdit
          ? FloatingActionButton(
              onPressed: () => _openAddCategory(context),
              backgroundColor: AppColors.primary,
              child: const Icon(Icons.add),
            )
          : null,
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

class _BudgetCategoryTile extends StatelessWidget {
  const _BudgetCategoryTile({required this.category, required this.canEdit});

  final BudgetCategory category;
  final bool canEdit;

  @override
  Widget build(BuildContext context) {
    final percent = category.allocated == 0
        ? 0.0
        : (category.spent / category.allocated).clamp(0.0, 1.0);
    final isOverBudget = category.spent > category.allocated;

    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: AppColors.surface,
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: AppColors.border.withOpacity(0.5)),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.02),
            blurRadius: 4,
            offset: const Offset(0, 2),
          ),
        ],
      ),
      child: Column(
        children: [
          Row(
            children: [
              Container(
                padding: const EdgeInsets.all(10),
                decoration: BoxDecoration(
                  color: AppColors.primarySoft,
                  borderRadius: BorderRadius.circular(10),
                ),
                child: Icon(category.icon, color: AppColors.primary, size: 20),
              ),
              const SizedBox(width: 16),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      category.name,
                      style: const TextStyle(
                        fontWeight: FontWeight.w600,
                        fontSize: 16,
                      ),
                    ),
                    const SizedBox(height: 4),
                    Text(
                      '${formatRupees(category.spent)} spent of ${formatRupees(category.allocated)}',
                      style: TextStyle(
                        color: isOverBudget
                            ? AppColors.warning
                            : AppColors.textMuted,
                        fontSize: 13,
                        fontWeight: isOverBudget
                            ? FontWeight.w600
                            : FontWeight.normal,
                      ),
                    ),
                  ],
                ),
              ),
              if (canEdit)
                IconButton(
                  icon: const Icon(
                    Icons.edit_outlined,
                    color: AppColors.textMuted,
                  ),
                  onPressed: () => _openEditCategory(context, category),
                ),
            ],
          ),
          const SizedBox(height: 12),
          ClipRRect(
            borderRadius: BorderRadius.circular(4),
            child: LinearProgressIndicator(
              value: percent,
              minHeight: 6,
              backgroundColor: AppColors.background,
              color: isOverBudget ? AppColors.warning : AppColors.primary,
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
}
