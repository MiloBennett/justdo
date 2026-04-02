import 'package:flutter/material.dart';
import 'package:flutter/cupertino.dart';
import 'home_screen.dart';
import 'profile_screen.dart';
import 'calendar_screen.dart';
import 'statistics_screen.dart';
import 'settings_screen.dart';
import '../models/schedule_settings.dart';
import '../models/course.dart';
import '../models/event.dart';
import '../models/todo.dart';

class MainScreen extends StatefulWidget {
  const MainScreen({super.key});

  @override
  State<MainScreen> createState() => _MainScreenState();
}

class _MainScreenState extends State<MainScreen>
    with SingleTickerProviderStateMixin {
  int _currentIndex = 0;
  int? _pressedIndex;
  ScheduleSettings _settings = ScheduleSettings();

  // 共享数据
  final List<Course> _courses = [];
  final List<Event> _events = [];
  final List<Todo> _todos = [];

  final List<IconData> _icons = [
    CupertinoIcons.check_mark_circled,
    CupertinoIcons.calendar,
    CupertinoIcons.chart_pie,
    CupertinoIcons.person,
  ];

  void _onTabTapped(int index) {
    setState(() {
      _currentIndex = index;
      _pressedIndex = null;
    });
  }

  void _openSettings() async {
    final result = await Navigator.push<ScheduleSettings>(
      context,
      MaterialPageRoute(
        builder: (context) => SettingsScreen(settings: _settings),
      ),
    );

    if (result != null) {
      setState(() {
        _settings = result;
      });
    }
  }

  void _addCourse(Course course) {
    setState(() {
      _courses.add(course);
    });
  }

  void _removeCourse(Course course) {
    setState(() {
      _courses.remove(course);
    });
  }

  void _addEvent(Event event) {
    setState(() {
      _events.add(event);
      _sortEvents();
    });
  }

  void _removeEvent(Event event) {
    setState(() {
      _events.remove(event);
    });
  }

  void _toggleEventComplete(Event event) {
    setState(() {
      event.isCompleted = !event.isCompleted;
    });
  }

  void _sortEvents() {
    _events.sort((a, b) {
      final dateComparison = a.date.compareTo(b.date);
      if (dateComparison != 0) return dateComparison;
      final aMinutes = a.startTime.hour * 60 + a.startTime.minute;
      final bMinutes = b.startTime.hour * 60 + b.startTime.minute;
      return aMinutes.compareTo(bMinutes);
    });
  }

  Widget _buildTabItem(int index) {
    final isSelected = _currentIndex == index;
    final isPressed = _pressedIndex == index;
    return GestureDetector(
      onTapDown: (_) {
        setState(() {
          _pressedIndex = index;
        });
      },
      onTapUp: (_) {
        _onTabTapped(index);
      },
      onTapCancel: () {
        setState(() {
          _pressedIndex = null;
        });
      },
      child: AnimatedScale(
        scale: isPressed ? 0.9 : 1.0,
        duration: const Duration(milliseconds: 150),
        child: AnimatedContainer(
          duration: const Duration(milliseconds: 150),
          width: 70,
          height: 36,
          decoration: BoxDecoration(
            color: isSelected
                ? CupertinoColors.activeBlue
                : CupertinoColors.systemGrey5,
            borderRadius: BorderRadius.circular(18),
            boxShadow: isSelected
                ? [
                    const BoxShadow(
                      color: Color(0x4D007AFF),
                      blurRadius: 8,
                      offset: Offset(0, 2),
                    ),
                  ]
                : null,
          ),
          child: Icon(
            _icons[index],
            color: isSelected
                ? CupertinoColors.white
                : CupertinoColors.systemGrey,
            size: 20,
          ),
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return CupertinoPageScaffold(
      child: Stack(
        children: [
          // 内容区域
          Positioned.fill(bottom: 80, child: _buildContent()),
          // 底部导航栏
          Positioned(
            left: 0,
            right: 0,
            bottom: 0,
            child: Container(
              height: 80,
              padding: EdgeInsets.only(
                bottom: MediaQuery.of(context).padding.bottom,
              ),
              decoration: const BoxDecoration(
                color: CupertinoColors.systemBackground,
                border: Border(
                  top: BorderSide(color: CupertinoColors.separator, width: 0.5),
                ),
              ),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                crossAxisAlignment: CrossAxisAlignment.center,
                children: [
                  _buildTabItem(0),
                  _buildTabItem(1),
                  _buildTabItem(2),
                  _buildTabItem(3),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildContent() {
    switch (_currentIndex) {
      case 0:
        return HomeScreen(
          courses: _courses,
          events: _events,
          currentWeek: 1,
          onEventComplete: _toggleEventComplete,
          settings: _settings,
          onSettingsPressed: _openSettings,
          onAddCourse: _addCourse,
          onRemoveCourse: _removeCourse,
          onAddEvent: _addEvent,
          onRemoveEvent: _removeEvent,
        );
      case 1:
        return CalendarScreen(
          events: _events,
          onAddEvent: _addEvent,
          onRemoveEvent: _removeEvent,
          onToggleComplete: _toggleEventComplete,
        );
      case 2:
        return StatisticsScreen(todos: _todos);
      case 3:
        return const ProfileScreen();
      default:
        return HomeScreen(
          courses: _courses,
          events: _events,
          currentWeek: 1,
          onEventComplete: _toggleEventComplete,
          settings: _settings,
          onSettingsPressed: _openSettings,
          onAddCourse: _addCourse,
          onRemoveCourse: _removeCourse,
          onAddEvent: _addEvent,
          onRemoveEvent: _removeEvent,
        );
    }
  }
}
