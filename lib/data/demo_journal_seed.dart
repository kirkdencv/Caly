import '../models/daily_note.dart';
import '../models/food_entry.dart';
import '../models/meal_category.dart';

/// Builds a small, fictional journal history for the public demo.
///
/// Dates are relative to the first day the app runs, so the examples always
/// appear as earlier journal days instead of eventually looking like stale
/// fixed test data.
List<DailyNote> buildDemoJournalSeed(DateTime today) {
  final journalToday = dateOnly(today);

  return [
    _demoNote(
      date: journalToday.subtract(const Duration(days: 1)),
      entries: const [
        _DemoFood(
          'oats-banana',
          'Oatmeal with banana',
          'Oatmeal with banana',
          1,
          'bowl',
          350,
          MealCategory.breakfast,
        ),
        _DemoFood(
          'adobo-rice',
          'Chicken adobo and rice',
          'Chicken adobo with white rice',
          1,
          'plate',
          620,
          MealCategory.lunch,
        ),
        _DemoFood(
          'salmon-salad',
          'Grilled salmon salad',
          'Grilled salmon salad',
          1,
          'plate',
          480,
          MealCategory.dinner,
        ),
      ],
    ),
    _demoNote(
      date: journalToday.subtract(const Duration(days: 3)),
      entries: const [
        _DemoFood(
          'latte',
          'Iced latte',
          'Iced milk latte',
          1,
          'cup',
          140,
          MealCategory.breakfast,
        ),
        _DemoFood(
          'tuna-sandwich',
          'Tuna sandwich',
          'Tuna salad sandwich',
          1,
          'sandwich',
          430,
          MealCategory.lunch,
        ),
        _DemoFood(
          'beef-stir-fry',
          'Beef stir-fry with rice',
          'Beef vegetable stir-fry with rice',
          1,
          'plate',
          650,
          MealCategory.dinner,
        ),
      ],
    ),
    _demoNote(
      date: journalToday.subtract(const Duration(days: 9)),
      entries: const [
        _DemoFood(
          'eggs-toast',
          'Scrambled eggs and toast',
          'Scrambled eggs with toast',
          1,
          'plate',
          350,
          MealCategory.breakfast,
        ),
        _DemoFood(
          'ramen',
          'Chicken ramen',
          'Chicken ramen',
          1,
          'bowl',
          520,
          MealCategory.lunch,
        ),
        _DemoFood(
          'grilled-chicken',
          'Grilled chicken and rice',
          'Grilled chicken breast with rice',
          1,
          'plate',
          610,
          MealCategory.dinner,
        ),
      ],
    ),
  ];
}

DailyNote _demoNote({
  required DateTime date,
  required List<_DemoFood> entries,
}) {
  final createdAt = date.add(const Duration(hours: 8));
  return DailyNote.fromEntries(
    date: date,
    entries: entries
        .map(
          (food) => FoodEntry(
            id: 'demo-${formatDateKey(date)}-${food.id}',
            originalText: food.originalText,
            foodName: food.foodName,
            quantity: food.quantity,
            unit: food.unit,
            calories: food.calories,
            mealCategory: food.mealCategory,
          ),
        )
        .toList(growable: false),
    createdAt: createdAt,
    updatedAt: date.add(const Duration(hours: 20)),
  );
}

class _DemoFood {
  const _DemoFood(
    this.id,
    this.originalText,
    this.foodName,
    this.quantity,
    this.unit,
    this.calories,
    this.mealCategory,
  );

  final String id;
  final String originalText;
  final String foodName;
  final double quantity;
  final String unit;
  final int calories;
  final String mealCategory;
}
