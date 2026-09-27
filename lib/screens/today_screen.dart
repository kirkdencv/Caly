import 'package:final_project/widgets/meal_section.dart';
import 'package:flutter/material.dart';
import '../theme/caly_spacing.dart';


class TodayScreen extends StatefulWidget{
  const TodayScreen({super.key});

  @override
  State<TodayScreen> createState() => _TodayScreenState();
}

class _TodayScreenState extends State<TodayScreen> {
  final List<String> _breakfastFoods = [];

  void onAddFood () {
    setState(() {
      _breakfastFoods.add("1 cup of rice");
    });
  }
  @override
  Widget build(BuildContext context) {
    final caly = Theme.of(context);
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
                MealSection(meal: 'BREAKFAST', onAddFood: (){onAddFood();},),
                for(var bFood in _breakfastFoods)
                  Text(bFood, style: caly.textTheme.bodyMedium?.copyWith(color: caly.colorScheme.onSurfaceVariant))
                ,
                SizedBox(height: sm),
                MealSection(meal: 'LUNCH', onAddFood: (){onAddFood();}),
                SizedBox(height: sm),
                MealSection(meal: 'DINNER', onAddFood: (){onAddFood();}),
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

// class TodayScreen extends StatefulWidget{
//   const TodayScreen({super.key});

//   @override
//   State<TodayScreen> createState() => _TodayScreenState();
// }

// class _TodayScreenState extends State<TodayScreen>{
  
//   @override
//   Widget build(BuildContext context) {
//     return Scaffold();
//   }
// }

