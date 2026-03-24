import 'package:flutter/material.dart';
import '../models/todo.dart';

class TodoMindMapScreen extends StatefulWidget {
  final Todo todo;
  final Function(Todo) onToggle;
  final Function(Todo, Todo) onAddSubtask;
  final Function(Todo, Todo) onDeleteSubtask;
  final Function(Todo, Todo) onToggleSubtask;

  const TodoMindMapScreen({
    super.key,
    required this.todo,
    required this.onToggle,
    required this.onAddSubtask,
    required this.onDeleteSubtask,
    required this.onToggleSubtask,
  });

  @override
  State<TodoMindMapScreen> createState() => _TodoMindMapScreenState();
}

class _TodoMindMapScreenState extends State<TodoMindMapScreen> {
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text(widget.todo.title),
        actions: [
          if (widget.todo.subtasks.isNotEmpty)
            Center(
              child: Padding(
                padding: const EdgeInsets.only(right: 16),
                child: Text(
                  '${widget.todo.completedSubtasksCount}/${widget.todo.totalSubtasksCount}',
                  style: const TextStyle(fontSize: 14),
                ),
              ),
            ),
        ],
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // 主任务卡片
            _buildMainTaskCard(),
            const SizedBox(height: 24),
            // 子任务树
            if (widget.todo.subtasks.isNotEmpty) ...[
              const Text(
                '子任务',
                style: TextStyle(
                  fontSize: 16,
                  fontWeight: FontWeight.bold,
                  color: Colors.grey,
                ),
              ),
              const SizedBox(height: 12),
              _buildSubtaskTree(widget.todo, 0),
            ],
            // 添加子任务按钮
            const SizedBox(height: 16),
            _buildAddSubtaskButton(widget.todo),
          ],
        ),
      ),
    );
  }

  Widget _buildMainTaskCard() {
    final theme = Theme.of(context);

    return Card(
      elevation: 4,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                GestureDetector(
                  onTap: () {
                    setState(() {
                      widget.onToggle(widget.todo);
                    });
                  },
                  child: Icon(
                    widget.todo.isCompleted
                        ? Icons.check_circle
                        : Icons.circle_outlined,
                    color: widget.todo.isCompleted
                        ? Colors.green
                        : theme.colorScheme.primary,
                    size: 28,
                  ),
                ),
                const SizedBox(width: 12),
                Expanded(
                  child: Text(
                    widget.todo.title,
                    style: TextStyle(
                      fontSize: 18,
                      fontWeight: FontWeight.bold,
                      decoration: widget.todo.isCompleted
                          ? TextDecoration.lineThrough
                          : null,
                      color: widget.todo.isCompleted ? Colors.grey : null,
                    ),
                  ),
                ),
              ],
            ),
            if (widget.todo.description.isNotEmpty) ...[
              const SizedBox(height: 12),
              Text(
                widget.todo.description,
                style: TextStyle(fontSize: 14, color: Colors.grey.shade700),
              ),
            ],
            if (widget.todo.subtasks.isNotEmpty) ...[
              const SizedBox(height: 16),
              LinearProgressIndicator(
                value: widget.todo.completionProgress,
                backgroundColor: Colors.grey.shade300,
                valueColor: AlwaysStoppedAnimation<Color>(
                  widget.todo.completionProgress >= 1.0
                      ? Colors.green
                      : theme.colorScheme.primary,
                ),
                minHeight: 6,
              ),
              const SizedBox(height: 8),
              Text(
                '进度: ${(widget.todo.completionProgress * 100).toInt()}%',
                style: TextStyle(fontSize: 12, color: Colors.grey.shade600),
              ),
            ],
          ],
        ),
      ),
    );
  }

  Widget _buildSubtaskTree(Todo parent, int depth) {
    if (parent.subtasks.isEmpty) return const SizedBox.shrink();

    final color = _getDepthColor(depth);

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: parent.subtasks.asMap().entries.map((entry) {
        final subtask = entry.value;
        final isLast = entry.key == parent.subtasks.length - 1;

        return Padding(
          padding: EdgeInsets.only(bottom: isLast ? 0 : 8),
          child: _buildSubtaskItem(subtask, parent, depth, color, isLast),
        );
      }).toList(),
    );
  }

  Widget _buildSubtaskItem(
    Todo subtask,
    Todo parent,
    int depth,
    Color color,
    bool isLast,
  ) {
    final hasChildren = subtask.subtasks.isNotEmpty;

    return Row(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        // 树状连接线
        if (depth > 0) _buildTreeLines(depth, isLast),
        // 子任务卡片
        Expanded(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // 子任务内容
              Container(
                decoration: BoxDecoration(
                  color: Colors.white,
                  borderRadius: BorderRadius.circular(12),
                  border: Border.all(color: color.withOpacity(0.5)),
                  boxShadow: [
                    BoxShadow(
                      color: Colors.black.withOpacity(0.05),
                      blurRadius: 4,
                      offset: const Offset(0, 2),
                    ),
                  ],
                ),
                child: Padding(
                  padding: const EdgeInsets.all(12),
                  child: Row(
                    children: [
                      // 缩进指示器
                      Container(
                        width: 4,
                        height: 40,
                        decoration: BoxDecoration(
                          color: color,
                          borderRadius: BorderRadius.circular(2),
                        ),
                      ),
                      const SizedBox(width: 12),
                      // 复选框
                      GestureDetector(
                        onTap: () {
                          setState(() {
                            widget.onToggleSubtask(parent, subtask);
                          });
                        },
                        child: Icon(
                          subtask.isCompleted
                              ? Icons.check_circle
                              : Icons.circle_outlined,
                          color: subtask.isCompleted ? Colors.green : color,
                          size: 24,
                        ),
                      ),
                      const SizedBox(width: 12),
                      // 标题
                      Expanded(
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text(
                              subtask.title,
                              style: TextStyle(
                                fontSize: 15 - depth * 0.5,
                                fontWeight: depth == 0
                                    ? FontWeight.w600
                                    : FontWeight.normal,
                                decoration: subtask.isCompleted
                                    ? TextDecoration.lineThrough
                                    : null,
                                color: subtask.isCompleted ? Colors.grey : null,
                              ),
                            ),
                            if (hasChildren)
                              Padding(
                                padding: const EdgeInsets.only(top: 4),
                                child: Text(
                                  '${subtask.completedSubtasksCount}/${subtask.totalSubtasksCount} 子任务',
                                  style: TextStyle(
                                    fontSize: 11,
                                    color: Colors.grey.shade600,
                                  ),
                                ),
                              ),
                          ],
                        ),
                      ),
                      // 添加子任务按钮
                      IconButton(
                        icon: Icon(
                          Icons.add_circle_outline,
                          color: color,
                          size: 22,
                        ),
                        onPressed: () => _showAddSubtaskDialog(subtask),
                        padding: EdgeInsets.zero,
                        constraints: const BoxConstraints(
                          minWidth: 36,
                          minHeight: 36,
                        ),
                        tooltip: '添加子任务',
                      ),
                      // 删除按钮
                      IconButton(
                        icon: const Icon(
                          Icons.delete_outline,
                          color: Colors.red,
                          size: 20,
                        ),
                        onPressed: () {
                          setState(() {
                            widget.onDeleteSubtask(parent, subtask);
                          });
                        },
                        padding: EdgeInsets.zero,
                        constraints: const BoxConstraints(
                          minWidth: 36,
                          minHeight: 36,
                        ),
                        tooltip: '删除',
                      ),
                    ],
                  ),
                ),
              ),
              // 递归显示子任务
              if (hasChildren) ...[
                const SizedBox(height: 8),
                _buildSubtaskTree(subtask, depth + 1),
              ],
            ],
          ),
        ),
      ],
    );
  }

  Widget _buildTreeLines(int depth, bool isLast) {
    return SizedBox(
      width: 24.0 * depth,
      child: Row(
        children: List.generate(depth, (index) {
          final isLastLevel = index == depth - 1;
          return SizedBox(
            width: 24,
            child: CustomPaint(
              size: const Size(24, 48),
              painter: TreeLinePainter(
                isLastLevel: isLastLevel,
                isLastItem: isLast && isLastLevel,
                color: _getDepthColor(index),
              ),
            ),
          );
        }),
      ),
    );
  }

  Widget _buildAddSubtaskButton(Todo parent) {
    return SizedBox(
      width: double.infinity,
      child: OutlinedButton.icon(
        onPressed: () => _showAddSubtaskDialog(parent),
        icon: const Icon(Icons.add),
        label: const Text('添加子任务'),
        style: OutlinedButton.styleFrom(
          padding: const EdgeInsets.symmetric(vertical: 12),
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(12),
          ),
        ),
      ),
    );
  }

  Color _getDepthColor(int depth) {
    final colors = [
      Colors.blue,
      Colors.purple,
      Colors.orange,
      Colors.teal,
      Colors.pink,
    ];
    return colors[depth % colors.length];
  }

  void _showAddSubtaskDialog(Todo parent) {
    final controller = TextEditingController();

    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('添加子任务'),
        content: TextField(
          controller: controller,
          autofocus: true,
          decoration: const InputDecoration(
            hintText: '输入子任务名称',
            border: OutlineInputBorder(),
          ),
          onSubmitted: (value) {
            if (value.trim().isNotEmpty) {
              final subtask = Todo(
                id: DateTime.now().millisecondsSinceEpoch.toString(),
                title: value.trim(),
              );
              setState(() {
                widget.onAddSubtask(parent, subtask);
              });
              Navigator.pop(context);
            }
          },
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text('取消'),
          ),
          ElevatedButton(
            onPressed: () {
              if (controller.text.trim().isNotEmpty) {
                final subtask = Todo(
                  id: DateTime.now().millisecondsSinceEpoch.toString(),
                  title: controller.text.trim(),
                );
                setState(() {
                  widget.onAddSubtask(parent, subtask);
                });
                Navigator.pop(context);
              }
            },
            child: const Text('添加'),
          ),
        ],
      ),
    ).then((_) => controller.dispose());
  }
}

class TreeLinePainter extends CustomPainter {
  final bool isLastLevel;
  final bool isLastItem;
  final Color color;

  TreeLinePainter({
    required this.isLastLevel,
    required this.isLastItem,
    required this.color,
  });

  @override
  void paint(Canvas canvas, Size size) {
    final paint = Paint()
      ..color = color.withOpacity(0.5)
      ..strokeWidth = 2
      ..style = PaintingStyle.stroke;

    final centerY = size.height / 2;

    if (isLastLevel) {
      // 最后一级：画垂直线到中心，然后水平线到右边
      if (isLastItem) {
        // 最后一个项目：只画上半部分
        final path = Path()
          ..moveTo(size.width / 2, 0)
          ..lineTo(size.width / 2, centerY)
          ..lineTo(size.width, centerY);
        canvas.drawPath(path, paint);
      } else {
        // 非最后项目：画完整垂直线
        final path = Path()
          ..moveTo(size.width / 2, 0)
          ..lineTo(size.width / 2, size.height);
        canvas.drawPath(path, paint);
        // 画水平线
        final hPath = Path()
          ..moveTo(size.width / 2, centerY)
          ..lineTo(size.width, centerY);
        canvas.drawPath(hPath, paint);
      }
    } else {
      // 非最后一级：只画垂直线
      final path = Path()
        ..moveTo(size.width / 2, 0)
        ..lineTo(size.width / 2, size.height);
      canvas.drawPath(path, paint);
    }

    // 画连接点
    final dotPaint = Paint()
      ..color = color
      ..style = PaintingStyle.fill;
    canvas.drawCircle(Offset(size.width / 2, centerY), 3, dotPaint);
  }

  @override
  bool shouldRepaint(covariant CustomPainter oldDelegate) => false;
}
