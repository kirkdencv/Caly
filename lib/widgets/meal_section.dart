import 'package:flutter/material.dart';

import '../models/food_entry.dart';
import '../theme/caly_spacing.dart';

/// Displays one meal's entries and reports user actions back to TodayScreen.
///
/// This widget is stateless on purpose. TodayScreen owns the food lists, while
/// MealSection only renders the values it receives.
class MealSection extends StatelessWidget {
  const MealSection({
    super.key,
    required this.meal,
    required this.entries,
    required this.onAddFood,
    required this.onCaloriesTap,
    required this.onRetry,
  });

  final String meal;
  final List<FoodEntry> entries;
  final VoidCallback onAddFood;
  final ValueChanged<FoodEntry> onCaloriesTap;
  final ValueChanged<FoodEntry> onRetry;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          meal.toUpperCase(),
          style: theme.textTheme.labelSmall?.copyWith(
            color: theme.colorScheme.onSurfaceVariant,
            fontWeight: FontWeight.w500,
          ),
        ),
        const SizedBox(height: xs),
        for (final entry in entries) ...[
          FoodEntryRow(
            entry: entry,
            onCaloriesTap: () => onCaloriesTap(entry),
            onRetry: () => onRetry(entry),
          ),
          const SizedBox(height: xs),
        ],
        InkWell(
          key: ValueKey('add-food-$meal'),
          onTap: onAddFood,
          borderRadius: BorderRadius.circular(4),
          child: Padding(
            padding: const EdgeInsets.symmetric(vertical: 3),
            child: Text(
              'Add food...',
              style: theme.textTheme.bodyMedium?.copyWith(
                color: theme.colorScheme.onSurfaceVariant.withValues(
                  alpha: 0.58,
                ),
              ),
            ),
          ),
        ),
        const SizedBox(height: xs),
        Divider(height: 1, color: theme.colorScheme.outline),
      ],
    );
  }
}

class FoodEntryRow extends StatelessWidget {
  const FoodEntryRow({
    super.key,
    required this.entry,
    required this.onCaloriesTap,
    required this.onRetry,
  });

  final FoodEntry entry;
  final VoidCallback onCaloriesTap;
  final VoidCallback onRetry;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    return Column(
      key: ValueKey(entry.id),
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Row(
          children: [
            Expanded(
              child: Text(
                entry.originalText,
                overflow: TextOverflow.ellipsis,
                style: theme.textTheme.bodyMedium,
              ),
            ),
            const SizedBox(width: sm),
            _EntryStatusAction(
              entry: entry,
              onCaloriesTap: onCaloriesTap,
              onRetry: onRetry,
            ),
          ],
        ),
        if (entry.status == FoodEntryStatus.error) ...[
          const SizedBox(height: 2),
          Text(
            entry.errorMessage ?? 'Could not interpret this food.',
            key: ValueKey('error-${entry.id}'),
            style: theme.textTheme.labelSmall?.copyWith(
              color: theme.colorScheme.error,
            ),
          ),
        ],
      ],
    );
  }
}

class _EntryStatusAction extends StatelessWidget {
  const _EntryStatusAction({
    required this.entry,
    required this.onCaloriesTap,
    required this.onRetry,
  });

  final FoodEntry entry;
  final VoidCallback onCaloriesTap;
  final VoidCallback onRetry;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);

    return switch (entry.status) {
      FoodEntryStatus.loading => SizedBox(
        key: ValueKey('loading-${entry.id}'),
        width: 18,
        height: 18,
        child: const CircularProgressIndicator(strokeWidth: 2),
      ),
      FoodEntryStatus.error => TextButton.icon(
        key: ValueKey('retry-${entry.id}'),
        onPressed: onRetry,
        style: TextButton.styleFrom(
          minimumSize: Size.zero,
          padding: const EdgeInsets.symmetric(horizontal: 4, vertical: 2),
          tapTargetSize: MaterialTapTargetSize.shrinkWrap,
        ),
        icon: const Icon(Icons.refresh, size: 16),
        label: const Text('Try again'),
      ),
      FoodEntryStatus.ready => InkWell(
        key: ValueKey('calories-${entry.id}'),
        onTap: onCaloriesTap,
        borderRadius: BorderRadius.circular(6),
        child: Padding(
          padding: const EdgeInsets.symmetric(horizontal: 2, vertical: 2),
          child: Text(
            '${entry.calories} kcal',
            style: theme.textTheme.bodyMedium,
          ),
        ),
      ),
    };
  }
}
