import 'package:flutter/material.dart';

import '../config/app_defaults.dart';
import '../state/app_state.dart';
import '../theme/design_system.dart';
import 'emergency_info_screen.dart';
import 'permissions_screen.dart';
import 'rules_screen.dart';
import 'safe_contacts_screen.dart';

class SettingsScreen extends StatelessWidget {
  const SettingsScreen({super.key, required this.appState});

  final AppState appState;

  @override
  Widget build(BuildContext context) {
    final user = appState.currentUser;

    return SafeArea(
      child: SingleChildScrollView(
        padding: const EdgeInsets.fromLTRB(
          AppSpacing.md,
          AppSpacing.md,
          AppSpacing.md,
          120,
        ),
        child: Center(
          child: ConstrainedBox(
            constraints: const BoxConstraints(maxWidth: 520),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.stretch,
              children: [
                _SettingsHeader(onBack: () => appState.setIndex(0)),
                const SizedBox(height: AppSpacing.lg),
                _InfoCard(
                  title: 'Hesabini guvene almamiza yardimci ol!',
                  body:
                      'Bilgilerini gozden gecirmeni ve hesabina ilave giris korumasi eklemeni tavsiye ediyoruz. Dogru bilgiler, guvenlik sorunu durumunda iletisime gecmemize yardimci olur.',
                  footerLabel: 'Acil Durum Ilk Cagri Kisileri',
                  onTap: () {
                    Navigator.of(context).push(
                      MaterialPageRoute<void>(
                        builder: (_) => SafeContactsScreen(appState: appState),
                      ),
                    );
                  },
                ),
                const SizedBox(height: AppSpacing.md),
                _InfoCard(
                  title: 'Hesap Bilgileri',
                  body:
<<<<<<< HEAD
                      'Ad: ${user?.username.isNotEmpty == true ? user!.username : AppDefaults.fallbackProfileName}\nE-mail: ${user?.email.isNotEmpty == true ? user!.email : AppDefaults.fallbackProfileEmail}\nTelefon: ${user?.phone.isNotEmpty == true ? user!.phone : '-'}',
=======
                      'Ad: ${user?.username.isNotEmpty == true ? user!.username : MockData.profile.name}\nE-mail: ${user?.email.isNotEmpty == true ? user!.email : MockData.profile.email}\nTelefon: ${user?.phone.isNotEmpty == true ? user!.phone : '-'}',
>>>>>>> frontend-sinem
                  footerLabel: 'Profil ekranina git',
                  onTap: () => appState.setIndex(3),
                ),
                const SizedBox(height: AppSpacing.md),
                _InfoCard(
                  title: 'Profil Gorunurlugu',
                  body:
                      'Yapilan ihbarlarda profil adin gorunsun mu? Bu ayar acik oldugunda bildirim gecmisinde hesabin iliskilendirilir.',
                  trailing: Switch.adaptive(
                    value: appState.isProfileVisibleInAlerts,
                    onChanged: appState.setProfileVisibilityInAlerts,
                  ),
<<<<<<< HEAD
                  footerLabel: appState.isProfileVisibleInAlerts
                      ? 'Aktif'
                      : 'Kapali',
=======
                  footerLabel: appState.isProfileVisibleInAlerts ? 'Aktif' : 'Kapali',
>>>>>>> frontend-sinem
                  onTap: () {},
                ),
                const SizedBox(height: AppSpacing.md),
                Row(
                  children: [
                    Expanded(
                      child: _MiniActionCard(
                        icon: Icons.health_and_safety_rounded,
                        label: 'Acil Bilgiler',
                        onTap: () {
                          Navigator.of(context).push(
                            MaterialPageRoute<void>(
<<<<<<< HEAD
                              builder: (_) =>
                                  EmergencyInfoScreen(appState: appState),
=======
                              builder: (_) => EmergencyInfoScreen(appState: appState),
>>>>>>> frontend-sinem
                            ),
                          );
                        },
                      ),
                    ),
                    const SizedBox(width: AppSpacing.sm),
                    Expanded(
                      child: _MiniActionCard(
                        icon: Icons.verified_user_rounded,
                        label: 'Izinler',
                        onTap: () {
                          Navigator.of(context).push(
                            MaterialPageRoute<void>(
<<<<<<< HEAD
                              builder: (_) =>
                                  PermissionsScreen(appState: appState),
=======
                              builder: (_) => PermissionsScreen(appState: appState),
>>>>>>> frontend-sinem
                            ),
                          );
                        },
                      ),
                    ),
                    const SizedBox(width: AppSpacing.sm),
                    Expanded(
                      child: _MiniActionCard(
                        icon: Icons.rule_rounded,
                        label: 'Kurallar',
                        onTap: () {
                          Navigator.of(context).push(
                            MaterialPageRoute<void>(
                              builder: (_) => const RulesScreen(),
                            ),
                          );
                        },
                      ),
                    ),
                  ],
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}

class _SettingsHeader extends StatelessWidget {
  const _SettingsHeader({required this.onBack});

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
              style: AppTextStyles.title.copyWith(
                fontSize: 30,
                letterSpacing: 0.8,
              ),
            ),
          ),
          const SizedBox(width: 42),
        ],
      ),
    );
  }
}

class _InfoCard extends StatelessWidget {
  const _InfoCard({
    required this.title,
    required this.body,
    required this.onTap,
    this.footerLabel,
    this.trailing,
  });

  final String title;
  final String body;
  final VoidCallback onTap;
  final String? footerLabel;
  final Widget? trailing;

  @override
  Widget build(BuildContext context) {
    return InkWell(
      onTap: onTap,
      borderRadius: BorderRadius.circular(AppRadius.md),
      child: Container(
        constraints: const BoxConstraints(minHeight: 170),
        padding: const EdgeInsets.all(AppSpacing.md),
        decoration: BoxDecoration(
          gradient: const LinearGradient(
            begin: Alignment.topLeft,
            end: Alignment.bottomRight,
            colors: [Color(0xFF91A99B), Color(0xFF4D7D4E)],
          ),
          borderRadius: BorderRadius.circular(AppRadius.md),
          boxShadow: AppShadows.soft,
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Expanded(
                  child: Text(
                    title,
                    style: AppTextStyles.title.copyWith(
                      color: Colors.white,
                      fontSize: 30,
                      fontWeight: FontWeight.w500,
                    ),
                  ),
                ),
                // ignore: use_null_aware_elements
                if (trailing case final trailingWidget?) trailingWidget,
              ],
            ),
            const SizedBox(height: AppSpacing.sm),
            Text(
              body,
              style: AppTextStyles.body.copyWith(
                color: Colors.white.withValues(alpha: 0.92),
                fontSize: 20,
                height: 1.35,
              ),
            ),
            if (footerLabel case final footerText?) ...[
              const SizedBox(height: AppSpacing.sm),
              Container(
<<<<<<< HEAD
                padding: const EdgeInsets.symmetric(
                  horizontal: 10,
                  vertical: 6,
                ),
=======
                padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 6),
>>>>>>> frontend-sinem
                decoration: BoxDecoration(
                  color: Colors.black.withValues(alpha: 0.18),
                  borderRadius: BorderRadius.circular(8),
                ),
                child: Text(
                  footerText,
                  style: AppTextStyles.caption.copyWith(color: Colors.white70),
                ),
              ),
            ],
          ],
        ),
      ),
    );
  }
}

class _MiniActionCard extends StatelessWidget {
  const _MiniActionCard({
    required this.icon,
    required this.label,
    required this.onTap,
  });

  final IconData icon;
  final String label;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    return InkWell(
      onTap: onTap,
      borderRadius: BorderRadius.circular(AppRadius.md),
      child: Container(
        padding: const EdgeInsets.symmetric(vertical: AppSpacing.sm),
        decoration: BoxDecoration(
          color: const Color(0xFF1B3A63).withValues(alpha: 0.94),
          borderRadius: BorderRadius.circular(AppRadius.md),
          border: Border.all(color: Colors.white10),
        ),
        child: Column(
          children: [
            Icon(icon, color: const Color(0xFFBFEFD2), size: 24),
            const SizedBox(height: 6),
            Text(
              label,
              style: AppTextStyles.caption.copyWith(color: Colors.white),
            ),
          ],
        ),
      ),
    );
  }
}
