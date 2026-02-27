class HomeMetric {
  const HomeMetric({
    required this.title,
    required this.value,
    required this.delta,
  });

  final String title;
  final String value;
  final String delta;
}

class ReportItem {
  const ReportItem({
    required this.title,
    required this.location,
    required this.status,
    required this.time,
  });

  final String title;
  final String location;
  final String status;
  final String time;
}

class SettingOption {
  const SettingOption({
    required this.id,
    required this.title,
    required this.subtitle,
    required this.enabled,
  });

  final String id;
  final String title;
  final String subtitle;
  final bool enabled;

  SettingOption copyWith({bool? enabled}) {
    return SettingOption(
      id: id,
      title: title,
      subtitle: subtitle,
      enabled: enabled ?? this.enabled,
    );
  }
}

class ProfileData {
  const ProfileData({
    required this.name,
    required this.email,
    required this.role,
    required this.badges,
  });

  final String name;
  final String email;
  final String role;
  final List<String> badges;
}

class MockData {
  static const String appName = "SAYE'nde";
  static const String campusLocation = 'Kampus Yolu, Malatya';
  static const String selectedLocationLabel = 'Secili konum';
  static const String selectedLatLng = '38.3552, 38.3095';
  static const List<String> reportCategories = [
    'Trafik',
    'Ariza',
    'Saglik',
    'Takip',
    'Hayvan',
    'Suc',
  ];
  static const String welcomeMessage =
      'Saha verilerini tek panelde takip et, ekip aksiyonlarini hizlandir.';

  static const List<HomeMetric> homeMetrics = [
    HomeMetric(title: 'Aktif Gorev', value: '12', delta: '+3 bugun'),
    HomeMetric(title: 'Tamamlanan', value: '87%', delta: '+5 bu hafta'),
    HomeMetric(title: 'Acil Bildirim', value: '4', delta: '2 yeni'),
    HomeMetric(title: 'Cevrimici Ekip', value: '26', delta: 'stabil'),
  ];

  static const List<ReportItem> reports = [
    ReportItem(
      title: 'Yol Bakim Uyarisi',
      location: 'Kadikoy / Istanbul',
      status: 'Inceleniyor',
      time: '09:40',
    ),
    ReportItem(
      title: 'Aydinlatma Arizasi',
      location: 'Bornova / Izmir',
      status: 'Yonlendirildi',
      time: '10:12',
    ),
    ReportItem(
      title: 'Su Baskini Riski',
      location: 'Yildirim / Bursa',
      status: 'Acil',
      time: '10:28',
    ),
  ];

  static const List<SettingOption> settings = [
    SettingOption(
      id: 'push',
      title: 'Push Bildirimleri',
      subtitle: 'Anlik olaylari bildirim olarak al.',
      enabled: true,
    ),
    SettingOption(
      id: 'location',
      title: 'Konum Erisimi',
      subtitle: 'Yakin raporlari dogru listelemek icin kullanilir.',
      enabled: true,
    ),
    SettingOption(
      id: 'summary',
      title: 'Gunluk Ozet',
      subtitle: 'Her aksam performans ozeti gonder.',
      enabled: false,
    ),
  ];

  static const ProfileData profile = ProfileData(
    name: 'Saye Operator',
    email: 'operator@sayende.app',
    role: 'Field Coordinator',
    badges: ['Proaktif', 'Hizli Donus', 'Saha Uzmani'],
  );
}
