# CLAUDE.md

This file provides guidance to Claude Code (claude.ai/code) when working with code in this repository.

## Commands

```bash
flutter pub get          # Install dependencies
flutter run              # Run on connected device (wireless ADB common for this project)
flutter analyze          # Lint
flutter test             # Run tests (none exist yet)
flutter build apk        # Android release build
```

For wireless Android debugging, connect via ADB: `adb connect <device-ip>:5555` then `flutter run`.

## Architecture

**Peanut Budget** is a personal expense/income tracker. No external state management library — state is lifted into `MainShell` (a `StatefulWidget` in `main.dart`) and passed down via callbacks and constructor params.

### Data layer

- `services/database.dart` — SQLite singleton (`DatabaseService.instance`) for `Entry` records. Table: `entries`. Methods: `insertEntry`, `getAllEntries` (sorted by date DESC).
- `services/category_store.dart` — SharedPreferences wrapper for the user's category list (stored as `List<String>` under key `'categories'`). Defaults: Meals, Transport, Leisure.

### Model

- `models/entry.dart` — `Entry` with fields: `id`, `title`, `amount`, `category`, `isExpense` (bool), `date`. Includes `toMap`/`fromMap` for SQLite serialization.

### Screens & navigation

Bottom `NavigationBar` with two tabs managed by index in `MainShell`:

1. **Dashboard** (`screens/dashboard.dart`) — Weekly/monthly summary cards (`_SummaryCard`/`_Stat`), category list with add/delete, FAB to open `AddEntryModal`.
2. **History** (`screens/history.dart`) — Placeholder, not yet implemented.

### Widgets

- `widgets/add_entry_modal.dart` — Bottom-sheet modal for new entries. Supports expense/income toggle, inline category creation, date picker. On submit, calls the callback passed from `MainShell` which writes to SQLite and updates state.
