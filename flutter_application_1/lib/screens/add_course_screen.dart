import 'package:flutter/material.dart';
import '../models/course.dart';

class AddCourseScreen extends StatefulWidget {
  final int totalSections;

  const AddCourseScreen({super.key, this.totalSections = 10});

  @override
  State<AddCourseScreen> createState() => _AddCourseScreenState();
}

class _AddCourseScreenState extends State<AddCourseScreen> {
  final _nameController = TextEditingController();
  final _classroomController = TextEditingController();
  final _teacherController = TextEditingController();
  final _formKey = GlobalKey<FormState>();

  int _selectedDay = 1;
  int _startSection = 1;
  int _endSection = 2;
  int _startWeek = 1;
  int _endWeek = 16;
  Color _selectedColor = Colors.blue;
  WeekType _weekType = WeekType.every;

  final List<Color> _colors = [
    Colors.blue,
    Colors.red,
    Colors.green,
    Colors.orange,
    Colors.purple,
    Colors.teal,
    Colors.pink,
    Colors.indigo,
  ];

  final List<String> _dayNames = ['', '周一', '周二', '周三', '周四', '周五', '周六', '周日'];

  @override
  void dispose() {
    _nameController.dispose();
    _classroomController.dispose();
    _teacherController.dispose();
    super.dispose();
  }

  void _submit() {
    if (_formKey.currentState!.validate()) {
      if (_endSection < _startSection) {
        ScaffoldMessenger.of(
          context,
        ).showSnackBar(const SnackBar(content: Text('结束节次不能小于开始节次')));
        return;
      }
      if (_endWeek < _startWeek) {
        ScaffoldMessenger.of(
          context,
        ).showSnackBar(const SnackBar(content: Text('结束周次不能小于开始周次')));
        return;
      }

      final course = Course(
        id: DateTime.now().millisecondsSinceEpoch.toString(),
        name: _nameController.text.trim(),
        classroom: _classroomController.text.trim(),
        teacher: _teacherController.text.trim(),
        dayOfWeek: _selectedDay,
        startSection: _startSection,
        endSection: _endSection,
        color: _selectedColor,
        startWeek: _startWeek,
        endWeek: _endWeek,
        weekType: _weekType,
      );
      Navigator.pop(context, course);
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('添加课程')),
      body: Form(
        key: _formKey,
        child: ListView(
          padding: const EdgeInsets.all(16),
          children: [
            TextFormField(
              controller: _nameController,
              decoration: const InputDecoration(
                labelText: '课程名称',
                border: OutlineInputBorder(),
                prefixIcon: Icon(Icons.book),
              ),
              validator: (value) {
                if (value == null || value.trim().isEmpty) {
                  return '请输入课程名称';
                }
                return null;
              },
              autofocus: true,
            ),
            const SizedBox(height: 16),
            TextFormField(
              controller: _classroomController,
              decoration: const InputDecoration(
                labelText: '教室',
                border: OutlineInputBorder(),
                prefixIcon: Icon(Icons.location_on),
              ),
            ),
            const SizedBox(height: 16),
            TextFormField(
              controller: _teacherController,
              decoration: const InputDecoration(
                labelText: '教师',
                border: OutlineInputBorder(),
                prefixIcon: Icon(Icons.person),
              ),
            ),
            const SizedBox(height: 16),
            DropdownButtonFormField<int>(
              value: _selectedDay,
              decoration: const InputDecoration(
                labelText: '星期',
                border: OutlineInputBorder(),
                prefixIcon: Icon(Icons.calendar_today),
              ),
              items: List.generate(7, (index) {
                final day = index + 1;
                return DropdownMenuItem(
                  value: day,
                  child: Text(_dayNames[day]),
                );
              }),
              onChanged: (value) {
                setState(() {
                  _selectedDay = value!;
                });
              },
            ),
            const SizedBox(height: 16),
            Row(
              children: [
                Expanded(
                  child: DropdownButtonFormField<int>(
                    value: _startSection,
                    decoration: const InputDecoration(
                      labelText: '开始节次',
                      border: OutlineInputBorder(),
                    ),
                    items: List.generate(widget.totalSections, (index) {
                      final section = index + 1;
                      return DropdownMenuItem(
                        value: section,
                        child: Text('第$section节'),
                      );
                    }),
                    onChanged: (value) {
                      setState(() {
                        _startSection = value!;
                      });
                    },
                  ),
                ),
                const SizedBox(width: 16),
                Expanded(
                  child: DropdownButtonFormField<int>(
                    value: _endSection,
                    decoration: const InputDecoration(
                      labelText: '结束节次',
                      border: OutlineInputBorder(),
                    ),
                    items: List.generate(widget.totalSections, (index) {
                      final section = index + 1;
                      return DropdownMenuItem(
                        value: section,
                        child: Text('第$section节'),
                      );
                    }),
                    onChanged: (value) {
                      setState(() {
                        _endSection = value!;
                      });
                    },
                  ),
                ),
              ],
            ),
            const SizedBox(height: 16),
            Row(
              children: [
                Expanded(
                  child: TextFormField(
                    initialValue: _startWeek.toString(),
                    decoration: const InputDecoration(
                      labelText: '开始周次',
                      border: OutlineInputBorder(),
                    ),
                    keyboardType: TextInputType.number,
                    onChanged: (value) {
                      _startWeek = int.tryParse(value) ?? 1;
                    },
                  ),
                ),
                const SizedBox(width: 16),
                Expanded(
                  child: TextFormField(
                    initialValue: _endWeek.toString(),
                    decoration: const InputDecoration(
                      labelText: '结束周次',
                      border: OutlineInputBorder(),
                    ),
                    keyboardType: TextInputType.number,
                    onChanged: (value) {
                      _endWeek = int.tryParse(value) ?? 16;
                    },
                  ),
                ),
              ],
            ),
            const SizedBox(height: 16),
            DropdownButtonFormField<WeekType>(
              value: _weekType,
              decoration: const InputDecoration(
                labelText: '周次类型',
                border: OutlineInputBorder(),
                prefixIcon: Icon(Icons.repeat),
              ),
              items: const [
                DropdownMenuItem(value: WeekType.every, child: Text('每周')),
                DropdownMenuItem(value: WeekType.odd, child: Text('单周')),
                DropdownMenuItem(value: WeekType.even, child: Text('双周')),
              ],
              onChanged: (value) {
                setState(() {
                  _weekType = value!;
                });
              },
            ),
            const SizedBox(height: 16),
            const Text('课程颜色:', style: TextStyle(fontSize: 16)),
            const SizedBox(height: 8),
            Wrap(
              spacing: 8,
              runSpacing: 8,
              children: _colors.map((color) {
                return GestureDetector(
                  onTap: () {
                    setState(() {
                      _selectedColor = color;
                    });
                  },
                  child: Container(
                    width: 40,
                    height: 40,
                    decoration: BoxDecoration(
                      color: color,
                      borderRadius: BorderRadius.circular(8),
                      border: _selectedColor == color
                          ? Border.all(color: Colors.black, width: 3)
                          : null,
                    ),
                    child: _selectedColor == color
                        ? const Icon(Icons.check, color: Colors.white)
                        : null,
                  ),
                );
              }).toList(),
            ),
            const SizedBox(height: 24),
            ElevatedButton(
              onPressed: _submit,
              style: ElevatedButton.styleFrom(
                padding: const EdgeInsets.symmetric(vertical: 16),
              ),
              child: const Text('添加课程'),
            ),
          ],
        ),
      ),
    );
  }
}
