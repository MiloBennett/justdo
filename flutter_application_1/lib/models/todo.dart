class Todo {
  String id;
  String title;
  String description;
  bool isCompleted;
  DateTime createdAt;
  List<Todo> subtasks;
  bool isExpanded;

  Todo({
    required this.id,
    required this.title,
    this.description = '',
    this.isCompleted = false,
    DateTime? createdAt,
    List<Todo>? subtasks,
    this.isExpanded = false,
  }) : createdAt = createdAt ?? DateTime.now(),
       subtasks = subtasks ?? [];

  void toggleComplete() {
    isCompleted = !isCompleted;
  }

  void toggleExpanded() {
    isExpanded = !isExpanded;
  }

  void addSubtask(Todo subtask) {
    subtasks.add(subtask);
  }

  void removeSubtask(String subtaskId) {
    subtasks.removeWhere((task) => task.id == subtaskId);
  }

  double get completionProgress {
    if (subtasks.isEmpty) {
      return isCompleted ? 1.0 : 0.0;
    }
    final completedCount = subtasks.where((task) => task.isCompleted).length;
    return completedCount / subtasks.length;
  }

  int get totalSubtasksCount {
    int count = subtasks.length;
    for (var subtask in subtasks) {
      count += subtask.totalSubtasksCount;
    }
    return count;
  }

  int get completedSubtasksCount {
    int count = subtasks.where((task) => task.isCompleted).length;
    for (var subtask in subtasks) {
      count += subtask.completedSubtasksCount;
    }
    return count;
  }
}
