import 'package:flutter/cupertino.dart';
import '../models/todo.dart';

class TodoDrawer extends StatelessWidget {
  final List<Todo> todos;
  final Function(String category)? onCategoryTap;

  const TodoDrawer({super.key, required this.todos, this.onCategoryTap});

  @override
  Widget build(BuildContext context) {
    final lifeCount = todos
        .where((t) => t.category == '生活' && !t.isCompleted)
        .length;
    final studyCount = todos
        .where((t) => t.category == '学习' && !t.isCompleted)
        .length;
    final shoppingCount = todos
        .where((t) => t.category == '购物' && !t.isCompleted)
        .length;
    final playCount = todos
        .where((t) => t.category == '游玩' && !t.isCompleted)
        .length;
    final otherCount = todos
        .where(
          (t) => (t.category == null || t.category!.isEmpty) && !t.isCompleted,
        )
        .length;
    final completedCount = todos.where((t) => t.isCompleted).length;

    return Container(
      width: 280,
      color: CupertinoColors.systemBackground,
      child: SafeArea(
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const SizedBox(height: 20),
            // 标题
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 20),
              child: Row(
                children: [
                  const Icon(
                    CupertinoIcons.list_bullet,
                    color: CupertinoColors.activeBlue,
                    size: 24,
                  ),
                  const SizedBox(width: 12),
                  const Text(
                    '任务分类',
                    style: TextStyle(
                      fontSize: 20,
                      fontWeight: FontWeight.bold,
                      color: CupertinoColors.label,
                      decoration: TextDecoration.none,
                    ),
                  ),
                ],
              ),
            ),
            const SizedBox(height: 20),
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 20),
              child: Container(height: 0.5, color: CupertinoColors.separator),
            ),
            const SizedBox(height: 12),
            // 分类列表
            Expanded(
              child: ListView(
                padding: const EdgeInsets.symmetric(horizontal: 12),
                children: [
                  _buildCategoryItem(
                    context,
                    icon: CupertinoIcons.house,
                    iconColor: CupertinoColors.systemGreen,
                    title: '生活',
                    count: lifeCount,
                    onTap: () => onCategoryTap?.call('生活'),
                  ),
                  _buildCategoryItem(
                    context,
                    icon: CupertinoIcons.book,
                    iconColor: CupertinoColors.systemBlue,
                    title: '学习',
                    count: studyCount,
                    onTap: () => onCategoryTap?.call('学习'),
                  ),
                  _buildCategoryItem(
                    context,
                    icon: CupertinoIcons.cart,
                    iconColor: CupertinoColors.systemOrange,
                    title: '购物',
                    count: shoppingCount,
                    onTap: () => onCategoryTap?.call('购物'),
                  ),
                  _buildCategoryItem(
                    context,
                    icon: CupertinoIcons.game_controller,
                    iconColor: CupertinoColors.systemPurple,
                    title: '游玩',
                    count: playCount,
                    onTap: () => onCategoryTap?.call('游玩'),
                  ),
                  if (otherCount > 0)
                    _buildCategoryItem(
                      context,
                      icon: CupertinoIcons.doc,
                      iconColor: CupertinoColors.systemGrey,
                      title: '未分类',
                      count: otherCount,
                      onTap: () => onCategoryTap?.call('未分类'),
                    ),
                  _buildCategoryItem(
                    context,
                    icon: CupertinoIcons.checkmark_circle_fill,
                    iconColor: CupertinoColors.systemGreen,
                    title: '已完成',
                    count: completedCount,
                    onTap: () => onCategoryTap?.call('已完成'),
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildCategoryItem(
    BuildContext context, {
    required IconData icon,
    required Color iconColor,
    required String title,
    required int count,
    required VoidCallback onTap,
  }) {
    return GestureDetector(
      onTap: onTap,
      child: Container(
        margin: const EdgeInsets.only(bottom: 4),
        padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 12),
        decoration: BoxDecoration(borderRadius: BorderRadius.circular(10)),
        child: Row(
          children: [
            Container(
              width: 36,
              height: 36,
              decoration: BoxDecoration(
                color: iconColor.withOpacity(0.1),
                borderRadius: BorderRadius.circular(8),
              ),
              child: Icon(icon, color: iconColor, size: 20),
            ),
            const SizedBox(width: 12),
            Expanded(
              child: Text(
                title,
                style: const TextStyle(
                  fontSize: 15,
                  fontWeight: FontWeight.w500,
                  color: CupertinoColors.label,
                  decoration: TextDecoration.none,
                ),
              ),
            ),
            Container(
              padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
              decoration: BoxDecoration(
                color: CupertinoColors.systemGrey5,
                borderRadius: BorderRadius.circular(10),
              ),
              child: Text(
                '$count',
                style: const TextStyle(
                  fontSize: 13,
                  fontWeight: FontWeight.w600,
                  color: CupertinoColors.secondaryLabel,
                  decoration: TextDecoration.none,
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
