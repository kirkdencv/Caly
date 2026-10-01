import 'local_storage_service.dart';

/// Demo-only credential check. This is intentionally not secure authentication.
///
/// These credentials are shipped inside the application and can be discovered
/// by anyone. Replace this entire service with real authentication before using
/// Caly for real accounts or private data.
class LocalDemoAuthService {
  LocalDemoAuthService({LocalStorageService? storage})
    : storage = storage ?? LocalStorageService();

  static const demoEmail = 'caly.user@gmail.com';
  static const demoPassword = 'calyuser123';
  final LocalStorageService storage;

  Future<bool> hasActiveSession() async {
    return storage.loadDemoLoginSession();
  }

  Future<bool> signIn({required String email, required String password}) async {
    final matches =
        email.trim().toLowerCase() == demoEmail && password == demoPassword;
    if (!matches) return false;

    await storage.saveDemoLoginSession();
    return true;
  }

  Future<void> signOut() => storage.clearDemoLoginSession();
}
