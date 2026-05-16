import 'package:flutter/material.dart';
import 'models/entry.dart';
import 'screens/dashboard.dart';
import 'screens/history.dart';
import 'services/database.dart';
import 'services/category_store.dart';

void main() {
  runApp(const MainApp());
}

// root widget
class MainApp extends StatelessWidget {
  const MainApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Peanut Budget',
      theme: ThemeData(
        colorScheme: ColorScheme.fromSeed(seedColor: Colors.green),
        useMaterial3: true,
      ),
      home: const MainShell(),
    );
  }
}

// nav bar
class MainShell extends StatefulWidget {
  const MainShell({super.key});

  @override
  State<MainShell> createState() => _MainShellState();
}

// nav bar state
class _MainShellState extends State<MainShell> {
  int _selectedIndex = 0;
  List<Entry> _entries = [];
  List<String> _categories = [];
  bool _isLoading = true;

  final _db = DatabaseService.instance;
  final _categoryStore = CategoryStore();

  @override
  void initState() {
    super.initState();
    _load();
  }

  Future<void> _load() async {
    final entries = await _db.getAllEntries();
    final categories = await _categoryStore.load();
    setState(() {
      _entries = entries;
      _categories = categories;
      _isLoading = false;
    });
  }

  Future<void> _addEntry(Entry entry) async {
    await _db.insertEntry(entry);
    setState(() => _entries.add(entry));
  }

  Future<void> _addCategory(String name) async {
    if (_categories.contains(name)) return;
    final updated = [..._categories, name];
    await _categoryStore.save(updated);
    setState(() => _categories = updated);
  }

  Future<void> _deleteCategory(String name) async {
    final updated = _categories.where((c) => c != name).toList();
    await _categoryStore.save(updated);
    setState(() => _categories = updated);
  }

  Future<void> _deleteEntry(String id) async {
    await _db.deleteEntry(id);
    setState(() => _entries.removeWhere((e) => e.id == id));
  }

  @override
  Widget build(BuildContext context) {
    if (_isLoading) {
      return const Scaffold(body: Center(child: CircularProgressIndicator()));
    }

    final screens = [
      DashboardScreen(
        entries: _entries,
        categories: _categories,
        onAddEntry: _addEntry,
        onAddCategory: _addCategory,
        onDeleteCategory: _deleteCategory,
      ),
      HistoryScreen(entries: _entries, onDeleteEntry: _deleteEntry),
    ];

    return Scaffold(
      body: screens[_selectedIndex],
      bottomNavigationBar: NavigationBar(
        selectedIndex: _selectedIndex,
        onDestinationSelected: (i) => setState(() => _selectedIndex = i),
        destinations: const [
          NavigationDestination(
            icon: Icon(Icons.dashboard_outlined),
            selectedIcon: Icon(Icons.dashboard),
            label: 'Dashboard',
          ),
          NavigationDestination(
            icon: Icon(Icons.history_outlined),
            selectedIcon: Icon(Icons.history),
            label: 'History',
          ),
        ],
      ),
    );
  }
}
