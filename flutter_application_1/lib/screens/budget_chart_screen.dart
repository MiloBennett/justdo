import 'package:flutter/cupertino.dart';
import '../models/budget.dart';
import '../models/bill.dart';

class BudgetChartScreen extends StatelessWidget {
  final List<Budget> budgets;
  final List<Bill> bills;

  const BudgetChartScreen({
    super.key,
    required this.budgets,
    required this.bills,
  });

  @override
  Widget build(BuildContext context) {
    final now = DateTime.now();

    return CupertinoPageScaffold(
      backgroundColor: CupertinoColors.systemGroupedBackground,
      navigationBar: const CupertinoNavigationBar(middle: Text('预算分析')),
      child: SafeArea(
        child: budgets.isEmpty
            ? _buildEmptyState()
            : ListView(
                padding: const EdgeInsets.all(16),
                children: [
                  _buildSummaryCard(now),
                  const SizedBox(height: 20),
                  _buildBarChart(now),
                  const SizedBox(height: 20),
                  _buildLegend(),
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
              CupertinoIcons.chart_bar,
              size: 40,
              color: CupertinoColors.systemGrey,
            ),
          ),
          const SizedBox(height: 16),
          const Text(
            '暂无预算数据',
            style: TextStyle(
              fontSize: 17,
              fontWeight: FontWeight.w600,
              color: CupertinoColors.label,
              decoration: TextDecoration.none,
            ),
          ),
          const SizedBox(height: 8),
          const Text(
            '请先添加预算后再查看分析',
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

  Widget _buildSummaryCard(DateTime now) {
    double totalBudget = 0;
    double totalSpent = 0;

    for (var budget in budgets) {
      totalBudget += budget.amount;
      totalSpent += budget.getSpentAmount(bills, now);
    }

    final progress = totalBudget > 0 ? totalSpent / totalBudget : 0.0;
    final remaining = totalBudget - totalSpent;

    return Container(
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        color: CupertinoColors.systemBackground,
        borderRadius: BorderRadius.circular(16),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const Text(
            '本月总览',
            style: TextStyle(
              fontSize: 17,
              fontWeight: FontWeight.w600,
              color: CupertinoColors.label,
              decoration: TextDecoration.none,
            ),
          ),
          const SizedBox(height: 16),
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceAround,
            children: [
              _buildSummaryItem('预算', totalBudget, CupertinoColors.systemBlue),
              _buildSummaryItem(
                '已花费',
                totalSpent,
                CupertinoColors.systemOrange,
              ),
              _buildSummaryItem(
                '剩余',
                remaining,
                remaining >= 0
                    ? CupertinoColors.systemGreen
                    : CupertinoColors.systemRed,
              ),
            ],
          ),
          const SizedBox(height: 16),
          ClipRRect(
            borderRadius: BorderRadius.circular(6),
            child: Container(
              height: 8,
              decoration: BoxDecoration(
                color: CupertinoColors.systemGrey5,
                borderRadius: BorderRadius.circular(6),
              ),
              child: FractionallySizedBox(
                alignment: Alignment.centerLeft,
                widthFactor: progress.clamp(0.0, 1.0),
                child: Container(
                  decoration: BoxDecoration(
                    color: progress > 1.0
                        ? CupertinoColors.systemRed
                        : progress > 0.8
                        ? CupertinoColors.systemOrange
                        : CupertinoColors.systemBlue,
                    borderRadius: BorderRadius.circular(6),
                  ),
                ),
              ),
            ),
          ),
          const SizedBox(height: 8),
          Text(
            '已使用 ${(progress * 100).toStringAsFixed(1)}%',
            style: const TextStyle(
              fontSize: 13,
              color: CupertinoColors.secondaryLabel,
              decoration: TextDecoration.none,
            ),
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
          '¥${amount.toStringAsFixed(0)}',
          style: TextStyle(
            fontSize: 20,
            fontWeight: FontWeight.w700,
            color: color,
            decoration: TextDecoration.none,
          ),
        ),
      ],
    );
  }

  Widget _buildBarChart(DateTime now) {
    double maxAmount = 0;
    for (var budget in budgets) {
      final spent = budget.getSpentAmount(bills, now);
      if (budget.amount > maxAmount) maxAmount = budget.amount;
      if (spent > maxAmount) maxAmount = spent;
    }

    if (maxAmount == 0) maxAmount = 100;

    return Container(
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        color: CupertinoColors.systemBackground,
        borderRadius: BorderRadius.circular(16),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const Text(
            '各分类对比',
            style: TextStyle(
              fontSize: 17,
              fontWeight: FontWeight.w600,
              color: CupertinoColors.label,
              decoration: TextDecoration.none,
            ),
          ),
          const SizedBox(height: 20),
          SizedBox(
            height: 200,
            child: Row(
              crossAxisAlignment: CrossAxisAlignment.end,
              mainAxisAlignment: MainAxisAlignment.spaceEvenly,
              children: budgets.map((budget) {
                final spent = budget.getSpentAmount(bills, now);
                return _buildBarGroup(budget, spent, maxAmount);
              }).toList(),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildBarGroup(Budget budget, double spent, double maxAmount) {
    final budgetHeight = (budget.amount / maxAmount) * 160;
    final spentHeight = (spent / maxAmount) * 160;
    final isOverBudget = spent > budget.amount;

    return Expanded(
      child: Padding(
        padding: const EdgeInsets.symmetric(horizontal: 4),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.end,
          children: [
            Text(
              '¥${spent.toStringAsFixed(0)}',
              style: TextStyle(
                fontSize: 10,
                color: isOverBudget
                    ? CupertinoColors.systemRed
                    : CupertinoColors.systemOrange,
                decoration: TextDecoration.none,
              ),
            ),
            const SizedBox(height: 4),
            Row(
              mainAxisAlignment: MainAxisAlignment.center,
              crossAxisAlignment: CrossAxisAlignment.end,
              children: [
                Container(
                  width: 14,
                  height: budgetHeight.clamp(4, 160),
                  decoration: BoxDecoration(
                    color: budget.color.withValues(alpha: 0.3),
                    borderRadius: const BorderRadius.vertical(
                      top: Radius.circular(4),
                    ),
                  ),
                ),
                const SizedBox(width: 2),
                Container(
                  width: 14,
                  height: spentHeight.clamp(4, 160),
                  decoration: BoxDecoration(
                    color: isOverBudget
                        ? CupertinoColors.systemRed
                        : budget.color,
                    borderRadius: const BorderRadius.vertical(
                      top: Radius.circular(4),
                    ),
                  ),
                ),
              ],
            ),
            const SizedBox(height: 8),
            Text(
              budget.category,
              style: const TextStyle(
                fontSize: 11,
                color: CupertinoColors.secondaryLabel,
                decoration: TextDecoration.none,
              ),
              maxLines: 1,
              overflow: TextOverflow.ellipsis,
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildLegend() {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: CupertinoColors.systemBackground,
        borderRadius: BorderRadius.circular(12),
      ),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceEvenly,
        children: [
          _buildLegendItem(
            '预算',
            CupertinoColors.systemBlue.withValues(alpha: 0.3),
          ),
          _buildLegendItem('实际开销', CupertinoColors.systemBlue),
          _buildLegendItem('超支', CupertinoColors.systemRed),
        ],
      ),
    );
  }

  Widget _buildLegendItem(String label, Color color) {
    return Row(
      children: [
        Container(
          width: 12,
          height: 12,
          decoration: BoxDecoration(
            color: color,
            borderRadius: BorderRadius.circular(3),
          ),
        ),
        const SizedBox(width: 6),
        Text(
          label,
          style: const TextStyle(
            fontSize: 13,
            color: CupertinoColors.secondaryLabel,
            decoration: TextDecoration.none,
          ),
        ),
      ],
    );
  }
}
