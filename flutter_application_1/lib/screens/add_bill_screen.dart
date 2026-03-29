import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
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
  final _noteController = TextEditingController();
  final _customSubCategoryController = TextEditingController();

  DateTime _selectedDate = DateTime.now();
  BillType _selectedType = BillType.deposit;
  Color _selectedColor = Colors.green;
  String _selectedCategory = '工资';
  String _selectedSubCategory = '';

  final List<String> _depositCategories = ['工资', '副业', '其他'];

  final List<String> _withdrawCategories = [
    '生活费',
    '购物',
    '餐饮',
    '交通',
    '娱乐',
    '医疗',
    '教育',
    '其他',
  ];

  final Map<String, List<String>> _subCategories = {
    '工资': ['基本工资', '绩效奖金', '加班费', '补贴', '其他'],
    '副业': ['兼职', '自由职业', '投资收益', '其他'],
    '生活费': ['洗化用品', '生活用品', '水电燃气', '房租', '物业费', '其他'],
    '购物': ['衣服鞋帽', '数码电子', '家居用品', '化妆品', '其他'],
    '餐饮': ['早餐', '午餐', '晚餐', '夜宵', '聚餐', '外卖', '其他'],
    '交通': ['公交地铁', '打车', '加油', '停车费', '维修保养', '其他'],
    '娱乐': ['电影', '游戏', '旅游', '运动健身', 'KTV', '其他'],
    '医疗': ['看病', '药品', '体检', '保健品', '其他'],
    '教育': ['学费', '书本', '培训课程', '考试费用', '其他'],
    '其他': ['其他'],
  };

  List<String> get _currentCategories => _selectedType == BillType.deposit
      ? _depositCategories
      : _withdrawCategories;

  List<String> get _currentSubCategories =>
      _subCategories[_selectedCategory] ?? ['其他'];

  @override
  void initState() {
    super.initState();
    if (widget.initialDate != null) {
      _selectedDate = widget.initialDate!;
    }
    _selectedSubCategory = _currentSubCategories.first;
  }

  @override
  void dispose() {
    _titleController.dispose();
    _amountController.dispose();
    _noteController.dispose();
    _customSubCategoryController.dispose();
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

    final note = _noteController.text.isNotEmpty ? _noteController.text : '';

    final bill = Bill(
      id: DateTime.now().millisecondsSinceEpoch.toString(),
      title: _titleController.text,
      amount: amount,
      date: _selectedDate,
      type: _selectedType,
      category: '$_selectedCategory - $_selectedSubCategory',
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
          onPressed: _save,
          child: const Text('保存'),
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
                        _selectedCategory = _depositCategories.first;
                        _selectedSubCategory = _currentSubCategories.first;
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
                        _selectedCategory = _withdrawCategories.first;
                        _selectedSubCategory = _currentSubCategories.first;
                      });
                    },
                  ),
                ],
              ),
              CupertinoListSection.insetGrouped(
                header: const Text('分类'),
                children: [
                  CupertinoListTile(
                    title: const Text('分类'),
                    additionalInfo: Text(_selectedCategory),
                    trailing: const CupertinoListTileChevron(),
                    onTap: () => _showCategoryPicker(),
                  ),
                  CupertinoListTile(
                    title: const Text('子分类'),
                    additionalInfo: Text(_selectedSubCategory),
                    trailing: const CupertinoListTileChevron(),
                    onTap: () => _showSubCategoryPicker(),
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
                    inputFormatters: [
                      FilteringTextInputFormatter.allow(
                        RegExp(r'^\d+\.?\d{0,2}'),
                      ),
                    ],
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

  void _showCategoryPicker() {
    showCupertinoModalPopup(
      context: context,
      builder: (context) => Container(
        height: 250,
        color: CupertinoColors.systemBackground,
        child: Column(
          children: [
            Container(
              padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  CupertinoButton(
                    padding: EdgeInsets.zero,
                    onPressed: () => Navigator.pop(context),
                    child: const Text('取消'),
                  ),
                  CupertinoButton(
                    padding: EdgeInsets.zero,
                    onPressed: () => Navigator.pop(context),
                    child: const Text('确定'),
                  ),
                ],
              ),
            ),
            Expanded(
              child: CupertinoPicker(
                itemExtent: 40,
                onSelectedItemChanged: (index) {
                  setState(() {
                    _selectedCategory = _currentCategories[index];
                    _selectedSubCategory = _currentSubCategories.first;
                  });
                },
                children: _currentCategories
                    .map((category) => Center(child: Text(category)))
                    .toList(),
              ),
            ),
          ],
        ),
      ),
    );
  }

  void _showSubCategoryPicker() {
    showCupertinoModalPopup(
      context: context,
      builder: (context) => Container(
        height: 350,
        color: CupertinoColors.systemBackground,
        child: Column(
          children: [
            Container(
              padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  CupertinoButton(
                    padding: EdgeInsets.zero,
                    onPressed: () => Navigator.pop(context),
                    child: const Text('取消'),
                  ),
                  CupertinoButton(
                    padding: EdgeInsets.zero,
                    onPressed: () => Navigator.pop(context),
                    child: const Text('确定'),
                  ),
                ],
              ),
            ),
            Expanded(
              child: CupertinoPicker(
                itemExtent: 40,
                onSelectedItemChanged: (index) {
                  setState(() {
                    if (index == _currentSubCategories.length) {
                      _showCustomSubCategoryDialog();
                    } else {
                      _selectedSubCategory = _currentSubCategories[index];
                    }
                  });
                },
                children: [
                  ..._currentSubCategories.map(
                    (subCategory) => Center(child: Text(subCategory)),
                  ),
                  const Center(
                    child: Text(
                      '+ 自定义',
                      style: TextStyle(color: CupertinoColors.activeBlue),
                    ),
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }

  void _showCustomSubCategoryDialog() {
    _customSubCategoryController.clear();
    showCupertinoDialog(
      context: context,
      builder: (context) => CupertinoAlertDialog(
        title: const Text('自定义子分类'),
        content: Padding(
          padding: const EdgeInsets.only(top: 16),
          child: CupertinoTextField(
            controller: _customSubCategoryController,
            placeholder: '请输入子分类名称',
            autofocus: true,
          ),
        ),
        actions: [
          CupertinoDialogAction(
            onPressed: () => Navigator.pop(context),
            child: const Text('取消'),
          ),
          CupertinoDialogAction(
            onPressed: () {
              final newSubCategory = _customSubCategoryController.text.trim();
              if (newSubCategory.isNotEmpty) {
                setState(() {
                  _subCategories[_selectedCategory] ??= [];
                  if (!_subCategories[_selectedCategory]!.contains('其他')) {
                    _subCategories[_selectedCategory]!.add('其他');
                  }
                  final otherIndex = _subCategories[_selectedCategory]!.indexOf(
                    '其他',
                  );
                  _subCategories[_selectedCategory]!.insert(
                    otherIndex,
                    newSubCategory,
                  );
                  _selectedSubCategory = newSubCategory;
                });
              }
              Navigator.pop(context);
            },
            child: const Text('确定'),
          ),
        ],
      ),
    );
  }
}
