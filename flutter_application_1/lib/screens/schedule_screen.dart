import 'package:flutter/material.dart';
import '../models/course.dart';
import '../models/schedule_settings.dart';
import 'add_course_screen.dart';

class ScheduleScreen extends StatefulWidget {
  final ScheduleSettings settings;
  final VoidCallback? onSettingsPressed;
  final List<Course> courses;
  final Function(Course) onAddCourse;
  final Function(Course) onRemoveCourse;

  const ScheduleScreen({
    super.key,
    required this.settings,
    this.onSettingsPressed,
    required this.courses,
    required this.onAddCourse,
    required this.onRemoveCourse,
  });

  @override
  State<ScheduleScreen> createState() => _ScheduleScreenState();
}

class _ScheduleScreenState extends State<ScheduleScreen> {
  int _currentWeek = 1;

  final List<String> _dayNames = ['', '周一', '周二', '周三', '周四', '周五', '周六', '周日'];

  void _addCourse() async {
    final result = await Navigator.push<Course>(
      context,
      MaterialPageRoute(
        builder: (context) =>
            AddCourseScreen(totalSections: widget.settings.totalSections),
      ),
    );

    if (result != null) {
      widget.onAddCourse(result);
    }
  }

  void _deleteCourse(Course course) {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('删除课程'),
        content: Text('确定要删除"${course.name}"吗？'),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text('取消'),
          ),
          TextButton(
            onPressed: () {
              widget.onRemoveCourse(course);
              Navigator.pop(context);
            },
            child: const Text('删除', style: TextStyle(color: Colors.red)),
          ),
        ],
      ),
    );
  }

  List<Course> _getCoursesForDayAndWeek(int day) {
    return widget.courses.where((course) {
      return course.dayOfWeek == day && course.shouldShowInWeek(_currentWeek);
    }).toList();
  }

  @override
  Widget build(BuildContext context) {
    final settings = widget.settings;
    final displayDays = settings.displayDays;
    final sectionTimes = settings.sectionTimes;

    return Scaffold(
      appBar: AppBar(
        title: const Text('我的课表'),
        centerTitle: true,
        actions: [
          IconButton(
            icon: const Icon(Icons.settings),
            tooltip: '课表设置',
            onPressed: widget.onSettingsPressed,
          ),
          IconButton(
            icon: const Icon(Icons.calendar_today),
            onPressed: () {
              showDialog(
                context: context,
                builder: (context) {
                  int selectedWeek = _currentWeek;
                  return AlertDialog(
                    title: const Text('选择周次'),
                    content: DropdownButton<int>(
                      value: selectedWeek,
                      isExpanded: true,
                      items: List.generate(20, (index) {
                        final week = index + 1;
                        return DropdownMenuItem(
                          value: week,
                          child: Text('第$week周'),
                        );
                      }),
                      onChanged: (value) {
                        selectedWeek = value!;
                      },
                    ),
                    actions: [
                      TextButton(
                        onPressed: () => Navigator.pop(context),
                        child: const Text('取消'),
                      ),
                      TextButton(
                        onPressed: () {
                          setState(() {
                            _currentWeek = selectedWeek;
                          });
                          Navigator.pop(context);
                        },
                        child: const Text('确定'),
                      ),
                    ],
                  );
                },
              );
            },
          ),
        ],
      ),
      body: Container(
        color: settings.backgroundColor,
        child: Column(
          children: [
            Container(
              padding: const EdgeInsets.all(12),
              color: Theme.of(context).colorScheme.primaryContainer,
              child: Row(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  IconButton(
                    icon: const Icon(Icons.chevron_left),
                    onPressed: _currentWeek > 1
                        ? () => setState(() => _currentWeek--)
                        : null,
                  ),
                  Text(
                    '第$_currentWeek周${_currentWeek % 2 == 1 ? '(单周)' : '(双周)'}',
                    style: const TextStyle(
                      fontSize: 18,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                  IconButton(
                    icon: const Icon(Icons.chevron_right),
                    onPressed: _currentWeek < 20
                        ? () => setState(() => _currentWeek++)
                        : null,
                  ),
                ],
              ),
            ),
            Expanded(
              child: widget.courses.isEmpty
                  ? const Center(
                      child: Column(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: [
                          Icon(
                            Icons.calendar_month,
                            size: 80,
                            color: Colors.grey,
                          ),
                          SizedBox(height: 16),
                          Text(
                            '暂无课程',
                            style: TextStyle(fontSize: 18, color: Colors.grey),
                          ),
                        ],
                      ),
                    )
                  : SingleChildScrollView(
                      child: Row(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          // 左侧节次列
                          SizedBox(
                            width: 50,
                            child: Column(
                              children: List.generate(settings.totalSections, (
                                index,
                              ) {
                                final section = index + 1;
                                return Container(
                                  height: settings.cardHeight,
                                  alignment: Alignment.center,
                                  decoration: BoxDecoration(
                                    border: Border(
                                      bottom: BorderSide(
                                        color: settings.gridLineColor
                                            .withOpacity(0.3),
                                      ),
                                    ),
                                  ),
                                  child: Column(
                                    mainAxisAlignment: MainAxisAlignment.center,
                                    children: [
                                      Text(
                                        '$section',
                                        style: TextStyle(
                                          fontWeight: FontWeight.bold,
                                          fontSize:
                                              settings.sectionNumberFontSize,
                                        ),
                                      ),
                                      if (settings.showTime)
                                        Text(
                                          sectionTimes[section] ?? '',
                                          style: TextStyle(
                                            fontSize: settings.timeFontSize,
                                            color: Colors.grey,
                                          ),
                                        ),
                                    ],
                                  ),
                                );
                              }),
                            ),
                          ),
                          // 右侧课程
                          Expanded(
                            child: Row(
                              children: List.generate(displayDays, (dayIndex) {
                                final day = dayIndex + 1;
                                final dayCourses = _getCoursesForDayAndWeek(
                                  day,
                                );

                                return Expanded(
                                  child: Column(
                                    children: [
                                      // 星期标题
                                      Container(
                                        height: 40,
                                        alignment: Alignment.center,
                                        decoration: BoxDecoration(
                                          color: day == DateTime.now().weekday
                                              ? settings.todayHighlightColor
                                                    .withOpacity(0.2)
                                              : null,
                                          border: Border(
                                            bottom: BorderSide(
                                              color: settings.gridLineColor
                                                  .withOpacity(0.3),
                                            ),
                                            left: BorderSide(
                                              color: settings.gridLineColor
                                                  .withOpacity(0.3),
                                            ),
                                          ),
                                        ),
                                        child: Text(
                                          _dayNames[day],
                                          style: TextStyle(
                                            fontWeight:
                                                day == DateTime.now().weekday
                                                ? FontWeight.bold
                                                : FontWeight.normal,
                                            color: day == DateTime.now().weekday
                                                ? settings.todayHighlightColor
                                                : null,
                                          ),
                                        ),
                                      ),
                                      // 课程格子
                                      SizedBox(
                                        height:
                                            settings.totalSections *
                                            settings.cardHeight,
                                        child: Stack(
                                          children: [
                                            // 背景网格
                                            ...List.generate(
                                              settings.totalSections,
                                              (sectionIndex) {
                                                return Positioned(
                                                  top:
                                                      sectionIndex *
                                                      settings.cardHeight,
                                                  left: 0,
                                                  right: 0,
                                                  height: settings.cardHeight,
                                                  child: Container(
                                                    decoration: BoxDecoration(
                                                      border: Border(
                                                        bottom: BorderSide(
                                                          color: settings
                                                              .gridLineColor
                                                              .withOpacity(0.3),
                                                        ),
                                                        left: BorderSide(
                                                          color: settings
                                                              .gridLineColor
                                                              .withOpacity(0.3),
                                                        ),
                                                      ),
                                                    ),
                                                  ),
                                                );
                                              },
                                            ),
                                            // 课程卡片
                                            ...dayCourses.map((course) {
                                              final top =
                                                  (course.startSection - 1) *
                                                  settings.cardHeight;
                                              final height =
                                                  (course.endSection -
                                                      course.startSection +
                                                      1) *
                                                  settings.cardHeight;
                                              final timeRange = settings
                                                  .timeTable
                                                  .getTimeRange(
                                                    course.startSection,
                                                    course.endSection,
                                                  );

                                              return Positioned(
                                                top: top,
                                                left: 2,
                                                right: 2,
                                                height: height - 4,
                                                child: GestureDetector(
                                                  onTap: () =>
                                                      _deleteCourse(course),
                                                  child: Container(
                                                    decoration: BoxDecoration(
                                                      color: course.color
                                                          .withOpacity(0.9),
                                                      borderRadius:
                                                          BorderRadius.circular(
                                                            settings
                                                                .cardBorderRadius,
                                                          ),
                                                      boxShadow:
                                                          settings
                                                              .enableCardShadow
                                                          ? [
                                                              BoxShadow(
                                                                color: settings
                                                                    .cardShadowColor,
                                                                blurRadius: 4,
                                                                offset:
                                                                    const Offset(
                                                                      0,
                                                                      2,
                                                                    ),
                                                              ),
                                                            ]
                                                          : null,
                                                    ),
                                                    padding:
                                                        const EdgeInsets.all(4),
                                                    child: Column(
                                                      mainAxisAlignment:
                                                          MainAxisAlignment
                                                              .center,
                                                      children: [
                                                        Text(
                                                          course.name,
                                                          style: TextStyle(
                                                            color: Colors.white,
                                                            fontSize: settings
                                                                .courseNameFontSize,
                                                            fontWeight:
                                                                FontWeight.bold,
                                                          ),
                                                          textAlign:
                                                              TextAlign.center,
                                                          maxLines: 2,
                                                          overflow: TextOverflow
                                                              .ellipsis,
                                                        ),
                                                        if (settings
                                                                .showCourseTeacher &&
                                                            course
                                                                .teacher
                                                                .isNotEmpty)
                                                          Text(
                                                            course.teacher,
                                                            style: TextStyle(
                                                              color: Colors
                                                                  .white70,
                                                              fontSize: settings
                                                                  .classroomFontSize,
                                                            ),
                                                            maxLines: 1,
                                                            overflow:
                                                                TextOverflow
                                                                    .ellipsis,
                                                          ),
                                                        if (course
                                                            .classroom
                                                            .isNotEmpty)
                                                          Text(
                                                            '@${course.classroom}',
                                                            style: TextStyle(
                                                              color: Colors
                                                                  .white70,
                                                              fontSize: settings
                                                                  .classroomFontSize,
                                                            ),
                                                            maxLines: 1,
                                                            overflow:
                                                                TextOverflow
                                                                    .ellipsis,
                                                          ),
                                                        if (settings.showTime &&
                                                            height > 80)
                                                          Text(
                                                            timeRange,
                                                            style: TextStyle(
                                                              color: Colors
                                                                  .white60,
                                                              fontSize:
                                                                  settings
                                                                      .classroomFontSize -
                                                                  1,
                                                            ),
                                                          ),
                                                      ],
                                                    ),
                                                  ),
                                                ),
                                              );
                                            }),
                                          ],
                                        ),
                                      ),
                                    ],
                                  ),
                                );
                              }),
                            ),
                          ),
                        ],
                      ),
                    ),
            ),
          ],
        ),
      ),
      floatingActionButton: FloatingActionButton(
        onPressed: _addCourse,
        child: const Icon(Icons.add),
      ),
    );
  }
}
