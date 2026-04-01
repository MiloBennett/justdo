import 'package:flutter/cupertino.dart';
import '../models/todo.dart';

class PromiseDialog extends StatefulWidget {
  final Todo currentTodo;
  final List<Todo> availableTodos;
  final Function(String title, Todo? selectedTodo) onConfirm;

  const PromiseDialog({
    super.key,
    required this.currentTodo,
    required this.availableTodos,
    required this.onConfirm,
  });

  @override
  State<PromiseDialog> createState() => _PromiseDialogState();
}

class _PromiseDialogState extends State<PromiseDialog> {
  Todo? selectedTodo;
  final TextEditingController _controller = TextEditingController();
  bool _isCustomInput = false;
  String _inputText = '';

  @override
  void initState() {
    super.initState();
    _controller.addListener(_onTextChanged);
  }

  void _onTextChanged() {
    setState(() {
      _inputText = _controller.text;
    });
  }

  @override
  void dispose() {
    _controller.removeListener(_onTextChanged);
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return CupertinoAlertDialog(
      title: const Column(
        children: [
          Icon(
            CupertinoIcons.sparkles,
            color: CupertinoColors.systemOrange,
            size: 32,
          ),
          SizedBox(height: 8),
          Text('那你想做什么？'),
        ],
      ),
      content: Padding(
        padding: const EdgeInsets.only(top: 16),
        child: SingleChildScrollView(
          child: Column(
            children: [
              Text(
                '允许你做想做的事，但必须承诺：\n"做完这个，必须回头啃那个"',
                style: TextStyle(
                  fontSize: 14,
                  color: CupertinoColors.systemGrey,
                ),
                textAlign: TextAlign.center,
              ),
              const SizedBox(height: 16),
              GestureDetector(
                onTap: () {
                  setState(() {
                    _isCustomInput = !_isCustomInput;
                    if (!_isCustomInput) {
                      _controller.clear();
                    }
                  });
                },
                child: Container(
                  padding: const EdgeInsets.symmetric(
                    horizontal: 12,
                    vertical: 8,
                  ),
                  decoration: BoxDecoration(
                    color: _isCustomInput
                        ? CupertinoColors.systemOrange.withOpacity(0.2)
                        : CupertinoColors.systemGrey6,
                    borderRadius: BorderRadius.circular(8),
                    border: Border.all(
                      color: _isCustomInput
                          ? CupertinoColors.systemOrange
                          : CupertinoColors.systemGrey4,
                      width: _isCustomInput ? 2 : 1,
                    ),
                  ),
                  child: Row(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      Icon(
                        _isCustomInput
                            ? CupertinoIcons.checkmark_circle_fill
                            : CupertinoIcons.pencil,
                        color: _isCustomInput
                            ? CupertinoColors.systemOrange
                            : CupertinoColors.systemGrey,
                        size: 18,
                      ),
                      const SizedBox(width: 8),
                      Text(
                        _isCustomInput ? '取消输入' : '输入想做的事',
                        style: TextStyle(
                          fontWeight: FontWeight.w600,
                          color: _isCustomInput
                              ? CupertinoColors.systemOrange
                              : CupertinoColors.label,
                        ),
                      ),
                    ],
                  ),
                ),
              ),
              if (_isCustomInput) ...[
                const SizedBox(height: 12),
                CupertinoTextField(
                  controller: _controller,
                  placeholder: '输入你想做的事情...',
                  padding: const EdgeInsets.all(12),
                  decoration: BoxDecoration(
                    color: CupertinoColors.systemGrey6,
                    borderRadius: BorderRadius.circular(8),
                  ),
                  maxLines: 2,
                ),
              ],
              if (widget.availableTodos.isNotEmpty && !_isCustomInput) ...[
                const SizedBox(height: 12),
                const Text(
                  '或选择现有任务',
                  style: TextStyle(
                    fontSize: 12,
                    color: CupertinoColors.systemGrey,
                  ),
                ),
                const SizedBox(height: 8),
                SizedBox(
                  height: 150,
                  child: CupertinoScrollbar(
                    child: ListView.builder(
                      shrinkWrap: true,
                      itemCount: widget.availableTodos.length,
                      itemBuilder: (context, index) {
                        final todo = widget.availableTodos[index];
                        final isSelected = selectedTodo?.id == todo.id;
                        return GestureDetector(
                          onTap: () {
                            setState(() {
                              selectedTodo = isSelected ? null : todo;
                            });
                          },
                          child: Container(
                            margin: const EdgeInsets.only(bottom: 6),
                            padding: const EdgeInsets.all(10),
                            decoration: BoxDecoration(
                              color: isSelected
                                  ? CupertinoColors.systemOrange.withOpacity(
                                      0.2,
                                    )
                                  : CupertinoColors.systemGrey6,
                              borderRadius: BorderRadius.circular(8),
                              border: isSelected
                                  ? Border.all(
                                      color: CupertinoColors.systemOrange,
                                      width: 2,
                                    )
                                  : null,
                            ),
                            child: Row(
                              children: [
                                Icon(
                                  isSelected
                                      ? CupertinoIcons.checkmark_circle_fill
                                      : CupertinoIcons.circle,
                                  color: isSelected
                                      ? CupertinoColors.systemOrange
                                      : CupertinoColors.systemGrey3,
                                  size: 16,
                                ),
                                const SizedBox(width: 8),
                                Expanded(
                                  child: Text(
                                    todo.title,
                                    style: const TextStyle(
                                      fontWeight: FontWeight.w500,
                                      fontSize: 13,
                                    ),
                                    maxLines: 1,
                                    overflow: TextOverflow.ellipsis,
                                  ),
                                ),
                              ],
                            ),
                          ),
                        );
                      },
                    ),
                  ),
                ),
              ],
            ],
          ),
        ),
      ),
      actions: [
        CupertinoDialogAction(
          child: const Text('取消'),
          onPressed: () => Navigator.pop(context),
        ),
        CupertinoDialogAction(
          isDefaultAction: true,
          onPressed:
              (_isCustomInput && _inputText.isNotEmpty) ||
                  (selectedTodo != null)
              ? () {
                  final String promiseTitle;
                  if (_isCustomInput && _inputText.isNotEmpty) {
                    promiseTitle = _inputText;
                  } else {
                    promiseTitle = selectedTodo!.title;
                  }
                  Navigator.pop(context);
                  showPromiseConfirmDialog(
                    context: context,
                    promiseTitle: promiseTitle,
                    currentTodoTitle: widget.currentTodo.title,
                    onConfirm: () {
                      if (_isCustomInput && _inputText.isNotEmpty) {
                        widget.onConfirm(_inputText, null);
                      } else if (selectedTodo != null) {
                        widget.onConfirm(selectedTodo!.title, selectedTodo);
                      }
                    },
                  );
                }
              : null,
          child: Text(
            (_isCustomInput && _inputText.isNotEmpty) || (selectedTodo != null)
                ? '下一步'
                : '选择一个或输入',
            style: TextStyle(
              color:
                  (_isCustomInput && _inputText.isNotEmpty) ||
                      (selectedTodo != null)
                  ? CupertinoColors.activeBlue
                  : CupertinoColors.systemGrey,
            ),
          ),
        ),
      ],
    );
  }
}

void showPromiseDialog({
  required BuildContext context,
  required Todo currentTodo,
  required List<Todo> availableTodos,
  required Function(String title, Todo? selectedTodo) onConfirm,
}) {
  showCupertinoDialog(
    context: context,
    builder: (context) => PromiseDialog(
      currentTodo: currentTodo,
      availableTodos: availableTodos,
      onConfirm: onConfirm,
    ),
  );
}

void showPromiseConfirmDialog({
  required BuildContext context,
  required String promiseTitle,
  required String currentTodoTitle,
  required VoidCallback onConfirm,
}) {
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
          '做完 "$promiseTitle"，必须回头啃 "$currentTodoTitle"',
          style: const TextStyle(fontSize: 15),
          textAlign: TextAlign.center,
        ),
      ),
      actions: [
        CupertinoDialogAction(
          child: const Text('取消'),
          onPressed: () => Navigator.pop(context),
        ),
        CupertinoDialogAction(
          isDefaultAction: true,
          onPressed: () {
            Navigator.pop(context);
            onConfirm();
          },
          child: const Text(
            '承诺！',
            style: TextStyle(color: CupertinoColors.activeBlue),
          ),
        ),
      ],
    ),
  );
}
