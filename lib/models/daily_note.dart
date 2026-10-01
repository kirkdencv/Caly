import 'food_entry.dart';

class DailyNote {
  DailyNote({
    required DateTime date,
    required List<FoodEntry> entries,
    required this.totalCalories,
    required this.createdAt,
    required this.updatedAt,
  }) : date = dateOnly(date),
       entries = List.unmodifiable(entries) {
    if (totalCalories < 0) {
      throw const FormatException('Daily total cannot be negative.');
    }
    final calculatedTotal = this.entries.fold(
      0,
      (total, entry) => total + entry.calories,
    );
    if (calculatedTotal != totalCalories) {
      throw const FormatException('Daily total does not match its entries.');
    }
  }

  factory DailyNote.fromEntries({
    required DateTime date,
    required List<FoodEntry> entries,
    required DateTime createdAt,
    DateTime? updatedAt,
  }) {
    final completedEntries = entries
        .where((entry) => entry.status == FoodEntryStatus.ready)
        .toList(growable: false);
    return DailyNote(
      date: date,
      entries: completedEntries,
      totalCalories: completedEntries.fold(
        0,
        (total, entry) => total + entry.calories,
      ),
      createdAt: createdAt,
      updatedAt: updatedAt ?? DateTime.now(),
    );
  }

  final DateTime date;
  final List<FoodEntry> entries;
  final int totalCalories;
  final DateTime createdAt;
  final DateTime updatedAt;

  String get dateKey => formatDateKey(date);

  Map<String, dynamic> toMap() {
    return {
      'date': dateKey,
      'entries': entries.map((entry) => entry.toMap()).toList(),
      'totalCalories': totalCalories,
      'createdAt': createdAt.toIso8601String(),
      'updatedAt': updatedAt.toIso8601String(),
    };
  }

  factory DailyNote.fromMap(Map<String, dynamic> map) {
    final dateValue = map['date'];
    final entriesValue = map['entries'];
    final totalValue = map['totalCalories'];
    final createdValue = map['createdAt'];
    final updatedValue = map['updatedAt'];

    if (dateValue is! String ||
        entriesValue is! List ||
        totalValue is! num ||
        totalValue < 0 ||
        totalValue != totalValue.roundToDouble() ||
        createdValue is! String ||
        updatedValue is! String) {
      throw const FormatException('Stored daily note has invalid fields.');
    }

    final date = DateTime.tryParse(dateValue);
    final createdAt = DateTime.tryParse(createdValue);
    final updatedAt = DateTime.tryParse(updatedValue);
    if (date == null || createdAt == null || updatedAt == null) {
      throw const FormatException('Stored daily note has invalid dates.');
    }

    final entries = entriesValue
        .map((value) {
          if (value is! Map) {
            throw const FormatException(
              'Stored daily note has an invalid entry.',
            );
          }
          return FoodEntry.fromMap(Map<String, dynamic>.from(value));
        })
        .toList(growable: false);
    final calculatedTotal = entries.fold(
      0,
      (total, entry) => total + entry.calories,
    );
    if (calculatedTotal != totalValue.toInt()) {
      throw const FormatException('Stored daily total does not match entries.');
    }

    return DailyNote(
      date: date,
      entries: entries,
      totalCalories: totalValue.toInt(),
      createdAt: createdAt,
      updatedAt: updatedAt,
    );
  }
}

DateTime dateOnly(DateTime value) =>
    DateTime(value.year, value.month, value.day);

String formatDateKey(DateTime value) {
  final date = dateOnly(value);
  final month = date.month.toString().padLeft(2, '0');
  final day = date.day.toString().padLeft(2, '0');
  return '${date.year}-$month-$day';
}
