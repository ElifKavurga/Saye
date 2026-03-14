import 'dart:async';
import 'dart:convert';

import 'package:flutter/material.dart';
import 'package:geocoding/geocoding.dart';
import 'package:geolocator/geolocator.dart';
import 'package:shared_preferences/shared_preferences.dart';

import '../config/app_defaults.dart';
import '../services/api_service.dart';
import '../services/emergency_contacts_storage.dart';

class SessionUser {
  const SessionUser({
    required this.id,
    required this.email,
    required this.username,
    required this.phone,
  });

  final int? id;
  final String email;
  final String username;
  final String phone;
}

enum RiskLevel { low, medium, high }

class LocalReportNotification {
  const LocalReportNotification({
    required this.category,
    required this.locationLabel,
    required this.latLng,
    required this.description,
    required this.createdAt,
  });

  final String category;
  final String locationLabel;
  final String latLng;
  final String description;
  final DateTime createdAt;
}

class NearbyReport {
  const NearbyReport({
    required this.id,
    required this.category,
    required this.description,
    required this.latitude,
    required this.longitude,
    required this.status,
    required this.createdAt,
  });

  final int id;
  final String category;
  final String description;
  final double latitude;
  final double longitude;
  final String status;
  final DateTime? createdAt;
}

class EmergencyHealthInfo {
  const EmergencyHealthInfo({
    this.bloodType = '',
    this.allergyNotes = '',
    this.emergencyNote = '',
  });

  final String bloodType;
  final String allergyNotes;
  final String emergencyNote;

  bool get hasContent =>
      bloodType.trim().isNotEmpty ||
      allergyNotes.trim().isNotEmpty ||
      emergencyNote.trim().isNotEmpty;

  EmergencyHealthInfo copyWith({
    String? bloodType,
    String? allergyNotes,
    String? emergencyNote,
  }) {
    return EmergencyHealthInfo(
      bloodType: bloodType ?? this.bloodType,
      allergyNotes: allergyNotes ?? this.allergyNotes,
      emergencyNote: emergencyNote ?? this.emergencyNote,
    );
  }
}

class AppPermission {
  const AppPermission({
    required this.id,
    required this.title,
    required this.description,
    required this.enabled,
  });

  final String id;
  final String title;
  final String description;
  final bool enabled;

  AppPermission copyWith({bool? enabled}) {
    return AppPermission(
      id: id,
      title: title,
      description: description,
      enabled: enabled ?? this.enabled,
    );
  }
}

class EmergencyContact {
  const EmergencyContact({
    required this.id,
    required this.name,
    required this.phone,
    this.isPrimary = false,
  });

  final String id;
  final String name;
  final String phone;
  final bool isPrimary;

  Map<String, dynamic> toJson() {
    return {'id': id, 'name': name, 'phone': phone, 'isPrimary': isPrimary};
  }

  factory EmergencyContact.fromJson(Map<String, dynamic> json) {
    return EmergencyContact(
      id: json['id']?.toString() ?? '',
      name: json['name']?.toString() ?? '',
      phone: json['phone']?.toString() ?? '',
      isPrimary: json['isPrimary'] as bool? ?? false,
    );
  }

  EmergencyContact copyWith({String? name, String? phone, bool? isPrimary}) {
    return EmergencyContact(
      id: id,
      name: name ?? this.name,
      phone: phone ?? this.phone,
      isPrimary: isPrimary ?? this.isPrimary,
    );
  }
}

class AppState extends ChangeNotifier {
  AppState({ApiService? apiService, EmergencyContactsStorage? contactsStorage})
    : _apiService = apiService ?? ApiService(),
      _contactsStorage = contactsStorage ?? EmergencyContactsStorage(),
      _settings = List<SettingOption>.from(AppDefaults.settings),
      _permissions = [
        AppPermission(
          id: 'location_info',
          title: 'Konum Bilgileri',
          description:
              'Acil durumda yakın güvenli bölgeyi hesaplamak için kullanılır.',
          enabled: true,
        ),
        AppPermission(
          id: 'background_refresh',
          title: 'Arkaplanda Yenileme',
          description:
              'Uygulama kapalıyken risk ve bildirim verilerini günceller.',
          enabled: true,
        ),
        AppPermission(
          id: 'quick_unlock_access',
          title: 'Ekran Kilitsiz Kolay Erişim',
          description:
              'Acil butona daha hızlı ulaşman için kilit ekranı kısayolu sunar.',
          enabled: false,
        ),
        AppPermission(
          id: 'gsm_sms',
          title: 'GSM/SMS izinleri',
          description:
              'Acil durumda önceden tanımlı kişilere SMS göndermek için gereklidir.',
          enabled: false,
        ),
        AppPermission(
          id: 'bluetooth',
          title: 'Bluetooth',
          description: 'Yakin cihaz taramasi ve takip analizi icin kullanilir.',
          enabled: true,
        ),
      ],
      _emergencyContacts = [
        const EmergencyContact(
          id: 'c1',
          name: 'Ayse Demir',
          phone: '0555 111 22 33',
          isPrimary: true,
        ),
        const EmergencyContact(
          id: 'c2',
          name: 'Mehmet Kaya',
          phone: '0555 444 55 66',
        ),
      ] {
    _loadEmergencyHealthInfo();
  }

  static const String _emergencyHealthInfoKey = 'emergency_health_info';
  final ApiService _apiService;
  final EmergencyContactsStorage _contactsStorage;

  int _selectedIndex = 0;
  final List<SettingOption> _settings;
  List<AppPermission> _permissions;
  final List<EmergencyContact> _emergencyContacts;
  SessionUser? _currentUser;
  RiskLevel _riskLevel = RiskLevel.low;
  bool _emergencyActive = false;
  bool _showRiskDecision = false;
  final List<LocalReportNotification> _localReports = [];
  final List<NearbyReport> _nearbyReports = [];
  bool _isProfileVisibleInAlerts = true;
  EmergencyHealthInfo _emergencyHealthInfo = const EmergencyHealthInfo();
  double? _currentLatitude;
  double? _currentLongitude;
  String? _currentLocationName;
  bool _isMapDataLoading = false;
  bool _isLoading = false;
  int _loadingCounter = 0;
  StreamSubscription<Position>? _locationStreamSubscription;

  int get selectedIndex => _selectedIndex;
  List<SettingOption> get settings => List.unmodifiable(_settings);
  SessionUser? get currentUser => _currentUser;
  bool get isAuthenticated => _currentUser != null;
  RiskLevel get riskLevel => _riskLevel;
  bool get emergencyActive => _emergencyActive;
  bool get showRiskDecision => _showRiskDecision;
  List<LocalReportNotification> get localReports =>
      List.unmodifiable(_localReports);
  List<NearbyReport> get nearbyReports => List.unmodifiable(_nearbyReports);
  bool get isProfileVisibleInAlerts => _isProfileVisibleInAlerts;
  EmergencyHealthInfo get emergencyHealthInfo => _emergencyHealthInfo;
  List<AppPermission> get permissions => List.unmodifiable(_permissions);
  List<EmergencyContact> get emergencyContacts =>
      List.unmodifiable(_emergencyContacts);
  double? get currentLatitude => _currentLatitude;
  double? get currentLongitude => _currentLongitude;
  String get currentLocationName => _currentLocationName ?? AppDefaults.campusLocation;
  bool get isMapDataLoading => _isMapDataLoading;
  bool get isLoading => _isLoading;
  EmergencyContact? get primaryEmergencyContact {
    for (final contact in _emergencyContacts) {
      if (contact.isPrimary) {
        return contact;
      }
    }
    return _emergencyContacts.isEmpty ? null : _emergencyContacts.first;
  }

  void setIndex(int index) {
    if (_selectedIndex == index) {
      return;
    }
    _selectedIndex = index;
    notifyListeners();
  }

  void toggleSetting(String id, bool enabled) {
    final index = _settings.indexWhere((item) => item.id == id);
    if (index == -1) {
      return;
    }
    _settings[index] = _settings[index].copyWith(enabled: enabled);
    notifyListeners();
  }

  Future<void> login({required String email, required String password}) async {
    await _withLoading(() async {
      try {
        final response = await _apiService.post(
          '/auth/login',
          body: {'email': email.trim(), 'password': password},
        );
        print("LOGIN RESPONSE: $response");
        final authData = _extractAuthData(response);
        final token = authData['token']?.toString();
        final userMap = _extractUserMap(authData['user']);
        if (token == null || token.isEmpty) {
          throw ApiException('Login response does not include a valid token');
        }
        await _apiService.saveToken(token);
        await _apiService.saveUserSession(userMap);
        _currentUser = _toSessionUser(userMap);
        _setDefaultLandingScenario();
        notifyListeners();
      } catch (e) {
        throw AppStateException(
          _toUserMessage(
            e,
            fallback: 'Giriş yapılamadı. Lütfen tekrar deneyin.',
          ),
        );
      }
    });
  }

  Future<void> register({
    required String email,
    required String username,
    required String password,
    required String phone,
  }) async {
    await _withLoading(() async {
      try {
        final response = await _apiService.post(
          '/auth/register',
          body: {
            'email': email.trim(),
            'username': username.trim(),
            'password': password,
            'phone': phone.trim(),
          },
        );
        final authData = _extractAuthData(response);
        final token = authData['token']?.toString();
        final userMap = _extractUserMap(authData['user']);
        if (token == null || token.isEmpty) {
          throw ApiException(
            'Register response does not include a valid token',
          );
        }
        await _apiService.saveToken(token);
        await _apiService.saveUserSession(userMap);
        _currentUser = _toSessionUser(userMap);
        _setDefaultLandingScenario();
        notifyListeners();
      } catch (e) {
        throw AppStateException(
          _toUserMessage(e, fallback: 'Kayit islemi tamamlanamadi.'),
        );
      }
    });
  }

  Future<void> checkAuthStatus() async {
    await _withLoading(() async {
      try {
        final token = await _apiService.readToken();
        if (token == null || token.isEmpty) {
          return;
        }
        final userMap = await _apiService.readUserSession();
        if (userMap == null) {
          await _apiService.clearSession();
          return;
        }
        _currentUser = _toSessionUser(userMap);
        _setDefaultLandingScenario();
        notifyListeners();
      } catch (e) {
        await _apiService.clearSession();
        _currentUser = null;
        _setDefaultLandingScenario();
        notifyListeners();
      }
    });
  }

  void demoLogin() {
    Future.microtask(() {
      _loadingCounter = 0;
      _isLoading = false;

      _currentUser = const SessionUser(
        id: 0,
        email: 'demo@sayende.app',
        username: 'demo_user',
        phone: '',
      );

      _setDefaultLandingScenario();
      notifyListeners();
    });
  }

  void cycleRiskLevel() {
    switch (_riskLevel) {
      case RiskLevel.low:
        _riskLevel = RiskLevel.medium;
      case RiskLevel.medium:
        _riskLevel = RiskLevel.high;
      case RiskLevel.high:
        _riskLevel = RiskLevel.low;
    }
    notifyListeners();
  }

  Future<void> updateUserLocation({
    required double lat,
    required double lng,
    double radiusMeters = 1000,
  }) async {
    await _withLoading(() async {
      _currentLatitude = lat;
      _currentLongitude = lng;
      _isMapDataLoading = true;
      notifyListeners();

      try {
        await Future.wait<void>([
          _updateLocationName(lat, lng),
          _refreshRiskLevel(lat: lat, lng: lng),
          _refreshNearbyReports(
            lat: lat,
            lng: lng,
            radiusMeters: radiusMeters,
          ),
        ]);
      } catch (e) {
        throw AppStateException(
          _toUserMessage(
            e,
            fallback: 'Harita verileri yüklenemedi. Bağlantını kontrol et.',
          ),
        );
      } finally {
        _isMapDataLoading = false;
        notifyListeners();
      }
    });
  }

  Future<void> fetchRealLocation({double radiusMeters = 1000}) async {
    final serviceEnabled = await Geolocator.isLocationServiceEnabled();
    if (!serviceEnabled) {
      throw AppStateException(
        'Cihazdaki konum servisi kapalı. Lütfen açık hale getirin.',
      );
    }

    LocationPermission permission = await Geolocator.checkPermission();
    if (permission == LocationPermission.denied) {
      permission = await Geolocator.requestPermission();
    }

    if (permission == LocationPermission.denied) {
      throw AppStateException('Konum izni reddedildi.');
    }
    if (permission == LocationPermission.deniedForever) {
      throw AppStateException(
        'Konum izni kalıcı olarak reddedildi. Ayarlardan izin verin.',
      );
    }

    final position = await Geolocator.getCurrentPosition(
      locationSettings: const LocationSettings(accuracy: LocationAccuracy.high),
    );

    _startLocationStream(radiusMeters: radiusMeters);

    await updateUserLocation(
      lat: position.latitude,
      lng: position.longitude,
      radiusMeters: radiusMeters,
    );
  }

  Future<void> activateEmergency() async {
    await _withLoading(() async {
      try {
        final userId = _requireCurrentUserId();
        final latitude = _currentLatitude ?? 38.3552;
        final longitude = _currentLongitude ?? 38.3095;
        await _postEmergencyStart(
          userId: userId,
          latitude: latitude,
          longitude: longitude,
        );

        _emergencyActive = true;
        _showRiskDecision = false;
        _selectedIndex = 0;
        notifyListeners();
      } catch (e) {
        throw AppStateException(
          _toUserMessage(e, fallback: 'SOS başlatılamadı. Lütfen tekrar dene.'),
        );
      }
    });
  }

  Future<void> deactivateEmergency() async {
    if (!_emergencyActive) {
      return;
    }
    await _withLoading(() async {
      try {
        final userId = _requireCurrentUserId();
        await _postEmergencyStop(userId: userId);

        _emergencyActive = false;
        notifyListeners();
      } catch (e) {
        throw AppStateException(
          _toUserMessage(
            e,
            fallback: 'Acil durum kapatılamadı. Lütfen tekrar dene.',
          ),
        );
      }
    });
  }

  void acceptRiskDecision() {
    _showRiskDecision = false;
    _riskLevel = RiskLevel.high;
    notifyListeners();
  }

  void declineRiskDecision() {
    _showRiskDecision = false;
    _riskLevel = RiskLevel.low;
    notifyListeners();
  }

  Future<void> addLocalReport({
    required String category,
    required String locationLabel,
    required String latLng,
    required String description,
    double? reportLatitude,
    double? reportLongitude,
  }) async {
    await _withLoading(() async {
      try {
        final latitude = reportLatitude ??
            _currentLatitude ??
            _parseLatitude(latLng);
        final longitude = reportLongitude ??
            _currentLongitude ??
            _parseLongitude(latLng);

        if (latitude == null || longitude == null) {
          throw ApiException('Rapor icin gecerli bir konum bulunamadi.');
        }

        final backendCategory = _toBackendCategory(category);

        await _postReport(
          category: backendCategory,
          description: description,
          latitude: latitude,
          longitude: longitude,
        );

        _localReports.insert(
          0,
          LocalReportNotification(
            category: category,
            locationLabel: locationLabel,
            latLng: latLng,
            description: description,
            createdAt: DateTime.now(),
          ),
        );
        await _refreshNearbyReports(
          lat: latitude,
          lng: longitude,
          radiusMeters: 1000,
        );
        notifyListeners();
      } catch (e) {
        throw AppStateException(
          _toUserMessage(e, fallback: 'İhbar gönderilemedi.'),
        );
      }
    });
  }

  void setProfileVisibilityInAlerts(bool visible) {
    if (_isProfileVisibleInAlerts == visible) {
      return;
    }
    _isProfileVisibleInAlerts = visible;
    notifyListeners();
  }

  Future<void> saveEmergencyHealthInfo({
    String? bloodType,
    String? allergyNotes,
    String? emergencyNote,
  }) async {
    final previous = _emergencyHealthInfo;
    _emergencyHealthInfo = _emergencyHealthInfo.copyWith(
      bloodType: bloodType?.trim() ?? '',
      allergyNotes: allergyNotes?.trim() ?? '',
      emergencyNote: emergencyNote?.trim() ?? '',
    );

    try {
      await _persistEmergencyHealthInfo();
    } catch (_) {
      _emergencyHealthInfo = previous;
      rethrow;
    } finally {
      notifyListeners();
    }
  }

  void setPermission(String id, bool enabled) {
    final index = _permissions.indexWhere((item) => item.id == id);
    if (index == -1) {
      return;
    }
    _permissions = List<AppPermission>.from(_permissions)
      ..[index] = _permissions[index].copyWith(enabled: enabled);
    notifyListeners();
  }

  Future<void> loadEmergencyContacts() async {
    final rawContacts = await _contactsStorage.readContacts();
    if (rawContacts.isNotEmpty) {
      _emergencyContacts
        ..clear()
        ..addAll(rawContacts.map((e) => EmergencyContact.fromJson(e)));
    }
    notifyListeners();
  }

  void addEmergencyContact({required String name, required String phone}) {
    final newId = DateTime.now().microsecondsSinceEpoch.toString();
    final shouldBePrimary = _emergencyContacts.isEmpty;
    _emergencyContacts.add(
      EmergencyContact(
        id: newId,
        name: name.trim(),
        phone: phone.trim(),
        isPrimary: shouldBePrimary,
      ),
    );
    notifyListeners();
    _persistEmergencyContacts();
  }

  void removeEmergencyContact(String id) {
    final index = _emergencyContacts.indexWhere((item) => item.id == id);
    if (index == -1) {
      return;
    }
    final wasPrimary = _emergencyContacts[index].isPrimary;
    _emergencyContacts.removeAt(index);
    if (wasPrimary && _emergencyContacts.isNotEmpty) {
      _emergencyContacts[0] = _emergencyContacts[0].copyWith(isPrimary: true);
    }
    notifyListeners();
    _persistEmergencyContacts();
  }

  void setPrimaryEmergencyContact(String id) {
    final exists = _emergencyContacts.any((item) => item.id == id);
    if (!exists) {
      return;
    }
    for (var i = 0; i < _emergencyContacts.length; i++) {
      final item = _emergencyContacts[i];
      _emergencyContacts[i] = item.copyWith(isPrimary: item.id == id);
    }
    notifyListeners();
    _persistEmergencyContacts();
  }

  Future<void> logout() async {
    await _apiService.clearSession();
    _currentUser = null;
    _selectedIndex = 0;
    _riskLevel = RiskLevel.low;
    _emergencyActive = false;
    _showRiskDecision = false;
    _localReports.clear();
    _nearbyReports.clear();
    _isProfileVisibleInAlerts = true;
    _currentLatitude = null;
    _currentLongitude = null;
    _isMapDataLoading = false;
    notifyListeners();
  }

  Map<String, dynamic> _extractAuthData(Map<String, dynamic> response) {
    final data = response['data'];
    if (data is! Map<String, dynamic>) {
      throw ApiException('Unexpected auth response: missing data object');
    }
    return data;
  }

  Map<String, dynamic> _extractUserMap(Object? rawUser) {
    if (rawUser is! Map<String, dynamic>) {
      throw ApiException('Unexpected auth response: missing user object');
    }
    return rawUser;
  }

  SessionUser _toSessionUser(Map<String, dynamic> userMap) {
    return SessionUser(
      id: (userMap['id'] as num?)?.toInt(),
      email: userMap['email']?.toString() ?? '',
      username: userMap['username']?.toString() ?? '',
      phone: userMap['phone']?.toString() ?? '',
    );
  }

  void _setDefaultLandingScenario() {
    _showRiskDecision = false;
  }

  Future<void> _refreshRiskLevel({
    required double lat,
    required double lng,
  }) async {
    Map<String, dynamic> riskResponse;
    try {
      riskResponse = await _apiService.get('/map/risk?lat=$lat&lng=$lng');
    } on ApiException catch (e) {
      if (e.statusCode != 404) {
        rethrow;
      }
      riskResponse = await _apiService.get('/risk?lat=$lat&lng=$lng');
    }

    final levelRaw = riskResponse['level']?.toString().toUpperCase();
    switch (levelRaw) {
      case 'LOW':
        _riskLevel = RiskLevel.low;
      case 'MEDIUM':
        _riskLevel = RiskLevel.medium;
      case 'HIGH':
        _riskLevel = RiskLevel.high;
      default:
        throw ApiException('Unknown risk level: $levelRaw');
    }
  }

  Future<void> _refreshNearbyReports({
    required double lat,
    required double lng,
    required double radiusMeters,
  }) async {
    List<dynamic> rawList;
    try {
      rawList = await _apiService.getList(
        '/map/nearby?lat=$lat&lng=$lng&radius=$radiusMeters',
      );
    } on ApiException catch (e) {
      if (e.statusCode != 404) {
        rethrow;
      }
      rawList = await _apiService.getList(
        '/map/reports?lat=$lat&lng=$lng&radius=$radiusMeters',
      );
    }

    _nearbyReports
      ..clear()
      ..addAll(rawList.whereType<Map<String, dynamic>>().map(_toNearbyReport));
  }

  NearbyReport _toNearbyReport(Map<String, dynamic> item) {
    final id = (item['id'] as num?)?.toInt() ?? 0;
    final latitude = (item['latitude'] as num?)?.toDouble();
    final longitude = (item['longitude'] as num?)?.toDouble();
    if (latitude == null || longitude == null) {
      throw ApiException('Nearby report does not include coordinates');
    }

    return NearbyReport(
      id: id,
      category: item['category']?.toString() ?? 'UNKNOWN',
      description: item['description']?.toString() ?? '',
      latitude: latitude,
      longitude: longitude,
      status: item['status']?.toString() ?? '',
      createdAt: DateTime.tryParse(item['createdAt']?.toString() ?? ''),
    );
  }

  int _requireCurrentUserId() {
    final id = _currentUser?.id;
    if (id == null) {
      throw ApiException(
        'Kullanıcı kimliği bulunamadı. Lütfen tekrar giriş yapın.',
      );
    }
    return id;
  }

  Future<void> _postReport({
    required String category,
    required String description,
    required double latitude,
    required double longitude,
  }) async {
    final payload = <String, dynamic>{
      'category': category,
      'description': description,
      'latitude': latitude,
      'longitude': longitude,
    };

    try {
      await _apiService.post('/api/reports', body: payload);
    } on ApiException catch (e) {
      if (e.statusCode != 404) {
        rethrow;
      }
      await _apiService.post('/reports', body: payload);
    }
  }

  Future<void> _postEmergencyStart({
    required int userId,
    required double latitude,
    required double longitude,
  }) async {
    final payload = <String, dynamic>{
      'userId': userId,
      'latitude': latitude,
      'longitude': longitude,
      'sharedTo': <String>[],
    };

    try {
      await _apiService.post('/emergency/start', body: payload);
    } on ApiException catch (e) {
      if (e.statusCode != 404) {
        rethrow;
      }
      await _apiService.post('/api/emergency/start', body: payload);
    }
  }

  Future<void> _postEmergencyStop({required int userId}) async {
    final payload = <String, dynamic>{'userId': userId};

    try {
      await _apiService.post('/emergency/stop', body: payload);
    } on ApiException catch (e) {
      if (e.statusCode != 404) {
        rethrow;
      }
      await _apiService.post('/api/emergency/stop', body: payload);
    }
  }

  String _toBackendCategory(String category) {
    const mapping = <String, String>{
        'Trafik': 'TRAFFIC',
      'Saglik': 'HEALTH',
      'Suc': 'SECURITY',
      'Takip': 'SECURITY',
      'Hayvan': 'ANIMALS',
      'Ariza': 'INFRASTRUCTURE',
        'TRAFIK': 'TRAFFIC',
        'SAGLIK': 'HEALTH',
      'SUÇ': 'SECURITY',
      'SAĞLIK': 'HEALTH',
      'SUC': 'SECURITY',
      'TAKIP': 'SECURITY',
      'HAYVAN': 'ANIMALS',
      'ARIZA': 'INFRASTRUCTURE',
      'LIGHTING': 'LIGHTING',
      'HEALTH': 'HEALTH',
      'SECURITY': 'SECURITY',
      'TRAFFIC': 'TRAFFIC',
      'ANIMALS': 'ANIMALS',
      'INFRASTRUCTURE': 'INFRASTRUCTURE',
    };
    return mapping[category] ?? category.toUpperCase();
  }

  double? _parseLatitude(String latLng) {
    final parts = latLng.split(',');
    if (parts.length != 2) {
      return null;
    }
    return double.tryParse(parts[0].trim());
  }

  double? _parseLongitude(String latLng) {
    final parts = latLng.split(',');
    if (parts.length != 2) {
      return null;
    }
    return double.tryParse(parts[1].trim());
  }

  String _toUserMessage(Object error, {required String fallback}) {
    if (error is AppStateException) {
      return error.message;
    }
    if (error is ApiException) {
      if (error.statusCode == null) {
        return 'Ag baglantisi kurulamadi. Internetini kontrol et.';
      }
      if (error.statusCode! >= 500) {
        return 'Sunucu şu anda yanıt vermiyor. Lütfen daha sonra tekrar dene.';
      }
      if (error.statusCode == 400) {
        return error.message.isNotEmpty
            ? error.message
            : 'Gonderilen bilgiler gecersiz.';
      }
      if (error.statusCode == 401 || error.statusCode == 403) {
        return 'Bu işlem için oturumun geçersiz. Lütfen tekrar giriş yap.';
      }
      if (error.message.isNotEmpty) {
        return error.message;
      }
    }
    return fallback;
  }

  Future<void> _updateLocationName(double lat, double lng) async {
    final fallbackLabel = _formatCoordinateLabel(lat, lng);
    try {
      final placemarks = await placemarkFromCoordinates(lat, lng);
      if (placemarks.isNotEmpty) {
        _currentLocationName = _resolveLocationName(
          placemarks.first,
          fallbackLabel: fallbackLabel,
        );
      } else {
        _currentLocationName = fallbackLabel;
      }
      notifyListeners();
    } catch (e) {
      debugPrint('Failed to get location name: $e');
      _currentLocationName = fallbackLabel;
      notifyListeners();
    }
  }

  String _resolveLocationName(
    Placemark placemark, {
    required String fallbackLabel,
  }) {
    final primaryCandidates = <String?>[
      placemark.subAdministrativeArea,
      placemark.locality,
      placemark.subLocality,
      placemark.administrativeArea,
    ];
    final secondaryCandidates = <String?>[
      placemark.locality,
      placemark.administrativeArea,
      placemark.country,
    ];

    String? pick(List<String?> values) {
      for (final value in values) {
        final trimmed = value?.trim();
        if (trimmed != null && trimmed.isNotEmpty) {
          return trimmed;
        }
      }
      return null;
    }

    final primary = pick(primaryCandidates);
    final secondary = pick(secondaryCandidates);
    final parts = <String>[
      if (primary != null) primary,
      if (secondary != null && secondary != primary) secondary,
    ];

    if (parts.isNotEmpty) {
      return parts.join(', ');
    }

    final fallbackCandidates = <String?>[
      placemark.name,
      placemark.street,
      placemark.country,
    ];
    for (final value in fallbackCandidates) {
      final trimmed = value?.trim();
      if (value != null && value.isNotEmpty) {
        return trimmed!;
      }
    }

    return fallbackLabel;
  }

  String _formatCoordinateLabel(double lat, double lng) {
    return '${lat.toStringAsFixed(4)}, ${lng.toStringAsFixed(4)}';
  }

  Future<T> _withLoading<T>(Future<T> Function() action) async {
    _loadingCounter++;
    _isLoading = _loadingCounter > 0;
    notifyListeners();
    try {
      return await action();
    } finally {
      _loadingCounter--;
      if (_loadingCounter < 0) {
        _loadingCounter = 0;
      }
      _isLoading = _loadingCounter > 0;
      notifyListeners();
    }
  }

  Future<void> _persistEmergencyContacts() async {
    final jsonList = _emergencyContacts.map((c) => c.toJson()).toList();
    await _contactsStorage.saveContacts(jsonList);
  }

  Future<void> _loadEmergencyHealthInfo() async {
    final prefs = await SharedPreferences.getInstance();
    final raw = prefs.getString(_emergencyHealthInfoKey);
    if (raw == null || raw.isEmpty) {
      return;
    }

    try {
      final data = jsonDecode(raw);
      if (data is! Map<String, dynamic>) {
        return;
      }

      _emergencyHealthInfo = EmergencyHealthInfo(
        bloodType: data['bloodType']?.toString().trim() ?? '',
        allergyNotes: data['allergyNotes']?.toString().trim() ?? '',
        emergencyNote: data['emergencyNote']?.toString().trim() ?? '',
      );
      notifyListeners();
    } catch (e) {
      debugPrint('Failed to load emergency health info: $e');
    }
  }

  Future<void> _persistEmergencyHealthInfo() async {
    final prefs = await SharedPreferences.getInstance();
    final data = <String, String>{
      'bloodType': _emergencyHealthInfo.bloodType,
      'allergyNotes': _emergencyHealthInfo.allergyNotes,
      'emergencyNote': _emergencyHealthInfo.emergencyNote,
    };
    await prefs.setString(_emergencyHealthInfoKey, jsonEncode(data));
  }

  void _startLocationStream({double radiusMeters = 1000}) {
    _locationStreamSubscription ??= Geolocator.getPositionStream(
      locationSettings: const LocationSettings(
        accuracy: LocationAccuracy.high,
        distanceFilter: 10,
      ),
    ).listen((Position position) {
      unawaited(
        updateUserLocation(
          lat: position.latitude,
          lng: position.longitude,
          radiusMeters: radiusMeters,
        ),
      );
    });
  }

  @override
  void dispose() {
    _locationStreamSubscription?.cancel();
    super.dispose();
  }
}

class AppStateException implements Exception {
  const AppStateException(this.message);

  final String message;

  @override
  String toString() => message;
}
