/// HTTP API client wrapper.
///
/// Provides a consistent interface for making HTTP requests
/// with error handling, timeouts, and logging.
library;

import 'dart:convert';
import 'package:http/http.dart' as http;
import '../constants/api_constants.dart';
import '../errors/exceptions.dart';
import '../utils/logger.dart';

class ApiClient {
  final http.Client _client;

  ApiClient({http.Client? client}) : _client = client ?? http.Client();

  /// Perform a GET request.
  Future<Map<String, dynamic>> get(
    String url, {
    Map<String, String>? headers,
  }) async {
    try {
      AppLogger.debug('GET → $url');
      final response = await _client
          .get(Uri.parse(url), headers: headers)
          .timeout(ApiConstants.apiTimeout);

      return _handleResponse(response);
    } catch (e) {
      if (e is ServerException) rethrow;
      throw ServerException(message: 'GET request failed: $e');
    }
  }

  /// Perform a POST request.
  Future<Map<String, dynamic>> post(
    String url, {
    Map<String, String>? headers,
    Map<String, dynamic>? body,
  }) async {
    try {
      AppLogger.debug('POST → $url');
      final response = await _client
          .post(
            Uri.parse(url),
            headers: {
              'Content-Type': 'application/json',
              ...?headers,
            },
            body: body != null ? jsonEncode(body) : null,
          )
          .timeout(ApiConstants.apiTimeout);

      return _handleResponse(response);
    } catch (e) {
      if (e is ServerException) rethrow;
      throw ServerException(message: 'POST request failed: $e');
    }
  }

  /// Handle HTTP response and extract JSON body.
  Map<String, dynamic> _handleResponse(http.Response response) {
    AppLogger.debug('Response: ${response.statusCode}');

    if (response.statusCode >= 200 && response.statusCode < 300) {
      if (response.body.isEmpty) return {};
      return jsonDecode(response.body) as Map<String, dynamic>;
    }

    throw ServerException(
      message: 'Server error: ${response.body}',
      statusCode: response.statusCode,
    );
  }

  /// Clean up resources.
  void dispose() {
    _client.close();
  }
}
