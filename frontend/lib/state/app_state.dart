import 'dart:async';
import 'dart:convert';

import 'package:flutter/material.dart';
import 'package:geocoding/geocoding.dart';
import 'package:geolocator/geolocator.dart';
import 'package:shared_preferences/shared_preferences.dart';

import '../config/app_defaults.dart';
import '../services/api_service.dart';
import '../services/emergency_contacts_service.dart';
import '../services/user_settings_service.dart';

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
    required this.riskRadiusMeters,
    required this.riskLevel,
    required this.riskScore,
    required this.clusterSize,
    required this.riskCenterLatitude,
    required this.riskCenterLongitude,
    required this.riskCircleId,
  });

  final int id;
  final String category;
  final String description;
  final double latitude;
  final double longitude;
  final String status;
  final DateTime? createdAt;
  final double riskRadiusMeters;
  final String riskLevel;
  final double riskScore;
  final int clusterSize;
  final double riskCenterLatitude;
  final double riskCenterLongitude;
  final String riskCircleId;
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

class UserSettingsData {
  const UserSettingsData({
    this.id,
    this.userId,
    this.profileVisible = true,
    this.locationTrackingEnabled = true,
    this.backgroundRefreshEnabled = true,
    this.bluetoothEnabled = true,
    this.gsmSmsEnabled = false,
    this.quickUnlockAccessEnabled = false,
  });

  final int? id;
  final int? userId;
  final bool profileVisible;
  final bool locationTrackingEnabled;
  final bool backgroundRefreshEnabled;
  final bool bluetoothEnabled;
  final bool gsmSmsEnabled;
  final bool quickUnlockAccessEnabled;

  factory UserSettingsData.fromJson(Map<String, dynamic> json) {
    return UserSettingsData(
      id: (json['id'] as num?)?.toInt(),
      userId: (json['userId'] as num?)?.toInt(),
      profileVisible: json['profileVisible'] as bool? ?? true,
      locationTrackingEnabled: json['locationTrackingEnabled'] as bool? ?? true,
      backgroundRefreshEnabled:
          json['backgroundRefreshEnabled'] as bool? ?? true,
      bluetoothEnabled: json['bluetoothEnabled'] as bool? ?? true,
      gsmSmsEnabled: json['gsmSmsEnabled'] as bool? ?? false,
      quickUnlockAccessEnabled:
          json['quickUnlockAccessEnabled'] as bool? ?? false,
    );
  }

  Map<String, dynamic> toRequestJson() {
    return {
      'profileVisible': profileVisible,
      'locationTrackingEnabled': locationTrackingEnabled,
      'backgroundRefreshEnabled': backgroundRefreshEnabled,
      'bluetoothEnabled': bluetoothEnabled,
      'gsmSmsEnabled': gsmSmsEnabled,
      'quickUnlockAccessEnabled': quickUnlockAccessEnabled,
    };
  }

  UserSettingsData copyWith({
    bool? profileVisible,
    bool? locationTrackingEnabled,
    bool? backgroundRefreshEnabled,
    bool? bluetoothEnabled,
    bool? gsmSmsEnabled,
    bool? quickUnlockAccessEnabled,
  }) {
    return UserSettingsData(
      id: id,
      userId: userId,
      profileVisible: profileVisible ?? this.profileVisible,
      locationTrackingEnabled:
          locationTrackingEnabled ?? this.locationTrackingEnabled,
      backgroundRefreshEnabled:
          backgroundRefreshEnabled ?? this.backgroundRefreshEnabled,
      bluetoothEnabled: bluetoothEnabled ?? this.bluetoothEnabled,
      gsmSmsEnabled: gsmSmsEnabled ?? this.gsmSmsEnabled,
      quickUnlockAccessEnabled:
          quickUnlockAccessEnabled ?? this.quickUnlockAccessEnabled,
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
    return {
      'id': id,
      'name': name,
      'phoneNumber': phone,
      'isPrimary': isPrimary,
    };
  }

  factory EmergencyContact.fromJson(Map<String, dynamic> json) {
    return EmergencyContact(
      id: json['id']?.toString() ?? '',
      name: json['name']?.toString() ?? '',
      phone: json['phoneNumber']?.toString() ?? json['phone']?.toString() ?? '',
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
  static const double _fallbackLatitude = 38.3552;
  static const double _fallbackLongitude = 38.3095;

  AppState({
    ApiService? apiService,
    EmergencyContactsService? emergencyContactsService,
    UserSettingsService? userSettingsService,
  }) : _apiService = apiService ?? ApiService(),
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
           description:
               'Yakin cihaz taramasi ve takip analizi icin kullanilir.',
           enabled: true,
         ),
       ],
       _emergencyContacts = [] {
    _emergencyContactsService =
        emergencyContactsService ??
        EmergencyContactsService(apiService: _apiService);
    _userSettingsService =
        userSettingsService ?? UserSettingsService(apiService: _apiService);
    _loadEmergencyHealthInfo();
  }

  static const String _emergencyHealthInfoKey = 'emergency_health_info';
  final ApiService _apiService;
  late final EmergencyContactsService _emergencyContactsService;
  late final UserSettingsService _userSettingsService;

  int _selectedIndex = 0;
  final List<SettingOption> _settings;
  List<AppPermission> _permissions;
  final List<EmergencyContact> _emergencyContacts;
  SessionUser? _currentUser;
  RiskLevel _riskLevel = RiskLevel.low;
  bool _emergencyActive = false;
  bool _showRiskDecision = false;
  bool _hasAcknowledgedHighRisk = false;
  final List<LocalReportNotification> _localReports = [];
  final List<NearbyReport> _nearbyReports = [];
  UserSettingsData _userSettings = const UserSettingsData();
  bool _hasLoadedUserSettings = false;
  bool _isUserSettingsLoading = false;
  bool _isUserSettingsSaving = false;
  EmergencyHealthInfo _emergencyHealthInfo = const EmergencyHealthInfo();
  double? _currentLatitude;
  double? _currentLongitude;
  String? _currentLocationName;
  bool _isMapDataLoading = false;
  DateTime? _lastMapSyncAt;
  Future<void>? _mapDataLoadFuture;
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
  bool get isProfileVisibleInAlerts => _userSettings.profileVisible;
  EmergencyHealthInfo get emergencyHealthInfo => _emergencyHealthInfo;
  List<AppPermission> get permissions => List.unmodifiable(_permissions);
  UserSettingsData get userSettings => _userSettings;
  List<EmergencyContact> get emergencyContacts =>
      List.unmodifiable(_emergencyContacts);
  double? get currentLatitude => _currentLatitude;
  double? get currentLongitude => _currentLongitude;
  String get currentLocationName =>
      _currentLocationName ?? AppDefaults.campusLocation;
  bool get isMapDataLoading => _isMapDataLoading;
  bool get isLoading => _isLoading;
  bool get hasLoadedUserSettings => _hasLoadedUserSettings;
  bool get isUserSettingsLoading => _isUserSettingsLoading;
  bool get isUserSettingsSaving => _isUserSettingsSaving;
  bool get isUserSettingsBusy =>
      _isUserSettingsLoading || _isUserSettingsSaving;
  EmergencyContact? get primaryEmergencyContact {
    for (final contact in _emergencyContacts) {
      if (contact.isPrimary) {
        return contact;
      }
    }
    return _emergencyContacts.isEmpty ? null : _emergencyContacts.first;
  }

  Future<void> initialize() async {
    await checkAuthStatus();
  }

  void setIndex(int index) {
    if (_selectedIndex == index) {
      return;
    }
    _selectedIndex = index;
    if (index == 2 && isAuthenticated) {
      refreshUserSettingsInBackground(force: true);
    }
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
        await _applyAuthenticatedSession(response);
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
        await _applyAuthenticatedSession(response);
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
          _setEmergencyContacts(const [], notify: false);
          _resetUserSettings(notify: false);
          _currentUser = null;
          _setDefaultLandingScenario();
          notifyListeners();
          return;
        }
        final userMap = await _apiService.readUserSession();
        if (userMap == null) {
          await _apiService.clearSession();
          _currentUser = null;
          _setEmergencyContacts(const [], notify: false);
          _resetUserSettings(notify: false);
          _setDefaultLandingScenario();
          notifyListeners();
          return;
        }
        _currentUser = _toSessionUser(userMap);
        _setDefaultLandingScenario();
        await _loadSessionSideData(notify: false);
        notifyListeners();
      } catch (e) {
        await _apiService.clearSession();
        _currentUser = null;
        _setEmergencyContacts(const [], notify: false);
        _resetUserSettings(notify: false);
        _setDefaultLandingScenario();
        notifyListeners();
      }
    });
  }

  Future<void> demoLogin() async {
    await _withLoading(() async {
      try {
        final response = await _apiService.post('/auth/demo-login');
        await _applyAuthenticatedSession(response);
      } catch (e) {
        throw AppStateException(
          _toUserMessage(e, fallback: 'Demo oturumu baslatilamadi.'),
        );
      }
    });
  }

  void cycleRiskLevel() {
    switch (_riskLevel) {
      case RiskLevel.low:
        _riskLevel = RiskLevel.medium;
        break;
      case RiskLevel.medium:
        _riskLevel = RiskLevel.high;
        break;
      case RiskLevel.high:
        _riskLevel = RiskLevel.low;
        break;
    }
    notifyListeners();
  }

  Future<void> updateUserLocation({
    required double lat,
    required double lng,
    double radiusMeters = 1000,
  }) async {
    _currentLatitude = lat;
    _currentLongitude = lng;
    _isMapDataLoading = true;
    notifyListeners();

    try {
      await Future.wait<void>([
        _updateLocationName(lat, lng),
        _refreshRiskLevel(lat: lat, lng: lng),
        _refreshNearbyReports(lat: lat, lng: lng, radiusMeters: radiusMeters),
      ]);
      _lastMapSyncAt = DateTime.now();
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
  }

  Future<void> ensureMapDataLoaded({
    bool force = false,
    double radiusMeters = 1000,
  }) async {
    if (_mapDataLoadFuture != null) {
      return _mapDataLoadFuture!;
    }

    final hasKnownLocation =
        _currentLatitude != null && _currentLongitude != null;
    final hasFreshData =
        !force &&
        _lastMapSyncAt != null &&
        DateTime.now().difference(_lastMapSyncAt!) < const Duration(minutes: 2);

    if (hasKnownLocation && hasFreshData) {
      return;
    }

    final loadFuture = _loadMapData(radiusMeters: radiusMeters);
    _mapDataLoadFuture = loadFuture;
    try {
      await loadFuture;
    } finally {
      if (identical(_mapDataLoadFuture, loadFuture)) {
        _mapDataLoadFuture = null;
      }
    }
  }

  Future<void> refreshMapData({
    double? lat,
    double? lng,
    double radiusMeters = 1000,
  }) async {
    await updateUserLocation(
      lat: lat ?? _currentLatitude ?? _fallbackLatitude,
      lng: lng ?? _currentLongitude ?? _fallbackLongitude,
      radiusMeters: radiusMeters,
    );
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
    _hasAcknowledgedHighRisk = true;
    _riskLevel = RiskLevel.high;
    notifyListeners();
  }

  void declineRiskDecision() {
    _showRiskDecision = false;
    _hasAcknowledgedHighRisk = true;
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
    try {
      final latitude =
          reportLatitude ?? _currentLatitude ?? _parseLatitude(latLng);
      final longitude =
          reportLongitude ?? _currentLongitude ?? _parseLongitude(latLng);

      if (latitude == null || longitude == null) {
        throw ApiException('Rapor icin gecerli bir konum bulunamadi.');
      }

      final backendCategory = _toBackendCategory(category);
      final submittedAt = DateTime.now();

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
          createdAt: submittedAt,
        ),
      );
      _insertOptimisticNearbyReport(
        category: backendCategory,
        description: description,
        latitude: latitude,
        longitude: longitude,
        createdAt: submittedAt,
      );
      notifyListeners();
      try {
        await refreshMapData(
          lat: _currentLatitude ?? latitude,
          lng: _currentLongitude ?? longitude,
          radiusMeters: 1000,
        );
      } catch (refreshError) {
        debugPrint('Report submitted but map refresh failed: $refreshError');
      }
    } catch (e) {
      throw AppStateException(
          _toUserMessage(e, fallback: 'İhbar gönderilemedi.'),
        );
    }
  }

  Future<void> fetchUserSettings({bool force = false}) async {
    if (_currentUser == null) {
      _resetUserSettings();
      return;
    }

    if (_isUserSettingsLoading || (!force && _hasLoadedUserSettings)) {
      return;
    }

    _isUserSettingsLoading = true;
    notifyListeners();
    try {
      await _loadUserSettingsForCurrentUser(force: force, notify: false);
      notifyListeners();
    } catch (e) {
      throw AppStateException(
        _toUserMessage(
          e,
          fallback: 'Ayarlar yuklenemedi. Lutfen tekrar deneyin.',
        ),
      );
    } finally {
      _isUserSettingsLoading = false;
      notifyListeners();
    }
  }

  void refreshUserSettingsInBackground({bool force = false}) {
    unawaited(_refreshUserSettingsSilently(force: force));
  }

  Future<void> updateProfileVisibilityInAlerts(bool visible) async {
    if (_userSettings.profileVisible == visible) {
      return;
    }
    await _saveUserSettings(
      _userSettings.copyWith(profileVisible: visible),
      fallback: 'Profil gorunurlugu guncellenemedi. Lutfen tekrar deneyin.',
    );
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

  Future<void> updatePermission(String id, bool enabled) async {
    final index = _permissions.indexWhere((item) => item.id == id);
    if (index == -1) {
      return;
    }

    if (_isServerBackedPermission(id)) {
      await _saveUserSettings(
        _userSettings.copyWith(
          locationTrackingEnabled: id == 'location_info'
              ? enabled
              : _userSettings.locationTrackingEnabled,
          backgroundRefreshEnabled: id == 'background_refresh'
              ? enabled
              : _userSettings.backgroundRefreshEnabled,
          bluetoothEnabled: id == 'bluetooth'
              ? enabled
              : _userSettings.bluetoothEnabled,
          gsmSmsEnabled: id == 'gsm_sms' ? enabled : _userSettings.gsmSmsEnabled,
          quickUnlockAccessEnabled: id == 'quick_unlock_access'
              ? enabled
              : _userSettings.quickUnlockAccessEnabled,
        ),
        fallback: 'Izin ayari guncellenemedi. Lutfen tekrar deneyin.',
      );
      return;
    }

    _setPermissionLocally(id, enabled);
    notifyListeners();
  }

  Future<void> loadEmergencyContacts() async {
    await _withLoading(() async {
      try {
        await _loadEmergencyContactsForCurrentUser();
      } catch (e) {
        throw AppStateException(
          _toUserMessage(
            e,
            fallback: 'Acil durum kisileri yuklenemedi. Lutfen tekrar deneyin.',
          ),
        );
      }
    });
  }

  Future<void> addEmergencyContact({
    required String name,
    required String phone,
  }) async {
    await _withLoading(() async {
      try {
        final userId = _requireCurrentUserId();
        await _emergencyContactsService.createContact(
          userId: userId,
          name: name,
          phoneNumber: phone,
          isPrimary: _emergencyContacts.isEmpty,
        );
        await _loadEmergencyContactsForCurrentUser(notify: false);
        notifyListeners();
      } catch (e) {
        throw AppStateException(
          _toUserMessage(
            e,
            fallback: 'Acil durum kisisi eklenemedi. Lutfen tekrar deneyin.',
          ),
        );
      }
    });
  }

  Future<void> removeEmergencyContact(String id) async {
    await _withLoading(() async {
      try {
        final userId = _requireCurrentUserId();
        await _emergencyContactsService.deleteContact(
          userId: userId,
          contactId: id,
        );
        await _loadEmergencyContactsForCurrentUser(notify: false);
        notifyListeners();
      } catch (e) {
        throw AppStateException(
          _toUserMessage(
            e,
            fallback: 'Acil durum kisisi silinemedi. Lutfen tekrar deneyin.',
          ),
        );
      }
    });
  }

  Future<void> setPrimaryEmergencyContact(String id) async {
    EmergencyContact? contact;
    for (final item in _emergencyContacts) {
      if (item.id == id) {
        contact = item;
        break;
      }
    }
    if (contact == null) {
      return;
    }
    final selectedContact = contact;

    await _withLoading(() async {
      try {
        final userId = _requireCurrentUserId();
        await _emergencyContactsService.updateContact(
          userId: userId,
          contactId: id,
          name: selectedContact.name,
          phoneNumber: selectedContact.phone,
          isPrimary: true,
        );
        await _loadEmergencyContactsForCurrentUser(notify: false);
        notifyListeners();
      } catch (e) {
        throw AppStateException(
          _toUserMessage(
            e,
            fallback:
                'Birincil acil durum kisisi guncellenemedi. Lutfen tekrar deneyin.',
          ),
        );
      }
    });
  }

  Future<void> logout() async {
    await _apiService.clearSession();
    _currentUser = null;
    _selectedIndex = 0;
    _riskLevel = RiskLevel.low;
    _emergencyActive = false;
    _showRiskDecision = false;
    _hasAcknowledgedHighRisk = false;
    _localReports.clear();
    _nearbyReports.clear();
    _emergencyContacts.clear();
    _resetUserSettings(notify: false);
    _currentLatitude = null;
    _currentLongitude = null;
    _isMapDataLoading = false;
    _lastMapSyncAt = null;
    _mapDataLoadFuture = null;
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

  Future<void> _applyAuthenticatedSession(Map<String, dynamic> response) async {
    final authData = _extractAuthData(response);
    final token = authData['token']?.toString();
    final userMap = _extractUserMap(authData['user']);
    if (token == null || token.isEmpty) {
      throw ApiException('Auth response does not include a valid token');
    }

    await _apiService.saveToken(token);
    await _apiService.saveUserSession(userMap);
    _currentUser = _toSessionUser(userMap);
    _setDefaultLandingScenario();
    await _loadSessionSideData(notify: false);
    notifyListeners();
  }

  Future<void> _loadSessionSideData({bool notify = false}) async {
    try {
      await _loadEmergencyContactsForCurrentUser(notify: notify);
    } catch (e) {
      debugPrint('Failed to load emergency contacts: $e');
      _setEmergencyContacts(const [], notify: notify);
    }

    try {
      await _loadUserSettingsForCurrentUser(force: true, notify: notify);
    } catch (e) {
      debugPrint('Failed to load user settings: $e');
      _resetUserSettings(notify: notify);
    }
  }

  Future<void> _refreshUserSettingsSilently({bool force = false}) async {
    try {
      await fetchUserSettings(force: force);
    } catch (_) {}
  }

  Future<void> _loadUserSettingsForCurrentUser({
    bool force = false,
    bool notify = true,
  }) async {
    final userId = _currentUser?.id;
    if (userId == null) {
      _resetUserSettings(notify: notify);
      return;
    }
    if (!force && _hasLoadedUserSettings) {
      return;
    }

    final rawSettings = await _userSettingsService.fetchSettings(
      userId: userId,
    );
    _applyUserSettings(UserSettingsData.fromJson(rawSettings), notify: notify);
  }

  Future<void> _saveUserSettings(
    UserSettingsData nextSettings, {
    required String fallback,
  }) async {
    final previousSettings = _userSettings;
    final previousPermissions = List<AppPermission>.from(_permissions);

    _applyUserSettings(nextSettings, notify: true);
    _isUserSettingsSaving = true;
    notifyListeners();

    try {
      final userId = _requireCurrentUserId();
      final rawSettings = await _userSettingsService.updateSettings(
        userId: userId,
        body: nextSettings.toRequestJson(),
      );
      _applyUserSettings(UserSettingsData.fromJson(rawSettings), notify: false);
      notifyListeners();
    } catch (e) {
      _userSettings = previousSettings;
      _permissions = previousPermissions;
      notifyListeners();
      throw AppStateException(_toUserMessage(e, fallback: fallback));
    } finally {
      _isUserSettingsSaving = false;
      notifyListeners();
    }
  }

  void _applyUserSettings(UserSettingsData settings, {bool notify = true}) {
    _userSettings = settings;
    _hasLoadedUserSettings = true;
    _setPermissionLocally('location_info', settings.locationTrackingEnabled);
    _setPermissionLocally(
      'background_refresh',
      settings.backgroundRefreshEnabled,
    );
    _setPermissionLocally('bluetooth', settings.bluetoothEnabled);
    _setPermissionLocally('gsm_sms', settings.gsmSmsEnabled);
    _setPermissionLocally(
      'quick_unlock_access',
      settings.quickUnlockAccessEnabled,
    );
    if (notify) {
      notifyListeners();
    }
  }

  void _resetUserSettings({bool notify = true}) {
    _userSettings = const UserSettingsData();
    _hasLoadedUserSettings = false;
    _isUserSettingsLoading = false;
    _isUserSettingsSaving = false;
    _setPermissionLocally('location_info', true);
    _setPermissionLocally('background_refresh', true);
    _setPermissionLocally('bluetooth', true);
    _setPermissionLocally('gsm_sms', false);
    _setPermissionLocally('quick_unlock_access', false);
    if (notify) {
      notifyListeners();
    }
  }

  void _setPermissionLocally(String id, bool enabled) {
    final index = _permissions.indexWhere((item) => item.id == id);
    if (index == -1) {
      return;
    }
    _permissions = List<AppPermission>.from(_permissions)
      ..[index] = _permissions[index].copyWith(enabled: enabled);
  }

  bool _isServerBackedPermission(String id) {
    return id == 'location_info' ||
        id == 'background_refresh' ||
        id == 'bluetooth' ||
        id == 'gsm_sms' ||
        id == 'quick_unlock_access';
  }

  Future<void> _loadEmergencyContactsForCurrentUser({
    bool notify = true,
  }) async {
    final userId = _currentUser?.id;
    if (userId == null) {
      _setEmergencyContacts(const [], notify: notify);
      return;
    }

    final rawContacts = await _emergencyContactsService.fetchContacts(
      userId: userId,
    );
    _setEmergencyContacts(
      rawContacts.map(EmergencyContact.fromJson).toList(growable: false),
      notify: notify,
    );
  }

  void _setEmergencyContacts(
    List<EmergencyContact> contacts, {
    bool notify = true,
  }) {
    _emergencyContacts
      ..clear()
      ..addAll(contacts);
    if (notify) {
      notifyListeners();
    }
  }

  Future<void> _refreshRiskLevel({
    required double lat,
    required double lng,
  }) async {
    final previousRiskLevel = _riskLevel;
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
        break;
      case 'MEDIUM':
        _riskLevel = RiskLevel.medium;
        break;
      case 'HIGH':
        _riskLevel = RiskLevel.high;
        break;
      default:
        throw ApiException('Unknown risk level: $levelRaw');
    }

    if (_riskLevel != RiskLevel.high) {
      _showRiskDecision = false;
      _hasAcknowledgedHighRisk = false;
      return;
    }

    final enteredHighRisk = previousRiskLevel != RiskLevel.high;
    if (!_emergencyActive && enteredHighRisk && !_hasAcknowledgedHighRisk) {
      _showRiskDecision = true;
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
      riskRadiusMeters: (item['riskRadiusMeters'] as num?)?.toDouble() ?? 150,
      riskLevel: item['riskLevel']?.toString() ?? 'MEDIUM',
      riskScore: (item['riskScore'] as num?)?.toDouble() ?? 25,
      clusterSize: (item['clusterSize'] as num?)?.toInt() ?? 1,
      riskCenterLatitude:
          (item['riskCenterLatitude'] as num?)?.toDouble() ?? latitude,
      riskCenterLongitude:
          (item['riskCenterLongitude'] as num?)?.toDouble() ?? longitude,
      riskCircleId:
          item['riskCircleId']?.toString() ??
          'circle-$id-${latitude.toStringAsFixed(6)}-${longitude.toStringAsFixed(6)}',
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
    final parts = <String>[];
    if (primary != null) {
      parts.add(primary);
    }
    if (secondary != null && secondary != primary) {
      parts.add(secondary);
    }

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
    _locationStreamSubscription ??=
        Geolocator.getPositionStream(
          locationSettings: const LocationSettings(
            accuracy: LocationAccuracy.high,
            distanceFilter: 10,
          ),
        ).listen((Position position) {
          unawaited(
            refreshMapData(
              lat: position.latitude,
              lng: position.longitude,
              radiusMeters: radiusMeters,
            ),
          );
        });
  }

  Future<void> _loadMapData({required double radiusMeters}) async {
    if (_currentLatitude != null && _currentLongitude != null) {
      await refreshMapData(radiusMeters: radiusMeters);
      return;
    }

    try {
      await fetchRealLocation(radiusMeters: radiusMeters);
      return;
    } catch (e) {
      debugPrint('Falling back to default map coordinates: $e');
    }

    await refreshMapData(
      lat: _fallbackLatitude,
      lng: _fallbackLongitude,
      radiusMeters: radiusMeters,
    );
  }

  void _insertOptimisticNearbyReport({
    required String category,
    required String description,
    required double latitude,
    required double longitude,
    required DateTime createdAt,
  }) {
    final duplicateExists = _nearbyReports.any(
      (report) =>
          _normalizeRiskCategory(report.category) ==
              _normalizeRiskCategory(category) &&
          (report.latitude - latitude).abs() < 0.00001 &&
          (report.longitude - longitude).abs() < 0.00001,
    );
    if (duplicateExists) {
      return;
    }

    _nearbyReports.insert(
      0,
      NearbyReport(
        id: -createdAt.microsecondsSinceEpoch,
        category: category,
        description: description,
        latitude: latitude,
        longitude: longitude,
        status: 'PENDING',
        createdAt: createdAt,
        riskRadiusMeters: _fallbackRiskRadiusForCategory(category),
        riskLevel: _fallbackRiskLevelForCategory(category),
        riskScore: _fallbackRiskScoreForCategory(category),
        clusterSize: 1,
        riskCenterLatitude: latitude,
        riskCenterLongitude: longitude,
        riskCircleId:
            'circle-${latitude.toStringAsFixed(6)}-${longitude.toStringAsFixed(6)}',
      ),
    );
  }

  double _fallbackRiskRadiusForCategory(String category) {
    switch (_normalizeRiskCategory(category)) {
      case 'SECURITY':
        return 400;
      case 'ANIMALS':
        return 360;
      case 'HEALTH':
        return 320;
      case 'TRAFFIC':
        return 150;
      default:
        return 220;
    }
  }

  String _fallbackRiskLevelForCategory(String category) {
    switch (_normalizeRiskCategory(category)) {
      case 'SECURITY':
      case 'ANIMALS':
      case 'HEALTH':
        return 'HIGH';
      case 'TRAFFIC':
        return 'MEDIUM';
      default:
        return 'MEDIUM';
    }
  }

  double _fallbackRiskScoreForCategory(String category) {
    switch (_normalizeRiskCategory(category)) {
      case 'SECURITY':
        return 70;
      case 'ANIMALS':
        return 65;
      case 'HEALTH':
        return 60;
      case 'TRAFFIC':
        return 40;
      default:
        return 35;
    }
  }

  String _normalizeRiskCategory(String category) {
    return category.trim().toUpperCase();
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
