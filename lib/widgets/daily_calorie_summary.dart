import 'package:flutter/material.dart';

import '../theme/caly_spacing.dart';
import '../utils/formatters.dart';

class DailyCalorieSummary extends StatelessWidget {
  const DailyCalorieSummary({
    super.key,
    required this.totalCalories,
    required this.dailyGoal,
  });

  final int totalCalories;
  final int dailyGoal;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final progress = dailyGoal <= 0
        ? 0.0
        : (totalCalories / dailyGoal).clamp(0.0, 1.0);

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
                  '${formatWholeNumber(totalCalories)} kcal',
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
                '${formatWholeNumber(dailyGoal)} kcal',
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
