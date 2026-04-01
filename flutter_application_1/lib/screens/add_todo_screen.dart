import 'package:flutter/cupertino.dart';
import '../models/todo.dart';

class AddTodoScreen extends StatefulWidget {
  const AddTodoScreen({super.key});

  @override
  State<AddTodoScreen> createState() => _AddTodoScreenState();
}

class _AddTodoScreenState extends State<AddTodoScreen> {
  final _titleController = TextEditingController();
  final _descriptionController = TextEditingController();
  DateTime? _startTime;
  DateTime? _endTime;
  String _selectedCategory = '未定义';
  final List<String> _categories = ['未定义', '学习', '工作', '生活', '游玩', '购物', '运动'];

  @override
  void dispose() {
    _titleController.dispose();
    _descriptionController.dispose();
    super.dispose();
  }

  Future<void> _selectStartTime() async {
    DateTime selectedDateTime = _startTime ?? DateTime.now();
    await showCupertinoModalPopup(
      context: context,
      builder: (BuildContext context) => Container(
        height: 260,
        decoration: const BoxDecoration(
          color: CupertinoColors.systemBackground,
          borderRadius: BorderRadius.vertical(top: Radius.circular(12)),
        ),
        child: Column(
          children: [
            Container(
              padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
              decoration: const BoxDecoration(
                border: Border(
                  bottom: BorderSide(
                    color: CupertinoColors.separator,
                    width: 0.5,
                  ),
                ),
              ),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  CupertinoButton(
                    padding: EdgeInsets.zero,
                    child: const Text('取消'),
                    onPressed: () => Navigator.pop(context),
                  ),
                  CupertinoButton(
                    padding: EdgeInsets.zero,
                    child: const Text('确定'),
                    onPressed: () {
                      setState(() {
                        _startTime = selectedDateTime;
                      });
                      Navigator.pop(context);
                    },
                  ),
                ],
              ),
            ),
            Expanded(
              child: CupertinoDatePicker(
                initialDateTime: _startTime ?? DateTime.now(),
                onDateTimeChanged: (DateTime newDateTime) {
                  selectedDateTime = newDateTime;
                },
                use24hFormat: true,
                minuteInterval: 1,
              ),
            ),
          ],
        ),
      ),
    );
  }

  Future<void> _selectEndTime() async {
    DateTime selectedDateTime = _endTime ?? _startTime ?? DateTime.now();
    await showCupertinoModalPopup(
      context: context,
      builder: (BuildContext context) => Container(
        height: 260,
        decoration: const BoxDecoration(
          color: CupertinoColors.systemBackground,
          borderRadius: BorderRadius.vertical(top: Radius.circular(12)),
        ),
        child: Column(
          children: [
            Container(
              padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
              decoration: const BoxDecoration(
                border: Border(
                  bottom: BorderSide(
                    color: CupertinoColors.separator,
                    width: 0.5,
                  ),
                ),
              ),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  CupertinoButton(
                    padding: EdgeInsets.zero,
                    child: const Text('取消'),
                    onPressed: () => Navigator.pop(context),
                  ),
                  CupertinoButton(
                    padding: EdgeInsets.zero,
                    child: const Text('确定'),
                    onPressed: () {
                      setState(() {
                        _endTime = selectedDateTime;
                      });
                      Navigator.pop(context);
                    },
                  ),
                ],
              ),
            ),
            Expanded(
              child: CupertinoDatePicker(
                initialDateTime: _endTime ?? _startTime ?? DateTime.now(),
                minimumDate: _startTime,
                onDateTimeChanged: (DateTime newDateTime) {
                  selectedDateTime = newDateTime;
                },
                use24hFormat: true,
                minuteInterval: 1,
              ),
            ),
          ],
        ),
      ),
    );
  }

  void _addCustomCategory() {
    final controller = TextEditingController();
    showCupertinoDialog(
      context: context,
      builder: (context) => CupertinoAlertDialog(
        title: const Text('添加分类'),
        content: Padding(
          padding: const EdgeInsets.only(top: 12),
          child: CupertinoTextField(
            controller: controller,
            placeholder: '输入分类名称',
            autofocus: true,
          ),
        ),
        actions: [
          CupertinoDialogAction(
            child: const Text('取消'),
            onPressed: () => Navigator.pop(context),
          ),
          CupertinoDialogAction(
            isDefaultAction: true,
            child: const Text('添加'),
            onPressed: () {
              final name = controller.text.trim();
              if (name.isNotEmpty && !_categories.contains(name)) {
                setState(() {
                  _categories.add(name);
                  _selectedCategory = name;
                });
              }
              Navigator.pop(context);
            },
          ),
        ],
      ),
    );
  }

  void _submit() {
    final inputTitle = _titleController.text.trim();
    final todo = Todo(
      id: DateTime.now().millisecondsSinceEpoch.toString(),
      title: inputTitle.isEmpty ? _selectedCategory : inputTitle,
      description: _descriptionController.text.trim(),
      startTime: _startTime,
      endTime: _endTime,
      category: inputTitle.isEmpty ? null : _selectedCategory,
    );
    Navigator.pop(context, todo);
  }

  @override
  Widget build(BuildContext context) {
    return CupertinoPageScaffold(
      navigationBar: const CupertinoNavigationBar(middle: Text('添加待办')),
      child: SafeArea(
        child: ListView(
          padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
          children: [
            // 分类选择（可滑动）
            SizedBox(
              height: 40,
              child: ListView.separated(
                scrollDirection: Axis.horizontal,
                itemCount: _categories.length + 1,
                separatorBuilder: (context, index) => const SizedBox(width: 8),
                itemBuilder: (context, index) {
                  if (index == _categories.length) {
                    // 添加自定义分类按钮
                    return GestureDetector(
                      onTap: _addCustomCategory,
                      child: Container(
                        padding: const EdgeInsets.symmetric(horizontal: 12),
                        decoration: BoxDecoration(
                          border: Border.all(
                            color: CupertinoColors.systemGrey4,
                          ),
                          borderRadius: BorderRadius.circular(20),
                        ),
                        alignment: Alignment.center,
                        child: const Icon(
                          CupertinoIcons.add,
                          size: 18,
                          color: CupertinoColors.systemGrey,
                        ),
                      ),
                    );
                  }
                  final category = _categories[index];
                  final isSelected = _selectedCategory == category;
                  return GestureDetector(
                    onTap: () {
                      setState(() {
                        _selectedCategory = category;
                      });
                    },
                    child: Container(
                      padding: const EdgeInsets.symmetric(horizontal: 16),
                      decoration: BoxDecoration(
                        color: isSelected
                            ? CupertinoColors.activeBlue
                            : CupertinoColors.systemGrey6,
                        borderRadius: BorderRadius.circular(20),
                      ),
                      alignment: Alignment.center,
                      child: Text(
                        category,
                        style: TextStyle(
                          fontSize: 14,
                          fontWeight: isSelected
                              ? FontWeight.w600
                              : FontWeight.normal,
                          color: isSelected
                              ? CupertinoColors.white
                              : CupertinoColors.label,
                          decoration: TextDecoration.none,
                        ),
                      ),
                    ),
                  );
                },
              ),
            ),
            const SizedBox(height: 16),
            // 标题（可选）
            CupertinoTextField(
              controller: _titleController,
              placeholder: '标题（可选）',
              prefix: const Padding(
                padding: EdgeInsets.only(left: 8),
                child: Icon(CupertinoIcons.textformat, size: 20),
              ),
              padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 10),
            ),
            const SizedBox(height: 12),
            // 描述（可选）
            CupertinoTextField(
              controller: _descriptionController,
              placeholder: '描述（可选）',
              prefix: const Padding(
                padding: EdgeInsets.only(left: 8),
                child: Icon(CupertinoIcons.text_alignleft, size: 20),
              ),
              padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 10),
              maxLines: 3,
            ),
            const SizedBox(height: 12),
            // 时间选择
            Row(
              children: [
                Expanded(
                  child: GestureDetector(
                    onTap: _selectStartTime,
                    child: Container(
                      padding: const EdgeInsets.symmetric(
                        horizontal: 12,
                        vertical: 10,
                      ),
                      decoration: BoxDecoration(
                        border: Border.all(color: CupertinoColors.systemGrey4),
                        borderRadius: BorderRadius.circular(8),
                      ),
                      child: Row(
                        children: [
                          const Icon(CupertinoIcons.clock, size: 18),
                          const SizedBox(width: 6),
                          Expanded(
                            child: Text(
                              _startTime != null
                                  ? '${_startTime!.month}月${_startTime!.day}日 ${_startTime!.hour.toString().padLeft(2, '0')}:${_startTime!.minute.toString().padLeft(2, '0')}'
                                  : '开始时间',
                              style: TextStyle(
                                fontSize: 14,
                                color: _startTime != null
                                    ? CupertinoColors.label
                                    : CupertinoColors.placeholderText,
                              ),
                            ),
                          ),
                        ],
                      ),
                    ),
                  ),
                ),
                const SizedBox(width: 12),
                Expanded(
                  child: GestureDetector(
                    onTap: _selectEndTime,
                    child: Container(
                      padding: const EdgeInsets.symmetric(
                        horizontal: 12,
                        vertical: 10,
                      ),
                      decoration: BoxDecoration(
                        border: Border.all(color: CupertinoColors.systemGrey4),
                        borderRadius: BorderRadius.circular(8),
                      ),
                      child: Row(
                        children: [
                          const Icon(CupertinoIcons.clock_fill, size: 18),
                          const SizedBox(width: 6),
                          Expanded(
                            child: Text(
                              _endTime != null
                                  ? '${_endTime!.month}月${_endTime!.day}日 ${_endTime!.hour.toString().padLeft(2, '0')}:${_endTime!.minute.toString().padLeft(2, '0')}'
                                  : '结束时间',
                              style: TextStyle(
                                fontSize: 14,
                                color: _endTime != null
                                    ? CupertinoColors.label
                                    : CupertinoColors.placeholderText,
                              ),
                            ),
                          ),
                        ],
                      ),
                    ),
                  ),
                ),
              ],
            ),
            const SizedBox(height: 20),
            CupertinoButton.filled(onPressed: _submit, child: const Text('添加')),
          ],
        ),
      ),
    );
  }
}
