import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:fl_chart/fl_chart.dart';

import '../../models/budget_category.dart';
import '../../providers/budget_provider.dart';
import '../../theme/app_theme.dart';
import '../../utils/formatters.dart';
import '../../screens/budget_planning_screen.dart';
import '../layout/app_card.dart';

class BudgetOverview extends StatefulWidget {
  const BudgetOverview({super.key});

  @override
  State<BudgetOverview> createState() => _BudgetOverviewState();
}

class _BudgetOverviewState extends State<BudgetOverview> {
  int touchedIndex = -1;

  @override
  Widget build(BuildContext context) {
    final budgetProvider = Provider.of<BudgetProvider>(context);
    final categories = budgetProvider.categories;
    final totalAllocated = budgetProvider.totalAllocated;
    final totalSpent = budgetProvider.totalSpent;

    // Calculate percentage, handling division by zero
    double percentUsed = 0.0;
    if (totalAllocated > 0) {
      percentUsed = (totalSpent / totalAllocated).clamp(0.0, 1.0);
    } else if (totalSpent > 0) {
      // If no budget is allocated but money is spent, show as 100% or handling overflows
      percentUsed = 1.0;
    }

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
                onPressed: () {
                  Navigator.of(context).push(
                    MaterialPageRoute(
                      builder: (_) => const BudgetPlanningScreen(),
                    ),
                  );
                },
                icon: const Icon(Icons.open_in_new_rounded, size: 18),
                label: const Text('Manage'),
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
          // Redesigned Budget Ring - Donut Chart
          Center(
            child: SizedBox(
              width: 200,
              height: 200,
              child: Stack(
                alignment: Alignment.center,
                children: [
                  PieChart(
                    PieChartData(
                      sectionsSpace: 2,
                      centerSpaceRadius: 60,
                      startDegreeOffset: -90,
                      sections: _generatePieSections(categories),
                      pieTouchData: PieTouchData(
                        touchCallback: (FlTouchEvent event, pieTouchResponse) {
                          setState(() {
                            if (!event.isInterestedForInteractions ||
                                pieTouchResponse == null ||
                                pieTouchResponse.touchedSection == null) {
                              touchedIndex = -1;
                              return;
                            }
                            touchedIndex = pieTouchResponse
                                .touchedSection!
                                .touchedSectionIndex;
                          });
                        },
                      ),
                    ),
                  ),
                  // Center content
                  Column(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      if (touchedIndex != -1 &&
                          touchedIndex < categories.length) ...[
                        Text(
                          categories[touchedIndex].name,
                          textAlign: TextAlign.center,
                          style: Theme.of(context).textTheme.labelSmall
                              ?.copyWith(
                                color: AppColors.textMuted,
                                fontSize: 10,
                              ),
                          maxLines: 1,
                          overflow: TextOverflow.ellipsis,
                        ),
                        const SizedBox(height: 2),
                        Text(
                          formatRupees(categories[touchedIndex].spent),
                          style: Theme.of(context).textTheme.titleMedium
                              ?.copyWith(
                                fontWeight: FontWeight.bold,
                                color: AppColors.primary,
                                fontSize: 16,
                              ),
                        ),
                      ] else ...[
                        Text(
                          (percentUsed > 0 && percentUsed < 0.005)
                              ? '< 1%'
                              : '${(percentUsed * 100).round()}%',
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
                    ],
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

  List<PieChartSectionData> _generatePieSections(
    List<BudgetCategory> categories,
  ) {
    if (categories.isEmpty) {
      return [
        PieChartSectionData(
          color: AppColors.border,
          value: 1,
          title: '',
          radius: 16,
        ),
      ];
    }

    final total = categories.fold<double>(0, (sum, item) => sum + item.spent);

    if (total == 0) {
      return [
        PieChartSectionData(
          color: AppColors.border.withOpacity(0.5),
          value: 1,
          title: '',
          radius: 16,
        ),
      ];
    }

    // Colors for the chart
    final colors = [
      const Color(0xFF4285F4), // Google Blue
      const Color(0xFFEA4335), // Google Red
      const Color(0xFFFBBC05), // Google Yellow
      const Color(0xFF34A853), // Google Green
      const Color(0xFFFB8C00), // Orange
      const Color(0xFF8E24AA), // Purple
      const Color(0xFF00ACC1), // Cyan
    ];

    return categories.asMap().entries.map((entry) {
      final index = entry.key;
      final category = entry.value;
      final value = category.spent.toDouble();
      final isTouched = index == touchedIndex;
      final radius = isTouched ? 22.0 : 16.0;

      return PieChartSectionData(
        color: colors[index % colors.length],
        value: value > 0
            ? value
            : 0.001, // Ensure even 0 spent shows tiny if needed, or filter out
        title: '',
        radius: radius,
        showTitle: false,
      );
    }).toList();
  }
}

class _CategoryItem extends StatelessWidget {
  const _CategoryItem({
    required this.category,
    required this.percent,
    required this.isOverBudget,
  });

  final BudgetCategory category;
  final double percent;
  final bool isOverBudget;

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
