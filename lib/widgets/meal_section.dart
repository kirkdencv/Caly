import 'package:device_preview/device_preview.dart';
import 'package:flutter/gestures.dart';
import 'package:flutter/material.dart';
import '../theme/caly_theme.dart';
import '../theme/caly_spacing.dart';

class MealSection extends StatelessWidget{
  final String meal;
  const MealSection({super.key, required this.meal});

  @override
  Widget build(BuildContext context) {
    final caly = Theme.of(context);
    // REUSABLE WIDGET FOR THE MEAL
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text('${meal}', style: caly.textTheme.labelSmall?.copyWith(color: caly.colorScheme.onSurface)),
        SizedBox(height: xs),
        Text('Add food...', style: caly.textTheme.bodyMedium?.copyWith(color: caly.colorScheme.onSurfaceVariant)),
      ],
    );
  }
}

