import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import '../../providers/checklist_provider.dart';
import '../../theme/app_theme.dart';
import '../../utils/app_routes.dart';
import '../layout/app_card.dart';

class ChecklistPreview extends StatelessWidget {
  const ChecklistPreview({super.key});

  @override
  Widget build(BuildContext context) {
    final checklistProvider = Provider.of<ChecklistProvider>(context);
    final tasks = checklistProvider.tasks;
    final completed = tasks.where((task) => task.completed).length;
    final total = tasks.length;
    final progress = total == 0 ? 0.0 : completed / total;
    final previewTasks = tasks.take(4).toList();

    return AppCard(
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 18),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Text('Checklist', style: Theme.of(context).textTheme.titleLarge),
              _ChipBadge(text: '$completed/$total'),
            ],
          ),
          const SizedBox(height: 12),
          LinearProgressIndicator(
            value: progress,
            minHeight: 6,
            backgroundColor: AppColors.primarySoft,
            color: AppColors.primary,
            borderRadius: BorderRadius.circular(999),
          ),
          const SizedBox(height: 6),
          Align(
            alignment: Alignment.centerRight,
            child: Text(
              '${(progress * 100).round()}% complete',
              style: Theme.of(context).textTheme.labelSmall,
            ),
          ),
          const SizedBox(height: 12),
          ...previewTasks.map((task) {
            return Padding(
              padding: const EdgeInsets.only(bottom: 10),
              child: InkWell(
                onTap: () => checklistProvider.toggleTask(task),
                borderRadius: BorderRadius.circular(12),
                child: Container(
                  padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 10),
                  decoration: BoxDecoration(
                    color: task.completed ? AppColors.primarySoft : AppColors.background,
                    borderRadius: BorderRadius.circular(12),
                    border: Border.all(color: AppColors.border),
                  ),
                  child: Row(
                    children: [
                      Checkbox(
                        value: task.completed,
                        activeColor: AppColors.primary,
                        onChanged: (_) => checklistProvider.toggleTask(task),
                      ),
                      const SizedBox(width: 6),
                      Expanded(
                        child: Text(
                          task.title,
                          style: TextStyle(
                            fontSize: 13,
                            color: task.completed
                                ? AppColors.textMuted
                                : AppColors.textPrimary,
                            decoration:
                                task.completed ? TextDecoration.lineThrough : null,
                          ),
                        ),
                      ),
                      _ChipBadge(text: task.timeline),
                    ],
                  ),
                ),
              ),
            );
          }),
          Center(
            child: TextButton.icon(
              onPressed: () => Navigator.of(context)
                  .pushReplacementNamed(AppRoutes.checklist),
              icon: const Icon(Icons.chevron_right, size: 18),
              label: Text('View all $total tasks'),
              style: TextButton.styleFrom(
                foregroundColor: AppColors.primary,
                textStyle: const TextStyle(fontSize: 12, fontWeight: FontWeight.w600),
              ),
            ),
          ),
        ],
      ),
    );
  }
}

class _ChipBadge extends StatelessWidget {
  const _ChipBadge({required this.text});

  final String text;

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
      decoration: BoxDecoration(
        color: AppColors.primarySoft,
        borderRadius: BorderRadius.circular(999),
      ),
      child: Text(
        text,
        style: const TextStyle(fontSize: 11, fontWeight: FontWeight.w600),
      ),
    );
  }
}
