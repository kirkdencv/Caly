import 'dart:async';

import 'package:flutter/material.dart';
import 'package:flutter/services.dart';

import '../models/daily_note.dart';
import '../models/food_entry.dart';
import '../models/meal_category.dart';
import '../services/food_api_service.dart';
import '../services/local_storage_service.dart';
import '../theme/caly_spacing.dart';
import '../utils/formatters.dart';
import '../widgets/daily_calorie_summary.dart';
import '../widgets/food_correction_sheet.dart';
import '../widgets/caly_page_body.dart';
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
  late final bool _ownsFoodApiService;
  late final LocalStorageService _localStorage;
  late final ValueNotifier<int> _dailyGoalNotifier;
  late final bool _ownsGoalNotifier;
  late final DateTime _journalDate;
  DateTime _createdAt = DateTime.now();
  bool _isLoadingStorage = true;
  String? _storageError;
  late final Map<String, _MealJournalState> _meals;

  @override
  void initState() {
    super.initState();
    _ownsFoodApiService = widget.foodApiService == null;
    _foodApiService = widget.foodApiService ?? FoodApiService();
    _localStorage = widget.localStorageService ?? LocalStorageService();
    _meals = {
      for (final meal in MealCategory.values) meal: _MealJournalState(),
    };
    _ownsGoalNotifier = widget.dailyGoalNotifier == null;
    _dailyGoalNotifier = widget.dailyGoalNotifier ?? ValueNotifier(2000);
    _journalDate = dateOnly(widget.journalDate ?? DateTime.now());
    _loadLocalData();
  }

  @override
  void dispose() {
    for (final meal in _meals.values) {
      meal.dispose();
    }
    if (_ownsFoodApiService) _foodApiService.close();
    if (_ownsGoalNotifier) _dailyGoalNotifier.dispose();
    super.dispose();
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
        for (final meal in _meals.values) {
          meal.entries.clear();
        }
        if (note != null) {
          _createdAt = note.createdAt;
          for (final entry in note.entries) {
            _entriesForMeal(entry.mealCategory).add(entry);
          }
        }
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
    for (final meal in MealCategory.values) {
      yield* _meals[meal]!.entries;
    }
  }

  int get _totalCalories =>
      _allEntries.fold(0, (sum, entry) => sum + entry.calories);

  List<FoodEntry> _entriesForMeal(String meal) => _mealState(meal).entries;

  _MealJournalState _mealState(String meal) {
    final normalized = MealCategory.normalize(meal);
    return _meals[normalized]!;
  }

  void _draftChanged(String meal, String value) {
    final state = _mealState(meal);
    state.timer?.cancel();
    final revision = ++state.revision;
    setState(() {
      state.isThinking = false;
      state.error = null;
    });
    if (value.trim().isEmpty) return;
    state.timer = Timer(
      _interpretDelay,
      () => _submitDraft(meal, value, revision),
    );
  }

  void _draftSubmitted(String meal, String value) {
    final state = _mealState(meal);
    state.timer?.cancel();
    _submitDraft(meal, value, state.revision);
  }

  Future<void> _submitDraft(
    String meal,
    String scheduledText,
    int revision,
  ) async {
    if (!mounted) return;
    final state = _mealState(meal);
    final controller = state.controller;
    final foodText = controller.text.trim();
    if (foodText.isEmpty ||
        foodText != scheduledText.trim() ||
        revision != state.revision) {
      return;
    }

    setState(() {
      state.isThinking = true;
      state.error = null;
    });

    try {
      final interpreted = await _foodApiService.interpretFood(
        text: foodText,
        meal: meal,
      );
      if (!mounted ||
          revision != state.revision ||
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
        state.revision = revision + 1;
        state.isThinking = false;
        state.error = null;
      });
      HapticFeedback.selectionClick();
      await _saveCurrentNote();
    } on FoodApiException catch (error) {
      if (!mounted ||
          revision != state.revision ||
          controller.text.trim() != foodText) {
        return;
      }
      setState(() {
        state.isThinking = false;
        state.error = error.message;
      });
    }
  }

  void _retryDraft(String meal) {
    final state = _mealState(meal);
    _submitDraft(meal, state.controller.text, state.revision);
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
    final isToday = _journalDate == dateOnly(DateTime.now());

    return SafeArea(
      child: CalyPageBody(
        child: ListView(
          padding: const EdgeInsets.fromLTRB(md, md, md, lg),
          children: [
            LargeTitleHeader(
              title: isToday ? 'Today' : 'Journal',
              subtitle: formatJournalDate(_journalDate),
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
            ValueListenableBuilder<int>(
              valueListenable: _dailyGoalNotifier,
              builder: (_, dailyGoal, _) => DailyCalorieSummary(
                totalCalories: _totalCalories,
                dailyGoal: dailyGoal,
              ),
            ),
            const SizedBox(height: lg),
            for (final meal in MealCategory.values) ...[
              _buildMealSection(meal),
              if (meal != MealCategory.dinner) const SizedBox(height: sm),
            ],
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
      ),
    );
  }

  Widget _buildMealSection(String meal) {
    final state = _mealState(meal);
    return MealSection(
      meal: meal,
      entries: state.entries,
      draftController: state.controller,
      draftIsThinking: state.isThinking,
      draftError: state.error,
      onDraftChanged: (value) => _draftChanged(meal, value),
      onDraftSubmitted: (value) => _draftSubmitted(meal, value),
      onDraftRetry: () => _retryDraft(meal),
      onCaloriesTap: _openCorrection,
      onRetry: _interpretEntry,
      onDelete: _removeEntry,
    );
  }
}

class _MealJournalState {
  final entries = <FoodEntry>[];
  final controller = TextEditingController();
  Timer? timer;
  int revision = 0;
  bool isThinking = false;
  String? error;

  void dispose() {
    timer?.cancel();
    controller.dispose();
  }
}
