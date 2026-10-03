import 'package:flutter/material.dart';

import '../models/food_entry.dart';
import '../theme/caly_spacing.dart';

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
    Navigator.of(context).pop(
      widget.entry.copyWith(
        originalText: _originalController.text.trim(),
        foodName: _nameController.text.trim(),
        quantity: double.parse(_quantityController.text.trim()),
        unit: _unitController.text.trim(),
        calories: int.parse(_caloriesController.text.trim()),
      ),
    );
  }

  String? _requiredText(String? value) {
    return value == null || value.trim().isEmpty ? 'Required' : null;
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
}
