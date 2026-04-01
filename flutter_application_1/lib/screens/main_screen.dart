import 'package:flutter/material.dart';
import 'package:flutter/cupertino.dart';
import 'home_screen.dart';
import 'profile_screen.dart';
import 'calendar_screen.dart';
import 'settings_screen.dart';
import '../models/schedule_settings.dart';
import '../models/course.dart';
import '../models/event.dart';

class MainScreen extends StatefulWidget {
  const MainScreen({super.key});

  @override
  State<MainScreen> createState() => _MainScreenState();
}

class _MainScreenState extends State<MainScreen>
    with SingleTickerProviderStateMixin {
  int _currentIndex = 0;
  ScheduleSettings _settings = ScheduleSettings();
  late AnimationController _animationController;
  late Animation<double> _scaleAnimation;

  // 共享数据
  final List<Course> _courses = [];
  final List<Event> _events = [];

  final List<IconData> _icons = [
    CupertinoIcons.check_mark_circled,
    CupertinoIcons.calendar,
    CupertinoIcons.person,
  ];

  @override
  void initState() {
    super.initState();
    _animationController = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 200),
    );
    _scaleAnimation = Tween<double>(begin: 1.0, end: 0.9).animate(
      CurvedAnimation(parent: _animationController, curve: Curves.easeInOut),
    );
  }

  @override
  void dispose() {
    _animationController.dispose();
    super.dispose();
  }

  void _onTabTapped(int index) {
    _animationController.forward().then((_) {
      _animationController.reverse();
    });
    setState(() {
      _currentIndex = index;
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
    return GestureDetector(
      onTap: () => _onTabTapped(index),
      child: AnimatedContainer(
        duration: const Duration(milliseconds: 200),
        width: 44,
        height: 44,
        decoration: BoxDecoration(
          color: isSelected
              ? CupertinoColors.activeBlue
              : CupertinoColors.systemGrey4,
          borderRadius: BorderRadius.circular(22),
          boxShadow: isSelected
              ? [
                  BoxShadow(
                    color: CupertinoColors.activeBlue.withOpacity(0.3),
                    blurRadius: 8,
                    offset: const Offset(0, 2),
                  ),
                ]
              : null,
        ),
        child: AnimatedScale(
          scale: isSelected ? 1.1 : 1.0,
          duration: const Duration(milliseconds: 200),
          child: Icon(_icons[index], color: CupertinoColors.white, size: 22),
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
