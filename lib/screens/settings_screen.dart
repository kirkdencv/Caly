import 'package:flutter/material.dart';

import '../services/local_demo_auth_service.dart';
import '../services/local_storage_service.dart';
import '../theme/caly_spacing.dart';
import '../theme/caly_theme.dart';
import '../widgets/large_title_header.dart';
import 'sign_in_screen.dart';

class SettingsScreen extends StatefulWidget {
  const SettingsScreen({
    super.key,
    required this.authService,
    required this.localStorageService,
    required this.dailyGoalNotifier,
  });

  final LocalDemoAuthService authService;
  final LocalStorageService localStorageService;
  final ValueNotifier<int> dailyGoalNotifier;

  @override
  State<SettingsScreen> createState() => _SettingsScreenState();
}

class _SettingsScreenState extends State<SettingsScreen> {
  int _dailyGoal = 2000;
  bool _isLoadingGoal = true;
  bool _isSigningOut = false;

  @override
  void initState() {
    super.initState();
    _dailyGoal = widget.dailyGoalNotifier.value;
    widget.dailyGoalNotifier.addListener(_handleGoalChanged);
    _loadGoal();
  }

  @override
  void dispose() {
    widget.dailyGoalNotifier.removeListener(_handleGoalChanged);
    super.dispose();
  }

  void _handleGoalChanged() {
    if (mounted) setState(() => _dailyGoal = widget.dailyGoalNotifier.value);
  }

  Future<void> _loadGoal() async {
    try {
      final savedGoal = await widget.localStorageService.loadCalorieGoal();
      if (!mounted) return;
      if (savedGoal != null) widget.dailyGoalNotifier.value = savedGoal;
      setState(() {
        _dailyGoal = savedGoal ?? widget.dailyGoalNotifier.value;
        _isLoadingGoal = false;
      });
    } catch (_) {
      if (!mounted) return;
      setState(() => _isLoadingGoal = false);
      _showMessage('Could not load the saved calorie goal.');
    }
  }

  Future<void> _editGoal() async {
    final value = await showDialog<int>(
      context: context,
      builder: (context) => _GoalDialog(initialGoal: _dailyGoal),
    );
    if (value == null || value <= 0) return;

    try {
      await widget.localStorageService.saveCalorieGoal(value);
      if (!mounted) return;
      widget.dailyGoalNotifier.value = value;
    } catch (_) {
      if (!mounted) return;
      _showMessage('Could not save the calorie goal. Try again.');
    }
  }

  void _showMessage(String message) {
    ScaffoldMessenger.of(
      context,
    ).showSnackBar(SnackBar(content: Text(message)));
  }

  Future<void> _signOut() async {
    setState(() => _isSigningOut = true);
    try {
      await widget.authService.signOut();
      if (!mounted) return;
      Navigator.of(context).pushAndRemoveUntil(
        MaterialPageRoute<void>(
          builder: (_) => SignInScreen(authService: widget.authService),
        ),
        (_) => false,
      );
    } catch (_) {
      if (!mounted) return;
      setState(() => _isSigningOut = false);
      _showMessage('Could not clear the local demo session. Try again.');
    }
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    return SafeArea(
      child: ListView(
        padding: const EdgeInsets.fromLTRB(md, md, md, lg),
        children: [
          const LargeTitleHeader(title: 'Settings'),
          const SizedBox(height: md),
          const _SettingsLabel('GOAL'),
          SettingsRow(
            label: 'Daily calorie goal',
            value: _isLoadingGoal
                ? 'Loading...'
                : '${_formatNumber(_dailyGoal)} kcal',
            onTap: _isLoadingGoal ? null : _editGoal,
          ),
          const SizedBox(height: md),
          const _SettingsLabel('PREFERENCES'),
          SettingsRow(
            label: 'Appearance',
            value: 'System',
            onTap: () => _showMessage('Caly is light-only for the MVP.'),
          ),
          const SizedBox(height: md),
          const _SettingsLabel('ACCOUNT'),
          const SettingsRow(
            label: 'Email',
            value: LocalDemoAuthService.demoEmail,
          ),
          const SettingsRow(label: 'Account type', value: 'Local demo'),
          const SizedBox(height: md),
          const _SettingsLabel('DATA'),
          SettingsRow(
            label: 'Clear food journal',
            destructive: true,
            onTap: () => _showMessage(
              'Delete individual saved days from History when editing is added.',
            ),
          ),
          const SizedBox(height: md),
          const _SettingsLabel('ABOUT'),
          SettingsRow(
            label: 'About Caly',
            value: 'Version 1.0',
            onTap: () => _showMessage(
              'Caly makes calorie logging feel like writing a note.',
            ),
          ),
          const SizedBox(height: xl),
          OutlinedButton(
            key: const Key('demo-sign-out'),
            onPressed: _isSigningOut ? null : _signOut,
            style: OutlinedButton.styleFrom(
              minimumSize: const Size.fromHeight(48),
              foregroundColor: calyError,
              side: const BorderSide(color: calyOutline),
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(12),
              ),
            ),
            child: _isSigningOut
                ? const SizedBox(
                    width: 18,
                    height: 18,
                    child: CircularProgressIndicator(strokeWidth: 2),
                  )
                : const Text(
                    'Sign out',
                    style: TextStyle(fontWeight: FontWeight.w600),
                  ),
          ),
          const SizedBox(height: md),
          Text(
            'Caly keeps logging simple: write food, see calories, continue.',
            style: theme.textTheme.labelSmall?.copyWith(
              color: theme.colorScheme.onSurfaceVariant,
            ),
          ),
        ],
      ),
    );
  }
}

class _GoalDialog extends StatefulWidget {
  const _GoalDialog({required this.initialGoal});

  final int initialGoal;

  @override
  State<_GoalDialog> createState() => _GoalDialogState();
}

class _GoalDialogState extends State<_GoalDialog> {
  late final TextEditingController _controller;

  @override
  void initState() {
    super.initState();
    _controller = TextEditingController(text: '${widget.initialGoal}');
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return AlertDialog(
      title: const Text('Daily calorie goal'),
      content: TextField(
        key: const Key('goal-input'),
        controller: _controller,
        autofocus: true,
        keyboardType: TextInputType.number,
        decoration: const InputDecoration(suffixText: 'kcal'),
      ),
      actions: [
        TextButton(
          onPressed: () => Navigator.pop(context),
          child: const Text('Cancel'),
        ),
        FilledButton(
          key: const Key('goal-save'),
          onPressed: () =>
              Navigator.pop(context, int.tryParse(_controller.text)),
          child: const Text('Save'),
        ),
      ],
    );
  }
}

String _formatNumber(int value) {
  return value.toString().replaceAllMapped(
    RegExp(r'\B(?=(\d{3})+(?!\d))'),
    (match) => ',',
  );
}

class _SettingsLabel extends StatelessWidget {
  const _SettingsLabel(this.label);

  final String label;

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 2),
      child: Text(
        label,
        style: Theme.of(context).textTheme.labelSmall?.copyWith(
          color: Theme.of(context).colorScheme.onSurfaceVariant,
        ),
      ),
    );
  }
}

class SettingsRow extends StatelessWidget {
  const SettingsRow({
    super.key,
    required this.label,
    this.value,
    this.onTap,
    this.destructive = false,
  });

  final String label;
  final String? value;
  final VoidCallback? onTap;
  final bool destructive;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    return InkWell(
      onTap: onTap,
      child: Container(
        constraints: const BoxConstraints(minHeight: 54),
        decoration: BoxDecoration(
          border: Border(bottom: BorderSide(color: theme.colorScheme.outline)),
        ),
        child: Row(
          children: [
            Expanded(
              child: Text(
                label,
                style: theme.textTheme.bodyMedium?.copyWith(
                  color: destructive ? theme.colorScheme.error : null,
                ),
              ),
            ),
            if (value != null)
              Text(
                value!,
                style: theme.textTheme.labelSmall?.copyWith(
                  color: theme.colorScheme.onSurfaceVariant,
                ),
              ),
            if (onTap != null) ...[
              const SizedBox(width: 4),
              Icon(
                Icons.chevron_right_rounded,
                size: 20,
                color: theme.colorScheme.onSurfaceVariant,
              ),
            ],
          ],
        ),
      ),
    );
  }
}
