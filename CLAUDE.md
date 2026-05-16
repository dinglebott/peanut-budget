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

App icons are generated via `flutter_launcher_icons` config in `pubspec.yaml` (foreground/background + adaptive icon). Regenerate with `dart run flutter_launcher_icons` after changing assets.

## Architecture

**Peanut Budget** is a personal expense/income tracker. No external state management library — state is lifted into `MainShell` (a `StatefulWidget` in `main.dart`) and passed down via callbacks and constructor params. Data is loaded once in `initState` and held in memory; children receive the lists and mutator callbacks rather than reaching into services directly.

### Data layer

- `services/database.dart` — SQLite singleton (`DatabaseService.instance`) for `Entry` records. Table: `entries`. Methods: `insertEntry`, `getAllEntries` (sorted by date DESC), `deleteEntry`.
- `services/category_store.dart` — SharedPreferences wrapper for the user's category list (stored as `List<String>` under key `'categories'`). Defaults: Meals, Transport, Leisure. Categories are referenced by string only — entries hold the category name verbatim, so deleting a category does not touch existing entries (re-adding the exact same name restores the linkage).

### Model

- `models/entry.dart` — `Entry` with fields: `id`, `title`, `amount`, `category`, `isExpense` (bool), `date`. Includes `toMap`/`fromMap` for SQLite serialization (`is_expense` stored as 0/1, `date` stored as ms-since-epoch).

### Screens & navigation

Bottom `NavigationBar` with two tabs managed by index in `MainShell`:

1. **Dashboard** (`screens/dashboard.dart`) — Two top buttons (`_AddButtons`: Add Expense / Add Income) that open `AddEntryModal` with the appropriate type preset. Weekly/monthly summary cards (`_SummaryCard`/`_Stat`) and a category list (`_CategoriesCard`) with inline add and a confirmation dialog on delete.
2. **History** (`screens/history.dart`) — Entries grouped into expandable monthly cards (`_MonthCard`), sorted newest-first. Each month shows totals (spent / earned / net) and, when expanded, a list of `_EntryRow` items with per-entry delete (with confirmation). A top filter button opens a multi-select dialog over the current categories; deleted categories are pruned from the active filter in `didUpdateWidget`.

### Widgets

- `widgets/add_entry_modal.dart` — Bottom-sheet modal for new entries. Type (expense vs income) is fixed per open via `initialIsExpense`. Supports inline category creation, date picker (capped at today), and validation: invalid/missing fields surface in an `AlertDialog` rather than failing silently. The modal keeps a local mirror of `categories` because `showModalBottomSheet` is on a separate route and does not rebuild from parent state changes. On submit, calls the callback passed from `MainShell` which writes to SQLite and updates state.

## Deployment notes (Android)

Fields to update before a release build (see README "DEPLOYMENT GUIDE" for the full walkthrough):
- App display name — `android/app/src/main/AndroidManifest.xml`
- Package identifier — `android/app/build.gradle.kts`
- Version — `pubspec.yaml` (`version:` field, format `X.Y.Z+build`)
