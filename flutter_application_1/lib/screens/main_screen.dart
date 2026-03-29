import 'package:flutter/material.dart';
import 'package:flutter/cupertino.dart';
import 'home_screen.dart';
import 'bill_screen.dart';
import 'profile_screen.dart';
import 'settings_screen.dart';
import '../models/schedule_settings.dart';
import '../models/course.dart';
import '../models/event.dart';
import '../models/bill.dart';
import '../models/budget.dart';

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
  final List<Bill> _bills = [];
  final List<Budget> _budgets = [
    Budget(
      id: '1',
      category: '餐饮',
      amount: 2000,
      type: BudgetType.monthly,
      startDate: DateTime.now(),
      color: const Color(0xFFFF9500),
    ),
    Budget(
      id: '2',
      category: '交通',
      amount: 500,
      type: BudgetType.monthly,
      startDate: DateTime.now(),
      color: const Color(0xFF007AFF),
    ),
    Budget(
      id: '3',
      category: '购物',
      amount: 1500,
      type: BudgetType.monthly,
      startDate: DateTime.now(),
      color: const Color(0xFFFF2D55),
    ),
    Budget(
      id: '4',
      category: '娱乐',
      amount: 800,
      type: BudgetType.monthly,
      startDate: DateTime.now(),
      color: const Color(0xFF5856D6),
    ),
  ];

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

  void _addBill(Bill bill) {
    setState(() {
      _bills.add(bill);
    });
  }

  void _removeBill(Bill bill) {
    setState(() {
      _bills.remove(bill);
    });
  }

  void _toggleBillComplete(Bill bill) {
    setState(() {
      bill.isCompleted = !bill.isCompleted;
    });
  }

  void _addBudget(Budget budget) {
    setState(() {
      _budgets.add(budget);
    });
  }

  void _removeBudget(Budget budget) {
    setState(() {
      _budgets.remove(budget);
    });
  }

  @override
  Widget build(BuildContext context) {
    return CupertinoTabScaffold(
      tabBar: CupertinoTabBar(
        currentIndex: _currentIndex,
        onTap: (index) {
          setState(() {
            _currentIndex = index;
          });
        },
        items: const [
          BottomNavigationBarItem(
            icon: Icon(CupertinoIcons.check_mark_circled),
            activeIcon: Icon(CupertinoIcons.check_mark_circled_solid),
            label: '待办',
          ),
          BottomNavigationBarItem(
            icon: Icon(CupertinoIcons.money_dollar_circle),
            activeIcon: Icon(CupertinoIcons.money_dollar_circle_fill),
            label: '账单',
          ),
          BottomNavigationBarItem(
            icon: Icon(CupertinoIcons.person),
            activeIcon: Icon(CupertinoIcons.person_solid),
            label: '我的',
          ),
        ],
      ),
      tabBuilder: (context, index) {
        switch (index) {
          case 0:
            return CupertinoTabView(
              builder: (context) => HomeScreen(
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
              ),
            );
          case 1:
            return CupertinoTabView(
              builder: (context) => BillScreen(
                bills: _bills,
                budgets: _budgets,
                onAddBill: _addBill,
                onRemoveBill: _removeBill,
                onToggleComplete: _toggleBillComplete,
                onAddBudget: _addBudget,
                onRemoveBudget: _removeBudget,
              ),
            );
          case 2:
            return CupertinoTabView(
              builder: (context) => const ProfileScreen(),
            );
          default:
            return CupertinoTabView(
              builder: (context) => HomeScreen(
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
              ),
            );
        }
      },
    );
  }
}
