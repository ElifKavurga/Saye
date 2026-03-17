import 'api_service.dart';

class EmergencyContactsService {
  EmergencyContactsService({ApiService? apiService})
    : _apiService = apiService ?? ApiService();

  final ApiService _apiService;

  Future<List<Map<String, dynamic>>> fetchContacts({
    required int userId,
  }) async {
    final response = await _apiService.get(
      '/api/emergency-contacts',
      headers: _headers(userId),
    );
    final data = response['data'];
    if (data is! List) {
      throw ApiException('Unexpected emergency contacts response');
    }

    return data
        .whereType<Map>()
        .map((item) => Map<String, dynamic>.from(item))
        .toList(growable: false);
  }

  Future<Map<String, dynamic>> createContact({
    required int userId,
    required String name,
    required String phoneNumber,
    bool isPrimary = false,
  }) async {
    final response = await _apiService.post(
      '/api/emergency-contacts',
      headers: _headers(userId),
      body: {
        'name': name.trim(),
        'phoneNumber': phoneNumber.trim(),
        'isPrimary': isPrimary,
      },
    );
    return _extractDataMap(response);
  }

  Future<Map<String, dynamic>> updateContact({
    required int userId,
    required String contactId,
    required String name,
    required String phoneNumber,
    required bool isPrimary,
  }) async {
    final response = await _apiService.put(
      '/api/emergency-contacts/$contactId',
      headers: _headers(userId),
      body: {
        'name': name.trim(),
        'phoneNumber': phoneNumber.trim(),
        'isPrimary': isPrimary,
      },
    );
    return _extractDataMap(response);
  }

  Future<void> deleteContact({
    required int userId,
    required String contactId,
  }) async {
    await _apiService.delete(
      '/api/emergency-contacts/$contactId',
      headers: _headers(userId),
    );
  }

  Map<String, String> _headers(int userId) => {'X-USER-ID': userId.toString()};

  Map<String, dynamic> _extractDataMap(Map<String, dynamic> response) {
    final data = response['data'];
    if (data is! Map) {
      throw ApiException('Unexpected emergency contact response');
    }
    return Map<String, dynamic>.from(data);
  }
}
