import 'dart:async';

import 'package:flutter/material.dart';

import '../theme/caly_spacing.dart';
import '../theme/caly_theme.dart';

class CalyBrandHeader extends StatelessWidget {
  const CalyBrandHeader({super.key});

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    return Column(
      children: [
        Image.asset(
          'assets/images/caly_mascot.png',
          key: const Key('caly-mascot'),
          width: 136,
          height: 136,
          fit: BoxFit.contain,
        ),
        const SizedBox(height: xs),
        const _CalicoWordmark(),
        const SizedBox(height: 4),
        Text(
          'Write what you ate.',
          style: theme.textTheme.labelSmall?.copyWith(
            color: theme.colorScheme.onSurfaceVariant,
          ),
        ),
        const SizedBox(height: md),
        const _AnimatedFoodPreview(),
      ],
    );
  }
}

class _CalicoWordmark extends StatelessWidget {
  const _CalicoWordmark();

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final isDark = theme.brightness == Brightness.dark;
    final style = theme.textTheme.headlineSmall?.copyWith(
      fontWeight: FontWeight.w700,
      letterSpacing: 2.5,
    );
    return Text.rich(
      key: const Key('caly-wordmark'),
      TextSpan(
        children: [
          TextSpan(
            text: 'C',
            style: style?.copyWith(
              color: isDark
                  ? const Color(0xFFB8B9B6)
                  : const Color(0xFF666765),
            ),
          ),
          TextSpan(
            text: 'A',
            style: style?.copyWith(
              color: isDark
                  ? const Color(0xFFFFB071)
                  : const Color(0xFFF2A064),
            ),
          ),
          TextSpan(
            text: 'L',
            style: style?.copyWith(
              color: isDark ? theme.colorScheme.onSurface : calyInk,
            ),
          ),
          TextSpan(
            text: 'Y',
            style: style?.copyWith(
              color: isDark
                  ? const Color(0xFFF2A6B8)
                  : const Color(0xFFE99AAA),
            ),
          ),
        ],
      ),
    );
  }
}

enum _PreviewPhase { typing, thinking, result }

class _AnimatedFoodPreview extends StatefulWidget {
  const _AnimatedFoodPreview();

  @override
  State<_AnimatedFoodPreview> createState() => _AnimatedFoodPreviewState();
}

class _AnimatedFoodPreviewState extends State<_AnimatedFoodPreview> {
  static const _food = 'Chicken adobo and rice';
  Timer? _timer;
  _PreviewPhase _phase = _PreviewPhase.typing;
  int _characterCount = 0;
  int _phaseTicks = 0;

  @override
  void initState() {
    super.initState();
    _timer = Timer.periodic(
      const Duration(milliseconds: 90),
      (_) => _advance(),
    );
  }

  void _advance() {
    if (!mounted) return;
    setState(() {
      switch (_phase) {
        case _PreviewPhase.typing:
          if (_characterCount < _food.length) {
            _characterCount++;
          } else {
            _moveTo(_PreviewPhase.thinking);
          }
          return;
        case _PreviewPhase.thinking:
          if (++_phaseTicks >= 12) _moveTo(_PreviewPhase.result);
          return;
        case _PreviewPhase.result:
          if (++_phaseTicks >= 20) {
            _characterCount = 0;
            _moveTo(_PreviewPhase.typing);
          }
          return;
      }
    });
  }

  void _moveTo(_PreviewPhase phase) {
    _phase = phase;
    _phaseTicks = 0;
  }

  @override
  void dispose() {
    _timer?.cancel();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final typedText = _food.substring(0, _characterCount);
    return Container(
      key: const Key('login-food-preview'),
      constraints: const BoxConstraints(minHeight: 58),
      padding: const EdgeInsets.symmetric(horizontal: sm, vertical: 12),
      decoration: BoxDecoration(
        color: theme.colorScheme.surfaceContainer,
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: theme.colorScheme.outline),
        boxShadow: [
          BoxShadow(
            color: theme.shadowColor.withValues(alpha: 0.04),
            blurRadius: 18,
            offset: const Offset(0, 6),
          ),
        ],
      ),
      child: Row(
        children: [
          Expanded(
            child: Text(
              typedText.isEmpty ? 'Start typing...' : typedText,
              key: const Key('login-preview-text'),
              style: theme.textTheme.bodyMedium?.copyWith(
                color: typedText.isEmpty
                    ? theme.colorScheme.onSurfaceVariant
                    : theme.colorScheme.onSurface,
              ),
            ),
          ),
          const SizedBox(width: sm),
          AnimatedSwitcher(
            duration: const Duration(milliseconds: 180),
            child: switch (_phase) {
              _PreviewPhase.typing => const SizedBox(width: 46),
              _PreviewPhase.thinking => Text(
                '.' * ((_phaseTicks % 3) + 1),
                key: const Key('login-preview-thinking'),
                style: theme.textTheme.bodyMedium?.copyWith(
                  color: theme.colorScheme.onSurfaceVariant,
                  fontWeight: FontWeight.w600,
                  letterSpacing: 2,
                ),
              ),
              _PreviewPhase.result => Text(
                '620 kcal',
                key: const Key('login-preview-calories'),
                style: theme.textTheme.bodyMedium?.copyWith(
                  fontWeight: FontWeight.w600,
                ),
              ),
            },
          ),
        ],
      ),
    );
  }
}
