import 'dart:async';
import 'dart:convert';

import 'package:http/http.dart' as http;

import '../models/food_entry.dart';

class FoodApiException implements Exception {
  const FoodApiException(this.message);

  final String message;

  @override
  String toString() => message;
}

class FoodApiService {
  FoodApiService({
    http.Client? client,
    String baseUrl = const String.fromEnvironment(
      'CALY_API_BASE_URL',
      defaultValue: 'http://127.0.0.1:8000',
    ),
    this.timeout = const Duration(seconds: 10),
  }) : _client = client ?? http.Client(),
       _ownsClient = client == null,
       _baseUri = Uri.parse(baseUrl);

  final http.Client _client;
  final bool _ownsClient;
  final Uri _baseUri;
  final Duration timeout;

  Future<FoodEntry> interpretFood({
    required String text,
    required String meal,
  }) async {
    final endpoint = _baseUri.resolve('/api/v1/foods/interpret');

    try {
      final response = await _client
          .post(
            endpoint,
            headers: const {'Content-Type': 'application/json; charset=UTF-8'},
            body: jsonEncode({'text': text, 'meal': meal.toLowerCase()}),
          )
          .timeout(timeout);

      if (response.statusCode != 200) {
        throw FoodApiException(_serverErrorMessage(response));
      }

      final decoded = jsonDecode(utf8.decode(response.bodyBytes));
      if (decoded is! Map<String, dynamic>) {
        throw const FoodApiException(
          'The food service returned an unexpected response.',
        );
      }

      try {
        return FoodEntry.fromJson(decoded);
      } on FormatException catch (error) {
        throw FoodApiException(error.message);
      }
    } on TimeoutException {
      throw const FoodApiException(
        'The food service took too long to respond. Try again.',
      );
    } on http.ClientException {
      throw const FoodApiException(
        'Could not reach the food service. Check that FastAPI is running.',
      );
    } on FormatException {
      throw const FoodApiException(
        'The food service returned invalid JSON. Try again.',
      );
    }
  }

  String _serverErrorMessage(http.Response response) {
    try {
      final decoded = jsonDecode(utf8.decode(response.bodyBytes));
      if (decoded is Map<String, dynamic>) {
        final detail = decoded['detail'];
        if (detail is String && detail.isNotEmpty) return detail;
        if (detail is List && detail.isNotEmpty && detail.first is Map) {
          final message = (detail.first as Map)['msg'];
          if (message is String && message.isNotEmpty) return message;
        }
      }
    } on FormatException {
      // Fall through to the status-based message below.
    }

    return 'The food service returned status ${response.statusCode}.';
  }

  void close() {
    if (_ownsClient) _client.close();
  }
}
