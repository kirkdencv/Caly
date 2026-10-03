abstract final class MealCategory {
  static const breakfast = 'Breakfast';
  static const lunch = 'Lunch';
  static const dinner = 'Dinner';

  static const values = [breakfast, lunch, dinner];

  static bool isValid(String value) {
    return switch (value.trim().toLowerCase()) {
      'breakfast' || 'lunch' || 'dinner' => true,
      _ => false,
    };
  }

  static String normalize(String value) {
    final normalized = value.trim().toLowerCase();
    return switch (normalized) {
      'breakfast' => breakfast,
      'lunch' => lunch,
      'dinner' => dinner,
      _ => throw FormatException('Unknown meal category: $value'),
    };
  }

  static String toApiValue(String value) => normalize(value).toLowerCase();
}
