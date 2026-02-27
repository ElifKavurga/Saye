import 'package:flutter/material.dart';

import '../data/mock_data.dart';

class SessionUser {
  const SessionUser({
    required this.email,
    required this.username,
    required this.phone,
  });

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

class EmergencyHealthInfo {
  const EmergencyHealthInfo({
    this.bloodType = '',
    this.allergyNotes = '',
    this.emergencyNote = '',
  });

  final String bloodType;
  final String allergyNotes;
  final String emergencyNote;

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

  EmergencyContact copyWith({
    String? name,
    String? phone,
    bool? isPrimary,
  }) {
    return EmergencyContact(
      id: id,
      name: name ?? this.name,
      phone: phone ?? this.phone,
      isPrimary: isPrimary ?? this.isPrimary,
    );
  }
}

class AppState extends ChangeNotifier {
  AppState()
      : _settings = List<SettingOption>.from(MockData.settings),
        _permissions = const [
          AppPermission(
            id: 'location_info',
            title: 'Konum Bilgileri',
            description: 'Acil durumda yakin guvenli bolgeyi hesaplamak icin kullanilir.',
            enabled: true,
          ),
          AppPermission(
            id: 'background_refresh',
            title: 'Arkaplanda Yenileme',
            description: 'Uygulama kapaliyken risk ve bildirim verilerini gunceller.',
            enabled: true,
          ),
          AppPermission(
            id: 'quick_unlock_access',
            title: 'Ekran Kilitsiz Kolay Erisim',
            description: 'Acil butona daha hizli ulasman icin kilit ekrani kisayolu sunar.',
            enabled: false,
          ),
          AppPermission(
            id: 'gsm_sms',
            title: 'GSM/SMS izinleri',
            description: 'Acil durumda onceden tanimli kisilere SMS gondermek icin gereklidir.',
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
        ];

  int _selectedIndex = 0;
  final List<SettingOption> _settings;
  final List<AppPermission> _permissions;
  final List<EmergencyContact> _emergencyContacts;
  SessionUser? _currentUser;
  RiskLevel _riskLevel = RiskLevel.low;
  bool _emergencyActive = false;
  final List<LocalReportNotification> _localReports = [];
  bool _isProfileVisibleInAlerts = true;
  EmergencyHealthInfo _emergencyHealthInfo = const EmergencyHealthInfo();

  int get selectedIndex => _selectedIndex;
  List<SettingOption> get settings => List.unmodifiable(_settings);
  SessionUser? get currentUser => _currentUser;
  bool get isAuthenticated => _currentUser != null;
  RiskLevel get riskLevel => _riskLevel;
  bool get emergencyActive => _emergencyActive;
  List<LocalReportNotification> get localReports => List.unmodifiable(_localReports);
  bool get isProfileVisibleInAlerts => _isProfileVisibleInAlerts;
  EmergencyHealthInfo get emergencyHealthInfo => _emergencyHealthInfo;
  List<AppPermission> get permissions => List.unmodifiable(_permissions);
  List<EmergencyContact> get emergencyContacts => List.unmodifiable(_emergencyContacts);
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

  void login({
    required String email,
    required String password,
  }) {
    _currentUser = SessionUser(
      email: email.trim(),
      username: email.split('@').first,
      phone: '',
    );
    notifyListeners();
  }

  void register({
    required String email,
    required String username,
    required String password,
    required String phone,
  }) {
    _currentUser = SessionUser(
      email: email.trim(),
      username: username.trim(),
      phone: phone.trim(),
    );
    notifyListeners();
  }

  void demoLogin() {
    // TODO: Backend auth tamamlandiginda demo gecisini kaldir ve gercek login/register kullan.
    _currentUser = const SessionUser(
      email: 'demo@sayende.app',
      username: 'demo_user',
      phone: '',
    );
    notifyListeners();
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

  void activateEmergency() {
    _emergencyActive = true;
    _selectedIndex = 0;
    notifyListeners();
  }

  void deactivateEmergency() {
    if (!_emergencyActive) {
      return;
    }
    _emergencyActive = false;
    notifyListeners();
  }

  void addLocalReport({
    required String category,
    required String locationLabel,
    required String latLng,
    required String description,
  }) {
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
    notifyListeners();
  }

  void setProfileVisibilityInAlerts(bool visible) {
    if (_isProfileVisibleInAlerts == visible) {
      return;
    }
    _isProfileVisibleInAlerts = visible;
    notifyListeners();
  }

  void saveEmergencyHealthInfo({
    String? bloodType,
    String? allergyNotes,
    String? emergencyNote,
  }) {
    _emergencyHealthInfo = _emergencyHealthInfo.copyWith(
      bloodType: bloodType?.trim(),
      allergyNotes: allergyNotes?.trim(),
      emergencyNote: emergencyNote?.trim(),
    );
    notifyListeners();
  }

  void setPermission(String id, bool enabled) {
    final index = _permissions.indexWhere((item) => item.id == id);
    if (index == -1) {
      return;
    }
    _permissions[index] = _permissions[index].copyWith(enabled: enabled);
    notifyListeners();
  }

  void addEmergencyContact({
    required String name,
    required String phone,
  }) {
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
  }

  void logout() {
    _currentUser = null;
    _selectedIndex = 0;
    _riskLevel = RiskLevel.low;
    _emergencyActive = false;
    _localReports.clear();
    _isProfileVisibleInAlerts = true;
    _emergencyHealthInfo = const EmergencyHealthInfo();
    _emergencyContacts
      ..clear()
      ..addAll(const [
        EmergencyContact(
          id: 'c1',
          name: 'Ayse Demir',
          phone: '0555 111 22 33',
          isPrimary: true,
        ),
        EmergencyContact(
          id: 'c2',
          name: 'Mehmet Kaya',
          phone: '0555 444 55 66',
        ),
      ]);
    notifyListeners();
  }
}
