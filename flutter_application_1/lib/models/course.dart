import 'package:flutter/material.dart';

// 单双周类型
enum WeekType {
  every, // 每周
  odd, // 单周
  even, // 双周
}

class Course {
  String id;
  String name;
  String classroom;
  String teacher;
  int dayOfWeek; // 1-7 表示周一到周日
  int startSection; // 开始节次
  int endSection; // 结束节次
  Color color; // 课程颜色
  int startWeek; // 开始周次
  int endWeek; // 结束周次
  WeekType weekType; // 单双周类型

  Course({
    required this.id,
    required this.name,
    this.classroom = '',
    this.teacher = '',
    required this.dayOfWeek,
    required this.startSection,
    required this.endSection,
    this.color = Colors.blue,
    this.startWeek = 1,
    this.endWeek = 16,
    this.weekType = WeekType.every,
  });

  // 获取星期几的名称
  String get dayName {
    const days = ['', '周一', '周二', '周三', '周四', '周五', '周六', '周日'];
    return days[dayOfWeek];
  }

  // 获取节次范围的显示文本
  String get sectionRange {
    if (startSection == endSection) {
      return '第$startSection节';
    }
    return '第$startSection-$endSection节';
  }

  // 获取周次范围的显示文本
  String get weekRange {
    String weekTypeStr = '';
    switch (weekType) {
      case WeekType.odd:
        weekTypeStr = '单周';
        break;
      case WeekType.even:
        weekTypeStr = '双周';
        break;
      case WeekType.every:
        weekTypeStr = '';
        break;
    }
    if (weekTypeStr.isEmpty) {
      return '$startWeek-$endWeek周';
    }
    return '$startWeek-$endWeek周 $weekTypeStr';
  }

  // 判断当前周次是否应该显示此课程
  bool shouldShowInWeek(int week) {
    if (week < startWeek || week > endWeek) {
      return false;
    }
    switch (weekType) {
      case WeekType.every:
        return true;
      case WeekType.odd:
        return week % 2 == 1;
      case WeekType.even:
        return week % 2 == 0;
    }
  }

  // 获取单双周类型的显示文本
  String get weekTypeText {
    switch (weekType) {
      case WeekType.every:
        return '每周';
      case WeekType.odd:
        return '单周';
      case WeekType.even:
        return '双周';
    }
  }
}
