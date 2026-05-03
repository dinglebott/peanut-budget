class Entry {
  final String id;
  final String title;
  final double amount;
  final String category;
  final bool isExpense;
  final DateTime date;

  const Entry({
    required this.id,
    required this.title,
    required this.amount,
    required this.category,
    required this.isExpense,
    required this.date,
  });

  Map<String, dynamic> toMap() => {
    'id': id,
    'title': title,
    'amount': amount,
    'category': category,
    'is_expense': isExpense ? 1 : 0,
    'date': date.millisecondsSinceEpoch,
  };

  static Entry fromMap(Map<String, dynamic> map) => Entry(
    id: map['id'] as String,
    title: map['title'] as String,
    amount: map['amount'] as double,
    category: map['category'] as String,
    isExpense: (map['is_expense'] as int) == 1,
    date: DateTime.fromMillisecondsSinceEpoch(map['date'] as int),
  );
}
