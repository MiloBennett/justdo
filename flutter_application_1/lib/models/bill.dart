import 'package:flutter/material.dart';

enum BillType { deposit, withdraw }

class Bill {
  String id;
  String title;
  double amount;
  DateTime date;
  BillType type;
  String category;
  String note;
  Color color;
  bool isCompleted;

  Bill({
    required this.id,
    required this.title,
    required this.amount,
    required this.date,
    required this.type,
    this.category = '',
    this.note = '',
    this.color = Colors.green,
    this.isCompleted = false,
  });

  String get amountString {
    final prefix = type == BillType.deposit ? '+' : '-';
    return '$prefix¥${amount.toStringAsFixed(2)}';
  }

  bool isSameDate(DateTime other) {
    return date.year == other.year &&
        date.month == other.month &&
        date.day == other.day;
  }
}
