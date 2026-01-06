import 'package:flutter/material.dart';

import '../data/mock_data.dart';
import '../models/task.dart';
import '../theme/app_theme.dart';
import '../widgets/layout/app_card.dart';
import '../widgets/layout/mobile_scaffold.dart';

class ChecklistScreen extends StatefulWidget {
  const ChecklistScreen({super.key});

  @override
  State<ChecklistScreen> createState() => _ChecklistScreenState();
}

class _ChecklistScreenState extends State<ChecklistScreen> {
  late List<Task> tasks;
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
  void initState() {
    super.initState();
    tasks = seedTasks();
  }

  @override
  void dispose() {
    searchController.dispose();
    super.dispose();
  }

  void toggleTask(String taskId) {
    setState(() {
      tasks = tasks
          .map((task) => task.id == taskId
              ? task.copyWith(completed: !task.completed)
              : task)
          .toList();
    });
  }

  void toggleSection(String timeline) {
    setState(() {
      expandedSections[timeline] = !(expandedSections[timeline] ?? true);
    });
  }

  @override
  Widget build(BuildContext context) {
    final completedCount = tasks.where((task) => task.completed).length;
    final totalCount = tasks.length;
    final progress = totalCount == 0 ? 0.0 : completedCount / totalCount;

    final filteredTasks = tasks.where((task) {
      final timelineMatch =
          selectedTimeline == 'All' || task.timeline == selectedTimeline;
      final searchMatch = task.title.toLowerCase().contains(searchQuery.toLowerCase());
      return timelineMatch && searchMatch;
    }).toList();

    final Map<String, List<Task>> groupedTasks = {};
    for (final task in filteredTasks) {
      groupedTasks.putIfAbsent(task.timeline, () => []).add(task);
    }

    return MobileScaffold(
      currentIndex: 1,
      title: 'Checklist',
      showLogo: false,
      floatingActionButton: FloatingActionButton(
        onPressed: () {},
        backgroundColor: AppColors.primary,
        child: const Icon(Icons.add, color: Colors.white),
      ),
      child: SingleChildScrollView(
        padding: const EdgeInsets.fromLTRB(16, 16, 16, 24),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            AppCard(
              padding: const EdgeInsets.all(16),
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
                              'Progress',
                              style: TextStyle(fontSize: 12, fontWeight: FontWeight.w600),
                            ),
                            Text(
                              '$completedCount/$totalCount',
                              style: const TextStyle(fontSize: 11, color: AppColors.textMuted),
                            ),
                          ],
                        ),
                        const SizedBox(height: 6),
                        LinearProgressIndicator(
                          value: progress,
                          minHeight: 6,
                          backgroundColor: AppColors.primarySoft,
                          color: AppColors.primary,
                          borderRadius: BorderRadius.circular(999),
                        ),
                      ],
                    ),
                  ),
                  const SizedBox(width: 16),
                  Text(
                    '${(progress * 100).round()}%',
                    style: Theme.of(context).textTheme.headlineSmall,
                  ),
                ],
              ),
            ),
            const SizedBox(height: 16),
            TextField(
              controller: searchController,
              onChanged: (value) => setState(() => searchQuery = value),
              decoration: const InputDecoration(
                hintText: 'Search tasks...',
                prefixIcon: Icon(Icons.search),
              ),
            ),
            const SizedBox(height: 12),
            SizedBox(
              height: 38,
              child: ListView.separated(
                scrollDirection: Axis.horizontal,
                itemCount: timelineFilters.length,
                separatorBuilder: (_, __) => const SizedBox(width: 8),
                itemBuilder: (context, index) {
                  final filter = timelineFilters[index];
                  final selected = selectedTimeline == filter.value;
                  return ChoiceChip(
                    label: Text(filter.label),
                    selected: selected,
                    onSelected: (_) => setState(() => selectedTimeline = filter.value),
                    selectedColor: AppColors.primary,
                    backgroundColor: AppColors.surface,
                    labelStyle: TextStyle(
                      fontSize: 11,
                      color: selected ? Colors.white : AppColors.textPrimary,
                      fontWeight: FontWeight.w600,
                    ),
                  );
                },
              ),
            ),
            const SizedBox(height: 16),
            ...groupedTasks.entries.map((entry) {
              final timeline = entry.key;
              final timelineTasks = entry.value;
              final isExpanded = expandedSections[timeline] ?? true;
              final completedInGroup =
                  timelineTasks.where((task) => task.completed).length;

              return Padding(
                padding: const EdgeInsets.only(bottom: 12),
                child: AppCard(
                  padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
                  child: Column(
                    children: [
                      InkWell(
                        onTap: () => toggleSection(timeline),
                        child: Padding(
                          padding: const EdgeInsets.symmetric(vertical: 6),
                          child: Row(
                            mainAxisAlignment: MainAxisAlignment.spaceBetween,
                            children: [
                              Row(
                                children: [
                                  Text(
                                    '$timeline before',
                                    style: const TextStyle(fontSize: 13, fontWeight: FontWeight.w600),
                                  ),
                                  const SizedBox(width: 8),
                                  _Badge(text: '$completedInGroup/${timelineTasks.length}'),
                                ],
                              ),
                              Icon(
                                isExpanded ? Icons.expand_less : Icons.expand_more,
                                color: AppColors.textMuted,
                              ),
                            ],
                          ),
                        ),
                      ),
                      if (isExpanded)
                        Column(
                          children: timelineTasks.map((task) {
                            return Padding(
                              padding: const EdgeInsets.only(bottom: 8),
                              child: InkWell(
                                onTap: () => toggleTask(task.id),
                                borderRadius: BorderRadius.circular(12),
                                child: Container(
                                  padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 10),
                                  decoration: BoxDecoration(
                                    color: task.completed
                                        ? AppColors.primarySoft
                                        : AppColors.background,
                                    borderRadius: BorderRadius.circular(12),
                                    border: Border.all(color: AppColors.border),
                                  ),
                                  child: Row(
                                    children: [
                                      Checkbox(
                                        value: task.completed,
                                        activeColor: AppColors.primary,
                                        onChanged: (_) => toggleTask(task.id),
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
                          }).toList(),
                        ),
                    ],
                  ),
                ),
              );
            }),
            const SizedBox(height: 24),
          ],
        ),
      ),
    );
  }
}

class _TimelineFilter {
  const _TimelineFilter({required this.label, required this.value});

  final String label;
  final String value;
}

class _Badge extends StatelessWidget {
  const _Badge({required this.text});

  final String text;

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 2),
      decoration: BoxDecoration(
        color: AppColors.primarySoft,
        borderRadius: BorderRadius.circular(999),
      ),
      child: Text(
        text,
        style: const TextStyle(fontSize: 10, fontWeight: FontWeight.w600),
      ),
    );
  }
}
