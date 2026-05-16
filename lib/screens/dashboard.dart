import 'package:flutter/material.dart';
import '../models/entry.dart';
import '../widgets/add_entry_modal.dart';

class DashboardScreen extends StatelessWidget {
  final List<Entry> entries;
  final List<String> categories;
  final void Function(Entry) onAddEntry;
  final void Function(String) onAddCategory;
  final void Function(String) onDeleteCategory;

  const DashboardScreen({
    super.key,
    required this.entries,
    required this.categories,
    required this.onAddEntry,
    required this.onAddCategory,
    required this.onDeleteCategory,
  });

  double _total(bool isExpense, DateTime from) {
    return entries
        .where((e) => e.isExpense == isExpense && !e.date.isBefore(from))
        .fold(0.0, (sum, e) => sum + e.amount);
  }

  @override
  Widget build(BuildContext context) {
    final now = DateTime.now();
    final weekStart = DateTime(now.year, now.month, now.day)
        .subtract(Duration(days: now.weekday - 1));
    final monthStart = DateTime(now.year, now.month, 1);

    return Scaffold(
      appBar: AppBar(title: const Text('Dashboard')),
      body: ListView(
        padding: const EdgeInsets.all(16),
        children: [
          _AddButtons(
            categories: categories,
            onAddEntry: onAddEntry,
            onAddCategory: onAddCategory,
          ),
          const SizedBox(height: 12),
          _SummaryCard(
            title: 'This Week',
            income: _total(false, weekStart),
            expenses: _total(true, weekStart),
          ),
          const SizedBox(height: 12),
          _SummaryCard(
            title: 'This Month',
            income: _total(false, monthStart),
            expenses: _total(true, monthStart),
          ),
          const SizedBox(height: 12),
          _CategoriesCard(
            categories: categories,
            onAdd: onAddCategory,
            onDelete: onDeleteCategory,
          ),
        ],
      ),
    );
  }
}

class _AddButtons extends StatelessWidget {
  final List<String> categories;
  final void Function(Entry) onAddEntry;
  final void Function(String) onAddCategory;

  const _AddButtons({
    required this.categories,
    required this.onAddEntry,
    required this.onAddCategory,
  });

  void _open(BuildContext context, bool isExpense) {
    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      builder: (_) => AddEntryModal(
        categories: categories,
        onSave: onAddEntry,
        onAddCategory: onAddCategory,
        initialIsExpense: isExpense,
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Row(
      children: [
        Expanded(
          child: FilledButton.icon(
            onPressed: () => _open(context, true),
            icon: const Icon(Icons.arrow_upward),
            label: const Text('Add Expense'),
            style: FilledButton.styleFrom(
              backgroundColor: Colors.red.shade400,
              padding: const EdgeInsets.symmetric(vertical: 14),
            ),
          ),
        ),
        const SizedBox(width: 12),
        Expanded(
          child: FilledButton.icon(
            onPressed: () => _open(context, false),
            icon: const Icon(Icons.arrow_downward),
            label: const Text('Add Income'),
            style: FilledButton.styleFrom(
              backgroundColor: Colors.green,
              padding: const EdgeInsets.symmetric(vertical: 14),
            ),
          ),
        ),
      ],
    );
  }
}

class _SummaryCard extends StatelessWidget {
  final String title;
  final double income;
  final double expenses;

  const _SummaryCard({
    required this.title,
    required this.income,
    required this.expenses,
  });

  @override
  Widget build(BuildContext context) {
    final net = income - expenses;
    return Card(
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(title, style: Theme.of(context).textTheme.titleMedium),
            const SizedBox(height: 12),
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                _Stat(label: 'Expenses', amount: expenses, color: Colors.red.shade400),
                _Stat(label: 'Income', amount: income, color: Colors.green),
                _Stat(
                  label: 'Net',
                  amount: net,
                  color: net >= 0 ? Colors.green : Colors.red.shade400,
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }
}

class _Stat extends StatelessWidget {
  final String label;
  final double amount;
  final Color color;

  const _Stat({required this.label, required this.amount, required this.color});

  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        Text(label, style: Theme.of(context).textTheme.bodySmall),
        const SizedBox(height: 4),
        Text(
          '\$${amount.toStringAsFixed(2)}',
          style: TextStyle(
            color: color,
            fontWeight: FontWeight.bold,
            fontSize: 16,
          ),
        ),
      ],
    );
  }
}

class _CategoriesCard extends StatefulWidget {
  final List<String> categories;
  final void Function(String) onAdd;
  final void Function(String) onDelete;

  const _CategoriesCard({
    required this.categories,
    required this.onAdd,
    required this.onDelete,
  });

  @override
  State<_CategoriesCard> createState() => _CategoriesCardState();
}

class _CategoriesCardState extends State<_CategoriesCard> {
  final _controller = TextEditingController();
  bool _showAddField = false;

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  void _confirmAdd() {
    final name = _controller.text.trim();
    if (name.isEmpty) return;
    widget.onAdd(name);
    setState(() {
      _showAddField = false;
      _controller.clear();
    });
  }

  @override
  Widget build(BuildContext context) {
    return Card(
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Text(
                  'Manage Categories',
                  style: Theme.of(context).textTheme.titleMedium,
                ),
                IconButton(
                  icon: const Icon(Icons.add),
                  tooltip: 'Add category',
                  onPressed: () => setState(() => _showAddField = !_showAddField),
                ),
              ],
            ),
            if (widget.categories.isEmpty)
              const Padding(
                padding: EdgeInsets.symmetric(vertical: 8),
                child: Text('No categories yet'),
              )
            else
              ...widget.categories.map(
                (c) => Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Text(c),
                    IconButton(
                      icon: const Icon(Icons.delete_outline),
                      tooltip: 'Delete',
                      onPressed: () => widget.onDelete(c),
                    ),
                  ],
                ),
              ),
            if (_showAddField) ...[
              const SizedBox(height: 8),
              Row(
                children: [
                  Expanded(
                    child: TextField(
                      controller: _controller,
                      autofocus: true,
                      decoration: const InputDecoration(
                        hintText: 'New category name',
                        border: OutlineInputBorder(),
                        isDense: true,
                        contentPadding: EdgeInsets.symmetric(
                          horizontal: 12,
                          vertical: 10,
                        ),
                      ),
                      textCapitalization: TextCapitalization.words,
                      onSubmitted: (_) => _confirmAdd(),
                    ),
                  ),
                  const SizedBox(width: 8),
                  IconButton.filled(
                    onPressed: _confirmAdd,
                    icon: const Icon(Icons.check),
                  ),
                ],
              ),
            ],
          ],
        ),
      ),
    );
  }
}
