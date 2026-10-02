import 'package:device_preview/device_preview.dart';
import 'package:flutter/material.dart';

import 'screens/app_shell_screen.dart';
import 'screens/sign_in_screen.dart';
import 'services/local_demo_auth_service.dart';
import 'services/local_storage_service.dart';
import 'theme/caly_theme.dart';

Future<void> main() async {
  WidgetsFlutterBinding.ensureInitialized();
  final localStorage = LocalStorageService();
  final authService = LocalDemoAuthService(storage: localStorage);
  var initiallySignedIn = false;

  try {
    initiallySignedIn = await authService.hasActiveSession();
  } catch (_) {
    // If local preferences are unavailable, fail closed to Sign In.
  }

  runApp(
    DevicePreview(
      enabled: true,
      builder: (context) => MyApp(
        authService: authService,
        localStorage: localStorage,
        initiallySignedIn: initiallySignedIn,
      ),
    ),
  );
}

class MyApp extends StatelessWidget {
  const MyApp({
    super.key,
    this.authService,
    this.localStorage,
    this.initiallySignedIn = false,
  });

  final LocalDemoAuthService? authService;
  final LocalStorageService? localStorage;
  final bool initiallySignedIn;

  @override
  Widget build(BuildContext context) {
    final storage =
        localStorage ?? authService?.storage ?? LocalStorageService();
    final localAuth = authService ?? LocalDemoAuthService(storage: storage);
    return MaterialApp(
      title: 'Caly',
      debugShowCheckedModeBanner: false,
      locale: DevicePreview.locale(context),
      builder: DevicePreview.appBuilder,
      theme: calyTheme,
      darkTheme: calyDarkTheme,
      themeMode: ThemeMode.system,
      home: initiallySignedIn
          ? AppShellScreen(authService: localAuth, localStorage: storage)
          : SignInScreen(authService: localAuth),
    );
  }
}
