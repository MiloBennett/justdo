import 'package:flutter/material.dart';
import '../models/event.dart';
import 'add_event_screen.dart';

class CalendarScreen extends StatefulWidget {
  final List<Event> events;
  final Function(Event) onAddEvent;
  final Function(Event) onRemoveEvent;
  final Function(Event) onToggleComplete;

  const CalendarScreen({
    super.key,
    required this.events,
    required this.onAddEvent,
    required this.onRemoveEvent,
    required this.onToggleComplete,
  });

  @override
  State<CalendarScreen> createState() => _CalendarScreenState();
}

class _CalendarScreenState extends State<CalendarScreen> {
  DateTime _selectedDate = DateTime.now();
  DateTime _focusedMonth = DateTime.now();

  final List<String> _weekDayNames = ['一', '二', '三', '四', '五', '六', '日'];

  void _addEvent() async {
    final result = await Navigator.push<Event>(
      context,
      MaterialPageRoute(
        builder: (context) => AddEventScreen(initialDate: _selectedDate),
      ),
    );

    if (result != null) {
      widget.onAddEvent(result);
    }
  }

  void _deleteEvent(Event event) {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('删除计划'),
        content: Text('确定要删除"${event.title}"吗？'),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text('取消'),
          ),
          TextButton(
            onPressed: () {
              widget.onRemoveEvent(event);
              Navigator.pop(context);
            },
            child: const Text('删除', style: TextStyle(color: Colors.red)),
          ),
        ],
      ),
    );
  }

  List<Event> _getEventsForDate(DateTime date) {
    return widget.events.where((event) => event.isSameDate(date)).toList();
  }

  List<Event> _getEventsForSelectedDate() {
    return _getEventsForDate(_selectedDate);
  }

  void _previousMonth() {
    setState(() {
      _focusedMonth = DateTime(_focusedMonth.year, _focusedMonth.month - 1);
    });
  }

  void _nextMonth() {
    setState(() {
      _focusedMonth = DateTime(_focusedMonth.year, _focusedMonth.month + 1);
    });
  }

  void _goToToday() {
    setState(() {
      _focusedMonth = DateTime.now();
      _selectedDate = DateTime.now();
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('日历计划'),
        centerTitle: true,
        actions: [
          IconButton(
            icon: const Icon(Icons.today),
            tooltip: '今天',
            onPressed: _goToToday,
          ),
        ],
      ),
      body: Column(
        children: [
          // 月份导航
          Container(
            padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
            color: Theme.of(context).colorScheme.primaryContainer,
            child: Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                IconButton(
                  icon: const Icon(Icons.chevron_left),
                  onPressed: _previousMonth,
                ),
                Text(
                  '${_focusedMonth.year}年${_focusedMonth.month}月',
                  style: const TextStyle(
                    fontSize: 18,
                    fontWeight: FontWeight.bold,
                  ),
                ),
                IconButton(
                  icon: const Icon(Icons.chevron_right),
                  onPressed: _nextMonth,
                ),
              ],
            ),
          ),
          // 星期标题
          Container(
            padding: const EdgeInsets.symmetric(vertical: 8),
            child: Row(
              children: _weekDayNames.map((name) {
                return Expanded(
                  child: Center(
                    child: Text(
                      name,
                      style: TextStyle(
                        fontWeight: name == '六' || name == '日'
                            ? FontWeight.bold
                            : FontWeight.normal,
                        color: name == '六' || name == '日' ? Colors.red : null,
                      ),
                    ),
                  ),
                );
              }).toList(),
            ),
          ),
          // 日历网格
          _buildCalendarGrid(),
          const Divider(height: 1),
          // 当日计划列表
          Expanded(child: _buildEventList()),
        ],
      ),
    );
  }

  Widget _buildCalendarGrid() {
    final firstDayOfMonth = DateTime(
      _focusedMonth.year,
      _focusedMonth.month,
      1,
    );
    final lastDayOfMonth = DateTime(
      _focusedMonth.year,
      _focusedMonth.month + 1,
      0,
    );
    final daysInMonth = lastDayOfMonth.day;
    final firstWeekday = firstDayOfMonth.weekday;

    final List<Widget> dayWidgets = [];

    // 填充月初空白
    for (int i = 1; i < firstWeekday; i++) {
      dayWidgets.add(const Expanded(child: SizedBox()));
    }

    // 填充日期
    for (int day = 1; day <= daysInMonth; day++) {
      final date = DateTime(_focusedMonth.year, _focusedMonth.month, day);
      final isToday =
          date.year == DateTime.now().year &&
          date.month == DateTime.now().month &&
          date.day == DateTime.now().day;
      final isSelected =
          date.year == _selectedDate.year &&
          date.month == _selectedDate.month &&
          date.day == _selectedDate.day;
      final eventsOnDay = _getEventsForDate(date);
      final isWeekend = date.weekday == 6 || date.weekday == 7;

      dayWidgets.add(
        Expanded(
          child: GestureDetector(
            onTap: () {
              setState(() {
                _selectedDate = date;
              });
            },
            onDoubleTap: () {
              setState(() {
                _selectedDate = date;
              });
              _addEvent();
            },
            child: Container(
              margin: const EdgeInsets.all(2),
              decoration: BoxDecoration(
                color: isSelected
                    ? Theme.of(context).colorScheme.primary
                    : isToday
                    ? Theme.of(context).colorScheme.primaryContainer
                    : null,
                borderRadius: BorderRadius.circular(8),
              ),
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Text(
                    '$day',
                    style: TextStyle(
                      color: isSelected
                          ? Colors.white
                          : isWeekend
                          ? Colors.red
                          : null,
                      fontWeight: isToday || isSelected
                          ? FontWeight.bold
                          : FontWeight.normal,
                    ),
                  ),
                  if (eventsOnDay.isNotEmpty)
                    Text(
                      '有计划',
                      style: TextStyle(
                        fontSize: 8,
                        color: isSelected ? Colors.white : Colors.orange,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                ],
              ),
            ),
          ),
        ),
      );
    }

    // 组织成行
    final List<Widget> rows = [];
    for (int i = 0; i < dayWidgets.length; i += 7) {
      final rowChildren = dayWidgets.sublist(
        i,
        i + 7 > dayWidgets.length ? dayWidgets.length : i + 7,
      );
      // 补齐剩余位置
      while (rowChildren.length < 7) {
        rowChildren.add(const Expanded(child: SizedBox()));
      }
      rows.add(SizedBox(height: 48, child: Row(children: rowChildren)));
    }

    return Column(children: rows);
  }

  Widget _buildEventList() {
    final events = _getEventsForSelectedDate();

    if (events.isEmpty) {
      return Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(Icons.event_available, size: 64, color: Colors.grey.shade400),
            const SizedBox(height: 16),
            Text(
              '${_selectedDate.month}月${_selectedDate.day}日 暂无计划',
              style: TextStyle(fontSize: 16, color: Colors.grey.shade600),
            ),
            const SizedBox(height: 8),
            Text(
              '双击日期添加计划',
              style: TextStyle(fontSize: 14, color: Colors.grey.shade500),
            ),
          ],
        ),
      );
    }

    return ListView.builder(
      padding: const EdgeInsets.all(8),
      itemCount: events.length,
      itemBuilder: (context, index) {
        final event = events[index];
        return _buildEventCard(event);
      },
    );
  }

  Widget _buildEventCard(Event event) {
    return Card(
      margin: const EdgeInsets.symmetric(vertical: 4),
      child: InkWell(
        onTap: () => widget.onToggleComplete(event),
        onLongPress: () => _deleteEvent(event),
        borderRadius: BorderRadius.circular(12),
        child: Container(
          decoration: BoxDecoration(
            border: Border(left: BorderSide(color: event.color, width: 4)),
          ),
          child: Padding(
            padding: const EdgeInsets.all(12),
            child: Row(
              children: [
                // 时间
                SizedBox(
                  width: 60,
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        '${event.startTime.hour.toString().padLeft(2, '0')}:${event.startTime.minute.toString().padLeft(2, '0')}',
                        style: const TextStyle(
                          fontSize: 16,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                      Text(
                        '${event.endTime.hour.toString().padLeft(2, '0')}:${event.endTime.minute.toString().padLeft(2, '0')}',
                        style: TextStyle(
                          fontSize: 12,
                          color: Colors.grey.shade600,
                        ),
                      ),
                    ],
                  ),
                ),
                const SizedBox(width: 12),
                // 分隔线
                Container(width: 1, height: 40, color: Colors.grey.shade300),
                const SizedBox(width: 12),
                // 内容
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        event.title,
                        style: TextStyle(
                          fontSize: 16,
                          fontWeight: FontWeight.w500,
                          decoration: event.isCompleted
                              ? TextDecoration.lineThrough
                              : null,
                          color: event.isCompleted ? Colors.grey : null,
                        ),
                      ),
                      if (event.location.isNotEmpty)
                        Padding(
                          padding: const EdgeInsets.only(top: 4),
                          child: Row(
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
                                    fontSize: 12,
                                    color: Colors.grey.shade600,
                                  ),
                                  maxLines: 1,
                                  overflow: TextOverflow.ellipsis,
                                ),
                              ),
                            ],
                          ),
                        ),
                      if (event.description.isNotEmpty)
                        Padding(
                          padding: const EdgeInsets.only(top: 4),
                          child: Text(
                            event.description,
                            style: TextStyle(
                              fontSize: 12,
                              color: Colors.grey.shade500,
                            ),
                            maxLines: 2,
                            overflow: TextOverflow.ellipsis,
                          ),
                        ),
                    ],
                  ),
                ),
                // 完成状态
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
