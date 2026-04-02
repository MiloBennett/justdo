class FocusRecord {
  final String id;
  final String todoId;
  final String todoTitle;
  final String? category;
  final int duration; // 分钟
  final DateTime completedAt;

  FocusRecord({
    required this.id,
    required this.todoId,
    required this.todoTitle,
    this.category,
    required this.duration,
    required this.completedAt,
  });

  Map<String, dynamic> toJson() => {
    'id': id,
    'todoId': todoId,
    'todoTitle': todoTitle,
    'category': category,
    'duration': duration,
    'completedAt': completedAt.toIso8601String(),
  };

  factory FocusRecord.fromJson(Map<String, dynamic> json) => FocusRecord(
    id: json['id'],
    todoId: json['todoId'],
    todoTitle: json['todoTitle'],
    category: json['category'],
    duration: json['duration'],
    completedAt: DateTime.parse(json['completedAt']),
  );
}

class FocusRecordManager {
  static final List<FocusRecord> _records = [];

  static List<FocusRecord> get records => List.unmodifiable(_records);

  static void addRecord(FocusRecord record) {
    _records.add(record);
  }

  static void clearRecords() {
    _records.clear();
  }

  static int getTotalDurationByCategory(String category) {
    return _records
        .where((r) => (r.category ?? '未分类') == category)
        .fold(0, (sum, r) => sum + r.duration);
  }

  static Map<String, int> getDurationByCategory() {
    final result = <String, int>{};
    for (final record in _records) {
      final category = record.category ?? '未分类';
      result[category] = (result[category] ?? 0) + record.duration;
    }
    return result;
  }

  static Map<String, int> getCountByCategory() {
    final result = <String, int>{};
    for (final record in _records) {
      final category = record.category ?? '未分类';
      result[category] = (result[category] ?? 0) + 1;
    }
    return result;
  }
}
