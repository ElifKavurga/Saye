import 'dart:async';
import 'dart:convert';

import 'package:flutter/foundation.dart';
import 'package:flutter_secure_storage/flutter_secure_storage.dart';
import 'package:http/http.dart' as http;

class ApiException implements Exception {
  ApiException(this.message, {this.statusCode, this.isSessionExpired = false});

  final String message;
  final int? statusCode;
  final bool isSessionExpired;

  @override
  String toString() =>
      'ApiException(statusCode: $statusCode, isSessionExpired: '
      '$isSessionExpired, message: $message)';
}

class ApiService {
  ApiService({http.Client? client, FlutterSecureStorage? secureStorage})
    : _client = client ?? http.Client(),
      _secureStorage = secureStorage ?? const FlutterSecureStorage();

  static const String _envBaseUrl = String.fromEnvironment('API_BASE_URL');
  static String get baseUrl => _resolveBaseUrl();
  static const String _jwtTokenKey = 'jwt_token';
  static const String _refreshTokenKey = 'refresh_token';
  static const String _sessionUserKey = 'session_user';

  final http.Client _client;
  final FlutterSecureStorage _secureStorage;

  Future<void> Function()? _onSessionExpired;
  Future<void> Function(String accessToken, String refreshToken)?
  _onSessionTokensUpdated;
  Future<bool>? _refreshFuture;
  bool _hasHandledSessionExpiry = false;

  void setSessionHandlers({
    Future<void> Function()? onSessionExpired,
    Future<void> Function(String accessToken, String refreshToken)?
    onSessionTokensUpdated,
  }) {
    _onSessionExpired = onSessionExpired;
    _onSessionTokensUpdated = onSessionTokensUpdated;
  }

  Future<void> saveToken(String token) async {
    _hasHandledSessionExpiry = false;
    await _secureStorage.write(key: _jwtTokenKey, value: token);
  }

  Future<String?> readToken() async {
    return _secureStorage.read(key: _jwtTokenKey);
  }

  Future<void> saveRefreshToken(String refreshToken) async {
    _hasHandledSessionExpiry = false;
    await _secureStorage.write(key: _refreshTokenKey, value: refreshToken);
  }

  Future<String?> readRefreshToken() async {
    return _secureStorage.read(key: _refreshTokenKey);
  }

  Future<void> saveAuthSession({
    required String token,
    required String refreshToken,
    Map<String, dynamic>? user,
  }) async {
    await saveToken(token);
    await saveRefreshToken(refreshToken);
    if (user != null) {
      await saveUserSession(user);
    }
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
    await _secureStorage.delete(key: _refreshTokenKey);
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
    bool allowRefresh = true,
    bool includeAuthorizationHeader = true,
  }) async {
    final uri = Uri.parse('$baseUrl$endpoint');

    try {
      http.Response response = await _send(
        method: method,
        uri: uri,
        body: body,
        headers: await _buildHeaders(
          headers: headers,
          includeAuthorizationHeader: includeAuthorizationHeader,
        ),
      );

      if (response.statusCode == 401 &&
          allowRefresh &&
          !_isAuthEndpoint(endpoint)) {
        final refreshed = await _refreshAccessToken();
        if (!refreshed) {
          await _handleSessionExpired();
          throw ApiException(
            'Session expired',
            statusCode: 401,
            isSessionExpired: true,
          );
        }

        response = await _send(
          method: method,
          uri: uri,
          body: body,
          headers: await _buildHeaders(
            headers: headers,
            includeAuthorizationHeader: includeAuthorizationHeader,
          ),
        );

        if (response.statusCode == 401) {
          await _handleSessionExpired();
          throw ApiException(
            'Session expired',
            statusCode: 401,
            isSessionExpired: true,
          );
        }
      }

      return _handleResponse(response);
    } on http.ClientException catch (e) {
      throw ApiException('Network error: ${e.message}');
    } catch (e) {
      if (e is ApiException) {
        rethrow;
      }
      throw ApiException('Unexpected error: $e');
    }
  }

  Future<Map<String, String>> _buildHeaders({
    Map<String, String>? headers,
    required bool includeAuthorizationHeader,
  }) async {
    final token = includeAuthorizationHeader ? await readToken() : null;
    return <String, String>{
      'Content-Type': 'application/json',
      ...?headers,
      if (token != null && token.isNotEmpty) 'Authorization': 'Bearer $token',
    };
  }

  Future<http.Response> _send({
    required String method,
    required Uri uri,
    required Map<String, String> headers,
    Object? body,
  }) {
    switch (method) {
      case 'GET':
        return _client.get(uri, headers: headers);
      case 'POST':
        return _client.post(
          uri,
          headers: headers,
          body: body != null ? jsonEncode(body) : null,
        );
      case 'PUT':
        return _client.put(
          uri,
          headers: headers,
          body: body != null ? jsonEncode(body) : null,
        );
      case 'DELETE':
        return _client.delete(
          uri,
          headers: headers,
          body: body != null ? jsonEncode(body) : null,
        );
      default:
        throw ApiException('Unsupported HTTP method: $method');
    }
  }

  Future<bool> _refreshAccessToken() async {
    final ongoingRefresh = _refreshFuture;
    if (ongoingRefresh != null) {
      return ongoingRefresh;
    }

    final refreshFuture = _performTokenRefresh();
    _refreshFuture = refreshFuture;
    try {
      return await refreshFuture;
    } finally {
      if (identical(_refreshFuture, refreshFuture)) {
        _refreshFuture = null;
      }
    }
  }

  Future<bool> _performTokenRefresh() async {
    final refreshToken = await readRefreshToken();
    if (refreshToken == null || refreshToken.isEmpty) {
      return false;
    }

    final refreshBody = <String, dynamic>{'refreshToken': refreshToken};

    try {
      http.Response response = await _send(
        method: 'POST',
        uri: Uri.parse('$baseUrl/api/auth/refresh'),
        headers: const <String, String>{'Content-Type': 'application/json'},
        body: refreshBody,
      );

      if (response.statusCode == 404) {
        response = await _send(
          method: 'POST',
          uri: Uri.parse('$baseUrl/auth/refresh'),
          headers: const <String, String>{'Content-Type': 'application/json'},
          body: refreshBody,
        );
      }

      final responseMap = _handleResponse(response);
      if (responseMap is! Map<String, dynamic>) {
        return false;
      }

      final data = responseMap['data'];
      if (data is! Map) {
        return false;
      }

      final authData = Map<String, dynamic>.from(data);
      final token = authData['token']?.toString() ?? '';
      final newRefreshToken = authData['refreshToken']?.toString() ?? '';
      if (token.isEmpty || newRefreshToken.isEmpty) {
        return false;
      }

      final user = authData['user'];
      await saveAuthSession(
        token: token,
        refreshToken: newRefreshToken,
        user: user is Map<String, dynamic>
            ? user
            : user is Map
            ? Map<String, dynamic>.from(user)
            : null,
      );

      if (_onSessionTokensUpdated != null) {
        await _onSessionTokensUpdated!(token, newRefreshToken);
      }

      return true;
    } on ApiException {
      return false;
    }
  }

  Future<void> _handleSessionExpired() async {
    if (_hasHandledSessionExpiry) {
      return;
    }
    _hasHandledSessionExpiry = true;
    await clearSession();
    if (_onSessionExpired != null) {
      await _onSessionExpired!();
    }
  }

  bool _isAuthEndpoint(String endpoint) {
    return endpoint.startsWith('/auth') || endpoint.startsWith('/api/auth');
  }

  dynamic _handleResponse(http.Response response) {
    if (response.statusCode >= 200 && response.statusCode < 300) {
      if (response.body.isEmpty) {
        return <String, dynamic>{};
      }
      try {
        return jsonDecode(response.body);
      } catch (_) {
        return <String, dynamic>{};
      }
    }

    final responseBody = response.body.isNotEmpty
        ? () {
            try {
              return jsonDecode(response.body);
            } catch (_) {
              return null;
            }
          }()
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

  http.Client get httpClient => _client;

  static String _resolveBaseUrl() {
    if (_envBaseUrl.isNotEmpty) {
      return _envBaseUrl;
    }

    if (!kIsWeb && defaultTargetPlatform == TargetPlatform.android) {
      return 'http://10.0.2.2:8080';
    }

    return 'http://localhost:8080';
  }
}
