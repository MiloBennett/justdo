import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import '../models/bill.dart';

class AddBillScreen extends StatefulWidget {
  final DateTime? initialDate;

  const AddBillScreen({super.key, this.initialDate});

  @override
  State<AddBillScreen> createState() => _AddBillScreenState();
}

class _AddBillScreenState extends State<AddBillScreen> {
  final _titleController = TextEditingController();
  final _amountController = TextEditingController();
  final _categoryController = TextEditingController();
  final _noteController = TextEditingController();

  DateTime _selectedDate = DateTime.now();
  BillType _selectedType = BillType.deposit;
  Color _selectedColor = Colors.green;

  final List<Map<String, dynamic>> _categories = [
    {'name': '工资', 'icon': CupertinoIcons.money_dollar},
    {'name': '奖金', 'icon': CupertinoIcons.gift},
    {'name': '投资收益', 'icon': CupertinoIcons.chart_bar},
    {'name': '兼职', 'icon': CupertinoIcons.briefcase},
    {'name': '生活费', 'icon': CupertinoIcons.cart},
    {'name': '购物', 'icon': CupertinoIcons.bag},
    {'name': '餐饮', 'icon': CupertinoIcons.flame},
    {'name': '交通', 'icon': CupertinoIcons.car},
    {'name': '娱乐', 'icon': CupertinoIcons.music_note},
    {'name': '其他', 'icon': CupertinoIcons.ellipsis},
  ];

  @override
  void initState() {
    super.initState();
    if (widget.initialDate != null) {
      _selectedDate = widget.initialDate!;
    }
  }

  @override
  void dispose() {
    _titleController.dispose();
    _amountController.dispose();
    _categoryController.dispose();
    _noteController.dispose();
    super.dispose();
  }

  void _save() async {
    if (_titleController.text.isEmpty || _amountController.text.isEmpty) {
      return;
    }

    final amount = double.tryParse(_amountController.text);
    if (amount == null) {
      return;
    }

    final category = _categoryController.text.isNotEmpty
        ? _categoryController.text
        : '';

    final note = _noteController.text.isNotEmpty ? _noteController.text : '';

    final bill = Bill(
      id: DateTime.now().millisecondsSinceEpoch.toString(),
      title: _titleController.text,
      amount: amount,
      date: _selectedDate,
      type: _selectedType,
      category: category,
      note: note,
      color: _selectedColor,
    );

    Navigator.pop(context, bill);
  }

  @override
  Widget build(BuildContext context) {
    return CupertinoPageScaffold(
      navigationBar: CupertinoNavigationBar(
        middle: const Text('添加储蓄'),
        leading: CupertinoButton(
          padding: EdgeInsets.zero,
          child: const Text('取消'),
          onPressed: () => Navigator.pop(context),
        ),
        trailing: CupertinoButton(
          padding: EdgeInsets.zero,
          child: const Text('保存'),
          onPressed: _save,
        ),
      ),
      child: SafeArea(
        child: Container(
          color: CupertinoColors.systemGroupedBackground,
          child: ListView(
            children: [
              const SizedBox(height: 20),
              CupertinoListSection.insetGrouped(
                header: const Text('类型'),
                children: [
                  CupertinoListTile(
                    title: const Text('存款'),
                    leading: Icon(
                      CupertinoIcons.arrow_down_circle_fill,
                      color: _selectedType == BillType.deposit
                          ? CupertinoColors.systemGreen
                          : CupertinoColors.systemGrey,
                    ),
                    trailing: _selectedType == BillType.deposit
                        ? const Icon(
                            CupertinoIcons.checkmark,
                            color: CupertinoColors.activeBlue,
                          )
                        : null,
                    onTap: () {
                      setState(() {
                        _selectedType = BillType.deposit;
                        _selectedColor = Colors.green;
                      });
                    },
                  ),
                  CupertinoListTile(
                    title: const Text('取款'),
                    leading: Icon(
                      CupertinoIcons.arrow_up_circle_fill,
                      color: _selectedType == BillType.withdraw
                          ? CupertinoColors.systemOrange
                          : CupertinoColors.systemGrey,
                    ),
                    trailing: _selectedType == BillType.withdraw
                        ? const Icon(
                            CupertinoIcons.checkmark,
                            color: CupertinoColors.activeBlue,
                          )
                        : null,
                    onTap: () {
                      setState(() {
                        _selectedType = BillType.withdraw;
                        _selectedColor = Colors.orange;
                      });
                    },
                  ),
                ],
              ),
              CupertinoListSection.insetGrouped(
                header: const Text('基本信息'),
                children: [
                  CupertinoTextFormFieldRow(
                    controller: _titleController,
                    placeholder: '标题',
                    prefix: const Text('标题'),
                  ),
                  CupertinoTextFormFieldRow(
                    controller: _amountController,
                    placeholder: '金额',
                    prefix: const Text('金额'),
                    keyboardType: const TextInputType.numberWithOptions(
                      decimal: true,
                    ),
                  ),
                  CupertinoTextFormFieldRow(
                    controller: _categoryController,
                    placeholder: '分类',
                    prefix: const Text('分类'),
                  ),
                ],
              ),
              CupertinoListSection.insetGrouped(
                header: const Text('日期'),
                children: [
                  CupertinoListTile(
                    title: const Text('日期'),
                    additionalInfo: Text(
                      '${_selectedDate.year}年${_selectedDate.month}月${_selectedDate.day}日',
                    ),
                    trailing: const CupertinoListTileChevron(),
                    onTap: () => _showDatePicker(),
                  ),
                ],
              ),
              CupertinoListSection.insetGrouped(
                header: const Text('备注'),
                children: [
                  CupertinoTextFormFieldRow(
                    controller: _noteController,
                    placeholder: '添加备注',
                    maxLines: 3,
                  ),
                ],
              ),
            ],
          ),
        ),
      ),
    );
  }

  void _showDatePicker() {
    showCupertinoModalPopup(
      context: context,
      builder: (context) => Container(
        height: 300,
        color: CupertinoColors.systemBackground.resolveFrom(context),
        child: Column(
          children: [
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                CupertinoButton(
                  child: const Text('取消'),
                  onPressed: () => Navigator.pop(context),
                ),
                CupertinoButton(
                  child: const Text('确定'),
                  onPressed: () => Navigator.pop(context),
                ),
              ],
            ),
            Expanded(
              child: CupertinoDatePicker(
                mode: CupertinoDatePickerMode.date,
                initialDateTime: _selectedDate,
                onDateTimeChanged: (date) {
                  setState(() {
                    _selectedDate = date;
                  });
                },
              ),
            ),
          ],
        ),
      ),
    );
  }
}
