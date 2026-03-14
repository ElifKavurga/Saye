import 'package:flutter/material.dart';
import 'package:permission_handler/permission_handler.dart';

import '../state/app_state.dart';
import '../theme/design_system.dart';
import 'safe_contacts_screen.dart';

class PermissionsScreen extends StatelessWidget {
  const PermissionsScreen({super.key, required this.appState});

  final AppState appState;

  Future<void> _handlePermissionChange(
    BuildContext context,
    AppPermission permission,
    bool value,
  ) async {
    if (!value) {
      appState.setPermission(permission.id, false);
      return;
    }

    final osPermission = _mapPermission(permission.id);
    if (osPermission == null) {
      appState.setPermission(permission.id, true);
      return;
    }

    final status = await osPermission.request();
    if (!context.mounted) {
      return;
    }

    final granted =
        status == PermissionStatus.granted ||
        status == PermissionStatus.limited ||
        status == PermissionStatus.provisional;

    appState.setPermission(permission.id, granted);
  }

  Permission? _mapPermission(String permissionId) {
    switch (permissionId) {
      case 'location_info':
        return Permission.location;
      case 'background_refresh':
        return Permission.locationAlways;
      case 'bluetooth':
        return Permission.bluetoothConnect;
      case 'gsm_sms':
        return Permission.sms;
      default:
        return null;
    }
  }

  @override
  Widget build(BuildContext context) {
    return AnimatedBuilder(
      animation: appState,
      builder: (context, _) {
        return Scaffold(
          body: Container(
            decoration: const BoxDecoration(
              gradient: AppGradients.mainBackground,
            ),
            child: SafeArea(
              child: SingleChildScrollView(
                padding: const EdgeInsets.fromLTRB(
                  AppSpacing.md,
                  AppSpacing.md,
                  AppSpacing.md,
                  AppSpacing.lg,
                ),
                child: Center(
                  child: ConstrainedBox(
                    constraints: const BoxConstraints(maxWidth: 520),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.stretch,
                      children: [
                        _TopHeader(onBack: () => Navigator.of(context).pop()),
                        const SizedBox(height: AppSpacing.lg),
                        Container(
                          padding: const EdgeInsets.all(AppSpacing.md),
                          decoration: BoxDecoration(
                            gradient: const LinearGradient(
                              begin: Alignment.topLeft,
                              end: Alignment.bottomRight,
                              colors: [Color(0xFF8EA599), Color(0xFF467447)],
                            ),
                            borderRadius: BorderRadius.circular(AppRadius.md),
                            boxShadow: AppShadows.soft,
                          ),
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Center(
                                child: Text(
                                  'İzinler',
                                  style: AppTextStyles.title.copyWith(
                                    fontSize: 36,
                                  ),
                                ),
                              ),
                              const Divider(color: Colors.white70, height: 18),
                              Text(
                                'Uygulama için gerekli cihaz izinlerini buradan yönetebilirsiniz.',
                                style: AppTextStyles.body.copyWith(
                                  color: Colors.white.withValues(alpha: 0.9),
                                  fontSize: 21,
                                  height: 1.35,
                                ),
                              ),
                              const SizedBox(height: AppSpacing.sm),
                              Align(
                                alignment: Alignment.centerLeft,
                                child: TextButton.icon(
                                  onPressed: () {
                                    Navigator.of(context).push(
                                      MaterialPageRoute<void>(
                                        builder: (_) => SafeContactsScreen(
                                          appState: appState,
                                        ),
                                      ),
                                    );
                                  },
                                  icon: const Icon(
                                    Icons.group_rounded,
                                    color: Colors.white,
                                  ),
                                  label: const Text('Acil Durum Kişileri'),
                                ),
                              ),
                              const SizedBox(height: AppSpacing.md),
                              ...appState.permissions.map(
                                (permission) => _PermissionTile(
                                  permission: permission,
                                  onChanged: (value) => _handlePermissionChange(
                                    context,
                                    permission,
                                    value,
                                  ),
                                ),
                              ),
                            ],
                          ),
                        ),
                      ],
                    ),
                  ),
                ),
              ),
            ),
          ),
        );
      },
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

class _PermissionTile extends StatelessWidget {
  const _PermissionTile({required this.permission, required this.onChanged});

  final AppPermission permission;
  final ValueChanged<bool> onChanged;

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.only(bottom: AppSpacing.sm),
      child: InkWell(
        onTap: () => onChanged(!permission.enabled),
        borderRadius: BorderRadius.circular(AppRadius.md),
        child: Row(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    permission.title,
                    style: AppTextStyles.body.copyWith(
                      fontSize: 27,
                      color: Colors.white,
                    ),
                  ),
                  const SizedBox(height: 3),
                  Text(
                    permission.description,
                    style: AppTextStyles.caption.copyWith(
                      color: Colors.white70,
                      fontSize: 15,
                      height: 1.3,
                    ),
                  ),
                ],
              ),
            ),
            const SizedBox(width: AppSpacing.sm),
            Switch.adaptive(
              value: permission.enabled,
              onChanged: onChanged,
              activeThumbColor: const Color(0xFF22D1CA),
            ),
          ],
        ),
      ),
    );
  }
}
