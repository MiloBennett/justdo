import 'package:flutter/cupertino.dart';
import '../models/budget.dart';
import '../models/bill.dart';
import 'budget_chart_screen.dart';

class BudgetSettingsScreen extends StatefulWidget {
  final List<Budget> budgets;
  final List<Bill> bills;
  final Function(Budget) onAddBudget;
  final Function(Budget) onRemoveBudget;

  const BudgetSettingsScreen({
    super.key,
    required this.budgets,
    required this.bills,
    required this.onAddBudget,
    required this.onRemoveBudget,
  });

  @override
  State<BudgetSettingsScreen> createState() => _BudgetSettingsScreenState();
}

class _BudgetSettingsScreenState extends State<BudgetSettingsScreen> {
  final List<String> _categories = [
    '生活费',
    '购物',
    '餐饮',
    '交通',
    '娱乐',
    '医疗',
    '教育',
    '其他',
  ];

  void _addBudget() {
    showCupertinoModalPopup(
      context: context,
      builder: (context) => _BudgetAddSheet(
        categories: _categories,
        onAdd: (budget) {
          widget.onAddBudget(budget);
          Navigator.pop(context);
        },
      ),
    );
  }

  void _deleteBudget(Budget budget) {
    showCupertinoDialog(
      context: context,
      builder: (context) => CupertinoAlertDialog(
        title: const Text('删除预算'),
        content: Text('确定要删除"${budget.category}"的预算吗？'),
        actions: [
          CupertinoDialogAction(
            onPressed: () => Navigator.pop(context),
            child: const Text('取消'),
          ),
          CupertinoDialogAction(
            isDestructiveAction: true,
            onPressed: () {
              widget.onRemoveBudget(budget);
              Navigator.pop(context);
            },
            child: const Text('删除'),
          ),
        ],
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return CupertinoPageScaffold(
      backgroundColor: CupertinoColors.systemGroupedBackground,
      navigationBar: CupertinoNavigationBar(
        middle: const Text('预算管理'),
        trailing: Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            CupertinoButton(
              padding: EdgeInsets.zero,
              onPressed: () {
                Navigator.push(
                  context,
                  CupertinoPageRoute(
                    builder: (context) => BudgetChartScreen(
                      budgets: widget.budgets,
                      bills: widget.bills,
                    ),
                  ),
                );
              },
              child: const Icon(CupertinoIcons.chart_bar, size: 22),
            ),
            CupertinoButton(
              padding: EdgeInsets.zero,
              onPressed: _addBudget,
              child: const Icon(CupertinoIcons.gear, size: 24),
            ),
          ],
        ),
      ),
      child: SafeArea(
        child: CustomScrollView(
          slivers: [
            if (widget.budgets.isNotEmpty)
              SliverToBoxAdapter(child: _buildBudgetOverview()),
            if (widget.budgets.isEmpty)
              SliverFillRemaining(child: _buildEmptyState())
            else
              SliverToBoxAdapter(child: _buildBudgetList()),
          ],
        ),
      ),
    );
  }

  Widget _buildBudgetOverview() {
    final now = DateTime.now();
    double totalBudget = 0;
    double totalSpent = 0;

    for (var budget in widget.budgets) {
      totalBudget += budget.amount;
      totalSpent += budget.getSpentAmount(widget.bills, now);
    }

    final progress = totalBudget > 0 ? totalSpent / totalBudget : 0.0;
    final remaining = totalBudget - totalSpent;

    return Container(
      margin: const EdgeInsets.all(16),
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        gradient: const LinearGradient(
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
          colors: [Color(0xFFFF9500), Color(0xFFFF2D55)],
        ),
        borderRadius: BorderRadius.circular(16),
        boxShadow: [
          BoxShadow(
            color: const Color(0xFFFF9500).withValues(alpha: 0.3),
            blurRadius: 20,
            offset: const Offset(0, 10),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Text(
                '本月预算',
                style: TextStyle(
                  fontSize: 15,
                  color: CupertinoColors.white,
                  fontWeight: FontWeight.w500,
                  decoration: TextDecoration.none,
                ),
              ),
              Icon(
                CupertinoIcons.chart_pie,
                color: CupertinoColors.white,
                size: 22,
              ),
            ],
          ),
          const SizedBox(height: 16),
          Row(
            crossAxisAlignment: CrossAxisAlignment.end,
            children: [
              Text(
                '¥${totalSpent.toStringAsFixed(0)}',
                style: const TextStyle(
                  fontSize: 36,
                  fontWeight: FontWeight.w700,
                  color: CupertinoColors.white,
                  letterSpacing: -1,
                  decoration: TextDecoration.none,
                ),
              ),
              const SizedBox(width: 4),
              Padding(
                padding: const EdgeInsets.only(bottom: 6),
                child: Text(
                  '/ ¥${totalBudget.toStringAsFixed(0)}',
                  style: TextStyle(
                    fontSize: 16,
                    color: CupertinoColors.white.withValues(alpha: 0.7),
                    decoration: TextDecoration.none,
                  ),
                ),
              ),
            ],
          ),
          const SizedBox(height: 16),
          Container(
            height: 8,
            decoration: BoxDecoration(
              color: CupertinoColors.white.withValues(alpha: 0.3),
              borderRadius: BorderRadius.circular(4),
            ),
            child: FractionallySizedBox(
              alignment: Alignment.centerLeft,
              widthFactor: progress.clamp(0.0, 1.0),
              child: Container(
                decoration: BoxDecoration(
                  color: CupertinoColors.white,
                  borderRadius: BorderRadius.circular(4),
                ),
              ),
            ),
          ),
          const SizedBox(height: 12),
          Text(
            remaining >= 0
                ? '剩余 ¥${remaining.toStringAsFixed(2)}'
                : '超支 ¥${(-remaining).toStringAsFixed(2)}',
            style: const TextStyle(
              fontSize: 14,
              color: CupertinoColors.white,
              decoration: TextDecoration.none,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildEmptyState() {
    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Container(
            width: 80,
            height: 80,
            decoration: BoxDecoration(
              color: CupertinoColors.systemGrey5,
              borderRadius: BorderRadius.circular(20),
            ),
            child: const Icon(
              CupertinoIcons.chart_pie,
              size: 40,
              color: CupertinoColors.systemGrey,
            ),
          ),
          const SizedBox(height: 16),
          const Text(
            '暂无预算设置',
            style: TextStyle(
              fontSize: 17,
              fontWeight: FontWeight.w600,
              color: CupertinoColors.label,
              decoration: TextDecoration.none,
            ),
          ),
          const SizedBox(height: 8),
          const Text(
            '点击右上角设置按钮添加预算',
            style: TextStyle(
              fontSize: 14,
              color: CupertinoColors.secondaryLabel,
              decoration: TextDecoration.none,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildBudgetList() {
    final now = DateTime.now();

    return Container(
      margin: const EdgeInsets.symmetric(horizontal: 16),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const Text(
            '分类预算',
            style: TextStyle(
              fontSize: 17,
              fontWeight: FontWeight.w600,
              color: CupertinoColors.label,
              decoration: TextDecoration.none,
            ),
          ),
          const SizedBox(height: 12),
          Container(
            decoration: BoxDecoration(
              color: CupertinoColors.systemBackground,
              borderRadius: BorderRadius.circular(12),
            ),
            child: Column(
              children: widget.budgets.asMap().entries.map((entry) {
                final index = entry.key;
                final budget = entry.value;
                return _buildBudgetItem(
                  budget,
                  now,
                  index == widget.budgets.length - 1,
                );
              }).toList(),
            ),
          ),
          const SizedBox(height: 20),
        ],
      ),
    );
  }

  Widget _buildBudgetItem(Budget budget, DateTime now, bool isLast) {
    final spent = budget.getSpentAmount(widget.bills, now);
    final progress = budget.getProgress(widget.bills, now);
    final remaining = budget.amount - spent;
    final isOverBudget = progress > 1.0;

    return GestureDetector(
      onLongPress: () => _deleteBudget(budget),
      child: Container(
        padding: const EdgeInsets.all(16),
        decoration: BoxDecoration(
          border: isLast
              ? null
              : const Border(
                  bottom: BorderSide(
                    color: CupertinoColors.separator,
                    width: 0.5,
                  ),
                ),
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                Container(
                  width: 40,
                  height: 40,
                  decoration: BoxDecoration(
                    color: budget.color.withValues(alpha: 0.15),
                    borderRadius: BorderRadius.circular(10),
                  ),
                  child: Icon(
                    _getCategoryIcon(budget.category),
                    color: budget.color,
                    size: 22,
                  ),
                ),
                const SizedBox(width: 12),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        budget.category,
                        style: const TextStyle(
                          fontSize: 16,
                          fontWeight: FontWeight.w500,
                          color: CupertinoColors.label,
                          decoration: TextDecoration.none,
                        ),
                      ),
                      Text(
                        '${budget.typeString}预算',
                        style: const TextStyle(
                          fontSize: 12,
                          color: CupertinoColors.secondaryLabel,
                          decoration: TextDecoration.none,
                        ),
                      ),
                    ],
                  ),
                ),
                Column(
                  crossAxisAlignment: CrossAxisAlignment.end,
                  children: [
                    Text(
                      isOverBudget
                          ? '超支 ¥${(-remaining).toStringAsFixed(2)}'
                          : '剩余 ¥${remaining.toStringAsFixed(2)}',
                      style: TextStyle(
                        fontSize: 15,
                        fontWeight: FontWeight.w600,
                        color: isOverBudget
                            ? CupertinoColors.systemRed
                            : CupertinoColors.systemGreen,
                        decoration: TextDecoration.none,
                      ),
                    ),
                    Text(
                      '¥${spent.toStringAsFixed(2)} / ¥${budget.amount.toStringAsFixed(2)}',
                      style: const TextStyle(
                        fontSize: 11,
                        color: CupertinoColors.tertiaryLabel,
                        decoration: TextDecoration.none,
                      ),
                    ),
                  ],
                ),
              ],
            ),
            const SizedBox(height: 12),
            ClipRRect(
              borderRadius: BorderRadius.circular(4),
              child: Container(
                height: 6,
                decoration: BoxDecoration(
                  color: CupertinoColors.systemGrey5,
                  borderRadius: BorderRadius.circular(4),
                ),
                child: FractionallySizedBox(
                  alignment: Alignment.centerLeft,
                  widthFactor: progress.clamp(0.0, 1.0),
                  child: Container(
                    decoration: BoxDecoration(
                      color: isOverBudget
                          ? CupertinoColors.systemRed
                          : progress > 0.8
                          ? CupertinoColors.systemOrange
                          : budget.color,
                      borderRadius: BorderRadius.circular(4),
                    ),
                  ),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  IconData _getCategoryIcon(String category) {
    switch (category) {
      case '生活费':
        return CupertinoIcons.house;
      case '购物':
        return CupertinoIcons.bag;
      case '餐饮':
        return CupertinoIcons.cart;
      case '交通':
        return CupertinoIcons.car;
      case '娱乐':
        return CupertinoIcons.music_note;
      case '医疗':
        return CupertinoIcons.heart;
      case '教育':
        return CupertinoIcons.book;
      default:
        return CupertinoIcons.ellipsis;
    }
  }
}

class _BudgetAddSheet extends StatefulWidget {
  final List<String> categories;
  final Function(Budget) onAdd;

  const _BudgetAddSheet({required this.categories, required this.onAdd});

  @override
  State<_BudgetAddSheet> createState() => _BudgetAddSheetState();
}

class _BudgetAddSheetState extends State<_BudgetAddSheet> {
  final _amountController = TextEditingController();
  String _selectedCategory = '生活费';
  BudgetType _selectedType = BudgetType.monthly;

  final List<Color> _colors = [
    CupertinoColors.systemBlue,
    CupertinoColors.systemGreen,
    CupertinoColors.systemOrange,
    CupertinoColors.systemRed,
    CupertinoColors.systemPurple,
    CupertinoColors.systemTeal,
    CupertinoColors.systemPink,
    CupertinoColors.systemIndigo,
  ];

  @override
  void dispose() {
    _amountController.dispose();
    super.dispose();
  }

  void _save() {
    final amount = double.tryParse(_amountController.text);
    if (amount == null || amount <= 0) return;

    final budget = Budget(
      id: DateTime.now().millisecondsSinceEpoch.toString(),
      category: _selectedCategory,
      amount: amount,
      type: _selectedType,
      startDate: DateTime.now(),
      color:
          _colors[widget.categories.indexOf(_selectedCategory) %
              _colors.length],
    );

    widget.onAdd(budget);
  }

  @override
  Widget build(BuildContext context) {
    return Container(
      height: 400,
      color: CupertinoColors.systemGroupedBackground,
      child: Column(
        children: [
          Container(
            padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
            decoration: const BoxDecoration(
              color: CupertinoColors.systemBackground,
              border: Border(
                bottom: BorderSide(
                  color: CupertinoColors.separator,
                  width: 0.5,
                ),
              ),
            ),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                CupertinoButton(
                  padding: EdgeInsets.zero,
                  onPressed: () => Navigator.pop(context),
                  child: const Text('取消'),
                ),
                const Text(
                  '添加预算',
                  style: TextStyle(
                    fontSize: 17,
                    fontWeight: FontWeight.w600,
                    decoration: TextDecoration.none,
                  ),
                ),
                CupertinoButton(
                  padding: EdgeInsets.zero,
                  onPressed: _save,
                  child: const Text('保存'),
                ),
              ],
            ),
          ),
          Expanded(
            child: ListView(
              children: [
                const SizedBox(height: 16),
                CupertinoListSection.insetGrouped(
                  header: const Text('分类'),
                  children: [
                    CupertinoListTile(
                      title: const Text('分类'),
                      additionalInfo: Text(_selectedCategory),
                      trailing: const CupertinoListTileChevron(),
                      onTap: () => _showCategoryPicker(),
                    ),
                  ],
                ),
                CupertinoListSection.insetGrouped(
                  header: const Text('预算类型'),
                  children: [
                    CupertinoListTile(
                      title: const Text('月度预算'),
                      trailing: _selectedType == BudgetType.monthly
                          ? const Icon(
                              CupertinoIcons.checkmark,
                              color: CupertinoColors.activeBlue,
                            )
                          : null,
                      onTap: () {
                        setState(() {
                          _selectedType = BudgetType.monthly;
                        });
                      },
                    ),
                    CupertinoListTile(
                      title: const Text('周度预算'),
                      trailing: _selectedType == BudgetType.weekly
                          ? const Icon(
                              CupertinoIcons.checkmark,
                              color: CupertinoColors.activeBlue,
                            )
                          : null,
                      onTap: () {
                        setState(() {
                          _selectedType = BudgetType.weekly;
                        });
                      },
                    ),
                    CupertinoListTile(
                      title: const Text('日度预算'),
                      trailing: _selectedType == BudgetType.daily
                          ? const Icon(
                              CupertinoIcons.checkmark,
                              color: CupertinoColors.activeBlue,
                            )
                          : null,
                      onTap: () {
                        setState(() {
                          _selectedType = BudgetType.daily;
                        });
                      },
                    ),
                  ],
                ),
                CupertinoListSection.insetGrouped(
                  header: const Text('预算金额'),
                  children: [
                    CupertinoTextFormFieldRow(
                      controller: _amountController,
                      placeholder: '输入金额',
                      prefix: const Text('金额'),
                      keyboardType: const TextInputType.numberWithOptions(
                        decimal: true,
                      ),
                    ),
                  ],
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  void _showCategoryPicker() {
    showCupertinoModalPopup(
      context: context,
      builder: (context) => Container(
        height: 250,
        color: CupertinoColors.systemBackground,
        child: Column(
          children: [
            Container(
              padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  CupertinoButton(
                    padding: EdgeInsets.zero,
                    onPressed: () => Navigator.pop(context),
                    child: const Text('取消'),
                  ),
                  CupertinoButton(
                    padding: EdgeInsets.zero,
                    onPressed: () => Navigator.pop(context),
                    child: const Text('确定'),
                  ),
                ],
              ),
            ),
            Expanded(
              child: CupertinoPicker(
                itemExtent: 40,
                onSelectedItemChanged: (index) {
                  setState(() {
                    _selectedCategory = widget.categories[index];
                  });
                },
                children: widget.categories
                    .map((category) => Center(child: Text(category)))
                    .toList(),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
