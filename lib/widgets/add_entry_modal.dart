import 'package:flutter/material.dart';
import '../models/entry.dart';

class AddEntryModal extends StatefulWidget {
  final List<String> categories;
  final void Function(Entry) onSave;
  final void Function(String) onAddCategory;
  final bool initialIsExpense;

  const AddEntryModal({
    super.key,
    required this.categories,
    required this.onSave,
    required this.onAddCategory,
    this.initialIsExpense = true,
  });

  @override
  State<AddEntryModal> createState() => _AddEntryModalState();
}

class _AddEntryModalState extends State<AddEntryModal> {
  final _titleController = TextEditingController();
  final _amountController = TextEditingController();
  final _customCategoryController = TextEditingController();

  late List<String> _categories;
  String? _selectedCategory;
  DateTime _date = DateTime.now();
  late bool _isExpense;
  bool _showCustomField = false;

  @override
  void initState() {
    super.initState();
    _categories = List.of(widget.categories);
    _isExpense = widget.initialIsExpense;
  }

  @override
  void dispose() {
    _titleController.dispose();
    _amountController.dispose();
    _customCategoryController.dispose();
    super.dispose();
  }

  Future<void> _pickDate() async {
    final picked = await showDatePicker(
      context: context,
      initialDate: _date,
      firstDate: DateTime(2020),
      lastDate: DateTime.now(),
    );
    if (picked != null) setState(() => _date = picked);
  }

  void _confirmCustomCategory() {
    final name = _customCategoryController.text.trim();
    if (name.isEmpty) return;
    widget.onAddCategory(name);
    setState(() {
      if (!_categories.contains(name)) _categories.add(name);
      _selectedCategory = name;
      _showCustomField = false;
      _customCategoryController.clear();
    });
  }

  void _save() {
    final title = _titleController.text.trim();
    final amount = double.tryParse(_amountController.text.trim());
    if (title.isEmpty || amount == null || amount <= 0 || _selectedCategory == null) {
      return;
    }
    widget.onSave(Entry(
      id: DateTime.now().millisecondsSinceEpoch.toString(),
      title: title,
      amount: amount,
      category: _selectedCategory!,
      isExpense: _isExpense,
      date: _date,
    ));
    Navigator.pop(context);
  }

  String _formatDate(DateTime d) {
    const months = [
      'Jan', 'Feb', 'Mar', 'Apr', 'May', 'Jun',
      'Jul', 'Aug', 'Sep', 'Oct', 'Nov', 'Dec',
    ];
    return '${months[d.month - 1]} ${d.day}, ${d.year}';
  }

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: EdgeInsets.only(
        left: 16,
        right: 16,
        top: 24,
        bottom: MediaQuery.of(context).viewInsets.bottom + 24,
      ),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          Text(
            _isExpense ? 'Add Expense' : 'Add Income',
            style: Theme.of(context).textTheme.titleLarge,
          ),
          const SizedBox(height: 10),
          Divider(
            thickness: 4,
            height: 4,
            color: _isExpense ? Colors.red.shade400 : Colors.green,
          ),
          const SizedBox(height: 16),

          TextField(
            controller: _titleController,
            decoration: const InputDecoration(
              labelText: 'Title',
              hintText: 'e.g. Lunch with friends',
              border: OutlineInputBorder(),
            ),
            textCapitalization: TextCapitalization.sentences,
          ),
          const SizedBox(height: 12),

          DropdownButtonFormField<String>(
            initialValue: _selectedCategory,
            decoration: const InputDecoration(
              labelText: 'Category',
              border: OutlineInputBorder(),
            ),
            items: [
              ..._categories.map(
                (c) => DropdownMenuItem(value: c, child: Text(c)),
              ),
              const DropdownMenuItem(
                value: '__custom__',
                child: Text('+ Add custom category'),
              ),
            ],
            onChanged: (value) {
              if (value == '__custom__') {
                setState(() {
                  _showCustomField = true;
                  _selectedCategory = null;
                });
              } else {
                setState(() {
                  _selectedCategory = value;
                  _showCustomField = false;
                });
              }
            },
          ),

          if (_showCustomField) ...[
            const SizedBox(height: 8),
            Row(
              children: [
                Expanded(
                  child: TextField(
                    controller: _customCategoryController,
                    decoration: const InputDecoration(
                      labelText: 'Category name',
                      border: OutlineInputBorder(),
                    ),
                    textCapitalization: TextCapitalization.words,
                    onSubmitted: (_) => _confirmCustomCategory(),
                  ),
                ),
                const SizedBox(width: 8),
                IconButton.filled(
                  onPressed: _confirmCustomCategory,
                  icon: const Icon(Icons.check),
                ),
              ],
            ),
          ],
          const SizedBox(height: 12),

          OutlinedButton.icon(
            onPressed: _pickDate,
            icon: const Icon(Icons.calendar_today),
            label: Text(_formatDate(_date)),
            style: OutlinedButton.styleFrom(
              alignment: Alignment.centerLeft,
              padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 16),
            ),
          ),
          const SizedBox(height: 12),

          TextField(
            controller: _amountController,
            decoration: const InputDecoration(
              labelText: 'Amount',
              prefixText: '\$ ',
              border: OutlineInputBorder(),
            ),
            keyboardType: const TextInputType.numberWithOptions(decimal: true),
          ),
          const SizedBox(height: 20),

          FilledButton(
            onPressed: _save,
            child: const Text('Save'),
          ),
        ],
      ),
    );
  }
}
