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

  factory Task.fromDoc(dynamic doc) {
    final data = doc.data() as Map<String, dynamic>? ?? {};
    return Task(
      id: doc.id as String,
      title: (data['title'] ?? '').toString(),
      completed: data['completed'] == true,
      timeline: (data['timeline'] ?? '').toString(),
      category: (data['category'] ?? '').toString(),
    );
  }

  Map<String, dynamic> toMap() {
    return {
      'title': title,
      'completed': completed,
      'timeline': timeline,
      'category': category,
    };
  }

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
