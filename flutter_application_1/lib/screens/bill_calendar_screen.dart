import 'package:flutter/cupertino.dart';
import '../models/bill.dart';

class BillCalendarScreen extends StatefulWidget {
  final List<Bill> bills;
  final Function(Bill) onAddBill;
  final Function(Bill) onRemoveBill;
  final Function(Bill) onToggleComplete;

  const BillCalendarScreen({
    super.key,
    required this.bills,
    required this.onAddBill,
    required this.onRemoveBill,
    required this.onToggleComplete,
  });

  @override
  State<BillCalendarScreen> createState() => _BillCalendarScreenState();
}

class _BillCalendarScreenState extends State<BillCalendarScreen> {
  DateTime _selectedDate = DateTime.now();
  DateTime _focusedMonth = DateTime.now();

  final List<String> _weekDayNames = ['一', '二', '三', '四', '五', '六', '日'];

  void _addBill() async {}

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

  List<Bill> _getBillsForDate(DateTime date) {
    return widget.bills.where((bill) => bill.isSameDate(date)).toList();
  }

  List<Bill> _getBillsForSelectedDate() {
    return _getBillsForDate(_selectedDate);
  }

  double _getTotalAmount(BillType type) {
    return _getBillsForSelectedDate()
        .where((b) => b.type == type)
        .fold(0.0, (sum, b) => sum + b.amount);
  }

  void _previousMonth() {
    setState(() {
      _focusedMonth = DateTime(_focusedMonth.year, _focusedMonth.month - 1);
    });
  }

  void _nextMonth() {
    setState(() {
      _focusedMonth = DateTime(_focusedMonth.year, _focusedMonth.month + 1);
    });
  }

  @override
  Widget build(BuildContext context) {
    return CupertinoPageScaffold(
      navigationBar: CupertinoNavigationBar(
        middle: const Text('日历'),
        trailing: CupertinoButton(
          padding: EdgeInsets.zero,
          onPressed: _addBill,
          child: const Icon(CupertinoIcons.add, size: 26),
        ),
      ),
      child: SafeArea(
        child: Container(
          color: CupertinoColors.systemGroupedBackground,
          child: Column(
            children: [
              Container(
                padding: const EdgeInsets.symmetric(
                  horizontal: 16,
                  vertical: 10,
                ),
                color: CupertinoColors.systemBackground,
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    CupertinoButton(
                      padding: EdgeInsets.zero,
                      onPressed: _previousMonth,
                      child: const Icon(CupertinoIcons.chevron_left, size: 20),
                    ),
                    const SizedBox(width: 24),
                    Container(
                      padding: const EdgeInsets.symmetric(
                        horizontal: 20,
                        vertical: 6,
                      ),
                      decoration: BoxDecoration(
                        color: CupertinoColors.systemBlue.withValues(
                          alpha: 0.1,
                        ),
                        borderRadius: BorderRadius.circular(16),
                      ),
                      child: Text(
                        '${_focusedMonth.year}年${_focusedMonth.month}月',
                        style: const TextStyle(
                          fontSize: 17,
                          fontWeight: FontWeight.w600,
                          color: CupertinoColors.systemBlue,
                          decoration: TextDecoration.none,
                        ),
                      ),
                    ),
                    const SizedBox(width: 24),
                    CupertinoButton(
                      padding: EdgeInsets.zero,
                      onPressed: _nextMonth,
                      child: const Icon(CupertinoIcons.chevron_right, size: 20),
                    ),
                  ],
                ),
              ),
              Container(
                color: CupertinoColors.systemBackground,
                padding: const EdgeInsets.symmetric(vertical: 10),
                child: Row(
                  children: _weekDayNames.map((name) {
                    final isWeekend = name == '六' || name == '日';
                    return Expanded(
                      child: Center(
                        child: Text(
                          name,
                          style: TextStyle(
                            fontSize: 13,
                            fontWeight: FontWeight.w500,
                            color: isWeekend
                                ? CupertinoColors.systemRed
                                : CupertinoColors.secondaryLabel,
                            decoration: TextDecoration.none,
                          ),
                        ),
                      ),
                    );
                  }).toList(),
                ),
              ),
              Container(
                color: CupertinoColors.systemBackground,
                child: _buildCalendarGrid(),
              ),
              _buildDaySummary(),
              Expanded(child: _buildBillList()),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildCalendarGrid() {
    final firstDayOfMonth = DateTime(
      _focusedMonth.year,
      _focusedMonth.month,
      1,
    );
    final daysInMonth = DateTime(
      _focusedMonth.year,
      _focusedMonth.month + 1,
      0,
    ).day;
    final firstWeekday = firstDayOfMonth.weekday;

    final List<Widget> dayWidgets = [];

    for (int i = 1; i < firstWeekday; i++) {
      dayWidgets.add(const Expanded(child: SizedBox()));
    }

    for (int day = 1; day <= daysInMonth; day++) {
      final date = DateTime(_focusedMonth.year, _focusedMonth.month, day);
      final bills = _getBillsForDate(date);
      final isToday =
          date.year == DateTime.now().year &&
          date.month == DateTime.now().month &&
          date.day == DateTime.now().day;
      final isSelected =
          date.year == _selectedDate.year &&
          date.month == _selectedDate.month &&
          date.day == _selectedDate.day;
      final isWeekend = date.weekday == 6 || date.weekday == 7;

      double totalAmount = 0;
      if (bills.isNotEmpty) {
        for (var bill in bills) {
          if (bill.type == BillType.deposit) {
            totalAmount += bill.amount;
          } else {
            totalAmount -= bill.amount;
          }
        }
      }

      dayWidgets.add(
        Expanded(
          child: GestureDetector(
            onTap: () => setState(() => _selectedDate = date),
            child: Container(
              margin: const EdgeInsets.all(2),
              decoration: BoxDecoration(
                color: isSelected
                    ? CupertinoColors.systemBlue
                    : isToday
                    ? CupertinoColors.systemBlue.withValues(alpha: 0.1)
                    : null,
                borderRadius: BorderRadius.circular(8),
              ),
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Text(
                    '$day',
                    style: TextStyle(
                      fontSize: 15,
                      color: isSelected
                          ? CupertinoColors.white
                          : isWeekend
                          ? CupertinoColors.systemRed
                          : CupertinoColors.label,
                      fontWeight: isToday || isSelected
                          ? FontWeight.w600
                          : FontWeight.normal,
                      decoration: TextDecoration.none,
                    ),
                  ),
                  if (bills.isNotEmpty)
                    Text(
                      '${totalAmount >= 0 ? '+' : ''}¥${totalAmount.toStringAsFixed(0)}',
                      style: TextStyle(
                        fontSize: 9,
                        color: isSelected
                            ? CupertinoColors.white
                            : totalAmount >= 0
                            ? CupertinoColors.systemGreen
                            : CupertinoColors.systemOrange,
                        decoration: TextDecoration.none,
                      ),
                    ),
                ],
              ),
            ),
          ),
        ),
      );
    }

    final List<Widget> rows = [];
    for (int i = 0; i < dayWidgets.length; i += 7) {
      final rowChildren = dayWidgets.sublist(
        i,
        i + 7 > dayWidgets.length ? dayWidgets.length : i + 7,
      );
      while (rowChildren.length < 7) {
        rowChildren.add(const Expanded(child: SizedBox()));
      }
      rows.add(SizedBox(height: 44, child: Row(children: rowChildren)));
    }

    return Column(children: rows);
  }

  Widget _buildDaySummary() {
    final deposit = _getTotalAmount(BillType.deposit);
    final withdraw = _getTotalAmount(BillType.withdraw);

    return Container(
      padding: const EdgeInsets.all(20),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceAround,
        children: [
          _buildSummaryItem('存款', deposit, CupertinoColors.systemGreen),
          _buildSummaryItem('取款', withdraw, CupertinoColors.systemOrange),
          _buildSummaryItem(
            '余额',
            deposit - withdraw,
            deposit >= withdraw
                ? CupertinoColors.systemGreen
                : CupertinoColors.systemOrange,
          ),
        ],
      ),
    );
  }

  Widget _buildSummaryItem(String label, double amount, Color color) {
    return Column(
      children: [
        Text(
          label,
          style: const TextStyle(
            fontSize: 13,
            color: CupertinoColors.secondaryLabel,
            decoration: TextDecoration.none,
          ),
        ),
        const SizedBox(height: 4),
        Text(
          '¥${amount.toStringAsFixed(2)}',
          style: TextStyle(
            fontSize: 20,
            fontWeight: FontWeight.w600,
            color: color,
            decoration: TextDecoration.none,
          ),
        ),
      ],
    );
  }

  Widget _buildBillList() {
    final bills = _getBillsForSelectedDate();

    if (bills.isEmpty) {
      return const Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(
              CupertinoIcons.money_dollar,
              size: 48,
              color: CupertinoColors.tertiaryLabel,
            ),
            SizedBox(height: 12),
            Text(
              '暂无储蓄记录',
              style: TextStyle(
                fontSize: 15,
                color: CupertinoColors.tertiaryLabel,
                decoration: TextDecoration.none,
              ),
            ),
          ],
        ),
      );
    }

    return ListView.builder(
      padding: const EdgeInsets.symmetric(horizontal: 16),
      itemCount: bills.length,
      itemBuilder: (context, index) {
        final bill = bills[index];
        return _buildBillItem(bill);
      },
    );
  }

  Widget _buildBillItem(Bill bill) {
    final isWithdraw = bill.type == BillType.withdraw;

    return GestureDetector(
      onLongPress: () => _deleteBill(bill),
      child: Container(
        margin: const EdgeInsets.only(bottom: 1),
        padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
        decoration: const BoxDecoration(
          color: CupertinoColors.systemBackground,
          border: Border(
            bottom: BorderSide(color: CupertinoColors.separator, width: 0.5),
          ),
        ),
        child: Row(
          children: [
            Container(
              width: 36,
              height: 36,
              decoration: BoxDecoration(
                color:
                    (isWithdraw
                            ? CupertinoColors.systemOrange
                            : CupertinoColors.systemGreen)
                        .withValues(alpha: 0.15),
                borderRadius: BorderRadius.circular(8),
              ),
              child: Icon(
                isWithdraw
                    ? CupertinoIcons.arrow_up_circle_fill
                    : CupertinoIcons.arrow_down_circle_fill,
                color: isWithdraw
                    ? CupertinoColors.systemOrange
                    : CupertinoColors.systemGreen,
                size: 22,
              ),
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
                      fontWeight: FontWeight.w600,
                      decoration: TextDecoration.none,
                    ),
                  ),
                  if (bill.category.isNotEmpty)
                    Padding(
                      padding: const EdgeInsets.only(top: 2),
                      child: Text(
                        bill.category,
                        style: const TextStyle(
                          fontSize: 13,
                          color: CupertinoColors.secondaryLabel,
                          decoration: TextDecoration.none,
                        ),
                      ),
                    ),
                ],
              ),
            ),
            Text(
              bill.amountString,
              style: TextStyle(
                fontSize: 17,
                fontWeight: FontWeight.w500,
                color: isWithdraw
                    ? CupertinoColors.systemOrange
                    : CupertinoColors.systemGreen,
                decoration: TextDecoration.none,
              ),
            ),
          ],
        ),
      ),
    );
  }
}
