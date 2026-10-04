import 'dart:async';
import 'dart:convert';

import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:http/http.dart' as http;
import 'package:http/testing.dart';

import 'package:final_project/main.dart';
import 'package:final_project/models/daily_note.dart';
import 'package:final_project/models/food_entry.dart';
import 'package:final_project/screens/app_shell_screen.dart';
import 'package:final_project/screens/today_screen.dart';
import 'package:final_project/services/food_api_service.dart';
import 'package:final_project/services/local_demo_auth_service.dart';
import 'package:final_project/services/local_storage_service.dart';
import 'package:final_project/theme/caly_theme.dart';
import 'package:final_project/widgets/caly_brand_header.dart';
import 'package:final_project/widgets/meal_section.dart';

class MemoryDemoSessionStore implements LocalKeyValueStore {
  bool? value;
  Completer<void>? pendingWrite;
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
  Future<void> setBool(String key, bool newValue) async {
    if (pendingWrite case final pending?) await pending.future;
    value = newValue;
  }

  @override
  Future<void> remove(String key) async => value = null;
}

LocalDemoAuthService _authService(MemoryDemoSessionStore store) {
  return LocalDemoAuthService(storage: LocalStorageService(store: store));
}

FoodApiService _successfulFoodService({int calories = 90}) {
  return FoodApiService(
    client: MockClient((request) async {
      final body = jsonDecode(request.body) as Map<String, dynamic>;
      return http.Response(
        jsonEncode({
          'originalText': body['text'],
          'foodName': 'Greek yogurt, plain',
          'quantity': 1,
          'unit': 'serving',
          'calories': calories,
          'mealCategory': body['meal'],
        }),
        200,
      );
    }),
  );
}

Future<LocalStorageService> _seededLocalStorage() async {
  final storage = LocalStorageService(store: MemoryDemoSessionStore());
  final entries = <FoodEntry>[
    const FoodEntry(
      id: 'breakfast-rice',
      originalText: '1 cup rice',
      foodName: 'White rice, cooked',
      quantity: 1,
      unit: 'cup',
      calories: 200,
      mealCategory: 'Breakfast',
    ),
    const FoodEntry(
      id: 'breakfast-eggs',
      originalText: '2 boiled eggs',
      foodName: 'Eggs, boiled',
      quantity: 2,
      unit: 'pieces',
      calories: 150,
      mealCategory: 'Breakfast',
    ),
    const FoodEntry(
      id: 'breakfast-coffee',
      originalText: 'Iced coffee',
      foodName: 'Iced coffee',
      quantity: 1,
      unit: 'glass',
      calories: 120,
      mealCategory: 'Breakfast',
    ),
    const FoodEntry(
      id: 'lunch-adobo',
      originalText: 'Chicken adobo + 1 cup rice',
      foodName: 'Chicken adobo with rice',
      quantity: 1,
      unit: 'serving',
      calories: 520,
      mealCategory: 'Lunch',
    ),
    const FoodEntry(
      id: 'lunch-banana',
      originalText: '1 banana',
      foodName: 'Banana',
      quantity: 1,
      unit: 'piece',
      calories: 105,
      mealCategory: 'Lunch',
    ),
    const FoodEntry(
      id: 'dinner-tilapia',
      originalText: 'Grilled tilapia',
      foodName: 'Tilapia, grilled',
      quantity: 1,
      unit: 'serving',
      calories: 260,
      mealCategory: 'Dinner',
    ),
    const FoodEntry(
      id: 'dinner-rice',
      originalText: '1/2 cup rice',
      foodName: 'White rice, cooked',
      quantity: 0.5,
      unit: 'cup',
      calories: 100,
      mealCategory: 'Dinner',
    ),
  ];
  final timestamp = DateTime(2026, 9, 20, 8);
  await storage.saveDailyNote(
    DailyNote.fromEntries(
      date: DateTime.now(),
      entries: entries,
      createdAt: timestamp,
      updatedAt: timestamp,
    ),
  );
  return storage;
}

Future<void> _pumpToday(
  WidgetTester tester, {
  FoodApiService? foodApiService,
  LocalStorageService? localStorageService,
}) async {
  tester.view.physicalSize = const Size(390, 844);
  tester.view.devicePixelRatio = 1;
  addTearDown(tester.view.resetPhysicalSize);
  addTearDown(tester.view.resetDevicePixelRatio);

  final storage = localStorageService ?? await _seededLocalStorage();
  await tester.pumpWidget(
    MaterialApp(
      theme: calyTheme,
      home: Scaffold(
        body: TodayScreen(
          foodApiService: foodApiService ?? _successfulFoodService(),
          localStorageService: storage,
        ),
      ),
    ),
  );
  await tester.pumpAndSettle();
}

void main() {
  testWidgets('mockup journey opens the Today food note', (tester) async {
    final authService = _authService(MemoryDemoSessionStore());
    await tester.pumpWidget(MyApp(authService: authService));

    expect(find.byKey(const Key('caly-mascot')), findsOneWidget);
    expect(find.byKey(const Key('caly-wordmark')), findsOneWidget);
    expect(find.text('Sign in'), findsOneWidget);
    expect(find.text('Create an account'), findsNothing);
    expect(
      find.text('Demo login only — not secure authentication.'),
      findsNothing,
    );
    expect(find.text(LocalDemoAuthService.demoEmail), findsNothing);
    expect(find.text(LocalDemoAuthService.demoPassword), findsNothing);

    await tester.enterText(
      find.byKey(const Key('demo-email')),
      LocalDemoAuthService.demoEmail,
    );
    await tester.enterText(
      find.byKey(const Key('demo-password')),
      LocalDemoAuthService.demoPassword,
    );
    await tester.tap(find.byKey(const Key('demo-sign-in')));
    await tester.pumpAndSettle();

    expect(find.text('Today'), findsWidgets);
    expect(find.text('BREAKFAST'), findsOneWidget);
    await tester.drag(find.byType(Scrollable).first, const Offset(0, -500));
    await tester.pumpAndSettle();
    expect(find.text('0 kcal'), findsOneWidget);
    expect(find.byIcon(Icons.history_outlined), findsOneWidget);
    expect(find.byIcon(Icons.settings_outlined), findsOneWidget);
  });

  testWidgets('login preview loops through typing, thinking, and calories', (
    tester,
  ) async {
    await tester.pumpWidget(
      MyApp(authService: _authService(MemoryDemoSessionStore())),
    );

    expect(find.byKey(const Key('login-food-preview')), findsOneWidget);
    expect(find.byKey(const Key('login-preview-calories')), findsNothing);

    await tester.pump(const Duration(milliseconds: 2200));
    expect(find.byKey(const Key('login-preview-thinking')), findsOneWidget);

    await tester.pump(const Duration(milliseconds: 1200));
    expect(find.byKey(const Key('login-preview-calories')), findsOneWidget);
    expect(find.text('620 kcal'), findsOneWidget);
  });

  testWidgets('calico wordmark stays visible in dark mode', (tester) async {
    await tester.pumpWidget(
      MaterialApp(
        theme: calyTheme,
        darkTheme: calyDarkTheme,
        themeMode: ThemeMode.dark,
        home: const Scaffold(body: CalyBrandHeader()),
      ),
    );

    final wordmark = tester.widget<Text>(
      find.byKey(const Key('caly-wordmark')),
    );
    final rootSpan = wordmark.textSpan! as TextSpan;
    final spans = rootSpan.children!.cast<TextSpan>();

    expect(spans[0].style?.color, const Color(0xFFB8B9B6));
    expect(spans[1].style?.color, const Color(0xFFFFB071));
    expect(spans[2].style?.color, const Color(0xFFF4F1EA));
    expect(spans[3].style?.color, const Color(0xFFF2A6B8));

    await tester.pumpWidget(const SizedBox.shrink());
  });

  testWidgets('empty food input is not submitted', (tester) async {
    var requestCount = 0;
    final service = FoodApiService(
      client: MockClient((_) async {
        requestCount++;
        return http.Response('{}', 200);
      }),
    );
    await _pumpToday(tester, foodApiService: service);

    final originalLunchCount = tester
        .widgetList<MealSection>(find.byType(MealSection))
        .singleWhere((section) => section.meal == 'Lunch')
        .entries
        .length;

    await tester.enterText(
      find.byKey(const ValueKey('food-note-Lunch')),
      '   ',
    );
    await tester.pump(const Duration(seconds: 1));

    expect(requestCount, 0);
    expect(
      tester
          .widgetList<MealSection>(find.byType(MealSection))
          .singleWhere((section) => section.meal == 'Lunch')
          .entries,
      hasLength(originalLunchCount),
    );
  });

  testWidgets('adding food updates only the selected meal and total', (
    tester,
  ) async {
    final storage = await _seededLocalStorage();
    await _pumpToday(tester, localStorageService: storage);

    await tester.enterText(
      find.byKey(const ValueKey('food-note-Lunch')),
      'Greek yogurt',
    );
    await tester.pump(const Duration(milliseconds: 1300));
    await tester.pumpAndSettle();

    final mealSections = tester
        .widgetList<MealSection>(find.byType(MealSection))
        .toList();
    final breakfast = mealSections.singleWhere(
      (section) => section.meal == 'Breakfast',
    );
    final lunch = mealSections.singleWhere(
      (section) => section.meal == 'Lunch',
    );
    final dinner = mealSections.singleWhere(
      (section) => section.meal == 'Dinner',
    );

    expect(
      lunch.entries.any((entry) => entry.originalText == 'Greek yogurt'),
      isTrue,
    );
    expect(
      breakfast.entries.any((entry) => entry.originalText == 'Greek yogurt'),
      isFalse,
    );
    expect(
      dinner.entries.any((entry) => entry.originalText == 'Greek yogurt'),
      isFalse,
    );

    await tester.drag(find.byType(ListView), const Offset(0, -500));
    await tester.pumpAndSettle();
    expect(find.text('1,545 kcal'), findsOneWidget);

    final saved = await storage.loadDailyNote(DateTime.now());
    expect(
      saved!.entries.any((entry) => entry.originalText == 'Greek yogurt'),
      isTrue,
    );
    expect(saved.totalCalories, 1545);
  });

  testWidgets('correcting calories updates the row and daily total', (
    tester,
  ) async {
    final storage = await _seededLocalStorage();
    await _pumpToday(tester, localStorageService: storage);

    await tester.tap(find.byKey(const ValueKey('calories-breakfast-rice')));
    await tester.pumpAndSettle();
    await tester.enterText(find.byKey(const Key('correction-calories')), '180');
    await tester.enterText(find.byKey(const Key('correction-unit')), 'bowl');
    await tester.tap(find.byKey(const Key('correction-save')));
    await tester.pumpAndSettle();

    expect(find.text('180 kcal'), findsOneWidget);
    await tester.drag(find.byType(ListView), const Offset(0, -500));
    await tester.pumpAndSettle();
    expect(find.text('1,435 kcal'), findsOneWidget);

    final saved = await storage.loadDailyNote(DateTime.now());
    expect(
      saved!.entries
          .singleWhere((entry) => entry.id == 'breakfast-rice')
          .calories,
      180,
    );
    expect(
      saved.entries.singleWhere((entry) => entry.id == 'breakfast-rice').unit,
      'bowl',
    );
    expect(saved.totalCalories, 1435);
  });

  testWidgets('cancelling correction leaves the entry unchanged', (
    tester,
  ) async {
    final storage = await _seededLocalStorage();
    await _pumpToday(tester, localStorageService: storage);

    await tester.tap(find.byKey(const ValueKey('calories-breakfast-rice')));
    await tester.pumpAndSettle();
    await tester.enterText(find.byKey(const Key('correction-calories')), '999');
    await tester.tap(find.text('Cancel'));
    await tester.pumpAndSettle();

    expect(find.text('200 kcal'), findsOneWidget);
    expect(find.text('999 kcal'), findsNothing);

    final saved = await storage.loadDailyNote(DateTime.now());
    final rice = saved!.entries.singleWhere(
      (entry) => entry.id == 'breakfast-rice',
    );
    expect(rice.calories, 200);
    expect(saved.totalCalories, 1455);
  });

  testWidgets('deleting a food line removes its calories and updates storage', (
    tester,
  ) async {
    final storage = await _seededLocalStorage();
    await _pumpToday(tester, localStorageService: storage);

    await tester.drag(
      find.byKey(const ValueKey('dismiss-breakfast-rice')),
      const Offset(-500, 0),
    );
    await tester.pumpAndSettle();

    expect(find.text('1 cup rice'), findsNothing);
    expect(find.text('200 kcal'), findsNothing);
    await tester.drag(find.byType(ListView), const Offset(0, -500));
    await tester.pumpAndSettle();
    expect(find.text('1,255 kcal'), findsOneWidget);

    final saved = await storage.loadDailyNote(DateTime.now());
    expect(saved, isNotNull);
    expect(
      saved!.entries.any((entry) => entry.id == 'breakfast-rice'),
      isFalse,
    );
    expect(saved.totalCalories, 1255);
  });

  testWidgets('a deleted food line can be restored with Undo', (tester) async {
    final storage = await _seededLocalStorage();
    await _pumpToday(tester, localStorageService: storage);

    await tester.drag(
      find.byKey(const ValueKey('dismiss-breakfast-rice')),
      const Offset(-500, 0),
    );
    await tester.pump();
    await tester.pump(const Duration(milliseconds: 500));

    expect(find.text('1 cup rice'), findsNothing);
    expect(find.text('Undo'), findsOneWidget);

    tester.widget<SnackBarAction>(find.byType(SnackBarAction)).onPressed();
    await tester.pumpAndSettle();

    expect(find.text('1 cup rice'), findsOneWidget);
    expect(find.text('1,455 kcal'), findsOneWidget);
    final saved = await storage.loadDailyNote(DateTime.now());
    expect(saved!.entries.any((entry) => entry.id == 'breakfast-rice'), isTrue);
  });

  testWidgets('an affected row shows loading until interpretation completes', (
    tester,
  ) async {
    final response = Completer<http.Response>();
    final service = FoodApiService(client: MockClient((_) => response.future));
    await _pumpToday(tester, foodApiService: service);

    await tester.enterText(
      find.byKey(const ValueKey('food-note-Lunch')),
      'Greek yogurt',
    );
    await tester.pump(const Duration(milliseconds: 1300));
    await tester.pump();

    expect(find.text('Greek yogurt'), findsOneWidget);
    expect(
      tester
          .widget<TextField>(find.byKey(const ValueKey('food-note-Lunch')))
          .controller!
          .text,
      'Greek yogurt',
    );
    expect(find.byType(FoodThinkingIndicator), findsOneWidget);

    response.complete(
      http.Response(
        jsonEncode({
          'originalText': 'Greek yogurt',
          'foodName': 'Greek yogurt, plain',
          'quantity': 1,
          'unit': 'serving',
          'calories': 90,
          'mealCategory': 'lunch',
        }),
        200,
      ),
    );
    await tester.pumpAndSettle();

    expect(find.byType(FoodThinkingIndicator), findsNothing);
    expect(find.text('90 kcal'), findsOneWidget);
  });

  testWidgets('resuming typing ignores an outdated interpretation', (
    tester,
  ) async {
    final firstResponse = Completer<http.Response>();
    final secondResponse = Completer<http.Response>();
    var callCount = 0;
    final service = FoodApiService(
      client: MockClient((_) {
        callCount++;
        return callCount == 1 ? firstResponse.future : secondResponse.future;
      }),
    );
    await _pumpToday(tester, foodApiService: service);

    final field = find.byKey(const ValueKey('food-note-Lunch'));
    await tester.enterText(field, 'Chicken');
    await tester.pump(const Duration(milliseconds: 1300));

    expect(callCount, 1);
    expect(find.byKey(const ValueKey('draft-loading-Lunch')), findsOneWidget);
    expect(tester.widget<TextField>(field).controller!.text, 'Chicken');

    await tester.enterText(field, 'Chicken adobo');
    await tester.pump();

    expect(find.byKey(const ValueKey('draft-loading-Lunch')), findsNothing);

    firstResponse.complete(
      http.Response(
        jsonEncode({
          'originalText': 'Chicken',
          'foodName': 'Chicken',
          'quantity': 1,
          'unit': 'serving',
          'calories': 200,
          'mealCategory': 'lunch',
        }),
        200,
      ),
    );
    await tester.pump();

    final lunchAfterStaleResponse = tester
        .widgetList<MealSection>(find.byType(MealSection))
        .singleWhere((section) => section.meal == 'Lunch');
    expect(
      lunchAfterStaleResponse.entries.any(
        (entry) => entry.originalText == 'Chicken',
      ),
      isFalse,
    );
    expect(tester.widget<TextField>(field).controller!.text, 'Chicken adobo');

    await tester.pump(const Duration(milliseconds: 1300));

    expect(callCount, 2);
    expect(find.byKey(const ValueKey('draft-loading-Lunch')), findsOneWidget);

    secondResponse.complete(
      http.Response(
        jsonEncode({
          'originalText': 'Chicken adobo',
          'foodName': 'Chicken adobo',
          'quantity': 1,
          'unit': 'serving',
          'calories': 350,
          'mealCategory': 'lunch',
        }),
        200,
      ),
    );
    await tester.pumpAndSettle();

    expect(find.text('Chicken adobo'), findsOneWidget);
    expect(find.text('350 kcal'), findsOneWidget);
    expect(tester.widget<TextField>(field).controller!.text, isEmpty);
  });

  testWidgets('failed interpretation preserves text and can be retried', (
    tester,
  ) async {
    var callCount = 0;
    final service = FoodApiService(
      client: MockClient((request) async {
        callCount++;
        if (callCount == 1) {
          return http.Response(
            jsonEncode({'detail': 'Food service is temporarily unavailable.'}),
            503,
          );
        }
        return http.Response(
          jsonEncode({
            'originalText': 'Greek yogurt',
            'foodName': 'Greek yogurt, plain',
            'quantity': 1,
            'unit': 'serving',
            'calories': 90,
            'mealCategory': 'lunch',
          }),
          200,
        );
      }),
    );
    await _pumpToday(tester, foodApiService: service);

    await tester.enterText(
      find.byKey(const ValueKey('food-note-Lunch')),
      'Greek yogurt',
    );
    await tester.pump(const Duration(milliseconds: 1300));
    await tester.pumpAndSettle();

    expect(find.text('Greek yogurt'), findsOneWidget);
    expect(
      find.text('Food service is temporarily unavailable.'),
      findsOneWidget,
    );
    expect(find.byTooltip('Retry'), findsOneWidget);

    await tester.tap(find.byTooltip('Retry'));
    await tester.pumpAndSettle();

    expect(callCount, 2);
    expect(find.byTooltip('Retry'), findsNothing);
    expect(find.text('90 kcal'), findsOneWidget);
  });

  testWidgets('demo login validates both required fields', (tester) async {
    final authService = _authService(MemoryDemoSessionStore());
    await tester.pumpWidget(MyApp(authService: authService));

    await tester.tap(find.byKey(const Key('demo-sign-in')));
    await tester.pump();

    expect(find.text('Enter your email'), findsOneWidget);
    expect(find.text('Enter your password'), findsOneWidget);
    expect(find.byType(AppShellScreen), findsNothing);
  });

  testWidgets('invalid demo credentials show an error and stay signed out', (
    tester,
  ) async {
    final store = MemoryDemoSessionStore();
    final authService = _authService(store);
    await tester.pumpWidget(MyApp(authService: authService));

    await tester.enterText(
      find.byKey(const Key('demo-email')),
      'wrong@example.com',
    );
    await tester.enterText(
      find.byKey(const Key('demo-password')),
      'wrong-password',
    );
    await tester.tap(find.byKey(const Key('demo-sign-in')));
    await tester.pump();
    await tester.pump(const Duration(milliseconds: 300));

    expect(find.text('Invalid demo email or password.'), findsOneWidget);
    expect(find.byType(AppShellScreen), findsNothing);
    expect(store.value, isNull);
  });

  testWidgets('valid demo login shows loading before opening the app', (
    tester,
  ) async {
    final store = MemoryDemoSessionStore()..pendingWrite = Completer<void>();
    final authService = _authService(store);
    await tester.pumpWidget(MyApp(authService: authService));

    await tester.enterText(
      find.byKey(const Key('demo-email')),
      LocalDemoAuthService.demoEmail,
    );
    await tester.enterText(
      find.byKey(const Key('demo-password')),
      LocalDemoAuthService.demoPassword,
    );
    await tester.tap(find.byKey(const Key('demo-sign-in')));
    await tester.pump();

    expect(find.byKey(const Key('demo-login-loading')), findsOneWidget);
    expect(find.byType(AppShellScreen), findsNothing);

    store.pendingWrite!.complete();
    await tester.pumpAndSettle();

    expect(find.byType(AppShellScreen), findsOneWidget);
    expect(store.value, isTrue);
  });

  testWidgets('saved session opens the app and sign out returns to login', (
    tester,
  ) async {
    final store = MemoryDemoSessionStore()..value = true;
    final authService = _authService(store);
    await tester.pumpWidget(
      MyApp(authService: authService, initiallySignedIn: true),
    );

    expect(find.byType(AppShellScreen), findsOneWidget);
    await tester.tap(find.byIcon(Icons.settings_outlined));
    await tester.pumpAndSettle();

    expect(find.text(LocalDemoAuthService.demoEmail), findsOneWidget);
    expect(find.text('Local demo'), findsOneWidget);
    await tester.scrollUntilVisible(
      find.byKey(const Key('demo-sign-out')),
      250,
      scrollable: find.byType(Scrollable).first,
    );
    await tester.tap(find.byKey(const Key('demo-sign-out')));
    await tester.pump();
    await tester.pump(const Duration(milliseconds: 800));

    expect(store.value, isNull);
    expect(find.byKey(const Key('demo-sign-in')), findsOneWidget);
    expect(find.byType(AppShellScreen), findsNothing);
  });

  testWidgets('saved calorie goal loads, updates, and reaches Today', (
    tester,
  ) async {
    final store = MemoryDemoSessionStore()..value = true;
    final storage = LocalStorageService(store: store);
    await storage.saveCalorieGoal(2500);
    final authService = LocalDemoAuthService(storage: storage);
    await tester.pumpWidget(
      MyApp(
        authService: authService,
        localStorage: storage,
        initiallySignedIn: true,
      ),
    );
    await tester.pumpAndSettle();

    await tester.tap(find.byIcon(Icons.settings_outlined));
    await tester.pumpAndSettle();
    expect(find.text('2,500 kcal'), findsOneWidget);

    await tester.tap(find.text('Daily calorie goal'));
    await tester.pumpAndSettle();
    await tester.enterText(find.byKey(const Key('goal-input')), '1800');
    await tester.tap(find.byKey(const Key('goal-save')));
    await tester.pumpAndSettle();

    expect(await storage.loadCalorieGoal(), 1800);
    expect(find.text('1,800 kcal'), findsOneWidget);

    await tester.tap(find.byIcon(Icons.note_alt_outlined));
    await tester.pumpAndSettle();
    await tester.scrollUntilVisible(
      find.byKey(const Key('daily-goal')),
      250,
      scrollable: find.byType(Scrollable).first,
    );
    expect(find.text('1,800 kcal'), findsOneWidget);
  });

  testWidgets('historical correction saves back to the selected day', (
    tester,
  ) async {
    final store = MemoryDemoSessionStore()..value = true;
    final storage = LocalStorageService(store: store);
    final now = DateTime.now();
    final historicalDate = DateTime(2026, 9, 19);
    final timestamp = DateTime(2026, 9, 19, 8);
    await storage.saveDailyNote(
      DailyNote.fromEntries(
        date: now,
        entries: const [
          FoodEntry(
            id: 'today-entry',
            originalText: 'Today rice',
            foodName: 'Rice',
            quantity: 1,
            unit: 'serving',
            calories: 100,
            mealCategory: 'Breakfast',
          ),
        ],
        createdAt: now,
      ),
    );
    await storage.saveDailyNote(
      DailyNote.fromEntries(
        date: historicalDate,
        entries: const [
          FoodEntry(
            id: 'historical-entry',
            originalText: 'Historical rice',
            foodName: 'Rice',
            quantity: 1,
            unit: 'serving',
            calories: 200,
            mealCategory: 'Breakfast',
          ),
        ],
        createdAt: timestamp,
      ),
    );
    final authService = LocalDemoAuthService(storage: storage);
    await tester.pumpWidget(
      MyApp(
        authService: authService,
        localStorage: storage,
        initiallySignedIn: true,
      ),
    );
    await tester.pumpAndSettle();

    await tester.tap(find.byIcon(Icons.history_outlined));
    await tester.pumpAndSettle();
    await tester.tap(find.byKey(const ValueKey('history-note-2026-09-19')));
    await tester.pumpAndSettle();

    expect(find.text('Journal'), findsOneWidget);
    expect(find.text('Historical rice'), findsOneWidget);
    await tester.tap(find.byKey(const ValueKey('calories-historical-entry')));
    await tester.pumpAndSettle();
    await tester.enterText(find.byKey(const Key('correction-calories')), '180');
    await tester.tap(find.byKey(const Key('correction-save')));
    await tester.pumpAndSettle();

    final historical = await storage.loadDailyNote(historicalDate);
    final today = await storage.loadDailyNote(now);
    expect(historical!.totalCalories, 180);
    expect(historical.entries.single.calories, 180);
    expect(today!.totalCalories, 100);
    expect(today.entries.single.calories, 100);

    await tester.tap(find.byIcon(Icons.history_outlined));
    await tester.pumpAndSettle();
    expect(find.text('180 kcal'), findsOneWidget);
  });
}
