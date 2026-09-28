import 'package:flutter/material.dart';
import '../theme/caly_spacing.dart';

class MealSection extends StatelessWidget{
  final String meal;
  final VoidCallback onAddFood;
  const MealSection({super.key, required this.meal, required this.onAddFood});


  @override
  Widget build(BuildContext context) {
    final caly = Theme.of(context);
    // REUSABLE WIDGET FOR THE MEAL
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(meal, style: caly.textTheme.labelSmall?.copyWith(color: caly.colorScheme.onSurface)),
        SizedBox(height: xs),
        InkWell(child: Text('Add food...', style: caly.textTheme.bodyMedium?.copyWith(color: caly.colorScheme.onSurfaceVariant)), onTap: onAddFood,),
      ],
    );
  }
}
