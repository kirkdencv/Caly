import 'dart:async';

import 'package:flutter/material.dart';

import '../services/local_demo_auth_service.dart';
import '../theme/caly_spacing.dart';
import '../theme/caly_theme.dart';
import 'app_shell_screen.dart';

class SignInScreen extends StatefulWidget {
  const SignInScreen({super.key, required this.authService});

  final LocalDemoAuthService authService;

  @override
  State<SignInScreen> createState() => _SignInScreenState();
}

class _SignInScreenState extends State<SignInScreen> {
  final _formKey = GlobalKey<FormState>();
  final _emailController = TextEditingController();
  final _passwordController = TextEditingController();
  bool _obscurePassword = true;
  bool _isLoading = false;
  String? _errorMessage;

  @override
  void dispose() {
    _emailController.dispose();
    _passwordController.dispose();
    super.dispose();
  }

  Future<void> _signIn() async {
    FocusScope.of(context).unfocus();
    setState(() => _errorMessage = null);
    if (!_formKey.currentState!.validate()) return;

    setState(() => _isLoading = true);
    try {
      final matches = await widget.authService.signIn(
        email: _emailController.text,
        password: _passwordController.text,
      );
      if (!mounted) return;

      if (!matches) {
        setState(() {
          _isLoading = false;
          _errorMessage = 'Invalid demo email or password.';
        });
        return;
      }

      await Navigator.of(context).pushReplacement(
        MaterialPageRoute<void>(
          builder: (_) => AppShellScreen(
            authService: widget.authService,
            localStorage: widget.authService.storage,
          ),
        ),
      );
    } catch (_) {
      if (!mounted) return;
      setState(() {
        _isLoading = false;
        _errorMessage = 'Could not save the demo session. Try again.';
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    return Scaffold(
      body: SafeArea(
        child: SingleChildScrollView(
          padding: const EdgeInsets.fromLTRB(md, lg, md, md),
          child: Form(
            key: _formKey,
            child: Column(
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
                const SizedBox(height: md),
                TextFormField(
                  key: const Key('demo-email'),
                  controller: _emailController,
                  keyboardType: TextInputType.emailAddress,
                  textInputAction: TextInputAction.next,
                  decoration: const InputDecoration(
                    hintText: 'you@example.com',
                    prefixIcon: Icon(Icons.mail_outline_rounded, size: 20),
                  ),
                  validator: (value) => value == null || value.trim().isEmpty
                      ? 'Enter your email'
                      : null,
                ),
                const SizedBox(height: sm),
                TextFormField(
                  key: const Key('demo-password'),
                  controller: _passwordController,
                  obscureText: _obscurePassword,
                  textInputAction: TextInputAction.done,
                  onFieldSubmitted: (_) => _isLoading ? null : _signIn(),
                  decoration: InputDecoration(
                    hintText: 'Password',
                    prefixIcon: const Icon(
                      Icons.lock_outline_rounded,
                      size: 20,
                    ),
                    suffixIcon: IconButton(
                      onPressed: () {
                        setState(() => _obscurePassword = !_obscurePassword);
                      },
                      icon: Icon(
                        _obscurePassword
                            ? Icons.visibility_outlined
                            : Icons.visibility_off_outlined,
                        size: 20,
                      ),
                    ),
                  ),
                  validator: (value) => value == null || value.isEmpty
                      ? 'Enter your password'
                      : null,
                ),
                if (_errorMessage != null) ...[
                  const SizedBox(height: sm),
                  Text(
                    _errorMessage!,
                    key: const Key('demo-login-error'),
                    style: theme.textTheme.labelSmall?.copyWith(
                      color: theme.colorScheme.error,
                    ),
                    textAlign: TextAlign.center,
                  ),
                ],
                const SizedBox(height: sm),
                FilledButton(
                  key: const Key('demo-sign-in'),
                  onPressed: _isLoading ? null : _signIn,
                  child: _isLoading
                      ? const SizedBox(
                          key: Key('demo-login-loading'),
                          width: 18,
                          height: 18,
                          child: CircularProgressIndicator(strokeWidth: 2),
                        )
                      : const Text('Sign in'),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}

class _CalicoWordmark extends StatelessWidget {
  const _CalicoWordmark();

  @override
  Widget build(BuildContext context) {
    final style = Theme.of(context).textTheme.headlineSmall?.copyWith(
      fontWeight: FontWeight.w700,
      letterSpacing: 2.5,
    );
    return Text.rich(
      key: const Key('caly-wordmark'),
      TextSpan(
        children: [
          TextSpan(
            text: 'C',
            style: style?.copyWith(color: const Color(0xFF666765)),
          ),
          TextSpan(
            text: 'A',
            style: style?.copyWith(color: const Color(0xFFF2A064)),
          ),
          TextSpan(
            text: 'L',
            style: style?.copyWith(color: calyInk),
          ),
          TextSpan(
            text: 'Y',
            style: style?.copyWith(color: const Color(0xFFE99AAA)),
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
            _phase = _PreviewPhase.thinking;
            _phaseTicks = 0;
          }
          return;
        case _PreviewPhase.thinking:
          _phaseTicks++;
          if (_phaseTicks >= 12) {
            _phase = _PreviewPhase.result;
            _phaseTicks = 0;
          }
          return;
        case _PreviewPhase.result:
          _phaseTicks++;
          if (_phaseTicks >= 20) {
            _phase = _PreviewPhase.typing;
            _characterCount = 0;
            _phaseTicks = 0;
          }
          return;
      }
    });
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
