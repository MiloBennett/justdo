import 'package:flutter/material.dart';
import 'home_screen.dart';
import 'schedule_screen.dart';
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

class _MainScreenState extends State<MainScreen> {
  int _currentIndex = 0;
  ScheduleSettings _settings = ScheduleSettings();

  // 共享数据
  final List<Course> _courses = [];
  final List<Event> _events = [];

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

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: IndexedStack(
        index: _currentIndex,
        children: [
          HomeScreen(
            courses: _courses,
            events: _events,
            currentWeek: 1, // 默认第1周，可后续优化
            onEventComplete: _toggleEventComplete,
          ),
          ScheduleScreen(
            settings: _settings,
            onSettingsPressed: _openSettings,
            courses: _courses,
            onAddCourse: _addCourse,
            onRemoveCourse: _removeCourse,
          ),
          CalendarScreen(
            events: _events,
            onAddEvent: _addEvent,
            onRemoveEvent: _removeEvent,
            onToggleComplete: _toggleEventComplete,
          ),
        ],
      ),
      bottomNavigationBar: NavigationBar(
        selectedIndex: _currentIndex,
        onDestinationSelected: (index) {
          setState(() {
            _currentIndex = index;
          });
        },
        destinations: const [
          NavigationDestination(
            icon: Icon(Icons.check_circle_outline),
            selectedIcon: Icon(Icons.check_circle),
            label: '待办',
          ),
          NavigationDestination(
            icon: Icon(Icons.calendar_month_outlined),
            selectedIcon: Icon(Icons.calendar_month),
            label: '课表',
          ),
          NavigationDestination(
            icon: Icon(Icons.event_outlined),
            selectedIcon: Icon(Icons.event),
            label: '日历',
          ),
        ],
      ),
    );
  }
}
