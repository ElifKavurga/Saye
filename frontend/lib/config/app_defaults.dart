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

class AppDefaults {
  static const String campusLocation = 'Kampus Yolu, Malatya';
  static const String selectedLocationLabel = 'Secili konum';
  static const String selectedLatLng = '38.3552, 38.3095';

  static const String fallbackProfileName = 'Saye Operator';
  static const String fallbackProfileEmail = 'operator@sayende.app';

  static const List<String> reportCategories = [
    'Trafik',
    'Ariza',
    'Saglik',
    'Takip',
    'Hayvan',
    'Suc',
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
}
