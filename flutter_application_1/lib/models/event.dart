import 'package:flutter/material.dart';

class Event {
  String id;
  String title;
  String description;
  DateTime date;
  TimeOfDay startTime;
  TimeOfDay endTime;
  String location;
  Color color;
  bool isCompleted;

  Event({
    required this.id,
    required this.title,
    this.description = '',
    required this.date,
    required this.startTime,
    required this.endTime,
    this.location = '',
    this.color = Colors.blue,
    this.isCompleted = false,
  });

  // 获取日期字符串
  String get dateString {
    return '${date.year}-${date.month.toString().padLeft(2, '0')}-${date.day.toString().padLeft(2, '0')}';
  }

  // 获取时间范围字符串
  String get timeRangeString {
    final start =
        '${startTime.hour.toString().padLeft(2, '0')}:${startTime.minute.toString().padLeft(2, '0')}';
    final end =
        '${endTime.hour.toString().padLeft(2, '0')}:${endTime.minute.toString().padLeft(2, '0')}';
    return '$start - $end';
  }

  // 获取星期几
  String get weekDayName {
    const weekDays = ['周一', '周二', '周三', '周四', '周五', '周六', '周日'];
    return weekDays[date.weekday - 1];
  }

  // 判断是否是今天
  bool get isToday {
    final now = DateTime.now();
    return date.year == now.year &&
        date.month == now.month &&
        date.day == now.day;
  }

  // 获取持续时间（分钟）
  int get durationMinutes {
    final startMinutes = startTime.hour * 60 + startTime.minute;
    final endMinutes = endTime.hour * 60 + endTime.minute;
    return endMinutes - startMinutes;
  }

  // 判断是否与指定日期相同
  bool isSameDate(DateTime other) {
    return date.year == other.year &&
        date.month == other.month &&
        date.day == other.day;
  }
}
