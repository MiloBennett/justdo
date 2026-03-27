import 'package:flutter/cupertino.dart';
import '../models/bill.dart';
import 'add_bill_screen.dart';
import 'bill_calendar_screen.dart';

class BillScreen extends StatefulWidget {
  final List<Bill> bills;
  final Function(Bill) onAddBill;
  final Function(Bill) onRemoveBill;
  final Function(Bill) onToggleComplete;

  const BillScreen({
    super.key,
    required this.bills,
    required this.onAddBill,
    required this.onRemoveBill,
    required this.onToggleComplete,
  });

  @override
  State<BillScreen> createState() => _BillScreenState();
}

class _BillScreenState extends State<BillScreen> {
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
    return widget.bills
        .where((b) => b.type == type)
        .fold(0.0, (sum, b) => sum + b.amount);
  }

  @override
  Widget build(BuildContext context) {
    return CupertinoPageScaffold(
      navigationBar: CupertinoNavigationBar(
        middle: const Text('储蓄计划'),
        trailing: Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            CupertinoButton(
              padding: EdgeInsets.zero,
              child: const Icon(CupertinoIcons.calendar, size: 24),
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
            ),
            CupertinoButton(
              padding: EdgeInsets.zero,
              child: const Icon(CupertinoIcons.add, size: 26),
              onPressed: _addBill,
            ),
          ],
        ),
      ),
      child: SafeArea(
        child: Container(
          color: CupertinoColors.systemGroupedBackground,
          child: Column(
            children: [
              _buildSummary(),
              Expanded(child: _buildBillList()),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildSummary() {
    final deposit = _getTotalAmount(BillType.deposit);
    final withdraw = _getTotalAmount(BillType.withdraw);
    final balance = deposit - withdraw;

    return Container(
      padding: const EdgeInsets.all(20),
      color: CupertinoColors.systemBackground,
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceAround,
        children: [
          _buildSummaryItem('存款', deposit, CupertinoColors.systemGreen),
          _buildSummaryItem('取款', withdraw, CupertinoColors.systemOrange),
          _buildSummaryItem(
            '余额',
            balance,
            balance >= 0
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
    if (widget.bills.isEmpty) {
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

    final sortedBills = List<Bill>.from(widget.bills)
      ..sort((a, b) => b.date.compareTo(a.date));

    return ListView.builder(
      padding: const EdgeInsets.symmetric(horizontal: 16),
      itemCount: sortedBills.length,
      itemBuilder: (context, index) {
        final bill = sortedBills[index];
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
                        .withOpacity(0.15),
                borderRadius: BorderRadius.circular(8),
              ),
              child: Icon(
                isWithdraw
                    ? CupertinoIcons.minus_circle_fill
                    : CupertinoIcons.plus_circle_fill,
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
            Column(
              crossAxisAlignment: CrossAxisAlignment.end,
              children: [
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
                Text(
                  '${bill.date.month}/${bill.date.day}',
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
}
