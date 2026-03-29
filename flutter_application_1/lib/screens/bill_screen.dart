import 'package:flutter/cupertino.dart';
import 'package:intl/intl.dart';
import '../models/bill.dart';
import '../models/budget.dart';
import 'add_bill_screen.dart';
import 'bill_calendar_screen.dart';
import 'budget_settings_screen.dart';

class BillScreen extends StatefulWidget {
  final List<Bill> bills;
  final List<Budget> budgets;
  final Function(Bill) onAddBill;
  final Function(Bill) onRemoveBill;
  final Function(Bill) onToggleComplete;
  final Function(Budget) onAddBudget;
  final Function(Budget) onRemoveBudget;

  const BillScreen({
    super.key,
    required this.bills,
    required this.budgets,
    required this.onAddBill,
    required this.onRemoveBill,
    required this.onToggleComplete,
    required this.onAddBudget,
    required this.onRemoveBudget,
  });

  @override
  State<BillScreen> createState() => _BillScreenState();
}

class _BillScreenState extends State<BillScreen> {
  final _goalController = TextEditingController();
  double _savingsGoal = 0;
  bool _hasGoal = false;
  late PageController _pageController;
  int _currentPage = 0;

  @override
  void initState() {
    super.initState();
    _pageController = PageController(viewportFraction: 0.95);
  }

  @override
  void dispose() {
    _goalController.dispose();
    _pageController.dispose();
    super.dispose();
  }

  void _addBill() async {
    final result = await Navigator.push<Bill>(
      context,
      CupertinoPageRoute(builder: (context) => const AddBillScreen()),
    );

    if (result != null) {
      widget.onAddBill(result);
    }
  }

  void _deleteBill(Bill bill) {
    showCupertinoDialog(
      context: context,
      builder: (context) => CupertinoAlertDialog(
        title: const Text('删除储蓄'),
        content: Text('确定要删除"${bill.title}"吗？'),
        actions: [
          CupertinoDialogAction(
            onPressed: () => Navigator.pop(context),
            child: const Text('取消'),
          ),
          CupertinoDialogAction(
            isDestructiveAction: true,
            onPressed: () {
              widget.onRemoveBill(bill);
              Navigator.pop(context);
            },
            child: const Text('删除'),
          ),
        ],
      ),
    );
  }

  double _getTotalAmount(BillType type) {
    final currentYear = DateTime.now().year;
    return widget.bills
        .where((b) => b.type == type && b.date.year == currentYear)
        .fold(0.0, (sum, b) => sum + b.amount);
  }

  List<MapEntry<DateTime, List<Bill>>> _groupByDate(List<Bill> bills) {
    final Map<DateTime, List<Bill>> grouped = {};
    for (var bill in bills) {
      final date = DateTime(bill.date.year, bill.date.month, bill.date.day);
      grouped.putIfAbsent(date, () => []);
      grouped[date]!.add(bill);
    }
    final entries = grouped.entries.toList()
      ..sort((a, b) => b.key.compareTo(a.key));
    return entries;
  }

  void _showSetGoalDialog() {
    _goalController.text = _hasGoal ? _savingsGoal.toStringAsFixed(0) : '';
    showCupertinoDialog(
      context: context,
      builder: (context) => CupertinoAlertDialog(
        title: const Text('设置年度存款目标'),
        content: Padding(
          padding: const EdgeInsets.only(top: 16),
          child: CupertinoTextField(
            controller: _goalController,
            placeholder: '请输入目标金额',
            keyboardType: TextInputType.number,
            prefix: const Padding(
              padding: EdgeInsets.only(left: 8),
              child: Text('¥'),
            ),
          ),
        ),
        actions: [
          CupertinoDialogAction(
            onPressed: () => Navigator.pop(context),
            child: const Text('取消'),
          ),
          if (_hasGoal)
            CupertinoDialogAction(
              isDestructiveAction: true,
              onPressed: () {
                setState(() {
                  _savingsGoal = 0;
                  _hasGoal = false;
                });
                Navigator.pop(context);
              },
              child: const Text('清除目标'),
            ),
          CupertinoDialogAction(
            onPressed: () {
              final goal = double.tryParse(_goalController.text);
              if (goal != null && goal > 0) {
                setState(() {
                  _savingsGoal = goal;
                  _hasGoal = true;
                });
              }
              Navigator.pop(context);
            },
            child: const Text('确定'),
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
        middle: const Text('储蓄计划'),
        trailing: Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            CupertinoButton(
              padding: EdgeInsets.zero,
              onPressed: () {
                Navigator.push(
                  context,
                  CupertinoPageRoute(
                    builder: (context) => BudgetSettingsScreen(
                      budgets: widget.budgets,
                      bills: widget.bills,
                      onAddBudget: widget.onAddBudget,
                      onRemoveBudget: widget.onRemoveBudget,
                    ),
                  ),
                );
              },
              child: const Icon(CupertinoIcons.chart_pie, size: 22),
            ),
            CupertinoButton(
              padding: EdgeInsets.zero,
              onPressed: () {
                Navigator.push(
                  context,
                  CupertinoPageRoute(
                    builder: (context) => BillCalendarScreen(
                      bills: widget.bills,
                      onAddBill: widget.onAddBill,
                      onRemoveBill: widget.onRemoveBill,
                      onToggleComplete: widget.onToggleComplete,
                    ),
                  ),
                );
              },
              child: const Icon(CupertinoIcons.calendar, size: 24),
            ),
            CupertinoButton(
              padding: EdgeInsets.zero,
              onPressed: _addBill,
              child: const Icon(CupertinoIcons.add, size: 26),
            ),
          ],
        ),
      ),
      child: SafeArea(
        child: widget.bills.isEmpty && !_hasGoal
            ? _buildEmptyState()
            : CustomScrollView(
                slivers: [
                  SliverToBoxAdapter(child: _buildCarouselCards()),
                  _buildGroupedBillList(),
                ],
              ),
      ),
    );
  }

  Widget _buildCarouselCards() {
    final cards = <Widget>[_buildSummaryCard(), _buildGoalCard()];

    return Column(
      children: [
        SizedBox(
          height: 200,
          child: PageView.builder(
            controller: _pageController,
            itemCount: null,
            onPageChanged: (index) {
              setState(() {
                _currentPage = index % cards.length;
              });
            },
            itemBuilder: (context, index) {
              return Padding(
                padding: const EdgeInsets.symmetric(horizontal: 4),
                child: cards[index % cards.length],
              );
            },
          ),
        ),
        const SizedBox(height: 12),
        Row(
          mainAxisAlignment: MainAxisAlignment.center,
          children: List.generate(cards.length, (index) {
            return Container(
              margin: const EdgeInsets.symmetric(horizontal: 4),
              width: _currentPage == index ? 20 : 8,
              height: 8,
              decoration: BoxDecoration(
                color: _currentPage == index
                    ? CupertinoColors.activeBlue
                    : CupertinoColors.systemGrey4,
                borderRadius: BorderRadius.circular(4),
              ),
            );
          }),
        ),
        const SizedBox(height: 8),
      ],
    );
  }

  Widget _buildSummaryCard() {
    final deposit = _getTotalAmount(BillType.deposit);
    final withdraw = _getTotalAmount(BillType.withdraw);
    final balance = deposit - withdraw;

    return Container(
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        gradient: const LinearGradient(
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
          colors: [Color(0xFF007AFF), Color(0xFF5856D6)],
        ),
        borderRadius: BorderRadius.circular(16),
        boxShadow: [
          BoxShadow(
            color: const Color(0xFF007AFF).withValues(alpha: 0.3),
            blurRadius: 20,
            offset: const Offset(0, 10),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              const Text(
                '年度收支',
                style: TextStyle(
                  fontSize: 15,
                  color: CupertinoColors.white,
                  fontWeight: FontWeight.w500,
                  decoration: TextDecoration.none,
                ),
              ),
              Container(
                padding: const EdgeInsets.symmetric(
                  horizontal: 10,
                  vertical: 4,
                ),
                decoration: BoxDecoration(
                  color: CupertinoColors.white.withValues(alpha: 0.2),
                  borderRadius: BorderRadius.circular(12),
                ),
                child: Text(
                  '${DateTime.now().year}年',
                  style: const TextStyle(
                    fontSize: 12,
                    color: CupertinoColors.white,
                    decoration: TextDecoration.none,
                  ),
                ),
              ),
            ],
          ),
          const SizedBox(height: 8),
          Text(
            '¥${balance.toStringAsFixed(2)}',
            style: const TextStyle(
              fontSize: 36,
              fontWeight: FontWeight.w700,
              color: CupertinoColors.white,
              letterSpacing: -1,
              decoration: TextDecoration.none,
            ),
          ),
          const SizedBox(height: 20),
          Row(
            children: [
              Expanded(
                child: _buildSummaryItem(
                  '收入',
                  deposit,
                  CupertinoIcons.arrow_down_circle_fill,
                ),
              ),
              Container(
                width: 1,
                height: 40,
                color: CupertinoColors.white.withValues(alpha: 0.3),
              ),
              Expanded(
                child: _buildSummaryItem(
                  '支出',
                  withdraw,
                  CupertinoIcons.arrow_up_circle_fill,
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }

  Widget _buildSummaryItem(String label, double amount, IconData icon) {
    return Column(
      children: [
        Row(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(
              icon,
              color: CupertinoColors.white.withValues(alpha: 0.8),
              size: 16,
            ),
            const SizedBox(width: 4),
            Text(
              label,
              style: TextStyle(
                fontSize: 13,
                color: CupertinoColors.white.withValues(alpha: 0.8),
                decoration: TextDecoration.none,
              ),
            ),
          ],
        ),
        const SizedBox(height: 4),
        Text(
          '¥${amount.toStringAsFixed(2)}',
          style: const TextStyle(
            fontSize: 18,
            fontWeight: FontWeight.w600,
            color: CupertinoColors.white,
            decoration: TextDecoration.none,
          ),
        ),
      ],
    );
  }

  Widget _buildGoalCard() {
    final deposit = _getTotalAmount(BillType.deposit);
    final withdraw = _getTotalAmount(BillType.withdraw);
    final currentSavings = deposit - withdraw;
    final progress = _savingsGoal > 0 ? currentSavings / _savingsGoal : 0.0;
    final remaining = _savingsGoal - currentSavings;

    return GestureDetector(
      onTap: _showSetGoalDialog,
      child: Container(
        padding: const EdgeInsets.all(20),
        decoration: BoxDecoration(
          gradient: LinearGradient(
            begin: Alignment.topLeft,
            end: Alignment.bottomRight,
            colors: _hasGoal
                ? (progress >= 1.0
                      ? [const Color(0xFF34C759), const Color(0xFF30D158)]
                      : [const Color(0xFFFF9500), const Color(0xFFFF6B00)])
                : [const Color(0xFFFF9500), const Color(0xFFFF6B00)],
          ),
          borderRadius: BorderRadius.circular(16),
          boxShadow: [
            BoxShadow(
              color:
                  (_hasGoal && progress >= 1.0
                          ? const Color(0xFF34C759)
                          : const Color(0xFFFF9500))
                      .withValues(alpha: 0.3),
              blurRadius: 20,
              offset: const Offset(0, 10),
            ),
          ],
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Row(
                  children: [
                    Icon(
                      _hasGoal && progress >= 1.0
                          ? CupertinoIcons.checkmark_seal_fill
                          : CupertinoIcons.scope,
                      color: CupertinoColors.white,
                      size: 20,
                    ),
                    const SizedBox(width: 8),
                    const Text(
                      '年度存款目标',
                      style: TextStyle(
                        fontSize: 15,
                        color: CupertinoColors.white,
                        fontWeight: FontWeight.w500,
                        decoration: TextDecoration.none,
                      ),
                    ),
                  ],
                ),
                if (_hasGoal)
                  Text(
                    '${(progress * 100).toStringAsFixed(1)}%',
                    style: const TextStyle(
                      fontSize: 18,
                      fontWeight: FontWeight.w700,
                      color: CupertinoColors.white,
                      decoration: TextDecoration.none,
                    ),
                  ),
              ],
            ),
            const SizedBox(height: 16),
            if (_hasGoal) ...[
              Row(
                crossAxisAlignment: CrossAxisAlignment.end,
                children: [
                  Text(
                    '¥${currentSavings.toStringAsFixed(0)}',
                    style: const TextStyle(
                      fontSize: 28,
                      fontWeight: FontWeight.w700,
                      color: CupertinoColors.white,
                      letterSpacing: -1,
                      decoration: TextDecoration.none,
                    ),
                  ),
                  const SizedBox(width: 4),
                  Padding(
                    padding: const EdgeInsets.only(bottom: 4),
                    child: Text(
                      '/ ¥${_savingsGoal.toStringAsFixed(0)}',
                      style: TextStyle(
                        fontSize: 14,
                        color: CupertinoColors.white.withValues(alpha: 0.7),
                        decoration: TextDecoration.none,
                      ),
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 12),
              ClipRRect(
                borderRadius: BorderRadius.circular(6),
                child: Container(
                  height: 8,
                  decoration: BoxDecoration(
                    color: CupertinoColors.white.withValues(alpha: 0.3),
                    borderRadius: BorderRadius.circular(6),
                  ),
                  child: FractionallySizedBox(
                    alignment: Alignment.centerLeft,
                    widthFactor: progress.clamp(0.0, 1.0),
                    child: Container(
                      decoration: BoxDecoration(
                        color: CupertinoColors.white,
                        borderRadius: BorderRadius.circular(6),
                      ),
                    ),
                  ),
                ),
              ),
              const SizedBox(height: 8),
              Text(
                progress >= 1.0
                    ? '恭喜！已达成存款目标'
                    : remaining > 0
                    ? '还需存入 ¥${remaining.toStringAsFixed(2)}'
                    : '已超支 ¥${(-remaining).toStringAsFixed(2)}',
                style: const TextStyle(
                  fontSize: 13,
                  color: CupertinoColors.white,
                  decoration: TextDecoration.none,
                ),
              ),
            ] else ...[
              const SizedBox(height: 20),
              Center(
                child: Column(
                  children: [
                    const Text(
                      '点击设置年度存款目标',
                      style: TextStyle(
                        fontSize: 17,
                        fontWeight: FontWeight.w600,
                        color: CupertinoColors.white,
                        decoration: TextDecoration.none,
                      ),
                    ),
                    const SizedBox(height: 8),
                    Text(
                      '追踪你的年度存款进度',
                      style: TextStyle(
                        fontSize: 14,
                        color: CupertinoColors.white.withValues(alpha: 0.8),
                        decoration: TextDecoration.none,
                      ),
                    ),
                  ],
                ),
              ),
              const SizedBox(height: 20),
            ],
          ],
        ),
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
              CupertinoIcons.money_dollar_circle,
              size: 40,
              color: CupertinoColors.systemGrey,
            ),
          ),
          const SizedBox(height: 16),
          const Text(
            '暂无储蓄记录',
            style: TextStyle(
              fontSize: 17,
              fontWeight: FontWeight.w600,
              color: CupertinoColors.label,
              decoration: TextDecoration.none,
            ),
          ),
          const SizedBox(height: 8),
          const Text(
            '点击右上角 + 号添加新记录',
            style: TextStyle(
              fontSize: 14,
              color: CupertinoColors.secondaryLabel,
              decoration: TextDecoration.none,
            ),
          ),
          const SizedBox(height: 24),
          CupertinoButton(
            onPressed: _showSetGoalDialog,
            child: Container(
              padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 12),
              decoration: BoxDecoration(
                color: CupertinoColors.systemBlue,
                borderRadius: BorderRadius.circular(20),
              ),
              child: const Row(
                mainAxisSize: MainAxisSize.min,
                children: [
                  Icon(
                    CupertinoIcons.scope,
                    color: CupertinoColors.white,
                    size: 18,
                  ),
                  SizedBox(width: 8),
                  Text(
                    '设置年度存款目标',
                    style: TextStyle(
                      color: CupertinoColors.white,
                      fontWeight: FontWeight.w500,
                    ),
                  ),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildGroupedBillList() {
    if (widget.bills.isEmpty) {
      return const SliverToBoxAdapter(child: SizedBox());
    }

    final sortedBills = List<Bill>.from(widget.bills)
      ..sort((a, b) => b.date.compareTo(a.date));
    final groupedEntries = _groupByDate(sortedBills);

    final List<Widget> children = [];

    for (var entry in groupedEntries) {
      final date = entry.key;
      final bills = entry.value;
      final dayDeposit = bills
          .where((b) => b.type == BillType.deposit)
          .fold(0.0, (sum, b) => sum + b.amount);
      final dayWithdraw = bills
          .where((b) => b.type == BillType.withdraw)
          .fold(0.0, (sum, b) => sum + b.amount);
      final dayBalance = dayDeposit - dayWithdraw;

      children.add(
        Padding(
          padding: const EdgeInsets.fromLTRB(16, 16, 16, 8),
          child: Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Text(
                _formatDateHeader(date),
                style: const TextStyle(
                  fontSize: 13,
                  fontWeight: FontWeight.w600,
                  color: CupertinoColors.secondaryLabel,
                  decoration: TextDecoration.none,
                ),
              ),
              Text(
                dayBalance >= 0
                    ? '+¥${dayBalance.toStringAsFixed(2)}'
                    : '-¥${(-dayBalance).toStringAsFixed(2)}',
                style: TextStyle(
                  fontSize: 13,
                  fontWeight: FontWeight.w500,
                  color: dayBalance >= 0
                      ? CupertinoColors.systemGreen
                      : CupertinoColors.systemRed,
                  decoration: TextDecoration.none,
                ),
              ),
            ],
          ),
        ),
      );

      children.add(
        Container(
          margin: const EdgeInsets.symmetric(horizontal: 16),
          decoration: BoxDecoration(
            color: CupertinoColors.systemBackground,
            borderRadius: BorderRadius.circular(12),
          ),
          child: ClipRRect(
            borderRadius: BorderRadius.circular(12),
            child: Column(
              children: bills.asMap().entries.map((entry) {
                final index = entry.key;
                final bill = entry.value;
                return _buildBillItem(bill, index == bills.length - 1);
              }).toList(),
            ),
          ),
        ),
      );
    }

    children.add(const SizedBox(height: 20));

    return SliverList(delegate: SliverChildListDelegate(children));
  }

  Widget _buildBillItem(Bill bill, bool isLast) {
    final isWithdraw = bill.type == BillType.withdraw;
    final iconData = isWithdraw
        ? CupertinoIcons.arrow_up_circle_fill
        : CupertinoIcons.arrow_down_circle_fill;
    final color = isWithdraw
        ? CupertinoColors.systemRed
        : CupertinoColors.systemGreen;

    return GestureDetector(
      onLongPress: () => _deleteBill(bill),
      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
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
        child: Row(
          children: [
            Container(
              width: 44,
              height: 44,
              decoration: BoxDecoration(
                color: color.withValues(alpha: 0.1),
                borderRadius: BorderRadius.circular(12),
              ),
              child: Icon(iconData, color: color, size: 24),
            ),
            const SizedBox(width: 12),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    bill.title,
                    style: const TextStyle(
                      fontSize: 16,
                      fontWeight: FontWeight.w500,
                      color: CupertinoColors.label,
                      decoration: TextDecoration.none,
                    ),
                  ),
                  if (bill.category.isNotEmpty) ...[
                    const SizedBox(height: 3),
                    Row(
                      children: [
                        Container(
                          padding: const EdgeInsets.symmetric(
                            horizontal: 6,
                            vertical: 2,
                          ),
                          decoration: BoxDecoration(
                            color: CupertinoColors.systemGrey5,
                            borderRadius: BorderRadius.circular(4),
                          ),
                          child: Text(
                            bill.category,
                            style: const TextStyle(
                              fontSize: 11,
                              color: CupertinoColors.secondaryLabel,
                              decoration: TextDecoration.none,
                            ),
                          ),
                        ),
                        if (bill.note.isNotEmpty) ...[
                          const SizedBox(width: 6),
                          Expanded(
                            child: Text(
                              bill.note,
                              style: const TextStyle(
                                fontSize: 12,
                                color: CupertinoColors.tertiaryLabel,
                                decoration: TextDecoration.none,
                              ),
                              maxLines: 1,
                              overflow: TextOverflow.ellipsis,
                            ),
                          ),
                        ],
                      ],
                    ),
                  ],
                ],
              ),
            ),
            const SizedBox(width: 12),
            Column(
              crossAxisAlignment: CrossAxisAlignment.end,
              children: [
                Text(
                  bill.amountString,
                  style: TextStyle(
                    fontSize: 17,
                    fontWeight: FontWeight.w600,
                    color: color,
                    decoration: TextDecoration.none,
                  ),
                ),
                const SizedBox(height: 2),
                Text(
                  DateFormat('HH:mm').format(bill.date),
                  style: const TextStyle(
                    fontSize: 12,
                    color: CupertinoColors.tertiaryLabel,
                    decoration: TextDecoration.none,
                  ),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }

  String _formatDateHeader(DateTime date) {
    final now = DateTime.now();
    final today = DateTime(now.year, now.month, now.day);
    final yesterday = today.subtract(const Duration(days: 1));
    final dateOnly = DateTime(date.year, date.month, date.day);

    if (dateOnly == today) {
      return '今天';
    } else if (dateOnly == yesterday) {
      return '昨天';
    } else if (date.year == now.year) {
      return DateFormat('MM月dd日').format(date);
    } else {
      return DateFormat('yyyy年MM月dd日').format(date);
    }
  }
}
