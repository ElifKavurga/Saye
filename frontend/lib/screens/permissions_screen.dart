import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:permission_handler/permission_handler.dart';

import '../state/app_state.dart';
import '../theme/design_system.dart';
import 'safe_contacts_screen.dart';

class PermissionsScreen extends StatefulWidget {
  const PermissionsScreen({super.key, required this.appState});

  final AppState appState;

  @override
  State<PermissionsScreen> createState() => _PermissionsScreenState();
}

class _PermissionsScreenState extends State<PermissionsScreen> {
  AppState get appState => widget.appState;

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      appState.refreshUserSettingsInBackground(force: true);
    });
  }

  Future<void> _handlePermissionChange(
    BuildContext context,
    AppPermission permission,
    bool value,
  ) async {
    if (appState.isUserSettingsBusy) {
      return;
    }

    bool nextValue = value;
    if (value) {
      final osPermission = _mapPermission(permission.id);
      if (osPermission != null) {
        final status = await osPermission.request();
        if (!context.mounted) {
          return;
        }
        nextValue =
            status == PermissionStatus.granted ||
            status == PermissionStatus.limited ||
            status == PermissionStatus.provisional;
      }
    }

    try {
      await appState.updatePermission(permission.id, nextValue);
    } catch (error) {
      _showError(error);
    }
  }

  Permission? _mapPermission(String permissionId) {
    switch (permissionId) {
      case 'location_info':
        return Permission.location;
      case 'background_refresh':
        return Permission.locationAlways;
      case 'gsm_sms':
        return Permission.sms;
      default:
        return null;
    }
  }

  void _showError(Object error) {
    if (!mounted) {
      return;
    }

    final message = error is AppStateException
        ? error.message
        : error.toString();
    if (message.trim().isEmpty) {
      return;
    }
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(content: Text(message), behavior: SnackBarBehavior.floating),
    );
  }

  @override
  Widget build(BuildContext context) {
    return AnimatedBuilder(
      animation: appState,
      builder: (context, _) {
        final permissions = appState.permissions;

        return Scaffold(
          body: Container(
            decoration: const BoxDecoration(
              gradient: AppGradients.mainBackground,
            ),
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
                              _TopHeader(
                                onBack: () => Navigator.of(context).pop(),
                              ),
                              const SizedBox(height: AppSpacing.lg),
                              const _IntroCard(),
                              const SizedBox(height: AppSpacing.md),
                              _EmergencyContactsCard(appState: appState),
                              const SizedBox(height: AppSpacing.md),
                              ...permissions.map(
                                (permission) => Padding(
                                  padding: const EdgeInsets.only(
                                    bottom: AppSpacing.md,
                                  ),
                                  child: PermissionItemCard(
                                    key: ValueKey(permission.id),
                                    icon: _iconForPermission(permission.id),
                                    title: permission.title,
                                    description: permission.description,
                                    switchValue: permission.enabled,
                                    onChanged: (value) => _handlePermissionChange(
                                      context,
                                      permission,
                                      value,
                                    ),
                                  ),
                                ),
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
      },
    );
  }

  IconData _iconForPermission(String permissionId) {
    switch (permissionId) {
      case 'location_info':
        return Icons.location_on;
      case 'background_refresh':
        return Icons.sync;
      case 'quick_unlock_access':
        return Icons.lock_open;
      case 'gsm_sms':
        return Icons.sms;
      default:
        return Icons.tune_rounded;
    }
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
        border: Border.all(color: Colors.white.withValues(alpha: 0.08)),
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
              'Ayarlar / İzinler',
              textAlign: TextAlign.center,
              style: GoogleFonts.spaceGrotesk(
                color: Colors.white,
                fontSize: 20,
                fontWeight: FontWeight.w700,
              ),
            ),
          ),
          const SizedBox(width: 42),
        ],
      ),
    );
  }
}

class _IntroCard extends StatelessWidget {
  const _IntroCard();

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(AppSpacing.lg),
      decoration: BoxDecoration(
        gradient: const LinearGradient(
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
          colors: [Color(0xFF133A52), Color(0xFF3B8B72)],
        ),
        borderRadius: BorderRadius.circular(AppRadius.lg),
        boxShadow: AppShadows.soft,
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Container(
            padding: const EdgeInsets.symmetric(
              horizontal: AppSpacing.sm,
              vertical: AppSpacing.xs,
            ),
            decoration: BoxDecoration(
              color: Colors.white.withValues(alpha: 0.14),
              borderRadius: BorderRadius.circular(AppRadius.lg),
            ),
            child: Text(
              'Cihaz Erişimleri',
              style: AppTextStyles.caption.copyWith(
                color: Colors.white,
                fontWeight: FontWeight.w700,
              ),
            ),
          ),
          const SizedBox(height: AppSpacing.md),
          Text(
            'İzinler',
            style: GoogleFonts.spaceGrotesk(
              color: Colors.white,
              fontSize: 32,
              fontWeight: FontWeight.w700,
              letterSpacing: -0.4,
            ),
          ),
          const SizedBox(height: AppSpacing.xs),
          Text(
            'Uygulamanın doğru çalışması için gerekli izinleri buradan yönetebilirsiniz.',
            style: AppTextStyles.body.copyWith(
              color: AppColors.textSecondary.withValues(alpha: 0.96),
              fontSize: 14,
              height: 1.45,
            ),
          ),
        ],
      ),
    );
  }
}

class _EmergencyContactsCard extends StatelessWidget {
  const _EmergencyContactsCard({required this.appState});

  final AppState appState;

  @override
  Widget build(BuildContext context) {
    return Material(
      color: Colors.transparent,
      child: InkWell(
        onTap: () {
          Navigator.of(context).push(
            MaterialPageRoute<void>(
              builder: (_) => SafeContactsScreen(appState: appState),
            ),
          );
        },
        borderRadius: BorderRadius.circular(AppRadius.md),
        splashColor: Colors.transparent,
        highlightColor: Colors.transparent,
        hoverColor: Colors.transparent,
        focusColor: Colors.transparent,
        child: Container(
          padding: const EdgeInsets.all(AppSpacing.md),
          decoration: BoxDecoration(
            color: AppColors.card.withValues(alpha: 0.88),
            borderRadius: BorderRadius.circular(AppRadius.md),
            border: Border.all(color: Colors.white.withValues(alpha: 0.08)),
          ),
          child: Row(
            children: [
              Container(
                width: 46,
                height: 46,
                alignment: Alignment.center,
                decoration: BoxDecoration(
                  shape: BoxShape.circle,
                  gradient: LinearGradient(
                    begin: Alignment.topLeft,
                    end: Alignment.bottomRight,
                    colors: [
                      AppColors.aquaGlow.withValues(alpha: 0.95),
                      AppColors.oceanTeal.withValues(alpha: 0.92),
                    ],
                  ),
                ),
                child: const Icon(
                  Icons.group_rounded,
                  color: AppColors.deepNavy,
                ),
              ),
              const SizedBox(width: AppSpacing.md),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      'Acil Durum Kişileri',
                      style: AppTextStyles.title.copyWith(fontSize: 16),
                    ),
                    const SizedBox(height: 4),
                    Text(
                      'Acil durumda haber verilecek kişileri yönetin.',
                      style: AppTextStyles.body.copyWith(
                        color: Colors.white.withValues(alpha: 0.78),
                        fontSize: 14,
                      ),
                    ),
                  ],
                ),
              ),
              const SizedBox(width: AppSpacing.sm),
              const Icon(
                Icons.arrow_forward_ios_rounded,
                color: Colors.white70,
                size: 18,
              ),
            ],
          ),
        ),
      ),
    );
  }
}

class PermissionItemCard extends StatelessWidget {
  const PermissionItemCard({
    super.key,
    required this.icon,
    required this.title,
    required this.description,
    required this.switchValue,
    required this.onChanged,
  });

  final IconData icon;
  final String title;
  final String description;
  final bool switchValue;
  final ValueChanged<bool>? onChanged;

  @override
  Widget build(BuildContext context) {
    return Material(
      color: Colors.transparent,
      child: InkWell(
        onTap: onChanged == null ? null : () => onChanged!(!switchValue),
        borderRadius: BorderRadius.circular(AppRadius.md),
        splashColor: Colors.transparent,
        highlightColor: Colors.transparent,
        hoverColor: Colors.transparent,
        focusColor: Colors.transparent,
        child: Container(
          padding: const EdgeInsets.all(AppSpacing.md),
          decoration: BoxDecoration(
            color: AppColors.card.withValues(alpha: 0.88),
            borderRadius: BorderRadius.circular(AppRadius.md),
            border: Border.all(color: Colors.white.withValues(alpha: 0.08)),
            boxShadow: AppShadows.soft,
          ),
          child: Row(
            crossAxisAlignment: CrossAxisAlignment.center,
            children: [
              Container(
                width: 46,
                height: 46,
                alignment: Alignment.center,
                decoration: BoxDecoration(
                  shape: BoxShape.circle,
                  gradient: LinearGradient(
                    begin: Alignment.topLeft,
                    end: Alignment.bottomRight,
                    colors: [
                      AppColors.aquaGlow.withValues(alpha: 0.95),
                      AppColors.oceanTeal.withValues(alpha: 0.92),
                    ],
                  ),
                  boxShadow: [
                    BoxShadow(
                      color: AppColors.aquaGlow.withValues(alpha: 0.18),
                      blurRadius: 14,
                      offset: const Offset(0, 6),
                    ),
                  ],
                ),
                child: Icon(icon, color: AppColors.deepNavy, size: 24),
              ),
              const SizedBox(width: AppSpacing.md),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      title,
                      style: AppTextStyles.title.copyWith(
                        fontSize: 16,
                        fontWeight: FontWeight.w700,
                      ),
                    ),
                    const SizedBox(height: 4),
                    Text(
                      description,
                      style: AppTextStyles.body.copyWith(
                        color: Colors.white.withValues(alpha: 0.78),
                        fontSize: 14,
                        height: 1.4,
                      ),
                    ),
                  ],
                ),
              ),
              const SizedBox(width: AppSpacing.sm),
              Switch.adaptive(
                key: ValueKey(title),
                value: switchValue,
                onChanged: onChanged,
                activeThumbColor: const Color(0xFF22D1CA),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
