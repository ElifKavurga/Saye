import 'dart:convert';

import 'package:flutter/foundation.dart';
import 'package:flutter_secure_storage/flutter_secure_storage.dart';
import 'package:http/http.dart' as http;

class ApiException implements Exception {
  ApiException(this.message, {this.statusCode});

  final String message;
  final int? statusCode;

  @override
  String toString() =>
      'ApiException(statusCode: $statusCode, message: $message)';
}

class ApiService {
  ApiService({http.Client? client, FlutterSecureStorage? secureStorage})
    : _client = client ?? http.Client(),
      _secureStorage = secureStorage ?? const FlutterSecureStorage();

  static const String _envBaseUrl = String.fromEnvironment('API_BASE_URL');
  static String get baseUrl => _resolveBaseUrl();
  static const String _jwtTokenKey = 'jwt_token';
  static const String _sessionUserKey = 'session_user';

  final http.Client _client;
  final FlutterSecureStorage _secureStorage;

  Future<void> saveToken(String token) async {
    await _secureStorage.write(key: _jwtTokenKey, value: token);
  }

  Future<String?> readToken() async {
    return _secureStorage.read(key: _jwtTokenKey);
  }

  Future<void> saveUserSession(Map<String, dynamic> user) async {
    await _secureStorage.write(key: _sessionUserKey, value: jsonEncode(user));
  }

  Future<Map<String, dynamic>?> readUserSession() async {
    final raw = await _secureStorage.read(key: _sessionUserKey);
    if (raw == null || raw.isEmpty) {
      return null;
    }
    return jsonDecode(raw) as Map<String, dynamic>;
  }

  Future<void> clearSession() async {
    await _secureStorage.delete(key: _jwtTokenKey);
    await _secureStorage.delete(key: _sessionUserKey);
  }

  Future<void> clearToken() async {
    await _secureStorage.delete(key: _jwtTokenKey);
  }

  Future<Map<String, dynamic>> get(
    String endpoint, {
    Map<String, String>? headers,
  }) async {
    final response = await _request(
      method: 'GET',
      endpoint: endpoint,
      headers: headers,
    );
    if (response is Map<String, dynamic>) {
      return response;
    }
    throw ApiException(
      'Expected JSON object response but got ${response.runtimeType}',
    );
  }

  Future<dynamic> getAny(String endpoint, {Map<String, String>? headers}) {
    return _request(method: 'GET', endpoint: endpoint, headers: headers);
  }

  Future<List<dynamic>> getList(
    String endpoint, {
    Map<String, String>? headers,
  }) async {
    final response = await getAny(endpoint, headers: headers);
    if (response is List<dynamic>) {
      return response;
    }
    throw ApiException(
      'Expected JSON list response but got ${response.runtimeType}',
    );
  }

  Future<Map<String, dynamic>> post(
    String endpoint, {
    Object? body,
    Map<String, String>? headers,
  }) async {
    final response = await _request(
      method: 'POST',
      endpoint: endpoint,
      body: body,
      headers: headers,
    );
    if (response is Map<String, dynamic>) {
      return response;
    }
    throw ApiException(
      'Expected JSON object response but got ${response.runtimeType}',
    );
  }

  Future<Map<String, dynamic>> put(
    String endpoint, {
    Object? body,
    Map<String, String>? headers,
  }) async {
    final response = await _request(
      method: 'PUT',
      endpoint: endpoint,
      body: body,
      headers: headers,
    );
    if (response is Map<String, dynamic>) {
      return response;
    }
    throw ApiException(
      'Expected JSON object response but got ${response.runtimeType}',
    );
  }

  Future<Map<String, dynamic>> delete(
    String endpoint, {
    Object? body,
    Map<String, String>? headers,
  }) async {
    final response = await _request(
      method: 'DELETE',
      endpoint: endpoint,
      body: body,
      headers: headers,
    );
    if (response is Map<String, dynamic>) {
      return response;
    }
    throw ApiException(
      'Expected JSON object response but got ${response.runtimeType}',
    );
  }

  Future<dynamic> _request({
    required String method,
    required String endpoint,
    Object? body,
    Map<String, String>? headers,
  }) async {
    final token = await readToken();
    final mergedHeaders = <String, String>{
      'Content-Type': 'application/json',
      ...?headers,
      if (token != null && token.isNotEmpty) 'Authorization': 'Bearer $token',
    };

    final uri = Uri.parse('$baseUrl$endpoint');

    try {
      late final http.Response response;

      switch (method) {
        case 'GET':
          response = await _client.get(uri, headers: mergedHeaders);
          break;
        case 'POST':
          response = await _client.post(
            uri,
            headers: mergedHeaders,
            body: body != null ? jsonEncode(body) : null,
          );
          break;
        case 'PUT':
          response = await _client.put(
            uri,
            headers: mergedHeaders,
            body: body != null ? jsonEncode(body) : null,
          );
          break;
        case 'DELETE':
          response = await _client.delete(
            uri,
            headers: mergedHeaders,
            body: body != null ? jsonEncode(body) : null,
          );
          break;
        default:
          throw ApiException('Unsupported HTTP method: $method');
      }

      return _handleResponse(response);
    } on http.ClientException catch (e) {
      throw ApiException('Network error: ${e.message}');
    } catch (e) {
      if (e is ApiException) rethrow;
      throw ApiException('Unexpected error: $e');
    }
  }

  dynamic _handleResponse(http.Response response) {
    if (response.statusCode >= 200 && response.statusCode < 300) {
      if (response.body.isEmpty) {
        return <String, dynamic>{};
      }
      return jsonDecode(response.body);
    }

    final responseBody = response.body.isNotEmpty
        ? jsonDecode(response.body)
        : null;
    final responseMap = responseBody is Map<String, dynamic>
        ? responseBody
        : null;
    final message =
        responseMap?['message']?.toString() ??
        responseMap?['error']?.toString() ??
        'HTTP ${response.statusCode} error';

    throw ApiException(message, statusCode: response.statusCode);
  }

  static String _resolveBaseUrl() {
    if (_envBaseUrl.isNotEmpty) {
      return _envBaseUrl;
    }

    // Android emulator cannot reach host machine via localhost.
    if (!kIsWeb && defaultTargetPlatform == TargetPlatform.android) {
      return 'http://10.0.2.2:8080';
    }

    return 'http://localhost:8080';
  }
}
