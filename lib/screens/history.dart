import 'package:flutter/material.dart';
import '../models/entry.dart';

class HistoryScreen extends StatelessWidget {
  final List<Entry> entries;

  const HistoryScreen({super.key, required this.entries});

  @override
  Widget build(BuildContext context) {
    return const Scaffold(
      body: Center(child: Text('History — coming soon')),
    );
  }
}
