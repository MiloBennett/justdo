class Todo {
  String id;
  String title;
  String description;
  bool isCompleted;
  DateTime createdAt;
  DateTime? startTime;
  DateTime? endTime;
  int? duration; // 时长（分钟）
  int? priority; // 优先级（1-5，5最高）
  List<Todo> subtasks;
  bool isExpanded;
  bool isReluctant; // 标记为"不想做但得做"的任务
  String? promiseTargetId; // 承诺完成后要回去做的任务ID
  String? promiseTargetTitle; // 承诺的任务标题
  String? category; // 任务分类（生活、学习、购物、游玩）

  Todo({
    required this.id,
    required this.title,
    this.description = '',
    this.isCompleted = false,
    DateTime? createdAt,
    this.startTime,
    this.endTime,
    this.duration,
    this.priority,
    List<Todo>? subtasks,
    this.isExpanded = false,
    this.isReluctant = false,
    this.promiseTargetId,
    this.promiseTargetTitle,
    this.category,
  }) : createdAt = createdAt ?? DateTime.now(),
       subtasks = subtasks ?? [];

  void toggleComplete() {
    isCompleted = !isCompleted;
  }

  void toggleReluctant() {
    isReluctant = !isReluctant;
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

  static int calculatePriorityFromDuration(int durationMinutes) {
    if (durationMinutes >= 240) return 5; // 4小时以上：最高优先级
    if (durationMinutes >= 120) return 4; // 2-4小时：高优先级
    if (durationMinutes >= 60) return 3; // 1-2小时：中优先级
    if (durationMinutes >= 30) return 2; // 30分钟-1小时：低优先级
    return 1; // 30分钟以下：最低优先级
  }

  void sortSubtasksByPriority() {
    subtasks.sort((a, b) {
      final priorityA = a.priority ?? 0;
      final priorityB = b.priority ?? 0;
      return priorityB.compareTo(priorityA); // 降序
    });
  }

  // 获取当前任务树的最大深度（从1开始计数）
  int get maxDepth {
    if (subtasks.isEmpty) return 1;
    return 2; // 只有一层子任务
  }

  // 检查是否可以添加子任务（只有主任务可以添加子任务）
  bool get canAddSubtask {
    return subtasks.isEmpty || subtasks.first.subtasks.isEmpty;
  }
}
