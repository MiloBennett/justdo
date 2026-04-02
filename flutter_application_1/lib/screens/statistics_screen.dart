import 'package:flutter/cupertino.dart';
import 'package:fl_chart/fl_chart.dart';
import '../models/todo.dart';
import '../models/focus_record.dart';

class StatisticsScreen extends StatelessWidget {
  final List<Todo> todos;

  const StatisticsScreen({super.key, required this.todos});

  @override
  Widget build(BuildContext context) {
    final totalTodos = todos.length;
    final completedTodos = todos.where((t) => t.isCompleted).length;
    final pendingTodos = todos.where((t) => !t.isCompleted).length;
    final reluctantTodos = todos
        .where((t) => t.isReluctant && !t.isCompleted)
        .length;
    final completionRate = totalTodos > 0
        ? (completedTodos / totalTodos * 100).toStringAsFixed(1)
        : '0.0';

    final categoryStats = <String, int>{};
    for (var todo in todos) {
      final category = todo.category ?? '未分类';
      categoryStats[category] = (categoryStats[category] ?? 0) + 1;
    }

    final durationByCategory = FocusRecordManager.getDurationByCategory();

    return CupertinoPageScaffold(
      navigationBar: const CupertinoNavigationBar(middle: Text('数据统计')),
      child: SafeArea(
        child: ListView(
          padding: const EdgeInsets.all(16),
          children: [
            _buildOverviewCard(
              totalTodos: totalTodos,
              completedTodos: completedTodos,
              pendingTodos: pendingTodos,
              reluctantTodos: reluctantTodos,
              completionRate: completionRate,
            ),
            const SizedBox(height: 20),
            _buildPieChartSection(title: '任务分布', data: categoryStats),
            const SizedBox(height: 20),
            _buildPieChartSection(
              title: '专注时长分布（分钟）',
              data: durationByCategory,
            ),
            const SizedBox(height: 20),
            _buildCategorySection(categoryStats),
            const SizedBox(height: 20),
            _buildProgressSection(completedTodos, totalTodos),
          ],
        ),
      ),
    );
  }

  Widget _buildOverviewCard({
    required int totalTodos,
    required int completedTodos,
    required int pendingTodos,
    required int reluctantTodos,
    required String completionRate,
  }) {
    return Container(
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        gradient: const LinearGradient(
          colors: [CupertinoColors.activeBlue, Color(0xFF5AC8FA)],
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
        ),
        borderRadius: BorderRadius.circular(16),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const Text(
            '任务概览',
            style: TextStyle(
              fontSize: 18,
              fontWeight: FontWeight.bold,
              color: CupertinoColors.white,
              decoration: TextDecoration.none,
            ),
          ),
          const SizedBox(height: 20),
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceAround,
            children: [
              _buildStatItem(
                '总计',
                totalTodos.toString(),
                CupertinoColors.white,
              ),
              _buildStatItem(
                '已完成',
                completedTodos.toString(),
                CupertinoColors.white,
              ),
              _buildStatItem(
                '待办',
                pendingTodos.toString(),
                CupertinoColors.white,
              ),
              _buildStatItem('完成率', '$completionRate%', CupertinoColors.white),
            ],
          ),
        ],
      ),
    );
  }

  Widget _buildStatItem(String label, String value, Color color) {
    return Column(
      children: [
        Text(
          value,
          style: TextStyle(
            fontSize: 24,
            fontWeight: FontWeight.bold,
            color: color,
            decoration: TextDecoration.none,
          ),
        ),
        const SizedBox(height: 4),
        Text(
          label,
          style: TextStyle(
            fontSize: 12,
            color: color.withOpacity(0.8),
            decoration: TextDecoration.none,
          ),
        ),
      ],
    );
  }

  Widget _buildPieChartSection({
    required String title,
    required Map<String, int> data,
  }) {
    final total = data.values.fold(0, (sum, value) => sum + value);

    if (data.isEmpty || total == 0) {
      return Container(
        padding: const EdgeInsets.all(16),
        decoration: BoxDecoration(
          color: CupertinoColors.systemBackground,
          borderRadius: BorderRadius.circular(12),
          border: Border.all(color: CupertinoColors.separator),
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              title,
              style: const TextStyle(
                fontSize: 16,
                fontWeight: FontWeight.bold,
                color: CupertinoColors.label,
                decoration: TextDecoration.none,
              ),
            ),
            const SizedBox(height: 16),
            Center(
              child: Text(
                title.contains('时长') ? '暂无时长数据' : '暂无任务数据',
                style: const TextStyle(
                  fontSize: 10,
                  color: CupertinoColors.systemGrey,
                  decoration: TextDecoration.none,
                ),
              ),
            ),
          ],
        ),
      );
    }

    final colors = [
      const Color(0xFF2196F3), // 蓝色
      const Color(0xFF4CAF50), // 绿色
      const Color(0xFFFF9800), // 橙色
      const Color(0xFF9C27B0), // 紫色
      const Color(0xFF00BCD4), // 青色
      const Color(0xFFFFEB3B), // 黄色
      const Color(0xFF795548), // 棕色
      const Color(0xFF607D8B), // 蓝灰色
    ];

    int colorIndex = 0;
    final pieSections = <PieChartSectionData>[];
    final legendItems = <Map<String, dynamic>>[];

    for (final entry in data.entries) {
      if (entry.value > 0) {
        final percentage = (entry.value / total * 100);
        final color = colors[colorIndex % colors.length];
        pieSections.add(
          PieChartSectionData(
            value: entry.value.toDouble(),
            color: color,
            title: '${percentage.toStringAsFixed(1)}%',
            radius: 50,
            titleStyle: const TextStyle(
              fontSize: 10,
              fontWeight: FontWeight.bold,
              color: CupertinoColors.white,
              decoration: TextDecoration.none,
              backgroundColor: Color(0x00000000),
            ),
            titlePositionPercentageOffset: 0.6,
          ),
        );
        legendItems.add({
          'category': entry.key,
          'value': entry.value,
          'color': color,
        });
        colorIndex++;
      }
    }

    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: CupertinoColors.systemBackground,
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: CupertinoColors.separator),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            title,
            style: const TextStyle(
              fontSize: 16,
              fontWeight: FontWeight.bold,
              color: CupertinoColors.label,
              decoration: TextDecoration.none,
            ),
          ),
          const SizedBox(height: 16),
          SizedBox(
            height: 200,
            child: Row(
              children: [
                Expanded(
                  child: PieChart(
                    PieChartData(
                      sections: pieSections,
                      centerSpaceRadius: 0,
                      sectionsSpace: 2,
                    ),
                  ),
                ),
                const SizedBox(width: 16),
                Column(
                  mainAxisAlignment: MainAxisAlignment.center,
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: legendItems
                      .map(
                        (item) => Padding(
                          padding: const EdgeInsets.symmetric(vertical: 4),
                          child: Row(
                            children: [
                              Container(
                                width: 12,
                                height: 12,
                                decoration: BoxDecoration(
                                  color: item['color'] as Color,
                                  shape: BoxShape.circle,
                                ),
                              ),
                              const SizedBox(width: 8),
                              Text(
                                '${item['category']} (${item['value']})',
                                style: const TextStyle(
                                  fontSize: 12,
                                  color: CupertinoColors.label,
                                  decoration: TextDecoration.none,
                                ),
                              ),
                            ],
                          ),
                        ),
                      )
                      .toList(),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildCategorySection(Map<String, int> categoryStats) {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: CupertinoColors.systemBackground,
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: CupertinoColors.separator),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const Text(
            '分类统计',
            style: TextStyle(
              fontSize: 16,
              fontWeight: FontWeight.bold,
              color: CupertinoColors.label,
              decoration: TextDecoration.none,
            ),
          ),
          const SizedBox(height: 12),
          if (categoryStats.isEmpty)
            const Text(
              '暂无数据',
              style: TextStyle(
                fontSize: 10,
                color: CupertinoColors.systemGrey,
                decoration: TextDecoration.none,
              ),
            )
          else
            ...categoryStats.entries.map(
              (entry) => _buildCategoryItem(
                entry.key,
                entry.value,
                categoryStats.values.reduce((a, b) => a + b),
              ),
            ),
        ],
      ),
    );
  }

  Widget _buildCategoryItem(String category, int count, int total) {
    final percentage = total > 0
        ? (count / total * 100).toStringAsFixed(0)
        : '0';
    return Padding(
      padding: const EdgeInsets.only(bottom: 12),
      child: Row(
        children: [
          Expanded(
            flex: 2,
            child: Text(
              category,
              style: const TextStyle(
                fontSize: 14,
                decoration: TextDecoration.none,
              ),
            ),
          ),
          Expanded(
            flex: 3,
            child: Container(
              height: 8,
              decoration: BoxDecoration(
                color: CupertinoColors.systemGrey5,
                borderRadius: BorderRadius.circular(4),
              ),
              child: FractionallySizedBox(
                alignment: Alignment.centerLeft,
                widthFactor: count / (total > 0 ? total : 1),
                child: Container(
                  decoration: BoxDecoration(
                    color: CupertinoColors.activeBlue,
                    borderRadius: BorderRadius.circular(4),
                  ),
                ),
              ),
            ),
          ),
          const SizedBox(width: 8),
          SizedBox(
            width: 50,
            child: Text(
              '$count ($percentage%)',
              style: const TextStyle(
                fontSize: 12,
                color: CupertinoColors.systemGrey,
                decoration: TextDecoration.none,
              ),
              textAlign: TextAlign.right,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildProgressSection(int completed, int total) {
    final progress = total > 0 ? completed / total : 0.0;
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: CupertinoColors.systemBackground,
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: CupertinoColors.separator),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const Text(
            '完成进度',
            style: TextStyle(
              fontSize: 16,
              fontWeight: FontWeight.bold,
              color: CupertinoColors.label,
              decoration: TextDecoration.none,
            ),
          ),
          const SizedBox(height: 16),
          ClipRRect(
            borderRadius: BorderRadius.circular(8),
            child: Container(
              height: 12,
              decoration: BoxDecoration(
                color: CupertinoColors.systemGrey5,
                borderRadius: BorderRadius.circular(8),
              ),
              child: FractionallySizedBox(
                alignment: Alignment.centerLeft,
                widthFactor: progress,
                child: Container(
                  decoration: BoxDecoration(
                    color: CupertinoColors.activeBlue,
                    borderRadius: BorderRadius.circular(8),
                  ),
                ),
              ),
            ),
          ),
          const SizedBox(height: 8),
          Text(
            '已完成 $completed / $total 个任务',
            style: const TextStyle(
              fontSize: 13,
              color: CupertinoColors.systemGrey,
              decoration: TextDecoration.none,
            ),
          ),
        ],
      ),
    );
  }
}
