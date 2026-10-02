import 'dart:async';

import 'package:flutter/material.dart';
import 'package:flutter/services.dart';

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
  static const _interpretDelay = Duration(milliseconds: 1200);

  late final FoodApiService _foodApiService;
  late final LocalStorageService _localStorage;
  late final ValueNotifier<int> _dailyGoalNotifier;
  late final bool _ownsGoalNotifier;
  late final DateTime _journalDate;
  DateTime _createdAt = DateTime.now();
  int _dailyGoal = 2000;
  bool _isLoadingStorage = true;
  String? _storageError;
  final Map<String, TextEditingController> _draftControllers = {
    'Breakfast': TextEditingController(),
    'Lunch': TextEditingController(),
    'Dinner': TextEditingController(),
  };
  final Map<String, Timer> _draftTimers = {};
  final Map<String, int> _draftRevisions = {
    'Breakfast': 0,
    'Lunch': 0,
    'Dinner': 0,
  };
  final Map<String, bool> _draftIsThinking = {
    'Breakfast': false,
    'Lunch': false,
    'Dinner': false,
  };
  final Map<String, String?> _draftErrors = {
    'Breakfast': null,
    'Lunch': null,
    'Dinner': null,
  };

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
    for (final timer in _draftTimers.values) {
      timer.cancel();
    }
    for (final controller in _draftControllers.values) {
      controller.dispose();
    }
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
    try {
      final entries = _allEntries.toList();
      if (entries.isEmpty) {
        await _localStorage.deleteDailyNote(_journalDate);
      } else {
        await _localStorage.saveDailyNote(
          DailyNote.fromEntries(
            date: _journalDate,
            entries: entries,
            createdAt: _createdAt,
          ),
        );
      }
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

  void _draftChanged(String meal, String value) {
    _draftTimers.remove(meal)?.cancel();
    final revision = _draftRevisions[meal]! + 1;
    _draftRevisions[meal] = revision;
    setState(() {
      _draftIsThinking[meal] = false;
      _draftErrors[meal] = null;
    });
    if (value.trim().isEmpty) return;
    _draftTimers[meal] = Timer(
      _interpretDelay,
      () => _submitDraft(meal, value, revision),
    );
  }

  void _draftSubmitted(String meal, String value) {
    _draftTimers.remove(meal)?.cancel();
    _submitDraft(meal, value, _draftRevisions[meal]!);
  }

  Future<void> _submitDraft(
    String meal,
    String scheduledText,
    int revision,
  ) async {
    if (!mounted) return;
    final controller = _draftControllers[meal]!;
    final foodText = controller.text.trim();
    if (foodText.isEmpty ||
        foodText != scheduledText.trim() ||
        revision != _draftRevisions[meal]) {
      return;
    }

    setState(() {
      _draftIsThinking[meal] = true;
      _draftErrors[meal] = null;
    });

    try {
      final interpreted = await _foodApiService.interpretFood(
        text: foodText,
        meal: meal,
      );
      if (!mounted ||
          revision != _draftRevisions[meal] ||
          controller.text.trim() != foodText) {
        return;
      }

      final entry = interpreted.copyWith(
        id: '${DateTime.now().microsecondsSinceEpoch}',
        mealCategory: meal,
        status: FoodEntryStatus.ready,
        clearErrorMessage: true,
      );
      setState(() {
        _entriesForMeal(meal).add(entry);
        controller.clear();
        _draftRevisions[meal] = revision + 1;
        _draftIsThinking[meal] = false;
        _draftErrors[meal] = null;
      });
      HapticFeedback.selectionClick();
      await _saveCurrentNote();
    } on FoodApiException catch (error) {
      if (!mounted ||
          revision != _draftRevisions[meal] ||
          controller.text.trim() != foodText) {
        return;
      }
      setState(() {
        _draftIsThinking[meal] = false;
        _draftErrors[meal] = error.message;
      });
    }
  }

  void _retryDraft(String meal) {
    final text = _draftControllers[meal]!.text;
    _submitDraft(meal, text, _draftRevisions[meal]!);
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

  Future<void> _removeEntry(FoodEntry entry) async {
    final entries = _entriesForMeal(entry.mealCategory);
    final index = entries.indexWhere((item) => item.id == entry.id);
    if (index == -1) return;

    setState(() => entries.removeAt(index));
    HapticFeedback.lightImpact();
    await _saveCurrentNote();
    if (!mounted) return;

    ScaffoldMessenger.of(context)
      ..hideCurrentSnackBar()
      ..showSnackBar(
        SnackBar(
          content: Text('${entry.originalText} deleted'),
          action: SnackBarAction(
            label: 'Undo',
            onPressed: () => _restoreEntry(entry, index),
          ),
        ),
      );
  }

  Future<void> _restoreEntry(FoodEntry entry, int originalIndex) async {
    final entries = _entriesForMeal(entry.mealCategory);
    if (entries.any((item) => item.id == entry.id)) return;
    final index = originalIndex.clamp(0, entries.length);
    setState(() => entries.insert(index, entry));
    await _saveCurrentNote();
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
          _DailySummary(
            totalCalories: _totalCalories,
            dailyGoal: _dailyGoal,
            progress: progress,
          ),
          const SizedBox(height: lg),
          MealSection(
            meal: 'Breakfast',
            entries: _breakfastEntries,
            draftController: _draftControllers['Breakfast']!,
            draftIsThinking: _draftIsThinking['Breakfast']!,
            draftError: _draftErrors['Breakfast'],
            onDraftChanged: (value) => _draftChanged('Breakfast', value),
            onDraftSubmitted: (value) => _draftSubmitted('Breakfast', value),
            onDraftRetry: () => _retryDraft('Breakfast'),
            onCaloriesTap: _openCorrection,
            onRetry: _interpretEntry,
            onDelete: _removeEntry,
          ),
          const SizedBox(height: sm),
          MealSection(
            meal: 'Lunch',
            entries: _lunchEntries,
            draftController: _draftControllers['Lunch']!,
            draftIsThinking: _draftIsThinking['Lunch']!,
            draftError: _draftErrors['Lunch'],
            onDraftChanged: (value) => _draftChanged('Lunch', value),
            onDraftSubmitted: (value) => _draftSubmitted('Lunch', value),
            onDraftRetry: () => _retryDraft('Lunch'),
            onCaloriesTap: _openCorrection,
            onRetry: _interpretEntry,
            onDelete: _removeEntry,
          ),
          const SizedBox(height: sm),
          MealSection(
            meal: 'Dinner',
            entries: _dinnerEntries,
            draftController: _draftControllers['Dinner']!,
            draftIsThinking: _draftIsThinking['Dinner']!,
            draftError: _draftErrors['Dinner'],
            onDraftChanged: (value) => _draftChanged('Dinner', value),
            onDraftSubmitted: (value) => _draftSubmitted('Dinner', value),
            onDraftRetry: () => _retryDraft('Dinner'),
            onCaloriesTap: _openCorrection,
            onRetry: _interpretEntry,
            onDelete: _removeEntry,
          ),
          const SizedBox(height: md),
          Row(
            children: [
              Icon(
                Icons.info_outline_rounded,
                size: 14,
                color: theme.colorScheme.onSurfaceVariant,
              ),
              const SizedBox(width: 5),
              Expanded(
                child: Text(
                  'Calories are estimates and may vary.',
                  textAlign: TextAlign.center,
                  style: theme.textTheme.labelSmall?.copyWith(
                    color: theme.colorScheme.onSurfaceVariant,
                  ),
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }
}

class _DailySummary extends StatelessWidget {
  const _DailySummary({
    required this.totalCalories,
    required this.dailyGoal,
    required this.progress,
  });

  final int totalCalories;
  final int dailyGoal;
  final double progress;

  String _formatNumber(int value) {
    return value.toString().replaceAllMapped(
      RegExp(r'\B(?=(\d{3})+(?!\d))'),
      (match) => ',',
    );
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    return Container(
      padding: const EdgeInsets.all(sm),
      decoration: BoxDecoration(
        color: theme.colorScheme.surfaceContainer,
        borderRadius: BorderRadius.circular(18),
        border: Border.all(color: theme.colorScheme.outline),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            'Daily calories',
            style: theme.textTheme.labelSmall?.copyWith(
              color: theme.colorScheme.onSurfaceVariant,
              fontWeight: FontWeight.w500,
            ),
          ),
          const SizedBox(height: 4),
          Row(
            crossAxisAlignment: CrossAxisAlignment.end,
            children: [
              Expanded(
                child: Text(
                  '${_formatNumber(totalCalories)} kcal',
                  key: const Key('daily-total'),
                  style: theme.textTheme.titleLarge,
                ),
              ),
              Text(
                'of ',
                style: theme.textTheme.labelSmall?.copyWith(
                  color: theme.colorScheme.onSurfaceVariant,
                ),
              ),
              Text(
                '${_formatNumber(dailyGoal)} kcal',
                key: const Key('daily-goal'),
                style: theme.textTheme.labelSmall?.copyWith(
                  color: theme.colorScheme.onSurfaceVariant,
                ),
              ),
            ],
          ),
          const SizedBox(height: 12),
          ClipRRect(
            borderRadius: BorderRadius.circular(99),
            child: LinearProgressIndicator(
              minHeight: 7,
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

class FoodCorrectionSheet extends StatefulWidget {
  const FoodCorrectionSheet({super.key, required this.entry});

  final FoodEntry entry;

  @override
  State<FoodCorrectionSheet> createState() => _FoodCorrectionSheetState();
}

class _FoodCorrectionSheetState extends State<FoodCorrectionSheet> {
  final _formKey = GlobalKey<FormState>();
  late final TextEditingController _originalController;
  late final TextEditingController _nameController;
  late final TextEditingController _quantityController;
  late final TextEditingController _unitController;
  late final TextEditingController _caloriesController;

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
    _unitController = TextEditingController(text: widget.entry.unit);
    _caloriesController = TextEditingController(
      text: '${widget.entry.calories}',
    );
  }

  @override
  void dispose() {
    _originalController.dispose();
    _nameController.dispose();
    _quantityController.dispose();
    _unitController.dispose();
    _caloriesController.dispose();
    super.dispose();
  }

  void _save() {
    if (!_formKey.currentState!.validate()) return;
    final quantity = double.parse(_quantityController.text.trim());
    final calories = int.parse(_caloriesController.text.trim());
    Navigator.of(context).pop(
      widget.entry.copyWith(
        originalText: _originalController.text.trim(),
        foodName: _nameController.text.trim(),
        quantity: quantity,
        unit: _unitController.text.trim(),
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
      child: Form(
        key: _formKey,
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text('Edit food', style: theme.textTheme.titleLarge),
            const SizedBox(height: sm),
            TextFormField(
              controller: _originalController,
              decoration: const InputDecoration(
                labelText: 'Food',
                filled: false,
              ),
              validator: _requiredText,
            ),
            const SizedBox(height: sm),
            TextFormField(
              controller: _nameController,
              decoration: const InputDecoration(
                labelText: 'Food name',
                filled: false,
              ),
              validator: _requiredText,
            ),
            const SizedBox(height: sm),
            Row(
              children: [
                Expanded(
                  child: TextFormField(
                    controller: _quantityController,
                    keyboardType: const TextInputType.numberWithOptions(
                      decimal: true,
                    ),
                    decoration: const InputDecoration(labelText: 'Quantity'),
                    validator: (value) {
                      final quantity = double.tryParse(value?.trim() ?? '');
                      return quantity == null || quantity <= 0
                          ? 'Enter a valid amount'
                          : null;
                    },
                  ),
                ),
                const SizedBox(width: sm),
                Expanded(
                  child: TextFormField(
                    key: const Key('correction-unit'),
                    controller: _unitController,
                    textCapitalization: TextCapitalization.none,
                    decoration: const InputDecoration(labelText: 'Unit'),
                    validator: _requiredText,
                  ),
                ),
              ],
            ),
            const SizedBox(height: sm),
            TextFormField(
              key: const Key('correction-calories'),
              controller: _caloriesController,
              keyboardType: TextInputType.number,
              decoration: const InputDecoration(
                labelText: 'Calories',
                suffixText: 'kcal',
              ),
              validator: (value) {
                final calories = int.tryParse(value?.trim() ?? '');
                return calories == null || calories < 0
                    ? 'Enter valid calories'
                    : null;
              },
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
      ),
    );
  }

  String? _requiredText(String? value) {
    return value == null || value.trim().isEmpty ? 'Required' : null;
  }
}
