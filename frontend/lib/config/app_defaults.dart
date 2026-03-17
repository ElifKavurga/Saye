import 'app_strings.dart';

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
  static const String campusLocation = 'Kampüs Yolu, Malatya';
  static const String selectedLocationLabel = AppStrings.selectedLocation;
  static const String selectedLatLng = '38.3552, 38.3095';

  static const String fallbackProfileName = 'Saye Operator';
  static const String fallbackProfileEmail = 'operator@sayende.app';

  static const List<String> reportCategories = [
    AppStrings.trafficCategory,
    AppStrings.lightingCategory,
    AppStrings.infrastructureCategory,
    AppStrings.animalCategory,
    AppStrings.crimeCategory,
  ];

  static const List<SettingOption> settings = [
    SettingOption(
      id: 'push',
      title: 'Push Bildirimleri',
      subtitle: 'Anlık olayları bildirim olarak al.',
      enabled: true,
    ),
    SettingOption(
      id: 'location',
      title: 'Konum Erişimi',
      subtitle: 'Yakın raporları doğru listelemek için kullanılır.',
      enabled: true,
    ),
    SettingOption(
      id: 'summary',
      title: 'Günlük Özet',
      subtitle: 'Her akşam performans özeti gönder.',
      enabled: false,
    ),
  ];
}
