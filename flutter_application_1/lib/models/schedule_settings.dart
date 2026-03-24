import 'package:flutter/material.dart';
import 'time_table.dart';

class ScheduleSettings {
  // 显示设置
  bool showWeekend;
  bool showTime;
  int totalSections;
  double cardBorderRadius;
  double cardHeight;

  // 颜色设置
  Color backgroundColor;
  Color gridLineColor;
  Color todayHighlightColor;
  Color cardShadowColor;

  // 字体设置
  double courseNameFontSize;
  double classroomFontSize;
  double sectionNumberFontSize;
  double timeFontSize;

  // 其他设置
  bool showCourseTeacher;
  bool enableCardShadow;

  // 自定义时间表
  CustomTimeTable timeTable;

  ScheduleSettings({
    this.showWeekend = true,
    this.showTime = true,
    this.totalSections = 10,
    this.cardBorderRadius = 4.0,
    this.cardHeight = 60.0,
    this.backgroundColor = Colors.white,
    this.gridLineColor = Colors.grey,
    this.todayHighlightColor = Colors.blue,
    this.cardShadowColor = Colors.black26,
    this.courseNameFontSize = 12.0,
    this.classroomFontSize = 10.0,
    this.sectionNumberFontSize = 14.0,
    this.timeFontSize = 10.0,
    this.showCourseTeacher = false,
    this.enableCardShadow = true,
    CustomTimeTable? timeTable,
  }) : timeTable = timeTable ?? CustomTimeTable();

  ScheduleSettings copyWith({
    bool? showWeekend,
    bool? showTime,
    int? totalSections,
    double? cardBorderRadius,
    double? cardHeight,
    Color? backgroundColor,
    Color? gridLineColor,
    Color? todayHighlightColor,
    Color? cardShadowColor,
    double? courseNameFontSize,
    double? classroomFontSize,
    double? sectionNumberFontSize,
    double? timeFontSize,
    bool? showCourseTeacher,
    bool? enableCardShadow,
    CustomTimeTable? timeTable,
  }) {
    return ScheduleSettings(
      showWeekend: showWeekend ?? this.showWeekend,
      showTime: showTime ?? this.showTime,
      totalSections: totalSections ?? this.totalSections,
      cardBorderRadius: cardBorderRadius ?? this.cardBorderRadius,
      cardHeight: cardHeight ?? this.cardHeight,
      backgroundColor: backgroundColor ?? this.backgroundColor,
      gridLineColor: gridLineColor ?? this.gridLineColor,
      todayHighlightColor: todayHighlightColor ?? this.todayHighlightColor,
      cardShadowColor: cardShadowColor ?? this.cardShadowColor,
      courseNameFontSize: courseNameFontSize ?? this.courseNameFontSize,
      classroomFontSize: classroomFontSize ?? this.classroomFontSize,
      sectionNumberFontSize:
          sectionNumberFontSize ?? this.sectionNumberFontSize,
      timeFontSize: timeFontSize ?? this.timeFontSize,
      showCourseTeacher: showCourseTeacher ?? this.showCourseTeacher,
      enableCardShadow: enableCardShadow ?? this.enableCardShadow,
      timeTable: timeTable ?? this.timeTable,
    );
  }

  // 获取节次时间
  Map<int, String> get sectionTimes {
    final Map<int, String> times = {};
    for (int i = 1; i <= totalSections; i++) {
      times[i] = timeTable.getStartTime(i);
    }
    return times;
  }

  // 获取节次结束时间
  Map<int, String> get sectionEndTimes {
    final Map<int, String> times = {};
    for (int i = 1; i <= totalSections; i++) {
      times[i] = timeTable.getEndTime(i);
    }
    return times;
  }

  // 获取显示的天数
  int get displayDays => showWeekend ? 7 : 5;
}
