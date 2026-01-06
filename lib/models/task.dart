class Task {
  const Task({
    required this.id,
    required this.title,
    required this.completed,
    required this.timeline,
    required this.category,
  });

  final String id;
  final String title;
  final bool completed;
  final String timeline;
  final String category;

  Task copyWith({
    bool? completed,
  }) {
    return Task(
      id: id,
      title: title,
      completed: completed ?? this.completed,
      timeline: timeline,
      category: category,
    );
  }
}
