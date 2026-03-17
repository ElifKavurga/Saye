import 'api_service.dart';

class HealthProfileService {
  HealthProfileService({ApiService? apiService})
    : _apiService = apiService ?? ApiService();

  final ApiService _apiService;

  Future<Map<String, dynamic>> fetchProfile({required int userId}) async {
    try {
      final response = await _apiService.get(
        '/api/health-profile/me',
        headers: _headers(userId),
      );
      return _extractDataMap(response);
    } on ApiException catch (e) {
      if (e.statusCode != 404) {
        rethrow;
      }
      final response = await _apiService.get(
        '/health-profile/me',
        headers: _headers(userId),
      );
      return _extractDataMap(response);
    }
  }

  Future<Map<String, dynamic>> updateProfile({
    required int userId,
    required Map<String, dynamic> body,
  }) async {
    try {
      final response = await _apiService.put(
        '/api/health-profile/me',
        headers: _headers(userId),
        body: body,
      );
      return _extractDataMap(response);
    } on ApiException catch (e) {
      if (e.statusCode != 404) {
        rethrow;
      }
      final response = await _apiService.put(
        '/health-profile/me',
        headers: _headers(userId),
        body: body,
      );
      return _extractDataMap(response);
    }
  }

  Map<String, String> _headers(int userId) => {'X-USER-ID': userId.toString()};

  Map<String, dynamic> _extractDataMap(Map<String, dynamic> response) {
    final data = response['data'];
    if (data is! Map) {
      throw ApiException('Unexpected health profile response');
    }
    return Map<String, dynamic>.from(data);
  }
}
