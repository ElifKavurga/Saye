import 'dart:convert';

import 'package:flutter_secure_storage/flutter_secure_storage.dart';

class EmergencyContactsStorage {
  EmergencyContactsStorage({FlutterSecureStorage? secureStorage})
    : _secureStorage = secureStorage ?? const FlutterSecureStorage();

  static const String _storageKey = 'emergency_contacts';

  final FlutterSecureStorage _secureStorage;

  Future<List<Map<String, dynamic>>> readContacts() async {
    try {
      final raw = await _secureStorage.read(key: _storageKey);
      if (raw == null || raw.isEmpty) {
        return [];
      }

      final decoded = jsonDecode(raw);
      if (decoded is! List) {
        return [];
      }

      return decoded
          .whereType<Map>()
          .map((item) => Map<String, dynamic>.from(item))
          .toList(growable: false);
    } catch (_) {
      return [];
    }
  }

  Future<void> saveContacts(List<Map<String, dynamic>> contacts) async {
    try {
      final payload = jsonEncode(contacts);
      await _secureStorage.write(key: _storageKey, value: payload);
    } catch (_) {
      // Intentionally swallowed to avoid crashing app on storage failures.
    }
  }

  Future<void> clearContacts() async {
    try {
      await _secureStorage.delete(key: _storageKey);
    } catch (_) {
      // Intentionally swallowed to avoid crashing app on storage failures.
    }
  }
}
