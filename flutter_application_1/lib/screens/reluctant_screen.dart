import 'package:flutter/material.dart';
import 'package:flutter/cupertino.dart';
import '../models/todo.dart';

class ReluctantScreen extends StatefulWidget {
  final List<Todo> todos;
  final Function(Todo) onToggleComplete;
  final Function(Todo) onRemoveTodo;
  final Function(Todo) onToggleReluctant;

  const ReluctantScreen({
    super.key,
    required this.todos,
    required this.onToggleComplete,
    required this.onRemoveTodo,
    required this.onToggleReluctant,
  });

  @override
  State<ReluctantScreen> createState() => _ReluctantScreenState();
}

class _ReluctantScreenState extends State<ReluctantScreen> {
  // 获取今天的"不想做但得做"任务
  List<Todo> get reluctantTodos {
    final now = DateTime.now();
    return widget.todos.where((todo) {
      if (!todo.isReluctant) return false;
      if (todo.startTime == null) return true;
      return todo.startTime!.year == now.year &&
          todo.startTime!.month == now.month &&
          todo.startTime!.day == now.day;
    }).toList();
  }

  // 获取激励文案
  String getMotivationalText() {
    final messages = [
      '今天也要加油鸭！',
      '完成这些任务，你会更强大！',
      '不想做也得做，那就开心地做！',
      '每一步都是进步！',
      '战胜懒惰，拥抱成功！',
      '今天的努力，明天的收获！',
      '再难也要坚持下去！',
      '做完这些，奖励自己！',
    ];
    final index = DateTime.now().millisecondsSinceEpoch % messages.length;
    return messages[index];
  }

  @override
  Widget build(BuildContext context) {
    return CupertinoPageScaffold(
      navigationBar: CupertinoNavigationBar(
        middle: const Text('反效率'),
        leading: GestureDetector(
          onTap: () => Navigator.pop(context),
          child: const Icon(CupertinoIcons.back),
        ),
      ),
      child: SafeArea(
        child: reluctantTodos.isEmpty ? _buildEmptyState() : _buildTaskList(),
      ),
    );
  }

  Widget _buildEmptyState() {
    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Container(
            width: 120,
            height: 120,
            decoration: BoxDecoration(
              color: CupertinoColors.systemGreen.withOpacity(0.1),
              shape: BoxShape.circle,
            ),
            child: const Icon(
              CupertinoIcons.check_mark_circled,
              size: 60,
              color: CupertinoColors.systemGreen,
            ),
          ),
          const SizedBox(height: 24),
          const Text(
            '太棒了！',
            style: TextStyle(
              fontSize: 24,
              fontWeight: FontWeight.bold,
              color: CupertinoColors.black,
            ),
          ),
          const SizedBox(height: 12),
          const Text(
            '今天没有不想做的任务',
            style: TextStyle(fontSize: 16, color: CupertinoColors.systemGrey),
          ),
          const SizedBox(height: 8),
          const Text(
            '继续保持！',
            style: TextStyle(fontSize: 14, color: CupertinoColors.systemGrey2),
          ),
        ],
      ),
    );
  }

  Widget _buildTaskList() {
    final completedCount = reluctantTodos.where((t) => t.isCompleted).length;
    final totalCount = reluctantTodos.length;
    final progress = totalCount > 0 ? completedCount / totalCount : 0.0;

    return Column(
      children: [
        // 顶部激励区域
        Container(
          padding: const EdgeInsets.all(20),
          decoration: BoxDecoration(
            gradient: LinearGradient(
              colors: [
                CupertinoColors.systemOrange.withOpacity(0.1),
                CupertinoColors.systemRed.withOpacity(0.1),
              ],
              begin: Alignment.topLeft,
              end: Alignment.bottomRight,
            ),
          ),
          child: Column(
            children: [
              Row(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  const Icon(
                    CupertinoIcons.flame,
                    color: CupertinoColors.systemOrange,
                    size: 28,
                  ),
                  const SizedBox(width: 8),
                  Text(
                    getMotivationalText(),
                    style: const TextStyle(
                      fontSize: 18,
                      fontWeight: FontWeight.w600,
                      color: CupertinoColors.black,
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 16),
              // 进度条
              Column(
                children: [
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      Text(
                        '已完成 $completedCount/$totalCount',
                        style: const TextStyle(
                          fontSize: 14,
                          color: CupertinoColors.systemGrey,
                        ),
                      ),
                      Text(
                        '${(progress * 100).toInt()}%',
                        style: const TextStyle(
                          fontSize: 14,
                          fontWeight: FontWeight.bold,
                          color: CupertinoColors.systemOrange,
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: 8),
                  LinearProgressIndicator(
                    value: progress,
                    backgroundColor: CupertinoColors.systemGrey5,
                    valueColor: const AlwaysStoppedAnimation<Color>(
                      CupertinoColors.systemOrange,
                    ),
                    minHeight: 8,
                    borderRadius: BorderRadius.circular(4),
                  ),
                ],
              ),
            ],
          ),
        ),

        // 任务列表
        Expanded(
          child: ListView.builder(
            padding: const EdgeInsets.all(16),
            itemCount: reluctantTodos.length,
            itemBuilder: (context, index) {
              return _buildTaskItem(reluctantTodos[index]);
            },
          ),
        ),

        // 底部提示
        if (completedCount == totalCount && totalCount > 0)
          Container(
            padding: const EdgeInsets.all(16),
            color: CupertinoColors.systemGreen.withOpacity(0.1),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                const Icon(
                  CupertinoIcons.star_fill,
                  color: CupertinoColors.systemGreen,
                  size: 20,
                ),
                const SizedBox(width: 8),
                const Text(
                  '所有任务已完成！给自己一个奖励吧！',
                  style: TextStyle(
                    fontSize: 14,
                    fontWeight: FontWeight.w600,
                    color: CupertinoColors.systemGreen,
                  ),
                ),
              ],
            ),
          ),
      ],
    );
  }

  Widget _buildTaskItem(Todo todo) {
    return Container(
      margin: const EdgeInsets.only(bottom: 12),
      decoration: BoxDecoration(
        color: CupertinoColors.white,
        borderRadius: BorderRadius.circular(12),
        boxShadow: [
          BoxShadow(
            color: CupertinoColors.systemGrey.withOpacity(0.1),
            blurRadius: 8,
            offset: const Offset(0, 2),
          ),
        ],
        border: todo.isCompleted
            ? Border.all(color: CupertinoColors.systemGreen, width: 2)
            : null,
      ),
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Row(
          children: [
            // 完成状态按钮
            GestureDetector(
              onTap: () => widget.onToggleComplete(todo),
              child: Container(
                width: 28,
                height: 28,
                decoration: BoxDecoration(
                  shape: BoxShape.circle,
                  color: todo.isCompleted
                      ? CupertinoColors.systemGreen
                      : Colors.transparent,
                  border: Border.all(
                    color: todo.isCompleted
                        ? CupertinoColors.systemGreen
                        : CupertinoColors.systemGrey3,
                    width: 2,
                  ),
                ),
                child: todo.isCompleted
                    ? const Icon(
                        CupertinoIcons.check_mark,
                        color: CupertinoColors.white,
                        size: 16,
                      )
                    : null,
              ),
            ),
            const SizedBox(width: 12),

            // 任务内容
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    todo.title,
                    style: TextStyle(
                      fontSize: 16,
                      fontWeight: FontWeight.w600,
                      color: todo.isCompleted
                          ? CupertinoColors.systemGrey
                          : CupertinoColors.black,
                      decoration: todo.isCompleted
                          ? TextDecoration.lineThrough
                          : null,
                    ),
                  ),
                  if (todo.description.isNotEmpty) ...[
                    const SizedBox(height: 4),
                    Text(
                      todo.description,
                      style: TextStyle(
                        fontSize: 14,
                        color: CupertinoColors.systemGrey.withOpacity(0.8),
                      ),
                      maxLines: 2,
                      overflow: TextOverflow.ellipsis,
                    ),
                  ],
                  const SizedBox(height: 8),
                  Row(
                    children: [
                      Container(
                        padding: const EdgeInsets.symmetric(
                          horizontal: 8,
                          vertical: 4,
                        ),
                        decoration: BoxDecoration(
                          color: CupertinoColors.systemOrange.withOpacity(0.1),
                          borderRadius: BorderRadius.circular(4),
                        ),
                        child: const Row(
                          mainAxisSize: MainAxisSize.min,
                          children: [
                            Icon(
                              CupertinoIcons.flame,
                              color: CupertinoColors.systemOrange,
                              size: 12,
                            ),
                            SizedBox(width: 4),
                            Text(
                              '不想做但得做',
                              style: TextStyle(
                                fontSize: 12,
                                color: CupertinoColors.systemOrange,
                                fontWeight: FontWeight.w600,
                              ),
                            ),
                          ],
                        ),
                      ),
                    ],
                  ),
                ],
              ),
            ),

            // 操作按钮
            Column(
              children: [
                GestureDetector(
                  onTap: () {
                    if (todo.promiseTargetTitle != null) {
                      showCupertinoDialog(
                        context: context,
                        builder: (context) => CupertinoAlertDialog(
                          title: const Column(
                            children: [
                              Icon(
                                CupertinoIcons.hand_raised_fill,
                                color: CupertinoColors.systemGreen,
                                size: 32,
                              ),
                              SizedBox(height: 8),
                              Text('你的承诺'),
                            ],
                          ),
                          content: Padding(
                            padding: const EdgeInsets.only(top: 16),
                            child: Text(
                              '做完 "${todo.promiseTargetTitle}"，必须回头啃 "${todo.title}"',
                              style: const TextStyle(fontSize: 15),
                              textAlign: TextAlign.center,
                            ),
                          ),
                          actions: [
                            CupertinoDialogAction(
                              child: const Text('取消标记'),
                              onPressed: () {
                                Navigator.pop(context);
                                widget.onToggleReluctant(todo);
                              },
                            ),
                            CupertinoDialogAction(
                              isDefaultAction: true,
                              child: const Text('知道了'),
                              onPressed: () => Navigator.pop(context),
                            ),
                          ],
                        ),
                      );
                    } else {
                      widget.onToggleReluctant(todo);
                    }
                  },
                  child: Container(
                    padding: const EdgeInsets.all(8),
                    decoration: BoxDecoration(
                      color: CupertinoColors.systemGrey6,
                      borderRadius: BorderRadius.circular(8),
                    ),
                    child: Stack(
                      children: [
                        const Icon(
                          CupertinoIcons.arrow_uturn_left,
                          color: CupertinoColors.systemGrey,
                          size: 18,
                        ),
                        if (todo.promiseTargetId != null)
                          Positioned(
                            right: -2,
                            top: -2,
                            child: Container(
                              width: 8,
                              height: 8,
                              decoration: const BoxDecoration(
                                color: CupertinoColors.systemGreen,
                                shape: BoxShape.circle,
                              ),
                            ),
                          ),
                      ],
                    ),
                  ),
                ),
                const SizedBox(height: 8),
                GestureDetector(
                  onTap: () {
                    showCupertinoDialog(
                      context: context,
                      builder: (context) => CupertinoAlertDialog(
                        title: const Text('删除任务'),
                        content: Text('确定要删除"${todo.title}"吗？'),
                        actions: [
                          CupertinoDialogAction(
                            child: const Text('取消'),
                            onPressed: () => Navigator.pop(context),
                          ),
                          CupertinoDialogAction(
                            isDestructiveAction: true,
                            child: const Text('删除'),
                            onPressed: () {
                              widget.onRemoveTodo(todo);
                              Navigator.pop(context);
                            },
                          ),
                        ],
                      ),
                    );
                  },
                  child: Container(
                    padding: const EdgeInsets.all(8),
                    decoration: BoxDecoration(
                      color: CupertinoColors.destructiveRed.withOpacity(0.1),
                      borderRadius: BorderRadius.circular(8),
                    ),
                    child: const Icon(
                      CupertinoIcons.delete,
                      color: CupertinoColors.destructiveRed,
                      size: 18,
                    ),
                  ),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }
}
