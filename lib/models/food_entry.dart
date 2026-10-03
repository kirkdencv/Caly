enum FoodEntryStatus { loading, ready, error }

class FoodEntry {
  // One object keeps a food row's related values together. This is safer than
  // maintaining separate lists for names, calories, and meal categories.
  const FoodEntry({
    required this.id,
    required this.originalText,
    required this.foodName,
    required this.quantity,
    required this.unit,
    required this.calories,
    required this.mealCategory,
    this.status = FoodEntryStatus.ready,
    this.errorMessage,
  }) : assert(calories >= 0, 'Calories cannot be negative'),
       assert(quantity >= 0, 'Quantity cannot be negative');

  /// Stable identifier used to find and replace a corrected entry.
  final String id;

  /// The note text shown in the meal row, such as "1 cup rice".
  final String originalText;

  /// A normalized food name that correction and backend features can refine.
  final String foodName;

  /// Numeric serving amount, kept separate so correction can edit it.
  final double quantity;

  /// Serving unit paired with [quantity], such as cup or piece.
  final String unit;

  /// Calorie value used by TodayScreen's calculated daily total.
  final int calories;

  /// The user-selected meal; it is never inferred from the food text.
  final String mealCategory;

  /// Controls whether the row shows a spinner, calories, or a retry action.
  final FoodEntryStatus status;

  /// Friendly failure text retained with an errored row.
  final String? errorMessage;

  factory FoodEntry.fromJson(Map<String, dynamic> json) {
    final originalText = _requiredString(json, 'originalText');
    final foodName = _requiredString(json, 'foodName');
    final quantityValue = json['quantity'];
    final calorieValue = json['calories'];
    final mealCategory = _requiredString(json, 'mealCategory').toLowerCase();

    if (quantityValue is! num || quantityValue <= 0) {
      throw const FormatException(
        'The food service returned an invalid quantity.',
      );
    }
    if (calorieValue is! num ||
        calorieValue < 0 ||
        calorieValue != calorieValue.roundToDouble()) {
      throw const FormatException(
        'The food service returned an invalid calorie value.',
      );
    }
    if (!const {'breakfast', 'lunch', 'dinner'}.contains(mealCategory)) {
      throw const FormatException(
        'The food service returned an invalid meal category.',
      );
    }

    return FoodEntry(
      id: '${DateTime.now().microsecondsSinceEpoch}',
      originalText: originalText,
      foodName: foodName,
      quantity: quantityValue.toDouble(),
      unit: _requiredString(json, 'unit'),
      calories: calorieValue.toInt(),
      mealCategory: mealCategory,
    );
  }

  /// Converts a completed entry into JSON-safe local-storage values.
  Map<String, dynamic> toMap() {
    return {
      'id': id,
      'originalText': originalText,
      'foodName': foodName,
      'quantity': quantity,
      'unit': unit,
      'calories': calories,
      'mealCategory': mealCategory,
    };
  }

  /// Restores a completed entry from local storage.
  factory FoodEntry.fromMap(Map<String, dynamic> map) {
    final id = _requiredString(map, 'id');
    final originalText = _requiredString(map, 'originalText');
    final foodName = _requiredString(map, 'foodName');
    final unit = _requiredString(map, 'unit');
    final quantityValue = map['quantity'];
    final calorieValue = map['calories'];
    final storedMeal = _requiredString(map, 'mealCategory').toLowerCase();

    if (quantityValue is! num || quantityValue <= 0) {
      throw const FormatException('Stored food has an invalid quantity.');
    }
    if (calorieValue is! num ||
        calorieValue < 0 ||
        calorieValue != calorieValue.roundToDouble()) {
      throw const FormatException('Stored food has invalid calories.');
    }
    if (!const {'breakfast', 'lunch', 'dinner'}.contains(storedMeal)) {
      throw const FormatException('Stored food has an invalid meal category.');
    }

    final mealCategory =
        '${storedMeal[0].toUpperCase()}${storedMeal.substring(1)}';
    return FoodEntry(
      id: id,
      originalText: originalText,
      foodName: foodName,
      quantity: quantityValue.toDouble(),
      unit: unit,
      calories: calorieValue.toInt(),
      mealCategory: mealCategory,
    );
  }

  FoodEntry copyWith({
    String? id,
    String? originalText,
    String? foodName,
    double? quantity,
    String? unit,
    int? calories,
    String? mealCategory,
    FoodEntryStatus? status,
    String? errorMessage,
    bool clearErrorMessage = false,
  }) {
    // copyWith returns a new immutable entry while preserving unchanged data.
    // The correction sheet uses it instead of mutating the original object.
    return FoodEntry(
      id: id ?? this.id,
      originalText: originalText ?? this.originalText,
      foodName: foodName ?? this.foodName,
      quantity: quantity ?? this.quantity,
      unit: unit ?? this.unit,
      calories: calories ?? this.calories,
      mealCategory: mealCategory ?? this.mealCategory,
      status: status ?? this.status,
      errorMessage: clearErrorMessage
          ? null
          : errorMessage ?? this.errorMessage,
    );
  }
}

String _requiredString(Map<String, dynamic> json, String key) {
  final value = json[key];
  if (value is! String || value.trim().isEmpty) {
    throw FormatException('The food service response is missing $key.');
  }
  return value.trim();
}
