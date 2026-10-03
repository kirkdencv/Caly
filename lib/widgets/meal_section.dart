import 'dart:math' as math;

import 'package:flutter/material.dart';

import '../models/food_entry.dart';
import '../models/meal_category.dart';
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
    required this.draftController,
    required this.draftIsThinking,
    required this.draftError,
    required this.onDraftChanged,
    required this.onDraftSubmitted,
    required this.onDraftRetry,
    required this.onCaloriesTap,
    required this.onRetry,
    required this.onDelete,
  });

  final String meal;
  final List<FoodEntry> entries;
  final TextEditingController draftController;
  final bool draftIsThinking;
  final String? draftError;
  final ValueChanged<String> onDraftChanged;
  final ValueChanged<String> onDraftSubmitted;
  final VoidCallback onDraftRetry;
  final ValueChanged<FoodEntry> onCaloriesTap;
  final ValueChanged<FoodEntry> onRetry;
  final ValueChanged<FoodEntry> onDelete;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final hint = switch (meal) {
      MealCategory.breakfast => 'What did you have this morning?',
      MealCategory.lunch => 'Add lunch...',
      MealCategory.dinner => 'Add dinner...',
      _ => 'Add food or drink...',
    };

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
          Dismissible(
            key: ValueKey('dismiss-${entry.id}'),
            direction: DismissDirection.endToStart,
            onDismissed: (_) => onDelete(entry),
            background: Container(
              alignment: Alignment.centerRight,
              padding: const EdgeInsets.only(right: sm),
              decoration: BoxDecoration(
                color: theme.colorScheme.error,
                borderRadius: BorderRadius.circular(12),
              ),
              child: Icon(
                Icons.delete_outline_rounded,
                color: theme.colorScheme.onError,
                semanticLabel: 'Delete ${entry.originalText}',
              ),
            ),
            child: FoodEntryRow(
              entry: entry,
              onCaloriesTap: () => onCaloriesTap(entry),
              onRetry: () => onRetry(entry),
            ),
          ),
          const SizedBox(height: 4),
        ],
        Row(
          children: [
            Expanded(
              child: TextField(
                key: ValueKey('food-note-$meal'),
                controller: draftController,
                onChanged: onDraftChanged,
                onSubmitted: onDraftSubmitted,
                textInputAction: TextInputAction.done,
                textCapitalization: TextCapitalization.sentences,
                autocorrect: true,
                enableSuggestions: true,
                style: theme.textTheme.bodyMedium,
                decoration: InputDecoration(
                  hintText: hint,
                  hintStyle: theme.textTheme.bodyMedium?.copyWith(
                    color: theme.colorScheme.onSurfaceVariant.withValues(
                      alpha: 0.58,
                    ),
                  ),
                  border: InputBorder.none,
                  enabledBorder: InputBorder.none,
                  focusedBorder: InputBorder.none,
                  filled: false,
                  isDense: true,
                  contentPadding: const EdgeInsets.symmetric(vertical: 5),
                ),
              ),
            ),
            if (draftIsThinking)
              FoodThinkingIndicator(key: ValueKey('draft-loading-$meal'))
            else if (draftError != null)
              IconButton(
                key: ValueKey('draft-retry-$meal'),
                onPressed: onDraftRetry,
                tooltip: 'Retry',
                constraints: const BoxConstraints.tightFor(
                  width: 44,
                  height: 44,
                ),
                padding: EdgeInsets.zero,
                visualDensity: VisualDensity.compact,
                icon: Icon(
                  Icons.refresh_rounded,
                  size: 18,
                  color: theme.colorScheme.error,
                ),
              ),
          ],
        ),
        if (draftError != null) ...[
          const SizedBox(height: 2),
          Text(
            draftError!,
            key: ValueKey('draft-error-$meal'),
            style: theme.textTheme.labelSmall?.copyWith(
              color: theme.colorScheme.error,
            ),
          ),
        ],
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
    return Container(
      key: ValueKey(entry.id),
      constraints: const BoxConstraints(minHeight: 44),
      alignment: Alignment.center,
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Expanded(
                child: Text(
                  entry.originalText,
                  maxLines: 2,
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
      ),
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
      FoodEntryStatus.loading => FoodThinkingIndicator(
        key: ValueKey('loading-${entry.id}'),
      ),
      FoodEntryStatus.error => IconButton(
        key: ValueKey('retry-${entry.id}'),
        onPressed: onRetry,
        tooltip: 'Retry',
        constraints: const BoxConstraints.tightFor(width: 44, height: 44),
        padding: EdgeInsets.zero,
        visualDensity: VisualDensity.compact,
        icon: Icon(
          Icons.refresh_rounded,
          size: 18,
          color: theme.colorScheme.error,
        ),
      ),
      FoodEntryStatus.ready => Semantics(
        button: true,
        label: '${entry.calories} calories. Edit ${entry.originalText}',
        child: InkWell(
          key: ValueKey('calories-${entry.id}'),
          onTap: onCaloriesTap,
          borderRadius: BorderRadius.circular(8),
          child: ConstrainedBox(
            constraints: const BoxConstraints(minHeight: 44),
            child: Row(
              mainAxisSize: MainAxisSize.min,
              children: [
                Text(
                  '${entry.calories} kcal',
                  style: theme.textTheme.bodyMedium?.copyWith(
                    fontWeight: FontWeight.w500,
                  ),
                ),
                const SizedBox(width: 4),
                Icon(
                  Icons.edit_outlined,
                  size: 15,
                  color: theme.colorScheme.onSurfaceVariant,
                ),
              ],
            ),
          ),
        ),
      ),
    };
  }
}

/// Three gently moving dots shown while Caly interprets a note line.
class FoodThinkingIndicator extends StatefulWidget {
  const FoodThinkingIndicator({super.key});

  @override
  State<FoodThinkingIndicator> createState() => _FoodThinkingIndicatorState();
}

class _FoodThinkingIndicatorState extends State<FoodThinkingIndicator>
    with SingleTickerProviderStateMixin {
  late final AnimationController _controller;

  @override
  void initState() {
    super.initState();
    _controller = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 900),
    )..repeat();
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final color = Theme.of(context).colorScheme.onSurfaceVariant;
    return Semantics(
      label: 'Calculating calories',
      child: SizedBox(
        width: 32,
        height: 18,
        child: AnimatedBuilder(
          animation: _controller,
          builder: (context, _) {
            return Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: List.generate(3, (index) {
                final phase =
                    (_controller.value * 2 * math.pi) - (index * math.pi / 2.5);
                final lift = math.max(0.0, math.sin(phase)) * 3;
                return Transform.translate(
                  offset: Offset(0, -lift),
                  child: DecoratedBox(
                    decoration: BoxDecoration(
                      color: color,
                      shape: BoxShape.circle,
                    ),
                    child: const SizedBox.square(dimension: 5),
                  ),
                );
              }),
            );
          },
        ),
      ),
    );
  }
}
