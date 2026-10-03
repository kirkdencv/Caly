import 'dart:async';
import 'dart:convert';

import 'package:flutter_test/flutter_test.dart';
import 'package:http/http.dart' as http;
import 'package:http/testing.dart';

import 'package:final_project/services/food_api_service.dart';

void main() {
  test('interpretFood posts JSON and decodes the FastAPI contract', () async {
    final service = FoodApiService(
      baseUrl: 'http://example.test:8000',
      client: MockClient((request) async {
        expect(request.method, 'POST');
        expect(request.url.path, '/api/v1/foods/interpret');
        expect(request.headers['content-type'], contains('application/json'));
        expect(jsonDecode(request.body), {
          'text': '1 cup rice',
          'meal': 'breakfast',
        });

        return http.Response(
          jsonEncode({
            'originalText': '1 cup rice',
            'foodName': 'White rice, cooked',
            'quantity': 1,
            'unit': 'cup',
            'calories': 200,
            'mealCategory': 'breakfast',
          }),
          200,
        );
      }),
    );

    final entry = await service.interpretFood(
      text: '1 cup rice',
      meal: 'Breakfast',
    );

    expect(entry.originalText, '1 cup rice');
    expect(entry.foodName, 'White rice, cooked');
    expect(entry.calories, 200);
    expect(entry.mealCategory, 'breakfast');
  });

  test('non-success status exposes the useful FastAPI detail', () async {
    final service = FoodApiService(
      client: MockClient(
        (_) async => http.Response(
          jsonEncode({'detail': 'Food text must not be empty.'}),
          422,
        ),
      ),
    );

    expect(
      service.interpretFood(text: ' ', meal: 'Breakfast'),
      throwsA(
        isA<FoodApiException>().having(
          (error) => error.message,
          'message',
          'Food text must not be empty.',
        ),
      ),
    );
  });

  test('timeout becomes a useful retry message', () async {
    final neverCompletes = Completer<http.Response>();
    final service = FoodApiService(
      client: MockClient((_) => neverCompletes.future),
      timeout: const Duration(milliseconds: 1),
    );

    expect(
      service.interpretFood(text: 'rice', meal: 'Lunch'),
      throwsA(
        isA<FoodApiException>().having(
          (error) => error.message,
          'message',
          contains('too long'),
        ),
      ),
    );
  });

  test('invalid JSON becomes a useful response error', () async {
    final service = FoodApiService(
      client: MockClient((_) async => http.Response('not-json', 200)),
    );

    expect(
      service.interpretFood(text: 'rice', meal: 'Dinner'),
      throwsA(
        isA<FoodApiException>().having(
          (error) => error.message,
          'message',
          contains('invalid JSON'),
        ),
      ),
    );
  });

  test('missing response fields are rejected before reaching the UI', () async {
    final service = FoodApiService(
      client: MockClient(
        (_) async => http.Response(jsonEncode({'foodName': 'Rice'}), 200),
      ),
    );

    expect(
      service.interpretFood(text: 'rice', meal: 'Dinner'),
      throwsA(
        isA<FoodApiException>().having(
          (error) => error.message,
          'message',
          contains('originalText'),
        ),
      ),
    );
  });

  test('invalid response meal is rejected before reaching the UI', () async {
    final service = FoodApiService(
      client: MockClient(
        (_) async => http.Response(
          jsonEncode({
            'originalText': 'rice',
            'foodName': 'Rice',
            'quantity': 1,
            'unit': 'cup',
            'calories': 200,
            'mealCategory': 'snack',
          }),
          200,
        ),
      ),
    );

    expect(
      service.interpretFood(text: 'rice', meal: 'Dinner'),
      throwsA(
        isA<FoodApiException>().having(
          (error) => error.message,
          'message',
          contains('invalid meal category'),
        ),
      ),
    );
  });
}
