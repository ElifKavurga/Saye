import 'api_service.dart';

class UserSettingsService {
  UserSettingsService({ApiService? apiService})
    : _apiService = apiService ?? ApiService();

  final ApiService _apiService;

  Future<Map<String, dynamic>> fetchSettings({required int userId}) async {
    final response = await _apiService.get(
      '/api/settings/me',
      headers: _headers(userId),
    );
    return _extractDataMap(response);
  }

  Future<Map<String, dynamic>> updateSettings({
    required int userId,
    required Map<String, dynamic> body,
  }) async {
    final response = await _apiService.put(
      '/api/settings/me',
      headers: _headers(userId),
      body: body,
    );
    return _extractDataMap(response);
  }

  Map<String, String> _headers(int userId) => {'X-USER-ID': userId.toString()};

  Map<String, dynamic> _extractDataMap(Map<String, dynamic> response) {
    final data = response['data'];
    if (data is! Map) {
      throw ApiException('Unexpected user settings response');
    }
    return Map<String, dynamic>.from(data);
  }
}
