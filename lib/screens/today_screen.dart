import 'package:device_preview/device_preview.dart';
import 'package:final_project/widgets/meal_section.dart';
import 'package:flutter/material.dart';
import '../theme/caly_spacing.dart';
import '../theme/caly_theme.dart';


class TodayScreen extends StatelessWidget{
  const TodayScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final caly = Theme.of(context);
      // TODO: implement build
      return Scaffold(
        appBar: AppBar(backgroundColor: caly.colorScheme.primary),
        body: SafeArea(
          child: Padding(
            padding: EdgeInsets.all(md),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text('TODAY', style: caly.textTheme.headlineSmall),
                SizedBox(height: xs),
                Text('September 25, 2026', style: caly.textTheme.labelSmall?.copyWith(color: caly.colorScheme.onSurfaceVariant)),
                SizedBox(height: sm),
                MealSection(meal: 'BREAKFAST'),
                SizedBox(height: sm),
                MealSection(meal: 'LUNCH'),
                SizedBox(height: sm),
                MealSection(meal: 'DINNER'),
                SizedBox(height: md),
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Text("Total"),
                    Text("0 kcal")
                  ],
                )
                
              ],
            )
            ))
      );
    
  }
}