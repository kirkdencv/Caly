import 'package:flutter_test/flutter_test.dart';

import 'package:final_project/services/local_demo_auth_service.dart';
import 'package:final_project/services/local_storage_service.dart';

class MemoryStore implements LocalKeyValueStore {
  bool? value;
  final Map<String, String> strings = {};
  final Map<String, int> integers = {};

  @override
  Future<String?> getString(String key) async => strings[key];

  @override
  Future<void> setString(String key, String newValue) async =>
      strings[key] = newValue;

  @override
  Future<int?> getInt(String key) async => integers[key];

  @override
  Future<void> setInt(String key, int newValue) async =>
      integers[key] = newValue;

  @override
  Future<bool?> getBool(String key) async => value;

  @override
  Future<void> setBool(String key, bool newValue) async => value = newValue;

  @override
  Future<void> remove(String key) async => value = null;
}

LocalDemoAuthService _authService(MemoryStore store) {
  return LocalDemoAuthService(storage: LocalStorageService(store: store));
}

void main() {
  test('only the demo credentials create a local session', () async {
    final store = MemoryStore();
    final service = _authService(store);

    expect(
      await service.signIn(email: 'wrong@example.com', password: 'wrong'),
      isFalse,
    );
    expect(await service.hasActiveSession(), isFalse);

    expect(
      await service.signIn(
        email: LocalDemoAuthService.demoEmail,
        password: LocalDemoAuthService.demoPassword,
      ),
      isTrue,
    );
    expect(await service.hasActiveSession(), isTrue);
  });

  test('email comparison is trimmed and case-insensitive', () async {
    final service = _authService(MemoryStore());

    expect(
      await service.signIn(
        email: '  CALY.USER@GMAIL.COM ',
        password: LocalDemoAuthService.demoPassword,
      ),
      isTrue,
    );
  });

  test('sign out clears the saved local session', () async {
    final store = MemoryStore()..value = true;
    final service = _authService(store);

    await service.signOut();

    expect(await service.hasActiveSession(), isFalse);
  });
}
