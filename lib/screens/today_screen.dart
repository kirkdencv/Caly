import 'package:flutter/material.dart';

import '../models/daily_note.dart';
import '../models/food_entry.dart';
import '../services/food_api_service.dart';
import '../services/local_storage_service.dart';
import '../theme/caly_spacing.dart';
import '../widgets/large_title_header.dart';
import '../widgets/meal_section.dart';

class TodayScreen extends StatefulWidget {
  const TodayScreen({
    super.key,
    this.foodApiService,
    this.localStorageService,
    this.dailyGoalNotifier,
    this.journalDate,
    this.onSaved,
  });

  /// Optional injection point used by tests and by future app-level setup.
  final FoodApiService? foodApiService;
  final LocalStorageService? localStorageService;
  final ValueNotifier<int>? dailyGoalNotifier;
  final DateTime? journalDate;
  final VoidCallback? onSaved;

  @override
  State<TodayScreen> createState() => _TodayScreenState();
}

class _TodayScreenState extends State<TodayScreen> {
  late final FoodApiService _foodApiService;
  late final LocalStorageService _localStorage;
  late final ValueNotifier<int> _dailyGoalNotifier;
  late final bool _ownsGoalNotifier;
  late final DateTime _journalDate;
  DateTime _createdAt = DateTime.now();
  int _dailyGoal = 2000;
  bool _isLoadingStorage = true;
  String? _storageError;

  @override
  void initState() {
    super.initState();
    _foodApiService = widget.foodApiService ?? FoodApiService();
    _localStorage = widget.localStorageService ?? LocalStorageService();
    _ownsGoalNotifier = widget.dailyGoalNotifier == null;
    _dailyGoalNotifier = widget.dailyGoalNotifier ?? ValueNotifier(2000);
    _dailyGoal = _dailyGoalNotifier.value;
    _dailyGoalNotifier.addListener(_handleGoalChanged);
    _journalDate = dateOnly(widget.journalDate ?? DateTime.now());
    _loadLocalData();
  }

  @override
  void dispose() {
    _foodApiService.close();
    _dailyGoalNotifier.removeListener(_handleGoalChanged);
    if (_ownsGoalNotifier) _dailyGoalNotifier.dispose();
    super.dispose();
  }

  final List<FoodEntry> _breakfastEntries = [];
  final List<FoodEntry> _lunchEntries = [];
  final List<FoodEntry> _dinnerEntries = [];

  void _handleGoalChanged() {
    if (mounted) setState(() => _dailyGoal = _dailyGoalNotifier.value);
  }

  Future<void> _loadLocalData() async {
    try {
      final note = await _localStorage.loadDailyNote(_journalDate);
      final goal = await _localStorage.loadCalorieGoal();
      if (!mounted) return;

      if (goal != null && _dailyGoalNotifier.value != goal) {
        _dailyGoalNotifier.value = goal;
      }
      setState(() {
        _breakfastEntries.clear();
        _lunchEntries.clear();
        _dinnerEntries.clear();
        if (note != null) {
          _createdAt = note.createdAt;
          for (final entry in note.entries) {
            _entriesForMeal(entry.mealCategory).add(entry);
          }
        }
        _dailyGoal = goal ?? _dailyGoalNotifier.value;
        _isLoadingStorage = false;
      });
    } catch (_) {
      if (!mounted) return;
      setState(() {
        _isLoadingStorage = false;
        _storageError = 'Could not load the saved journal on this device.';
      });
    }
  }

  Future<void> _saveCurrentNote() async {
    final note = DailyNote.fromEntries(
      date: _journalDate,
      entries: _allEntries.toList(),
      createdAt: _createdAt,
    );
    try {
      await _localStorage.saveDailyNote(note);
      widget.onSaved?.call();
    } catch (_) {
      if (!mounted) return;
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('The entry changed, but could not be saved locally.'),
        ),
      );
    }
  }

  Iterable<FoodEntry> get _allEntries sync* {
    yield* _breakfastEntries;
    yield* _lunchEntries;
    yield* _dinnerEntries;
  }

  int get _totalCalories =>
      _allEntries.fold(0, (sum, entry) => sum + entry.calories);

  List<FoodEntry> _entriesForMeal(String meal) {
    return switch (meal) {
      'Breakfast' => _breakfastEntries,
      'Lunch' => _lunchEntries,
      'Dinner' => _dinnerEntries,
      _ => throw ArgumentError.value(meal, 'meal', 'Unknown meal category'),
    };
  }

  String _formatJournalDate(DateTime date) {
    const weekdays = [
      'Monday',
      'Tuesday',
      'Wednesday',
      'Thursday',
      'Friday',
      'Saturday',
      'Sunday',
    ];
    const months = [
      'January',
      'February',
      'March',
      'April',
      'May',
      'June',
      'July',
      'August',
      'September',
      'October',
      'November',
      'December',
    ];

    return '${weekdays[date.weekday - 1]}, ${months[date.month - 1]} ${date.day}';
  }

  Future<void> _openAddFood(String meal) async {
    final input = await showModalBottomSheet<NewFoodInput>(
      context: context,
      isScrollControlled: true,
      useSafeArea: true,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(22)),
      ),
      builder: (_) => AddFoodSheet(meal: meal),
    );

    if (input == null) return;

    final entry = FoodEntry(
      id: '${DateTime.now().microsecondsSinceEpoch}',
      originalText: input.foodText,
      foodName: input.foodText,
      quantity: 1,
      unit: 'serving',
      calories: 0,
      mealCategory: meal,
      status: FoodEntryStatus.loading,
    );

    setState(() => _entriesForMeal(meal).add(entry));
    await _interpretEntry(entry);
  }

  Future<void> _interpretEntry(FoodEntry entry) async {
    _replaceEntry(
      entry.copyWith(status: FoodEntryStatus.loading, clearErrorMessage: true),
    );

    try {
      final interpreted = await _foodApiService.interpretFood(
        text: entry.originalText,
        meal: entry.mealCategory,
      );
      if (!mounted) return;

      // Preserve the local row id and user-selected meal. The backend supplies
      // the interpreted name, quantity, unit, and calories.
      _replaceEntry(
        interpreted.copyWith(
          id: entry.id,
          mealCategory: entry.mealCategory,
          status: FoodEntryStatus.ready,
          clearErrorMessage: true,
        ),
      );
      await _saveCurrentNote();
    } on FoodApiException catch (error) {
      if (!mounted) return;
      // Keep originalText so the user never has to type the failed note again.
      _replaceEntry(
        entry.copyWith(
          status: FoodEntryStatus.error,
          errorMessage: error.message,
        ),
      );
    }
  }

  void _replaceEntry(FoodEntry replacement) {
    if (!mounted) return;
    final entries = _entriesForMeal(replacement.mealCategory);
    final index = entries.indexWhere((entry) => entry.id == replacement.id);
    if (index == -1) return;
    setState(() => entries[index] = replacement);
  }

  Future<void> _openCorrection(FoodEntry entry) async {
    final updated = await showModalBottomSheet<FoodEntry>(
      context: context,
      isScrollControlled: true,
      useSafeArea: true,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(22)),
      ),
      builder: (_) => FoodCorrectionSheet(entry: entry),
    );

    if (updated == null) return;

    final mealEntries = _entriesForMeal(updated.mealCategory);
    final index = mealEntries.indexWhere((item) => item.id == updated.id);
    if (index == -1) return;

    setState(() => mealEntries[index] = updated);
    await _saveCurrentNote();
  }

  String _formatNumber(int value) {
    return value.toString().replaceAllMapped(
      RegExp(r'\B(?=(\d{3})+(?!\d))'),
      (match) => ',',
    );
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final progress = (_totalCalories / _dailyGoal).clamp(0.0, 1.0);
    final isToday = _journalDate == dateOnly(DateTime.now());

    return SafeArea(
      child: ListView(
        padding: const EdgeInsets.fromLTRB(md, md, md, lg),
        children: [
          LargeTitleHeader(
            title: isToday ? 'Today' : 'Journal',
            subtitle: _formatJournalDate(_journalDate),
            trailing: IconButton.filledTonal(
              tooltip: 'More options',
              onPressed: () {
                ScaffoldMessenger.of(context).showSnackBar(
                  const SnackBar(
                    content: Text('Today is ready for your next food note.'),
                  ),
                );
              },
              style: IconButton.styleFrom(
                backgroundColor: theme.colorScheme.secondary,
              ),
              icon: Icon(Icons.more_horiz, color: theme.colorScheme.primary),
            ),
          ),
          if (_isLoadingStorage) ...[
            const SizedBox(height: sm),
            const LinearProgressIndicator(key: Key('journal-loading')),
          ],
          if (_storageError != null) ...[
            const SizedBox(height: sm),
            Text(
              _storageError!,
              style: theme.textTheme.labelSmall?.copyWith(
                color: theme.colorScheme.error,
              ),
            ),
          ],
          const SizedBox(height: md),
          MealSection(
            meal: 'Breakfast',
            entries: _breakfastEntries,
            onAddFood: () => _openAddFood('Breakfast'),
            onCaloriesTap: _openCorrection,
            onRetry: _interpretEntry,
          ),
          const SizedBox(height: sm),
          MealSection(
            meal: 'Lunch',
            entries: _lunchEntries,
            onAddFood: () => _openAddFood('Lunch'),
            onCaloriesTap: _openCorrection,
            onRetry: _interpretEntry,
          ),
          const SizedBox(height: sm),
          MealSection(
            meal: 'Dinner',
            entries: _dinnerEntries,
            onAddFood: () => _openAddFood('Dinner'),
            onCaloriesTap: _openCorrection,
            onRetry: _interpretEntry,
          ),
          const SizedBox(height: lg),
          Divider(height: 1, color: theme.colorScheme.outline),
          const SizedBox(height: sm),
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Text(
                'Total',
                style: theme.textTheme.bodyMedium?.copyWith(
                  color: theme.colorScheme.onSurfaceVariant,
                ),
              ),
              Text(
                '${_formatNumber(_totalCalories)} kcal',
                key: const Key('daily-total'),
                style: theme.textTheme.titleLarge,
              ),
            ],
          ),
          const SizedBox(height: xs),
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Text(
                'Daily goal',
                style: theme.textTheme.labelSmall?.copyWith(
                  color: theme.colorScheme.onSurfaceVariant,
                ),
              ),
              Text(
                '${_formatNumber(_dailyGoal)} kcal',
                key: const Key('daily-goal'),
                style: theme.textTheme.labelSmall?.copyWith(
                  color: theme.colorScheme.onSurfaceVariant,
                ),
              ),
            ],
          ),
          const SizedBox(height: xs),
          ClipRRect(
            borderRadius: BorderRadius.circular(99),
            child: LinearProgressIndicator(
              minHeight: 6,
              value: progress,
              backgroundColor: theme.colorScheme.outline,
              valueColor: AlwaysStoppedAnimation(theme.colorScheme.primary),
            ),
          ),
        ],
      ),
    );
  }
}

class NewFoodInput {
  const NewFoodInput({required this.foodText});

  final String foodText;
}

class AddFoodSheet extends StatefulWidget {
  const AddFoodSheet({super.key, required this.meal});

  final String meal;

  @override
  State<AddFoodSheet> createState() => _AddFoodSheetState();
}

class _AddFoodSheetState extends State<AddFoodSheet> {
  final _formKey = GlobalKey<FormState>();
  final _foodController = TextEditingController();

  @override
  void dispose() {
    _foodController.dispose();
    super.dispose();
  }

  void _save() {
    if (!_formKey.currentState!.validate()) return;

    Navigator.of(
      context,
    ).pop(NewFoodInput(foodText: _foodController.text.trim()));
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    return SingleChildScrollView(
      padding: EdgeInsets.fromLTRB(
        md,
        xs,
        md,
        MediaQuery.viewInsetsOf(context).bottom + md,
      ),
      child: Form(
        key: _formKey,
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text('Add to ${widget.meal}', style: theme.textTheme.titleLarge),
            const SizedBox(height: sm),
            TextFormField(
              key: const Key('add-food-name'),
              controller: _foodController,
              autofocus: true,
              textInputAction: TextInputAction.done,
              onFieldSubmitted: (_) => _save(),
              decoration: const InputDecoration(
                labelText: 'What did you eat?',
                hintText: 'e.g. 1 cup rice',
              ),
              validator: (value) {
                if (value == null || value.trim().isEmpty) {
                  return 'Enter a food note';
                }
                return null;
              },
            ),
            const SizedBox(height: md),
            FilledButton(
              key: const Key('add-food-save'),
              onPressed: _save,
              child: const Text('Add food'),
            ),
            const SizedBox(height: xs),
            SizedBox(
              width: double.infinity,
              child: TextButton(
                onPressed: () => Navigator.of(context).pop(),
                child: const Text('Cancel'),
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class FoodCorrectionSheet extends StatefulWidget {
  const FoodCorrectionSheet({super.key, required this.entry});

  final FoodEntry entry;

  @override
  State<FoodCorrectionSheet> createState() => _FoodCorrectionSheetState();
}

class _FoodCorrectionSheetState extends State<FoodCorrectionSheet> {
  late final TextEditingController _originalController;
  late final TextEditingController _nameController;
  late final TextEditingController _quantityController;
  late final TextEditingController _caloriesController;
  late String _unit;

  static const _units = ['cup', 'piece', 'pieces', 'serving', 'glass'];

  @override
  void initState() {
    super.initState();
    _originalController = TextEditingController(
      text: widget.entry.originalText,
    );
    _nameController = TextEditingController(text: widget.entry.foodName);
    final quantity = widget.entry.quantity;
    _quantityController = TextEditingController(
      text: quantity == quantity.roundToDouble()
          ? quantity.toInt().toString()
          : quantity.toString(),
    );
    _caloriesController = TextEditingController(
      text: '${widget.entry.calories}',
    );
    _unit = _units.contains(widget.entry.unit) ? widget.entry.unit : 'serving';
  }

  @override
  void dispose() {
    _originalController.dispose();
    _nameController.dispose();
    _quantityController.dispose();
    _caloriesController.dispose();
    super.dispose();
  }

  void _save() {
    final quantity =
        double.tryParse(_quantityController.text) ?? widget.entry.quantity;
    final calories =
        int.tryParse(_caloriesController.text) ?? widget.entry.calories;
    Navigator.of(context).pop(
      widget.entry.copyWith(
        originalText: _originalController.text.trim(),
        foodName: _nameController.text.trim(),
        quantity: quantity,
        unit: _unit,
        calories: calories,
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    return SingleChildScrollView(
      padding: EdgeInsets.fromLTRB(
        md,
        xs,
        md,
        MediaQuery.viewInsetsOf(context).bottom + md,
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text('Edit food', style: theme.textTheme.titleLarge),
          const SizedBox(height: sm),
          TextField(
            controller: _originalController,
            decoration: const InputDecoration(labelText: 'Food', filled: false),
          ),
          const SizedBox(height: sm),
          TextField(
            controller: _nameController,
            decoration: const InputDecoration(
              labelText: 'Food name',
              filled: false,
            ),
          ),
          const SizedBox(height: sm),
          Row(
            children: [
              Expanded(
                child: TextField(
                  controller: _quantityController,
                  keyboardType: const TextInputType.numberWithOptions(
                    decimal: true,
                  ),
                  decoration: const InputDecoration(labelText: 'Quantity'),
                ),
              ),
              const SizedBox(width: sm),
              Expanded(
                child: DropdownButtonFormField<String>(
                  initialValue: _unit,
                  isExpanded: true,
                  decoration: const InputDecoration(labelText: 'Serving'),
                  items: _units
                      .map(
                        (unit) =>
                            DropdownMenuItem(value: unit, child: Text(unit)),
                      )
                      .toList(),
                  onChanged: (value) => setState(() => _unit = value ?? _unit),
                ),
              ),
            ],
          ),
          const SizedBox(height: sm),
          TextField(
            key: const Key('correction-calories'),
            controller: _caloriesController,
            keyboardType: TextInputType.number,
            decoration: const InputDecoration(
              labelText: 'Calories',
              suffixText: 'kcal',
            ),
          ),
          const SizedBox(height: md),
          FilledButton(
            key: const Key('correction-save'),
            onPressed: _save,
            child: const Text('Save changes'),
          ),
          const SizedBox(height: xs),
          SizedBox(
            width: double.infinity,
            child: TextButton(
              onPressed: () => Navigator.of(context).pop(),
              child: const Text('Cancel'),
            ),
          ),
        ],
      ),
    );
  }
}
