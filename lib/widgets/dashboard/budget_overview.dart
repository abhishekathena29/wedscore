import 'package:flutter/material.dart';

import '../../data/mock_data.dart';
import '../../theme/app_theme.dart';
import '../../utils/formatters.dart';
import '../layout/app_card.dart';

class BudgetOverview extends StatelessWidget {
  const BudgetOverview({super.key});

  @override
  Widget build(BuildContext context) {
    final totalAllocated = budgetCategories.fold<int>(
      0,
      (sum, item) => sum + item.allocated,
    );
    final totalSpent = budgetCategories.fold<int>(
      0,
      (sum, item) => sum + item.spent,
    );
    final percentUsed = totalAllocated == 0
        ? 0
        : (totalSpent / totalAllocated).clamp(0, 1);

    return AppCard(
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 18),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            'Budget Overview',
            style: Theme.of(context).textTheme.titleLarge,
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
          ...budgetCategories.take(4).map((category) {
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
                      Text(
                        formatRupees(category.spent),
                        style: const TextStyle(
                          fontSize: 11,
                          color: AppColors.textMuted,
                        ),
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
