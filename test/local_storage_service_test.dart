import 'dart:convert';

import 'package:flutter_test/flutter_test.dart';

import 'package:final_project/models/daily_note.dart';
import 'package:final_project/models/food_entry.dart';
import 'package:final_project/services/local_storage_service.dart';

class MemoryLocalStore implements LocalKeyValueStore {
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

const sampleEntry = FoodEntry(
  id: 'rice-1',
  originalText: '1 cup rice',
  foodName: 'White rice, cooked',
  quantity: 1,
  unit: 'cup',
  calories: 200,
  mealCategory: 'Breakfast',
);

DailyNote noteFor(DateTime date, {List<FoodEntry>? entries}) {
  return DailyNote.fromEntries(
    date: date,
    entries: entries ?? [sampleEntry],
    createdAt: DateTime(2026, 9, 20, 8),
    updatedAt: DateTime(2026, 9, 20, 9),
  );
}

void main() {
  test('FoodEntry converts to and from a local map', () {
    final restored = FoodEntry.fromMap(sampleEntry.toMap());

    expect(restored.id, sampleEntry.id);
    expect(restored.originalText, sampleEntry.originalText);
    expect(restored.quantity, 1);
    expect(restored.calories, 200);
    expect(restored.mealCategory, 'Breakfast');
    expect(restored.status, FoodEntryStatus.ready);
  });

  test('DailyNote preserves date, entries, total, and timestamps', () {
    final original = noteFor(DateTime(2026, 9, 20, 18));
    final restored = DailyNote.fromMap(original.toMap());

    expect(restored.date, DateTime(2026, 9, 20));
    expect(restored.entries.single.id, 'rice-1');
    expect(restored.totalCalories, 200);
    expect(restored.createdAt, DateTime(2026, 9, 20, 8));
    expect(restored.updatedAt, DateTime(2026, 9, 20, 9));
  });

  test('DailyNote rejects a total that does not match its entries', () {
    final map = noteFor(DateTime(2026, 9, 20)).toMap();
    map['totalCalories'] = 999;

    expect(() => DailyNote.fromMap(map), throwsFormatException);
  });

  test('service saves, loads, updates, sorts, and deletes days', () async {
    final service = LocalStorageService(store: MemoryLocalStore());
    final older = noteFor(DateTime(2026, 9, 19));
    final newer = noteFor(DateTime(2026, 9, 20));

    await service.saveDailyNote(older);
    await service.saveDailyNote(newer);
    expect((await service.loadAllDailyNotes()).map((note) => note.date), [
      DateTime(2026, 9, 20),
      DateTime(2026, 9, 19),
    ]);

    final correctedEntry = sampleEntry.copyWith(calories: 180);
    await service.updateDailyNote(
      noteFor(DateTime(2026, 9, 20), entries: [correctedEntry]),
    );
    expect(
      (await service.loadDailyNote(DateTime(2026, 9, 20)))!.totalCalories,
      180,
    );

    await service.deleteDailyNote(DateTime(2026, 9, 19));
    expect(await service.loadDailyNote(DateTime(2026, 9, 19)), isNull);
    expect(await service.loadAllDailyNotes(), hasLength(1));
  });

  test('demo history seeds once and preserves existing journal days', () async {
    final store = MemoryLocalStore();
    final service = LocalStorageService(store: store);
    final today = DateTime(2026, 10, 4);
    final yesterday = DateTime(2026, 10, 3);
    final existing = noteFor(yesterday);
    await service.saveDailyNote(existing);

    await service.seedDemoHistoryIfNeeded(today: today);
    final seeded = await service.loadAllDailyNotes();

    expect(seeded, hasLength(3));
    expect(await service.loadDailyNote(yesterday), isNotNull);
    expect(
      (await service.loadDailyNote(yesterday))!.entries.single.id,
      existing.entries.single.id,
    );
    expect(seeded.map((note) => note.date), [
      DateTime(2026, 10, 3),
      DateTime(2026, 10, 1),
      DateTime(2026, 9, 25),
    ]);

    await service.deleteDailyNote(DateTime(2026, 10, 1));
    await service.seedDemoHistoryIfNeeded(today: today);
    expect(await service.loadDailyNote(DateTime(2026, 10, 1)), isNull);
  });

  test('saved journal data survives service recreation', () async {
    final store = MemoryLocalStore();
    final firstAppSession = LocalStorageService(store: store);
    await firstAppSession.saveDailyNote(noteFor(DateTime(2026, 9, 20)));

    // A new service instance represents reopening or reloading the app while
    // the underlying shared-preferences data remains on the device.
    final reloadedAppSession = LocalStorageService(store: store);
    final restored = await reloadedAppSession.loadDailyNote(
      DateTime(2026, 9, 20),
    );

    expect(restored, isNotNull);
    expect(restored!.entries.single.toMap(), sampleEntry.toMap());
    expect(restored.totalCalories, 200);
  });

  test('service saves and loads the calorie goal', () async {
    final service = LocalStorageService(store: MemoryLocalStore());

    expect(await service.loadCalorieGoal(), isNull);
    await service.saveCalorieGoal(2200);
    expect(await service.loadCalorieGoal(), 2200);
    expect(
      () => service.saveCalorieGoal(0),
      throwsA(isA<LocalStorageException>()),
    );
  });

  test('service saves and clears the demo session flag', () async {
    final service = LocalStorageService(store: MemoryLocalStore());

    expect(await service.loadDemoLoginSession(), isFalse);
    await service.saveDemoLoginSession();
    expect(await service.loadDemoLoginSession(), isTrue);
    await service.clearDemoLoginSession();
    expect(await service.loadDemoLoginSession(), isFalse);
  });

  test('service reports malformed journal JSON', () async {
    final store = MemoryLocalStore();
    store.values['caly.daily_notes.v1'] = jsonEncode(['not', 'a', 'map']);
    final service = LocalStorageService(store: store);

    expect(service.loadAllDailyNotes(), throwsA(isA<LocalStorageException>()));
  });
}
