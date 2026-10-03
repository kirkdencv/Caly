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
                Container(
                  width: 92,
                  height: 72,
                  decoration: BoxDecoration(
                    color: calySoftGold,
                    borderRadius: BorderRadius.circular(28),
                    border: Border.all(color: calyOutline),
                  ),
                  child: const Icon(
                    Icons.pets_rounded,
                    size: 42,
                    color: calyInk,
                  ),
                ),
                const SizedBox(height: sm),
                Text('Caly', style: theme.textTheme.headlineSmall),
                const SizedBox(height: 4),
                Text(
                  'Write what you ate. Keep it simple.',
                  style: theme.textTheme.labelSmall?.copyWith(
                    color: theme.colorScheme.onSurfaceVariant,
                  ),
                ),
                const SizedBox(height: md),
                _TodayPreviewCard(theme: theme),
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
                const SizedBox(height: xs),
                TextButton(
                  onPressed: _isLoading
                      ? null
                      : () => ScaffoldMessenger.of(context).showSnackBar(
                          const SnackBar(
                            content: Text(
                              'Account creation is unavailable in demo mode.',
                            ),
                          ),
                        ),
                  child: const Text('Create an account'),
                ),
                const SizedBox(height: sm),
                Text(
                  'Demo login only — not secure authentication.',
                  style: theme.textTheme.labelSmall?.copyWith(
                    color: theme.colorScheme.error,
                    fontWeight: FontWeight.w600,
                  ),
                ),
                const SizedBox(height: 4),
                Text(
                  '${LocalDemoAuthService.demoEmail}  •  '
                  '${LocalDemoAuthService.demoPassword}',
                  style: theme.textTheme.labelSmall?.copyWith(
                    color: theme.colorScheme.onSurfaceVariant,
                  ),
                  textAlign: TextAlign.center,
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}

class _TodayPreviewCard extends StatelessWidget {
  const _TodayPreviewCard({required this.theme});

  final ThemeData theme;

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(sm),
      decoration: BoxDecoration(
        color: calyWhite,
        borderRadius: BorderRadius.circular(14),
        border: Border.all(color: calyOutline),
        boxShadow: const [
          BoxShadow(
            color: Color(0x0A000000),
            blurRadius: 14,
            offset: Offset(0, 5),
          ),
        ],
      ),
      child: Column(
        children: [
          Align(
            alignment: Alignment.centerLeft,
            child: Text(
              'Today',
              style: theme.textTheme.labelSmall?.copyWith(
                fontWeight: FontWeight.w700,
              ),
            ),
          ),
          const SizedBox(height: xs),
          const _PreviewRow(label: '1 cup rice', value: '200 kcal'),
          const SizedBox(height: 6),
          const _PreviewRow(label: '2 boiled eggs', value: '150 kcal'),
          const Divider(height: sm),
          const _PreviewRow(label: 'Total', value: '350 kcal', strong: true),
        ],
      ),
    );
  }
}

class _PreviewRow extends StatelessWidget {
  const _PreviewRow({
    required this.label,
    required this.value,
    this.strong = false,
  });

  final String label;
  final String value;
  final bool strong;

  @override
  Widget build(BuildContext context) {
    final style = Theme.of(context).textTheme.labelSmall?.copyWith(
      fontWeight: strong ? FontWeight.w700 : FontWeight.w400,
    );
    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceBetween,
      children: [
        Text(label, style: style),
        Text(value, style: style),
      ],
    );
  }
}
