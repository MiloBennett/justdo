import 'package:flutter/material.dart';

enum BudgetType { monthly, weekly, daily }

class Budget {
  String id;
  String category;
  double amount;
  BudgetType type;
  DateTime startDate;
  Color color;

  Budget({
    required this.id,
    required this.category,
    required this.amount,
    required this.type,
    required this.startDate,
    this.color = Colors.blue,
  });

  double getSpentAmount(List<dynamic> bills, DateTime now) {
    DateTime periodStart;
    switch (type) {
      case BudgetType.monthly:
        periodStart = DateTime(now.year, now.month, 1);
        break;
      case BudgetType.weekly:
        periodStart = now.subtract(Duration(days: now.weekday - 1));
        periodStart = DateTime(
          periodStart.year,
          periodStart.month,
          periodStart.day,
        );
        break;
      case BudgetType.daily:
        periodStart = DateTime(now.year, now.month, now.day);
        break;
    }

    return bills
        .where(
          (bill) =>
              bill.category == category &&
              bill.date.isAfter(periodStart) &&
              bill.date.isBefore(now.add(const Duration(days: 1))),
        )
        .fold(0.0, (sum, bill) => sum + bill.amount);
  }

  double getProgress(List<dynamic> bills, DateTime now) {
    final spent = getSpentAmount(bills, now);
    return spent / amount;
  }

  String get typeString {
    switch (type) {
      case BudgetType.monthly:
        return '月度';
      case BudgetType.weekly:
        return '周度';
      case BudgetType.daily:
        return '日度';
    }
  }

  String get periodString {
    switch (type) {
      case BudgetType.monthly:
        return '本月';
      case BudgetType.weekly:
        return '本周';
      case BudgetType.daily:
        return '今日';
    }
  }
}
