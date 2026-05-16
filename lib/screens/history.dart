import 'package:flutter/material.dart';
import '../models/entry.dart';

class HistoryScreen extends StatefulWidget {
  final List<Entry> entries;
  final List<String> categories;
  final void Function(String) onDeleteEntry;

  const HistoryScreen({
    super.key,
    required this.entries,
    required this.categories,
    required this.onDeleteEntry,
  });

  @override
  State<HistoryScreen> createState() => _HistoryScreenState();
}

class _HistoryScreenState extends State<HistoryScreen> {
  final Set<String> _selectedCategories = {};

  @override
  void didUpdateWidget(HistoryScreen oldWidget) {
    super.didUpdateWidget(oldWidget);
    // If a category was deleted from Dashboard, drop it from the active filter
    // so the user isn't stuck with an uncheckable filter entry.
    if (oldWidget.categories != widget.categories) {
      _selectedCategories.retainAll(widget.categories);
    }
  }

  List<Entry> get _filteredEntries {
    if (_selectedCategories.isEmpty) return widget.entries;
    return widget.entries
        .where((e) => _selectedCategories.contains(e.category))
        .toList();
  }

  List<_MonthSummary> _buildSummaries(List<Entry> entries) {
    final Map<String, _MonthSummary> map = {};

    for (final entry in entries) {
      final key =
          '${entry.date.year}-${entry.date.month.toString().padLeft(2, '0')}';
      map.putIfAbsent(
        key,
        () => _MonthSummary(year: entry.date.year, month: entry.date.month),
      );
      map[key]!.entries.add(entry);
      if (entry.isExpense) {
        map[key]!.totalExpense += entry.amount;
      } else {
        map[key]!.totalIncome += entry.amount;
      }
    }

    final summaries = map.values.toList()
      ..sort((a, b) {
        final cmp = b.year.compareTo(a.year);
        return cmp != 0 ? cmp : b.month.compareTo(a.month);
      });

    for (final s in summaries) {
      s.entries.sort((a, b) => b.date.compareTo(a.date));
    }

    return summaries;
  }

  Future<void> _openFilterDialog() async {
    // local copy for the dialog so changes only apply on confirm
    final draft = Set<String>.from(_selectedCategories);

    final confirmed = await showDialog<bool>(
      context: context,
      builder: (ctx) => StatefulBuilder(
        builder: (ctx, setDialogState) {
          return AlertDialog(
            title: const Text('Filter by category'),
            content: SingleChildScrollView(
              child: Column(
                mainAxisSize: MainAxisSize.min,
                children: widget.categories.map((cat) {
                  return CheckboxListTile(
                    title: Text(cat),
                    value: draft.contains(cat),
                    onChanged: (checked) {
                      setDialogState(() {
                        if (checked == true) {
                          draft.add(cat);
                        } else {
                          draft.remove(cat);
                        }
                      });
                    },
                    controlAffinity: ListTileControlAffinity.leading,
                    dense: true,
                  );
                }).toList(),
              ),
            ),
            actions: [
              TextButton(
                onPressed: () => Navigator.pop(ctx, false),
                child: const Text('Cancel'),
              ),
              TextButton(
                onPressed: () => Navigator.pop(ctx, true),
                child: const Text('Apply'),
              ),
            ],
          );
        },
      ),
    );

    if (confirmed == true) {
      setState(() {
        _selectedCategories
          ..clear()
          ..addAll(draft);
      });
    }
  }

  String get _filterLabel {
    if (_selectedCategories.isEmpty) return 'All categories';
    if (_selectedCategories.length == 1) return _selectedCategories.first;
    return '${_selectedCategories.length} categories';
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final summaries = _buildSummaries(_filteredEntries);
    final isFiltered = _selectedCategories.isNotEmpty;

    return Scaffold(
      appBar: AppBar(title: const Text('History')),
      body: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          Padding(
            padding: const EdgeInsets.fromLTRB(16, 10, 16, 4),
            child: OutlinedButton.icon(
              onPressed: widget.categories.isEmpty ? null : _openFilterDialog,
              icon: Icon(
                Icons.filter_list,
                size: 18,
                color: isFiltered
                    ? theme.colorScheme.primary
                    : theme.colorScheme.onSurface.withValues(alpha: 0.6),
              ),
              label: Text(
                _filterLabel,
                style: TextStyle(
                  color: isFiltered
                      ? theme.colorScheme.primary
                      : theme.colorScheme.onSurface.withValues(alpha: 0.75),
                ),
              ),
              style: OutlinedButton.styleFrom(
                alignment: Alignment.centerLeft,
                side: BorderSide(
                  color: isFiltered
                      ? theme.colorScheme.primary
                      : theme.colorScheme.outline,
                ),
              ),
            ),
          ),
          const Divider(height: 16),
          Expanded(
            child: summaries.isEmpty
                ? Center(
                    child: Text(
                      isFiltered
                          ? 'No entries for the selected categories.'
                          : 'No entries yet.',
                    ),
                  )
                : ListView.separated(
                    padding: const EdgeInsets.only(bottom: 8),
                    itemCount: summaries.length,
                    separatorBuilder: (_, _) => const Divider(height: 1),
                    itemBuilder: (context, index) => _MonthCard(
                      key: ValueKey(
                        '${summaries[index].year}-${summaries[index].month}',
                      ),
                      summary: summaries[index],
                      onDeleteEntry: widget.onDeleteEntry,
                    ),
                  ),
          ),
        ],
      ),
    );
  }
}

class _MonthSummary {
  final int year;
  final int month;
  double totalExpense = 0;
  double totalIncome = 0;
  final List<Entry> entries = [];

  _MonthSummary({required this.year, required this.month});

  double get net => totalIncome - totalExpense;

  String get label {
    const months = [
      'January', 'February', 'March', 'April', 'May', 'June',
      'July', 'August', 'September', 'October', 'November', 'December',
    ];
    return '${months[month - 1]} $year';
  }
}

class _MonthCard extends StatefulWidget {
  final _MonthSummary summary;
  final void Function(String) onDeleteEntry;

  const _MonthCard({super.key, required this.summary, required this.onDeleteEntry});

  @override
  State<_MonthCard> createState() => _MonthCardState();
}

class _MonthCardState extends State<_MonthCard> {
  bool _expanded = false;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final net = widget.summary.net;
    final netColor = net >= 0 ? Colors.green : Colors.red.shade400;
    final netLabel = net >= 0
        ? '+\$${net.toStringAsFixed(2)}'
        : '-\$${net.abs().toStringAsFixed(2)}';

    return Column(
      children: [
        InkWell(
          onTap: () => setState(() => _expanded = !_expanded),
          child: Padding(
            padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 14),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Row(
                  children: [
                    Text(
                      widget.summary.label,
                      style: theme.textTheme.titleMedium?.copyWith(
                        fontWeight: FontWeight.w600,
                      ),
                    ),
                    const Spacer(),
                    Icon(
                      _expanded
                          ? Icons.keyboard_arrow_up
                          : Icons.keyboard_arrow_down,
                      color: theme.colorScheme.onSurface.withValues(alpha: 0.5),
                    ),
                  ],
                ),
                const SizedBox(height: 8),
                Row(
                  children: [
                    _Stat(
                      label: 'Spent',
                      value:
                          '\$${widget.summary.totalExpense.toStringAsFixed(2)}',
                      valueColor: Colors.red.shade400,
                    ),
                    const SizedBox(width: 24),
                    _Stat(
                      label: 'Earned',
                      value:
                          '\$${widget.summary.totalIncome.toStringAsFixed(2)}',
                      valueColor: Colors.green,
                    ),
                    const Spacer(),
                    _Stat(
                      label: 'Net',
                      value: netLabel,
                      valueColor: netColor,
                      alignRight: true,
                    ),
                  ],
                ),
              ],
            ),
          ),
        ),
        if (_expanded) ...[
          const Divider(height: 1, indent: 16, endIndent: 16),
          ...widget.summary.entries.map(
            (e) => _EntryRow(entry: e, onDelete: widget.onDeleteEntry),
          ),
        ],
      ],
    );
  }
}

class _EntryRow extends StatelessWidget {
  final Entry entry;
  final void Function(String) onDelete;

  const _EntryRow({required this.entry, required this.onDelete});

  String _formatDate(DateTime d) {
    final day = d.day.toString().padLeft(2, '0');
    const months = [
      'Jan', 'Feb', 'Mar', 'Apr', 'May', 'Jun',
      'Jul', 'Aug', 'Sep', 'Oct', 'Nov', 'Dec',
    ];
    return '${months[d.month - 1]} $day';
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final amountColor = entry.isExpense ? Colors.red.shade400 : Colors.green;
    final amountLabel = entry.isExpense
        ? '-\$${entry.amount.toStringAsFixed(2)}'
        : '+\$${entry.amount.toStringAsFixed(2)}';

    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 10),
      child: Row(
        children: [
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  entry.title,
                  style: theme.textTheme.bodyMedium?.copyWith(
                    fontWeight: FontWeight.w500,
                  ),
                ),
                const SizedBox(height: 2),
                Text(
                  '${entry.category} · ${_formatDate(entry.date)}',
                  style: theme.textTheme.bodySmall?.copyWith(
                    color: theme.colorScheme.onSurface.withValues(alpha: 0.55),
                  ),
                ),
              ],
            ),
          ),
          Text(
            amountLabel,
            style: theme.textTheme.bodyMedium?.copyWith(
              color: amountColor,
              fontWeight: FontWeight.w600,
            ),
          ),
          const SizedBox(width: 4),
          IconButton(
            icon: const Icon(Icons.delete_outline),
            tooltip: 'Delete',
            onPressed: () async {
              final confirmed = await showDialog<bool>(
                context: context,
                builder: (ctx) => AlertDialog(
                  title: const Text('Delete entry?'),
                  content: Text(
                    'Remove "${entry.title}" from your history. This cannot be undone.',
                  ),
                  actions: [
                    TextButton(
                      onPressed: () => Navigator.pop(ctx, false),
                      child: const Text('Cancel'),
                    ),
                    TextButton(
                      onPressed: () => Navigator.pop(ctx, true),
                      child: Text(
                        'Delete',
                        style: TextStyle(color: Colors.red.shade400),
                      ),
                    ),
                  ],
                ),
              );
              if (confirmed == true) onDelete(entry.id);
            },
            color: theme.colorScheme.onSurface.withValues(alpha: 0.4),
            iconSize: 20,
            visualDensity: VisualDensity.compact,
          ),
        ],
      ),
    );
  }
}

class _Stat extends StatelessWidget {
  final String label;
  final String value;
  final Color valueColor;
  final bool alignRight;

  const _Stat({
    required this.label,
    required this.value,
    required this.valueColor,
    this.alignRight = false,
  });

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    return Column(
      crossAxisAlignment:
          alignRight ? CrossAxisAlignment.end : CrossAxisAlignment.start,
      children: [
        Text(
          label,
          style: theme.textTheme.bodySmall?.copyWith(
            color: theme.colorScheme.onSurface.withValues(alpha: 0.6),
          ),
        ),
        Text(
          value,
          style: theme.textTheme.bodyMedium?.copyWith(
            color: valueColor,
            fontWeight: FontWeight.w600,
          ),
        ),
      ],
    );
  }
}
