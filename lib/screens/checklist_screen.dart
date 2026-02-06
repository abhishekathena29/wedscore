import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import '../models/task.dart';
import '../providers/checklist_provider.dart';
import '../theme/app_theme.dart';
import '../widgets/layout/app_card.dart';
import '../widgets/layout/mobile_scaffold.dart';

class ChecklistScreen extends StatefulWidget {
  const ChecklistScreen({super.key});

  @override
  State<ChecklistScreen> createState() => _ChecklistScreenState();
}

class _ChecklistScreenState extends State<ChecklistScreen> {
  String selectedTimeline = 'All';
  String searchQuery = '';
  final Map<String, bool> expandedSections = {};
  final TextEditingController searchController = TextEditingController();

  final List<_TimelineFilter> timelineFilters = const [
    _TimelineFilter(label: 'All', value: 'All'),
    _TimelineFilter(label: '12 mo', value: '12 months'),
    _TimelineFilter(label: '6 mo', value: '6 months'),
    _TimelineFilter(label: '3 mo', value: '3 months'),
    _TimelineFilter(label: '1 mo', value: '1 month'),
  ];

  @override
  void dispose() {
    searchController.dispose();
    super.dispose();
  }

  void toggleTask(Task task) {
    Provider.of<ChecklistProvider>(context, listen: false).toggleTask(task);
  }

  void toggleSection(String timeline) {
    setState(() {
      expandedSections[timeline] = !(expandedSections[timeline] ?? true);
    });
  }

  Future<void> _openAddTask() async {
    final titleController = TextEditingController();
    final categoryController = TextEditingController();
    String selectedTimeline = timelineFilters[1].value;

    await showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: Row(
          children: [
            Container(
              padding: const EdgeInsets.all(8),
              decoration: BoxDecoration(
                gradient: AppColors.primaryGradient,
                borderRadius: BorderRadius.circular(8),
              ),
              child: const Icon(
                Icons.add_task_rounded,
                size: 18,
                color: Colors.white,
              ),
            ),
            const SizedBox(width: 12),
            const Text('Add Task'),
          ],
        ),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            TextField(
              controller: titleController,
              decoration: const InputDecoration(
                labelText: 'Task title',
                prefixIcon: Icon(Icons.task_alt_rounded, size: 20),
              ),
            ),
            const SizedBox(height: 16),
            TextField(
              controller: categoryController,
              decoration: const InputDecoration(
                labelText: 'Category',
                prefixIcon: Icon(Icons.category_rounded, size: 20),
              ),
            ),
            const SizedBox(height: 16),
            DropdownButtonFormField<String>(
              value: selectedTimeline,
              items: timelineFilters
                  .where((filter) => filter.value != 'All')
                  .map(
                    (filter) => DropdownMenuItem(
                      value: filter.value,
                      child: Text(filter.label),
                    ),
                  )
                  .toList(),
              onChanged: (value) {
                if (value == null) return;
                selectedTimeline = value;
              },
              decoration: const InputDecoration(
                labelText: 'Timeline',
                prefixIcon: Icon(Icons.schedule_rounded, size: 20),
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
              final title = titleController.text.trim();
              final category = categoryController.text.trim();
              if (title.isEmpty || category.isEmpty) return;
              await Provider.of<ChecklistProvider>(
                context,
                listen: false,
              ).addTask(
                title: title,
                timeline: selectedTimeline,
                category: category,
              );
              if (context.mounted) Navigator.pop(context);
            },
            child: const Text('Add'),
          ),
        ],
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return MobileScaffold(
      currentIndex: 1,
      title: 'Checklist',
      showLogo: false,
      allowBack: false,
      floatingActionButton: Container(
        decoration: BoxDecoration(
          gradient: AppColors.primaryGradient,
          shape: BoxShape.circle,
          boxShadow: [
            BoxShadow(
              color: AppColors.primary.withOpacity(0.4),
              blurRadius: 16,
              offset: const Offset(0, 6),
            ),
          ],
        ),
        child: FloatingActionButton(
          onPressed: _openAddTask,
          backgroundColor: Colors.transparent,
          elevation: 0,
          child: const Icon(Icons.add_rounded, color: Colors.white),
        ),
      ),
      child: Consumer<ChecklistProvider>(
        builder: (context, checklistProvider, child) {
          final tasks = checklistProvider.tasks;
          final completedCount = tasks.where((task) => task.completed).length;
          final totalCount = tasks.length;
          final progress = totalCount == 0 ? 0.0 : completedCount / totalCount;

          final filteredTasks = tasks.where((task) {
            final timelineMatch =
                selectedTimeline == 'All' || task.timeline == selectedTimeline;
            final searchMatch = task.title.toLowerCase().contains(
              searchQuery.toLowerCase(),
            );
            return timelineMatch && searchMatch;
          }).toList();

          final Map<String, List<Task>> groupedTasks = {};
          for (final task in filteredTasks) {
            groupedTasks.putIfAbsent(task.timeline, () => []).add(task);
          }

          return SingleChildScrollView(
            padding: const EdgeInsets.fromLTRB(16, 16, 16, 24),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                // Progress Card
                Container(
                  padding: const EdgeInsets.all(20),
                  decoration: BoxDecoration(
                    gradient: AppColors.primaryGradient,
                    borderRadius: BorderRadius.circular(20),
                    boxShadow: [
                      BoxShadow(
                        color: AppColors.primary.withOpacity(0.3),
                        blurRadius: 16,
                        offset: const Offset(0, 8),
                      ),
                    ],
                  ),
                  child: Row(
                    children: [
                      Expanded(
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Row(
                              mainAxisAlignment: MainAxisAlignment.spaceBetween,
                              children: [
                                const Text(
                                  'Overall Progress',
                                  style: TextStyle(
                                    fontSize: 14,
                                    fontWeight: FontWeight.w600,
                                    color: Colors.white,
                                  ),
                                ),
                                Container(
                                  padding: const EdgeInsets.symmetric(
                                    horizontal: 10,
                                    vertical: 4,
                                  ),
                                  decoration: BoxDecoration(
                                    color: Colors.white.withOpacity(0.2),
                                    borderRadius: BorderRadius.circular(20),
                                  ),
                                  child: Text(
                                    '$completedCount/$totalCount',
                                    style: const TextStyle(
                                      fontSize: 12,
                                      fontWeight: FontWeight.w600,
                                      color: Colors.white,
                                    ),
                                  ),
                                ),
                              ],
                            ),
                            const SizedBox(height: 12),
                            ClipRRect(
                              borderRadius: BorderRadius.circular(6),
                              child: LinearProgressIndicator(
                                value: progress,
                                minHeight: 8,
                                backgroundColor: Colors.white.withOpacity(0.25),
                                color: Colors.white,
                              ),
                            ),
                          ],
                        ),
                      ),
                      const SizedBox(width: 20),
                      Container(
                        width: 60,
                        height: 60,
                        decoration: BoxDecoration(
                          color: Colors.white.withOpacity(0.2),
                          shape: BoxShape.circle,
                        ),
                        alignment: Alignment.center,
                        child: Text(
                          '${(progress * 100).round()}%',
                          style: const TextStyle(
                            fontSize: 16,
                            fontWeight: FontWeight.w700,
                            color: Colors.white,
                          ),
                        ),
                      ),
                    ],
                  ),
                ),
                const SizedBox(height: 20),
                // Search
                TextField(
                  controller: searchController,
                  onChanged: (value) => setState(() => searchQuery = value),
                  decoration: InputDecoration(
                    hintText: 'Search tasks...',
                    prefixIcon: const Icon(Icons.search_rounded),
                    filled: true,
                    fillColor: AppColors.surface,
                    border: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(14),
                      borderSide: BorderSide(color: AppColors.border),
                    ),
                  ),
                ),
                const SizedBox(height: 16),
                // Filter chips
                SizedBox(
                  height: 42,
                  child: ListView.separated(
                    scrollDirection: Axis.horizontal,
                    itemCount: timelineFilters.length,
                    separatorBuilder: (_, __) => const SizedBox(width: 10),
                    itemBuilder: (context, index) {
                      final filter = timelineFilters[index];
                      final selected = selectedTimeline == filter.value;
                      return GestureDetector(
                        onTap: () =>
                            setState(() => selectedTimeline = filter.value),
                        child: AnimatedContainer(
                          duration: const Duration(milliseconds: 200),
                          padding: const EdgeInsets.symmetric(
                            horizontal: 18,
                            vertical: 10,
                          ),
                          decoration: BoxDecoration(
                            gradient: selected
                                ? AppColors.primaryGradient
                                : null,
                            color: selected ? null : AppColors.surface,
                            borderRadius: BorderRadius.circular(20),
                            border: selected
                                ? null
                                : Border.all(color: AppColors.border),
                            boxShadow: selected
                                ? [
                                    BoxShadow(
                                      color: AppColors.primary.withOpacity(0.3),
                                      blurRadius: 8,
                                      offset: const Offset(0, 3),
                                    ),
                                  ]
                                : null,
                          ),
                          child: Text(
                            filter.label,
                            style: TextStyle(
                              fontSize: 13,
                              fontWeight: FontWeight.w600,
                              color: selected
                                  ? Colors.white
                                  : AppColors.textSecondary,
                            ),
                          ),
                        ),
                      );
                    },
                  ),
                ),
                const SizedBox(height: 20),
                // Task groups
                ...groupedTasks.entries.map((entry) {
                  final timeline = entry.key;
                  final timelineTasks = entry.value;
                  final isExpanded = expandedSections[timeline] ?? true;
                  final completedInGroup = timelineTasks
                      .where((task) => task.completed)
                      .length;

                  return Padding(
                    padding: const EdgeInsets.only(bottom: 14),
                    child: AppCard(
                      padding: const EdgeInsets.all(16),
                      child: Column(
                        children: [
                          InkWell(
                            onTap: () => toggleSection(timeline),
                            borderRadius: BorderRadius.circular(12),
                            child: Padding(
                              padding: const EdgeInsets.symmetric(vertical: 4),
                              child: Row(
                                children: [
                                  Container(
                                    padding: const EdgeInsets.all(8),
                                    decoration: BoxDecoration(
                                      color: AppColors.primarySoft,
                                      borderRadius: BorderRadius.circular(8),
                                    ),
                                    child: const Icon(
                                      Icons.schedule_rounded,
                                      size: 16,
                                      color: AppColors.primary,
                                    ),
                                  ),
                                  const SizedBox(width: 12),
                                  Expanded(
                                    child: Text(
                                      '$timeline before',
                                      style: Theme.of(
                                        context,
                                      ).textTheme.titleSmall,
                                    ),
                                  ),
                                  Container(
                                    padding: const EdgeInsets.symmetric(
                                      horizontal: 10,
                                      vertical: 4,
                                    ),
                                    decoration: BoxDecoration(
                                      gradient: AppColors.primaryGradient,
                                      borderRadius: BorderRadius.circular(20),
                                    ),
                                    child: Text(
                                      '$completedInGroup/${timelineTasks.length}',
                                      style: const TextStyle(
                                        fontSize: 11,
                                        fontWeight: FontWeight.w600,
                                        color: Colors.white,
                                      ),
                                    ),
                                  ),
                                  const SizedBox(width: 8),
                                  Icon(
                                    isExpanded
                                        ? Icons.keyboard_arrow_up_rounded
                                        : Icons.keyboard_arrow_down_rounded,
                                    color: AppColors.textMuted,
                                  ),
                                ],
                              ),
                            ),
                          ),
                          if (isExpanded) ...[
                            const SizedBox(height: 12),
                            ...timelineTasks.asMap().entries.map((taskEntry) {
                              final taskIndex = taskEntry.key;
                              final task = taskEntry.value;
                              return Padding(
                                padding: EdgeInsets.only(
                                  bottom: taskIndex < timelineTasks.length - 1
                                      ? 10
                                      : 0,
                                ),
                                child: InkWell(
                                  onTap: () => toggleTask(task),
                                  borderRadius: BorderRadius.circular(14),
                                  child: Container(
                                    padding: const EdgeInsets.all(14),
                                    decoration: BoxDecoration(
                                      color: task.completed
                                          ? AppColors.primarySoft
                                          : AppColors.background,
                                      borderRadius: BorderRadius.circular(14),
                                      border: Border.all(
                                        color: task.completed
                                            ? AppColors.primary.withOpacity(0.3)
                                            : AppColors.border,
                                      ),
                                    ),
                                    child: Row(
                                      children: [
                                        Container(
                                          width: 24,
                                          height: 24,
                                          decoration: BoxDecoration(
                                            gradient: task.completed
                                                ? AppColors.primaryGradient
                                                : null,
                                            color: task.completed
                                                ? null
                                                : Colors.transparent,
                                            borderRadius: BorderRadius.circular(
                                              6,
                                            ),
                                            border: task.completed
                                                ? null
                                                : Border.all(
                                                    color: AppColors.border,
                                                    width: 2,
                                                  ),
                                          ),
                                          child: task.completed
                                              ? const Icon(
                                                  Icons.check_rounded,
                                                  size: 16,
                                                  color: Colors.white,
                                                )
                                              : null,
                                        ),
                                        const SizedBox(width: 14),
                                        Expanded(
                                          child: Text(
                                            task.title,
                                            style: TextStyle(
                                              fontSize: 14,
                                              fontWeight: FontWeight.w500,
                                              color: task.completed
                                                  ? AppColors.textMuted
                                                  : AppColors.textPrimary,
                                              decoration: task.completed
                                                  ? TextDecoration.lineThrough
                                                  : null,
                                            ),
                                          ),
                                        ),
                                      ],
                                    ),
                                  ),
                                ),
                              );
                            }),
                          ],
                        ],
                      ),
                    ),
                  );
                }),
                if (groupedTasks.isEmpty)
                  Container(
                    padding: const EdgeInsets.symmetric(vertical: 40),
                    alignment: Alignment.center,
                    child: Column(
                      children: [
                        Icon(
                          Icons.checklist_rounded,
                          size: 56,
                          color: AppColors.textMuted.withOpacity(0.4),
                        ),
                        const SizedBox(height: 12),
                        Text(
                          'No tasks yet',
                          style: Theme.of(context).textTheme.titleSmall
                              ?.copyWith(color: AppColors.textMuted),
                        ),
                        const SizedBox(height: 4),
                        Text(
                          'Tap + to add your first task',
                          style: Theme.of(context).textTheme.labelSmall,
                        ),
                      ],
                    ),
                  ),
                const SizedBox(height: 24),
              ],
            ),
          );
        },
      ),
    );
  }
}

class _TimelineFilter {
  const _TimelineFilter({required this.label, required this.value});

  final String label;
  final String value;
}
