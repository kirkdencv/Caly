import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';

import 'package:final_project/models/daily_note.dart';
import 'package:final_project/models/food_entry.dart';
import 'package:final_project/screens/history_screen.dart';
import 'package:final_project/services/local_storage_service.dart';
import 'package:final_project/theme/caly_theme.dart';

class HistoryMemoryStore implements LocalKeyValueStore {
  final Map<String, Object> values = {};

  @override
  Future<String?> getString(String key) async => values[key] as String?;

  @override
  Future<void> setString(String key, String value) async => values[key] = value;

  @override
  Future<int?> getInt(String key) async => values[key] as int?;

  @override
  Future<void> setInt(String key, int value) async => values[key] = value;

  @override
  Future<bool?> getBool(String key) async => values[key] as bool?;

  @override
  Future<void> setBool(String key, bool value) async => values[key] = value;

  @override
  Future<void> remove(String key) async => values.remove(key);
}

FoodEntry _entry({
  required String id,
  required String text,
  required int calories,
}) {
  return FoodEntry(
    id: id,
    originalText: text,
    foodName: text,
    quantity: 1,
    unit: 'serving',
    calories: calories,
    mealCategory: 'Breakfast',
  );
}

DailyNote _note(DateTime date, FoodEntry entry) {
  return DailyNote.fromEntries(
    date: date,
    entries: [entry],
    createdAt: date.add(const Duration(hours: 8)),
    updatedAt: date.add(const Duration(hours: 9)),
  );
}

void main() {
  testWidgets('history loads saved notes in descending date order', (
    tester,
  ) async {
    final storage = LocalStorageService(store: HistoryMemoryStore());
    await storage.saveDailyNote(
      _note(
        DateTime(2026, 9, 18),
        _entry(id: 'rice', text: 'Rice bowl', calories: 200),
      ),
    );
    await storage.saveDailyNote(
      _note(
        DateTime(2026, 9, 20),
        _entry(id: 'banana', text: 'Banana', calories: 105),
      ),
    );

    DateTime? selectedDate;
    await tester.pumpWidget(
      MaterialApp(
        theme: calyTheme,
        home: Scaffold(
          body: HistoryScreen(
            localStorageService: storage,
            onOpenDate: (date) => selectedDate = date,
          ),
        ),
      ),
    );
    await tester.pumpAndSettle();

    final newer = find.byKey(const ValueKey('history-note-2026-09-20'));
    final older = find.byKey(const ValueKey('history-note-2026-09-18'));
    expect(newer, findsOneWidget);
    expect(older, findsOneWidget);
    expect(tester.getTopLeft(newer).dy, lessThan(tester.getTopLeft(older).dy));
    expect(find.text('105 kcal'), findsOneWidget);
    expect(find.text('200 kcal'), findsOneWidget);

    await tester.tap(older);
    expect(selectedDate, DateTime(2026, 9, 18));
  });

  testWidgets('history search filters the already-loaded local notes', (
    tester,
  ) async {
    final storage = LocalStorageService(store: HistoryMemoryStore());
    await storage.saveDailyNote(
      _note(
        DateTime(2026, 9, 18),
        _entry(id: 'rice', text: 'Rice bowl', calories: 200),
      ),
    );
    await storage.saveDailyNote(
      _note(
        DateTime(2026, 9, 20),
        _entry(id: 'banana', text: 'Banana', calories: 105),
      ),
    );

    await tester.pumpWidget(
      MaterialApp(
        theme: calyTheme,
        home: Scaffold(
          body: HistoryScreen(localStorageService: storage, onOpenDate: (_) {}),
        ),
      ),
    );
    await tester.pumpAndSettle();
    await tester.enterText(find.byKey(const Key('history-search')), 'banana');
    await tester.pump();

    expect(
      find.byKey(const ValueKey('history-note-2026-09-20')),
      findsOneWidget,
    );
    expect(find.byKey(const ValueKey('history-note-2026-09-18')), findsNothing);
    expect(find.text('Banana'), findsOneWidget);
  });
}
