import 'dart:convert';

import 'package:shared_preferences/shared_preferences.dart';

import '../models/daily_note.dart';

abstract interface class LocalKeyValueStore {
  Future<String?> getString(String key);
  Future<void> setString(String key, String value);
  Future<int?> getInt(String key);
  Future<void> setInt(String key, int value);
  Future<bool?> getBool(String key);
  Future<void> setBool(String key, bool value);
  Future<void> remove(String key);
}

class SharedPreferencesLocalStore implements LocalKeyValueStore {
  SharedPreferencesLocalStore({SharedPreferencesAsync? preferences})
    : _preferences = preferences ?? SharedPreferencesAsync();

  final SharedPreferencesAsync _preferences;

  @override
  Future<String?> getString(String key) => _preferences.getString(key);

  @override
  Future<void> setString(String key, String value) =>
      _preferences.setString(key, value);

  @override
  Future<int?> getInt(String key) => _preferences.getInt(key);

  @override
  Future<void> setInt(String key, int value) => _preferences.setInt(key, value);

  @override
  Future<bool?> getBool(String key) => _preferences.getBool(key);

  @override
  Future<void> setBool(String key, bool value) =>
      _preferences.setBool(key, value);

  @override
  Future<void> remove(String key) => _preferences.remove(key);
}

class LocalStorageException implements Exception {
  const LocalStorageException(this.message, [this.cause]);

  final String message;
  final Object? cause;

  @override
  String toString() => message;
}

class LocalStorageService {
  LocalStorageService({LocalKeyValueStore? store})
    : _store = store ?? SharedPreferencesLocalStore();

  static const _notesKey = 'caly.daily_notes.v1';
  static const _calorieGoalKey = 'caly.daily_goal';
  static const _demoSessionKey = 'caly.local_demo.signed_in';

  final LocalKeyValueStore _store;

  Future<void> saveDailyNote(DailyNote note) async {
    final notes = await _readNoteMaps();
    notes[note.dateKey] = note.toMap();
    await _writeNoteMaps(notes);
  }

  Future<DailyNote?> loadDailyNote(DateTime date) async {
    final notes = await _readNoteMaps();
    final value = notes[formatDateKey(date)];
    if (value == null) return null;
    return _decodeNote(value);
  }

  Future<List<DailyNote>> loadAllDailyNotes() async {
    final notes = await _readNoteMaps();
    final decoded = notes.values.map(_decodeNote).toList();
    decoded.sort((a, b) => b.date.compareTo(a.date));
    return decoded;
  }

  Future<void> updateDailyNote(DailyNote note) => saveDailyNote(note);

  Future<void> deleteDailyNote(DateTime date) async {
    final notes = await _readNoteMaps();
    notes.remove(formatDateKey(date));
    await _writeNoteMaps(notes);
  }

  Future<void> saveCalorieGoal(int calories) async {
    if (calories <= 0) {
      throw const LocalStorageException('Calorie goal must be positive.');
    }
    await _store.setInt(_calorieGoalKey, calories);
  }

  Future<int?> loadCalorieGoal() async {
    final goal = await _store.getInt(_calorieGoalKey);
    return goal != null && goal > 0 ? goal : null;
  }

  Future<void> saveDemoLoginSession() => _store.setBool(_demoSessionKey, true);

  Future<bool> loadDemoLoginSession() async =>
      await _store.getBool(_demoSessionKey) ?? false;

  Future<void> clearDemoLoginSession() => _store.remove(_demoSessionKey);

  Future<Map<String, dynamic>> _readNoteMaps() async {
    final encoded = await _store.getString(_notesKey);
    if (encoded == null || encoded.isEmpty) return {};
    try {
      final decoded = jsonDecode(encoded);
      if (decoded is! Map) throw const FormatException();
      return Map<String, dynamic>.from(decoded);
    } on FormatException catch (error) {
      throw LocalStorageException('Saved journal data is invalid.', error);
    }
  }

  Future<void> _writeNoteMaps(Map<String, dynamic> notes) async {
    await _store.setString(_notesKey, jsonEncode(notes));
  }

  DailyNote _decodeNote(dynamic value) {
    try {
      if (value is! Map) throw const FormatException();
      return DailyNote.fromMap(Map<String, dynamic>.from(value));
    } on FormatException catch (error) {
      throw LocalStorageException('A saved daily note is invalid.', error);
    }
  }
}
