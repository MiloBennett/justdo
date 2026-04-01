import 'package:flutter/material.dart';
import 'package:flutter/cupertino.dart';
import '../models/todo.dart';
import '../models/course.dart';
import '../models/event.dart';
import '../models/schedule_settings.dart';
import '../widgets/todo_item.dart';
import '../widgets/promise_dialog.dart';
import '../widgets/todo_drawer.dart';
import 'add_todo_screen.dart';
import 'todo_mind_map_screen.dart';
import 'focus_settings_screen.dart';
import 'schedule_screen.dart';
import 'calendar_screen.dart';
import 'reluctant_screen.dart';

class HomeScreen extends StatefulWidget {
  final List<Course> courses;
  final List<Event> events;
  final int currentWeek;
  final Function(Event) onEventComplete;
  final ScheduleSettings settings;
  final VoidCallback? onSettingsPressed;
  final Function(Course) onAddCourse;
  final Function(Course) onRemoveCourse;
  final Function(Event) onAddEvent;
  final Function(Event) onRemoveEvent;

  const HomeScreen({
    super.key,
    required this.courses,
    required this.events,
    required this.currentWeek,
    required this.onEventComplete,
    required this.settings,
    this.onSettingsPressed,
    required this.onAddCourse,
    required this.onRemoveCourse,
    required this.onAddEvent,
    required this.onRemoveEvent,
  });

  @override
  State<HomeScreen> createState() => _HomeScreenState();
}

class _HomeScreenState extends State<HomeScreen> {
  final List<Todo> _todos = [];
  bool _showCompleted = false;

  void _addTodo() async {
    final result = await Navigator.push<Todo>(
      context,
      MaterialPageRoute(builder: (context) => const AddTodoScreen()),
    );

    if (result != null) {
      setState(() {
        _todos.add(result);
      });
    }
  }

  void _toggleTodo(int index) {
    setState(() {
      _todos[index].toggleComplete();
    });
  }

  void _deleteTodo(int index) {
    setState(() {
      _todos.removeAt(index);
    });
  }

  void _navigateToMindMap(Todo todo) {
    Navigator.push(
      context,
      MaterialPageRoute(
        builder: (context) => TodoMindMapScreen(
          todo: todo,
          onToggle: (t) {
            setState(() {
              t.toggleComplete();
            });
          },
          onAddSubtask: (parent, subtask) {
            setState(() {
              parent.addSubtask(subtask);
            });
          },
          onDeleteSubtask: (parent, subtask) {
            setState(() {
              parent.removeSubtask(subtask.id);
            });
          },
          onToggleSubtask: (parent, subtask) {
            setState(() {
              subtask.toggleComplete();
            });
          },
        ),
      ),
    );
  }

  // 获取逾期的待办任务
  List<Todo> _getOverdueTodos() {
    final now = DateTime.now();
    return _todos.where((todo) {
      if (todo.isCompleted || todo.endTime == null) return false;
      return todo.endTime!.isBefore(now);
    }).toList()..sort((a, b) => a.endTime!.compareTo(b.endTime!));
  }

  // 获取即将到期的待办任务（60分钟内）
  List<Todo> _getUpcomingTodos() {
    final now = DateTime.now();
    return _todos.where((todo) {
      if (todo.isCompleted || todo.endTime == null) return false;
      final difference = todo.endTime!.difference(now);
      return difference.inMinutes <= 60 && difference.inMinutes > 0;
    }).toList()..sort((a, b) => a.endTime!.compareTo(b.endTime!));
  }

  // 获取未完成的待办任务
  List<Todo> _getPendingTodos() {
    return _todos
        .where((todo) => !todo.isCompleted && !todo.isReluctant)
        .toList();
  }

  // 获取已完成的待办任务
  List<Todo> _getCompletedTodos() {
    return _todos.where((todo) => todo.isCompleted).toList();
  }

  // 获取"不想做"任务
  List<Todo> _getReluctantTodos() {
    return _todos
        .where((todo) => todo.isReluctant && !todo.isCompleted)
        .toList();
  }

  // 获取今天的课程
  List<Course> _getTodayCourses() {
    final today = DateTime.now().weekday;
    return widget.courses.where((course) {
      return course.dayOfWeek == today &&
          course.shouldShowInWeek(widget.currentWeek);
    }).toList()..sort((a, b) => a.startSection.compareTo(b.startSection));
  }

  // 获取今天的日历计划
  List<Event> _getTodayEvents() {
    return widget.events.where((event) {
      return event.isToday && !event.isCompleted;
    }).toList()..sort((a, b) {
      final aMinutes = a.startTime.hour * 60 + a.startTime.minute;
      final bMinutes = b.startTime.hour * 60 + b.startTime.minute;
      return aMinutes.compareTo(bMinutes);
    });
  }

  List<Todo> _getAvailableTodos(Todo exclude) {
    return _todos.where((todo) {
      return !todo.isCompleted && todo.id != exclude.id;
    }).toList();
  }

  void _handleToggleReluctant(Todo todo) {
    if (todo.isReluctant) {
      todo.toggleReluctant();
      todo.promiseTargetId = null;
      todo.promiseTargetTitle = null;
      setState(() {});
    } else {
      final availableTodos = _getAvailableTodos(todo);
      showPromiseDialog(
        context: context,
        currentTodo: todo,
        availableTodos: availableTodos,
        onConfirm: (title, selectedTodo) {
          todo.isReluctant = true;
          if (selectedTodo != null) {
            todo.promiseTargetId = selectedTodo.id;
            todo.promiseTargetTitle = title;
          } else {
            final newTodo = Todo(
              id: 'custom_${DateTime.now().millisecondsSinceEpoch}',
              title: title,
              startTime: todo.startTime,
              endTime: todo.endTime,
            );
            _todos.add(newTodo);
            todo.promiseTargetId = newTodo.id;
            todo.promiseTargetTitle = title;
            todo.startTime = null;
            todo.endTime = null;
          }
          setState(() {});
        },
      );
    }
  }

  void _handleShowPromise(Todo todo) {
    if (todo.promiseTargetTitle != null) {
      showCupertinoDialog(
        context: context,
        builder: (context) => CupertinoAlertDialog(
          title: const Column(
            children: [
              Icon(
                CupertinoIcons.hand_raised_fill,
                color: CupertinoColors.systemGreen,
                size: 32,
              ),
              SizedBox(height: 8),
              Text('你的承诺'),
            ],
          ),
          content: Padding(
            padding: const EdgeInsets.only(top: 16),
            child: Text(
              '做完 "${todo.promiseTargetTitle}"，必须回头啃 "${todo.title}"',
              style: const TextStyle(fontSize: 15),
              textAlign: TextAlign.center,
            ),
          ),
          actions: [
            CupertinoDialogAction(
              child: const Text('查看想做的事'),
              onPressed: () {
                Navigator.pop(context);
                final targetTodo = _todos.firstWhere(
                  (t) => t.id == todo.promiseTargetId,
                  orElse: () => todo,
                );
                if (targetTodo.id != todo.id) {
                  _navigateToMindMap(targetTodo);
                }
              },
            ),
            CupertinoDialogAction(
              isDefaultAction: true,
              child: const Text('知道了'),
              onPressed: () => Navigator.pop(context),
            ),
          ],
        ),
      );
    }
  }

  // 获取最近7天的日历计划
  List<Event> _getUpcomingEvents() {
    final now = DateTime.now();
    final today = DateTime(now.year, now.month, now.day);
    final weekLater = today.add(const Duration(days: 7));

    return widget.events
        .where((event) {
          final eventDate = DateTime(
            event.date.year,
            event.date.month,
            event.date.day,
          );
          return eventDate.isAtSameMomentAs(today) ||
              (eventDate.isAfter(today) && eventDate.isBefore(weekLater));
        })
        .where((event) => !event.isCompleted)
        .toList()
      ..sort((a, b) {
        final dateComparison = a.date.compareTo(b.date);
        if (dateComparison != 0) return dateComparison;
        final aMinutes = a.startTime.hour * 60 + a.startTime.minute;
        final bMinutes = b.startTime.hour * 60 + b.startTime.minute;
        return aMinutes.compareTo(bMinutes);
      });
  }

  void _showDrawer() {
    showGeneralDialog(
      context: context,
      barrierDismissible: true,
      barrierLabel: '关闭侧边栏',
      barrierColor: Colors.black54,
      transitionDuration: const Duration(milliseconds: 300),
      pageBuilder: (context, animation, secondaryAnimation) {
        return Align(
          alignment: Alignment.centerLeft,
          child: TodoDrawer(
            todos: _todos,
            onCategoryTap: (category) {
              Navigator.of(context).pop();
            },
          ),
        );
      },
      transitionBuilder: (context, animation, secondaryAnimation, child) {
        return SlideTransition(
          position: Tween<Offset>(
            begin: const Offset(-1, 0),
            end: Offset.zero,
          ).animate(CurvedAnimation(parent: animation, curve: Curves.easeOut)),
          child: child,
        );
      },
    );
  }

  @override
  Widget build(BuildContext context) {
    final todayCourses = _getTodayCourses();
    final todayEvents = _getTodayEvents();
    final upcomingEvents = _getUpcomingEvents();
    final overdueTodos = _getOverdueTodos();
    final upcomingTodos = _getUpcomingTodos();

    return CupertinoPageScaffold(
      navigationBar: CupertinoNavigationBar(
        leading: GestureDetector(
          onTap: () {
            _showDrawer();
          },
          child: const Icon(CupertinoIcons.line_horizontal_3, size: 22),
        ),
        middle: GestureDetector(
          onTap: () {
            Navigator.push(
              context,
              CupertinoPageRoute(
                builder: (context) => CalendarScreen(
                  events: widget.events,
                  onAddEvent: widget.onAddEvent,
                  onRemoveEvent: widget.onRemoveEvent,
                  onToggleComplete: widget.onEventComplete,
                ),
              ),
            );
          },
          child: const Row(
            mainAxisSize: MainAxisSize.min,
            children: [
              Text('待办事项'),
              SizedBox(width: 4),
              Icon(CupertinoIcons.calendar, size: 18),
            ],
          ),
        ),
        trailing: Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            GestureDetector(
              onTap: () {
                Navigator.push(
                  context,
                  CupertinoPageRoute(
                    builder: (context) => ReluctantScreen(
                      todos: _todos,
                      onToggleComplete: (todo) {
                        setState(() {
                          todo.toggleComplete();
                        });
                      },
                      onRemoveTodo: (todo) {
                        setState(() {
                          _todos.remove(todo);
                        });
                      },
                      onToggleReluctant: (todo) {
                        if (todo.promiseTargetTitle != null) {
                          showCupertinoDialog(
                            context: context,
                            builder: (context) => CupertinoAlertDialog(
                              title: const Text('取消承诺'),
                              content: Text(
                                '确定要取消 "${todo.title}" 的"不想做"标记吗？\n\n你将失去做 "${todo.promiseTargetTitle}" 的机会',
                              ),
                              actions: [
                                CupertinoDialogAction(
                                  child: const Text('取消'),
                                  onPressed: () => Navigator.pop(context),
                                ),
                                CupertinoDialogAction(
                                  isDestructiveAction: true,
                                  child: const Text('确定取消'),
                                  onPressed: () {
                                    Navigator.pop(context);
                                    todo.isReluctant = false;
                                    todo.promiseTargetId = null;
                                    todo.promiseTargetTitle = null;
                                    setState(() {});
                                  },
                                ),
                              ],
                            ),
                          );
                        } else {
                          todo.toggleReluctant();
                          setState(() {});
                        }
                      },
                    ),
                  ),
                );
              },
              child: Padding(
                padding: const EdgeInsets.symmetric(horizontal: 8),
                child: Stack(
                  children: [
                    const Icon(CupertinoIcons.flame, size: 22),
                    // 如果有"不想做但得做"的任务，显示小红点
                    if (_todos.any((t) => t.isReluctant && !t.isCompleted))
                      Positioned(
                        right: 0,
                        top: 0,
                        child: Container(
                          width: 8,
                          height: 8,
                          decoration: const BoxDecoration(
                            color: CupertinoColors.systemOrange,
                            shape: BoxShape.circle,
                          ),
                        ),
                      ),
                  ],
                ),
              ),
            ),
            GestureDetector(
              onTap: () {
                Navigator.push(
                  context,
                  CupertinoPageRoute(
                    builder: (context) => ScheduleScreen(
                      settings: widget.settings,
                      onSettingsPressed: widget.onSettingsPressed,
                      courses: widget.courses,
                      onAddCourse: widget.onAddCourse,
                      onRemoveCourse: widget.onRemoveCourse,
                    ),
                  ),
                );
              },
              child: const Padding(
                padding: EdgeInsets.symmetric(horizontal: 8),
                child: Icon(CupertinoIcons.book, size: 22),
              ),
            ),
            GestureDetector(
              onTap: _addTodo,
              child: const Padding(
                padding: EdgeInsets.symmetric(horizontal: 8),
                child: Icon(CupertinoIcons.add, size: 22),
              ),
            ),
          ],
        ),
      ),
      child: SafeArea(
        child: ListView(
          padding: const EdgeInsets.all(16),
          children: [
            // 不想做但得做
            if (_getReluctantTodos().isNotEmpty) ...[
              _buildSectionHeader(
                '不想做但得做',
                CupertinoIcons.flame,
                Colors.orange,
              ),
              const SizedBox(height: 8),
              ..._getReluctantTodos().map(
                (todo) => TodoItem(
                  todo: todo,
                  onToggle: () {
                    setState(() {
                      todo.toggleComplete();
                    });
                  },
                  onDelete: () {
                    setState(() {
                      _todos.remove(todo);
                    });
                  },
                  onSettings: () {
                    Navigator.of(context, rootNavigator: true).push(
                      CupertinoPageRoute(
                        builder: (context) => FocusSettingsScreen(todo: todo),
                      ),
                    );
                  },
                  onTap: () => _navigateToMindMap(todo),
                  onToggleReluctant: () => _handleToggleReluctant(todo),
                  onShowPromise: () => _handleShowPromise(todo),
                ),
              ),
              const SizedBox(height: 16),
            ],

            // 逾期待办
            if (overdueTodos.isNotEmpty) ...[
              _buildSectionHeader(
                '逾期待办',
                CupertinoIcons.exclamationmark_triangle,
                Colors.red,
              ),
              const SizedBox(height: 8),
              ...overdueTodos.map(
                (todo) => TodoItem(
                  todo: todo,
                  onToggle: () {
                    setState(() {
                      todo.toggleComplete();
                    });
                  },
                  onDelete: () {
                    setState(() {
                      _todos.remove(todo);
                    });
                  },
                  onSettings: () {
                    Navigator.of(context, rootNavigator: true).push(
                      CupertinoPageRoute(
                        builder: (context) => FocusSettingsScreen(todo: todo),
                      ),
                    );
                  },
                  onTap: () => _navigateToMindMap(todo),
                  onToggleReluctant: () => _handleToggleReluctant(todo),
                  onShowPromise: () => _handleShowPromise(todo),
                ),
              ),
              const SizedBox(height: 16),
            ],

            // 即将到期待办（60分钟内）
            if (upcomingTodos.isNotEmpty) ...[
              _buildSectionHeader('即将到期', CupertinoIcons.timer, Colors.orange),
              const SizedBox(height: 8),
              ...upcomingTodos.map(
                (todo) => TodoItem(
                  todo: todo,
                  onToggle: () {
                    setState(() {
                      todo.toggleComplete();
                    });
                  },
                  onDelete: () {
                    setState(() {
                      _todos.remove(todo);
                    });
                  },
                  onSettings: () {
                    Navigator.of(context, rootNavigator: true).push(
                      CupertinoPageRoute(
                        builder: (context) => FocusSettingsScreen(todo: todo),
                      ),
                    );
                  },
                  onTap: () => _navigateToMindMap(todo),
                  onToggleReluctant: () => _handleToggleReluctant(todo),
                  onShowPromise: () => _handleShowPromise(todo),
                ),
              ),
              const SizedBox(height: 16),
            ],

            // 今日课程卡片
            if (todayCourses.isNotEmpty) ...[
              _buildSectionHeader('今日课程', CupertinoIcons.book, Colors.blue),
              const SizedBox(height: 8),
              ...todayCourses.map((course) => _buildCourseCard(course)),
              const SizedBox(height: 16),
            ],

            // 今日计划卡片
            if (todayEvents.isNotEmpty) ...[
              _buildSectionHeader(
                '今日计划',
                CupertinoIcons.calendar,
                Colors.orange,
              ),
              const SizedBox(height: 8),
              ...todayEvents.map((event) => _buildEventCard(event)),
              const SizedBox(height: 16),
            ],

            // 近期计划卡片
            if (upcomingEvents.where((e) => !e.isToday).isNotEmpty) ...[
              _buildSectionHeader('近期计划', CupertinoIcons.clock, Colors.green),
              const SizedBox(height: 8),
              ...upcomingEvents
                  .where((e) => !e.isToday)
                  .take(5)
                  .map((event) => _buildEventCard(event)),
              const SizedBox(height: 16),
            ],

            // 待办事项
            _buildSectionHeader('待办事项', CupertinoIcons.circle, Colors.purple),
            const SizedBox(height: 8),
            if (_getPendingTodos().isEmpty)
              Container(
                padding: const EdgeInsets.all(24),
                decoration: BoxDecoration(
                  color: CupertinoColors.systemGrey6,
                  borderRadius: BorderRadius.circular(12),
                ),
                child: const Center(
                  child: Text(
                    '暂无待办事项',
                    style: TextStyle(
                      fontSize: 14,
                      color: CupertinoColors.systemGrey,
                      decoration: TextDecoration.none,
                    ),
                  ),
                ),
              )
            else
              ..._getPendingTodos().map((todo) {
                final index = _todos.indexOf(todo);
                return TodoItem(
                  todo: todo,
                  onToggle: () => _toggleTodo(index),
                  onDelete: () => _deleteTodo(index),
                  onSettings: () {
                    Navigator.of(context, rootNavigator: true).push(
                      CupertinoPageRoute(
                        builder: (context) => FocusSettingsScreen(todo: todo),
                      ),
                    );
                  },
                  onTap: () => _navigateToMindMap(todo),
                  onToggleReluctant: () => _handleToggleReluctant(todo),
                  onShowPromise: () => _handleShowPromise(todo),
                );
              }),
            const SizedBox(height: 16),

            // 已完成事项
            if (_getCompletedTodos().isNotEmpty) ...[
              GestureDetector(
                onTap: () {
                  setState(() {
                    _showCompleted = !_showCompleted;
                  });
                },
                child: _buildCompletedHeader(),
              ),
              const SizedBox(height: 8),
              if (_showCompleted)
                ..._getCompletedTodos().map((todo) {
                  final index = _todos.indexOf(todo);
                  return TodoItem(
                    todo: todo,
                    onToggle: () => _toggleTodo(index),
                    onDelete: () => _deleteTodo(index),
                    onSettings: () {
                      Navigator.of(context, rootNavigator: true).push(
                        CupertinoPageRoute(
                          builder: (context) => FocusSettingsScreen(todo: todo),
                        ),
                      );
                    },
                    onTap: () => _navigateToMindMap(todo),
                    onToggleReluctant: () => _handleToggleReluctant(todo),
                    onShowPromise: () => _handleShowPromise(todo),
                  );
                }),
              const SizedBox(height: 16),
            ],

            const SizedBox(height: 80),
          ],
        ),
      ),
    );
  }

  Widget _buildSectionHeader(String title, IconData icon, Color color) {
    return Row(
      children: [
        Icon(icon, color: color, size: 20),
        const SizedBox(width: 8),
        Text(
          title,
          style: TextStyle(
            fontSize: 16,
            fontWeight: FontWeight.bold,
            color: color,
            decoration: TextDecoration.none,
          ),
        ),
      ],
    );
  }

  Widget _buildCompletedHeader() {
    final completedCount = _getCompletedTodos().length;
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 10),
      decoration: BoxDecoration(
        color: CupertinoColors.systemGrey6,
        borderRadius: BorderRadius.circular(12),
      ),
      child: Row(
        children: [
          const Icon(
            CupertinoIcons.checkmark_circle_fill,
            color: CupertinoColors.systemGreen,
            size: 20,
          ),
          const SizedBox(width: 8),
          const Text(
            '已完成',
            style: TextStyle(
              fontSize: 16,
              fontWeight: FontWeight.w600,
              color: CupertinoColors.label,
              decoration: TextDecoration.none,
            ),
          ),
          const SizedBox(width: 8),
          Container(
            padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 2),
            decoration: BoxDecoration(
              color: CupertinoColors.systemGrey5,
              borderRadius: BorderRadius.circular(10),
            ),
            child: Text(
              '$completedCount',
              style: const TextStyle(
                fontSize: 13,
                fontWeight: FontWeight.w500,
                color: CupertinoColors.secondaryLabel,
                decoration: TextDecoration.none,
              ),
            ),
          ),
          const Spacer(),
          Icon(
            _showCompleted
                ? CupertinoIcons.chevron_up
                : CupertinoIcons.chevron_down,
            color: CupertinoColors.systemGrey,
            size: 18,
          ),
        ],
      ),
    );
  }

  Widget _buildCourseCard(Course course) {
    return Card(
      margin: const EdgeInsets.only(bottom: 8),
      child: Container(
        decoration: BoxDecoration(
          border: Border(left: BorderSide(color: course.color, width: 4)),
        ),
        child: Padding(
          padding: const EdgeInsets.all(12),
          child: Row(
            children: [
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      course.name,
                      style: const TextStyle(
                        fontSize: 16,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                    const SizedBox(height: 4),
                    Row(
                      children: [
                        Icon(
                          Icons.access_time,
                          size: 14,
                          color: Colors.grey.shade600,
                        ),
                        const SizedBox(width: 4),
                        Text(
                          course.sectionRange,
                          style: TextStyle(
                            fontSize: 13,
                            color: Colors.grey.shade600,
                          ),
                        ),
                      ],
                    ),
                    if (course.classroom.isNotEmpty)
                      Row(
                        children: [
                          Icon(
                            Icons.location_on,
                            size: 14,
                            color: Colors.grey.shade600,
                          ),
                          const SizedBox(width: 4),
                          Text(
                            course.classroom,
                            style: TextStyle(
                              fontSize: 13,
                              color: Colors.grey.shade600,
                            ),
                          ),
                        ],
                      ),
                    if (course.teacher.isNotEmpty)
                      Row(
                        children: [
                          Icon(
                            Icons.person,
                            size: 14,
                            color: Colors.grey.shade600,
                          ),
                          const SizedBox(width: 4),
                          Text(
                            course.teacher,
                            style: TextStyle(
                              fontSize: 13,
                              color: Colors.grey.shade600,
                            ),
                          ),
                        ],
                      ),
                  ],
                ),
              ),
              Container(
                padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                decoration: BoxDecoration(
                  color: course.color.withOpacity(0.2),
                  borderRadius: BorderRadius.circular(4),
                ),
                child: Text(
                  course.dayName,
                  style: TextStyle(
                    color: course.color,
                    fontWeight: FontWeight.bold,
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildEventCard(Event event) {
    return Card(
      margin: const EdgeInsets.only(bottom: 8),
      child: InkWell(
        onTap: () => widget.onEventComplete(event),
        borderRadius: BorderRadius.circular(12),
        child: Container(
          decoration: BoxDecoration(
            border: Border(left: BorderSide(color: event.color, width: 4)),
          ),
          child: Padding(
            padding: const EdgeInsets.all(12),
            child: Row(
              children: [
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        event.title,
                        style: TextStyle(
                          fontSize: 16,
                          fontWeight: FontWeight.bold,
                          decoration: event.isCompleted
                              ? TextDecoration.lineThrough
                              : null,
                          color: event.isCompleted ? Colors.grey : null,
                        ),
                      ),
                      const SizedBox(height: 4),
                      Row(
                        children: [
                          Icon(
                            Icons.access_time,
                            size: 14,
                            color: Colors.grey.shade600,
                          ),
                          const SizedBox(width: 4),
                          Text(
                            event.timeRangeString,
                            style: TextStyle(
                              fontSize: 13,
                              color: Colors.grey.shade600,
                            ),
                          ),
                        ],
                      ),
                      if (!event.isToday)
                        Row(
                          children: [
                            Icon(
                              Icons.calendar_today,
                              size: 14,
                              color: Colors.grey.shade600,
                            ),
                            const SizedBox(width: 4),
                            Text(
                              '${event.date.month}月${event.date.day}日 ${event.weekDayName}',
                              style: TextStyle(
                                fontSize: 13,
                                color: Colors.grey.shade600,
                              ),
                            ),
                          ],
                        ),
                      if (event.location.isNotEmpty)
                        Row(
                          children: [
                            Icon(
                              Icons.location_on,
                              size: 14,
                              color: Colors.grey.shade600,
                            ),
                            const SizedBox(width: 4),
                            Expanded(
                              child: Text(
                                event.location,
                                style: TextStyle(
                                  fontSize: 13,
                                  color: Colors.grey.shade600,
                                ),
                                maxLines: 1,
                                overflow: TextOverflow.ellipsis,
                              ),
                            ),
                          ],
                        ),
                    ],
                  ),
                ),
                Icon(
                  event.isCompleted
                      ? Icons.check_circle
                      : Icons.check_circle_outline,
                  color: event.isCompleted ? Colors.green : Colors.grey,
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}
