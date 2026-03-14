import 'package:flutter/material.dart';
import 'package:permission_handler/permission_handler.dart';

import '../state/app_state.dart';
import '../theme/design_system.dart';

class EmergencyInfoScreen extends StatefulWidget {
  const EmergencyInfoScreen({super.key, required this.appState});

  final AppState appState;

  @override
  State<EmergencyInfoScreen> createState() => _EmergencyInfoScreenState();
}

class _EmergencyInfoScreenState extends State<EmergencyInfoScreen> {
  bool _locationPermissionEnabled = false;
  bool _backgroundLocationEnabled = false;
  bool _bluetoothPermissionEnabled = false;
  bool _smsPermissionEnabled = false;

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Container(
        decoration: const BoxDecoration(gradient: AppGradients.mainBackground),
        child: SafeArea(
          child: LayoutBuilder(
            builder: (context, constraints) {
              return SingleChildScrollView(
                padding: const EdgeInsets.fromLTRB(
                  AppSpacing.md,
                  AppSpacing.md,
                  AppSpacing.md,
                  AppSpacing.lg,
                ),
                child: ConstrainedBox(
                  constraints: BoxConstraints(minHeight: constraints.maxHeight),
                  child: Center(
                    child: ConstrainedBox(
                      constraints: const BoxConstraints(maxWidth: 520),
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.stretch,
                        children: [
                          _TopHeader(onBack: () => Navigator.of(context).pop()),
                          const SizedBox(height: AppSpacing.lg),
                          _PermissionSection(
                            locationPermissionEnabled:
                                _locationPermissionEnabled,
                            backgroundLocationEnabled:
                                _backgroundLocationEnabled,
                            bluetoothPermissionEnabled:
                                _bluetoothPermissionEnabled,
                            smsPermissionEnabled: _smsPermissionEnabled,
                            onLocationChanged: (value) async {
                              if (!value) {
                                setState(() => _locationPermissionEnabled = false);
                                return;
                              }
                              final status = await Permission.location.request();
                              if (!mounted) {
                                return;
                              }
                              setState(() {
                                _locationPermissionEnabled =
                                    status == PermissionStatus.granted ||
                                    status == PermissionStatus.limited ||
                                    status == PermissionStatus.provisional;
                              });
                            },
                            onBackgroundLocationChanged: (value) async {
                              if (!value) {
                                setState(
                                  () => _backgroundLocationEnabled = false,
                                );
                                return;
                              }
                              final status =
                                  await Permission.locationAlways.request();
                              if (!mounted) {
                                return;
                              }
                              setState(() {
                                _backgroundLocationEnabled =
                                    status == PermissionStatus.granted ||
                                    status == PermissionStatus.limited ||
                                    status == PermissionStatus.provisional;
                              });
                            },
                            onBluetoothChanged: (value) async {
                              if (!value) {
                                setState(
                                  () => _bluetoothPermissionEnabled = false,
                                );
                                return;
                              }
                              final status =
                                  await Permission.bluetoothConnect.request();
                              if (!mounted) {
                                return;
                              }
                              setState(() {
                                _bluetoothPermissionEnabled =
                                    status == PermissionStatus.granted ||
                                    status == PermissionStatus.limited ||
                                    status == PermissionStatus.provisional;
                              });
                            },
                            onSmsChanged: (value) async {
                              if (!value) {
                                setState(() => _smsPermissionEnabled = false);
                                return;
                              }
                              final status = await Permission.sms.request();
                              if (!mounted) {
                                return;
                              }
                              setState(() {
                                _smsPermissionEnabled =
                                    status == PermissionStatus.granted ||
                                    status == PermissionStatus.limited ||
                                    status == PermissionStatus.provisional;
                              });
                            },
                          ),
                        ],
                      ),
                    ),
                  ),
                ),
              );
            },
          ),
        ),
      ),
    );
  }
}

class _TopHeader extends StatelessWidget {
  const _TopHeader({required this.onBack});

  final VoidCallback onBack;

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(
        horizontal: AppSpacing.md,
        vertical: AppSpacing.sm,
      ),
      decoration: BoxDecoration(
        color: const Color(0xFF284872).withValues(alpha: 0.9),
        borderRadius: BorderRadius.circular(AppRadius.lg),
      ),
      child: Row(
        children: [
          IconButton(
            onPressed: onBack,
            icon: const Icon(
              Icons.chevron_left_rounded,
              color: Color(0xFF4D8EEB),
              size: 34,
            ),
          ),
          Expanded(
            child: Text(
              'AYARLAR / GENEL',
              textAlign: TextAlign.center,
              style: AppTextStyles.title.copyWith(fontSize: 30),
            ),
          ),
          const SizedBox(width: 42),
        ],
      ),
    );
  }
}

class _PermissionSection extends StatelessWidget {
  const _PermissionSection({
    required this.locationPermissionEnabled,
    required this.backgroundLocationEnabled,
    required this.bluetoothPermissionEnabled,
    required this.smsPermissionEnabled,
    required this.onLocationChanged,
    required this.onBackgroundLocationChanged,
    required this.onBluetoothChanged,
    required this.onSmsChanged,
  });

  final bool locationPermissionEnabled;
  final bool backgroundLocationEnabled;
  final bool bluetoothPermissionEnabled;
  final bool smsPermissionEnabled;
  final ValueChanged<bool> onLocationChanged;
  final ValueChanged<bool> onBackgroundLocationChanged;
  final ValueChanged<bool> onBluetoothChanged;
  final ValueChanged<bool> onSmsChanged;

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(AppSpacing.md),
      decoration: BoxDecoration(
        color: const Color(0xFF163157).withValues(alpha: 0.9),
        borderRadius: BorderRadius.circular(AppRadius.md),
        boxShadow: AppShadows.soft,
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            'İzinler',
            style: AppTextStyles.title.copyWith(fontSize: 28),
          ),
          const SizedBox(height: AppSpacing.xs),
          Text(
            'Uygulama için gerekli cihaz izinlerini buradan yönetebilirsiniz.',
            style: AppTextStyles.body.copyWith(
              color: Colors.white.withValues(alpha: 0.88),
              fontSize: 18,
            ),
          ),
          const SizedBox(height: AppSpacing.md),
          Padding(
            padding: const EdgeInsets.only(bottom: AppSpacing.sm),
            child: _PermissionToggleTile(
              title: 'Konum Bilgileri',
              description:
                  'Acil durumda yakın güvenli bölgeyi hesaplamak için kullanılır.',
              value: locationPermissionEnabled,
              onChanged: onLocationChanged,
            ),
          ),
          Padding(
            padding: const EdgeInsets.only(bottom: AppSpacing.sm),
            child: _PermissionToggleTile(
              title: 'Arkaplanda Yenileme',
              description:
                  'Uygulama kapalıyken risk ve bildirim verilerini günceller.',
              value: backgroundLocationEnabled,
              onChanged: onBackgroundLocationChanged,
            ),
          ),
          Padding(
            padding: const EdgeInsets.only(bottom: AppSpacing.sm),
            child: _PermissionToggleTile(
              title: 'Bluetooth',
              description:
                  'Yakin cihaz taramasi ve takip analizi icin kullanilir.',
              value: bluetoothPermissionEnabled,
              onChanged: onBluetoothChanged,
            ),
          ),
          _PermissionToggleTile(
            title: 'GSM/SMS izinleri',
            description:
                'Acil durumda önceden tanımlı kişilere SMS göndermek için gereklidir.',
            value: smsPermissionEnabled,
            onChanged: onSmsChanged,
          ),
        ],
      ),
    );
  }
}

class _PermissionToggleTile extends StatelessWidget {
  const _PermissionToggleTile({
    required this.title,
    required this.description,
    required this.value,
    required this.onChanged,
  });

  final String title;
  final String description;
  final bool value;
  final ValueChanged<bool> onChanged;

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(
        horizontal: AppSpacing.md,
        vertical: AppSpacing.sm,
      ),
      decoration: BoxDecoration(
        color: const Color(0xFF22446B),
        borderRadius: BorderRadius.circular(AppRadius.md),
        border: Border.all(color: Colors.white10),
      ),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  title,
                  style: AppTextStyles.body.copyWith(
                    color: Colors.white,
                    fontWeight: FontWeight.w700,
                    fontSize: 18,
                  ),
                ),
                const SizedBox(height: 4),
                Text(
                  description,
                  style: AppTextStyles.caption.copyWith(
                    color: Colors.white70,
                  ),
                ),
              ],
            ),
          ),
          const SizedBox(width: AppSpacing.sm),
          Switch.adaptive(value: value, onChanged: onChanged),
        ],
      ),
    );
  }
}
