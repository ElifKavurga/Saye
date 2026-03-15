import 'package:flutter/material.dart';

import '../config/app_defaults.dart';
import '../state/app_state.dart';
import '../theme/design_system.dart';
import 'permissions_screen.dart';
import 'profile_screen.dart';
import 'rules_screen.dart';
import 'safe_contacts_screen.dart';

class SettingsScreen extends StatefulWidget {
  const SettingsScreen({super.key, required this.appState});

  final AppState appState;

  @override
  State<SettingsScreen> createState() => _SettingsScreenState();
}

class _SettingsScreenState extends State<SettingsScreen> {
  AppState get appState => widget.appState;

  Future<void> _handleProfileVisibilityChanged(bool value) async {
    try {
      await appState.updateProfileVisibilityInAlerts(value);
    } catch (error) {
      _showError(error);
    }
  }

  void _showError(Object error) {
    if (!mounted) {
      return;
    }

    final message = error is AppStateException
        ? error.message
        : error.toString();
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(content: Text(message), behavior: SnackBarBehavior.floating),
    );
  }

  @override
  Widget build(BuildContext context) {
    final user = appState.currentUser;
    final isBusy = appState.isUserSettingsBusy;

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
                const SizedBox(height: AppSpacing.md),
                if (isBusy)
                  const Padding(
                    padding: EdgeInsets.only(bottom: AppSpacing.md),
                    child: LinearProgressIndicator(),
                  ),
                Text(
                  'Hesap, gizlilik ve guvenlik ayarlarini buradan yonetebilirsin.',
                  style: AppTextStyles.body.copyWith(
                    color: Colors.white70,
                    fontSize: 14,
                    height: 1.45,
                  ),
                ),
                const SizedBox(height: AppSpacing.md),
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
                      'Ad: ${user?.username.isNotEmpty == true ? user!.username : AppDefaults.fallbackProfileName}\nE-posta: ${user?.email.isNotEmpty == true ? user!.email : AppDefaults.fallbackProfileEmail}\nTelefon: ${user?.phone.isNotEmpty == true ? user!.phone : '-'}',
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
                    onChanged: isBusy ? null : _handleProfileVisibilityChanged,
                  ),
                  footerLabel: appState.isProfileVisibleInAlerts
                      ? 'Aktif'
                      : 'Kapali',
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
                              builder: (_) =>
                                  EmergencyHealthEditScreen(appState: appState),
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
                              builder: (_) =>
                                  PermissionsScreen(appState: appState),
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
        vertical: 14,
      ),
      decoration: BoxDecoration(
        gradient: const LinearGradient(
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
          colors: [Color(0xFF1F4268), Color(0xFF3A6796)],
        ),
        borderRadius: BorderRadius.circular(AppRadius.lg),
        border: Border.all(color: Colors.white.withValues(alpha: 0.14)),
        boxShadow: AppShadows.soft,
      ),
      child: Row(
        children: [
          Container(
            width: 44,
            height: 44,
            decoration: BoxDecoration(
              color: Colors.white.withValues(alpha: 0.08),
              borderRadius: BorderRadius.circular(14),
            ),
            child: IconButton(
              onPressed: onBack,
              icon: const Icon(
                Icons.chevron_left_rounded,
                color: Color(0xFF9CCEFF),
                size: 26,
              ),
            ),
          ),
          Expanded(
            child: Text(
              'Ayarlar / Genel',
              textAlign: TextAlign.center,
              style: AppTextStyles.headline.copyWith(
                fontSize: 22,
                letterSpacing: 0.2,
              ),
            ),
          ),
          const SizedBox(width: 44),
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
    return Material(
      color: Colors.transparent,
      child: InkWell(
        onTap: onTap,
        borderRadius: BorderRadius.circular(AppRadius.lg),
        child: Container(
          constraints: const BoxConstraints(minHeight: 158),
          padding: const EdgeInsets.all(AppSpacing.md),
          decoration: BoxDecoration(
            gradient: const LinearGradient(
              begin: Alignment.topLeft,
              end: Alignment.bottomRight,
              colors: [Color(0xFF93B58B), Color(0xFF527B63)],
            ),
            borderRadius: BorderRadius.circular(AppRadius.lg),
            border: Border.all(color: Colors.white.withValues(alpha: 0.14)),
            boxShadow: [
              ...AppShadows.soft,
              const BoxShadow(
                color: Color(0x22000000),
                blurRadius: 10,
                offset: Offset(0, 2),
              ),
            ],
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
                      style: AppTextStyles.headline.copyWith(
                        color: Colors.white,
                        fontSize: 20,
                        height: 1.18,
                      ),
                    ),
                  ),
                  // ignore: use_null_aware_elements
                  if (trailing != null) trailing!,
                ],
              ),
              const SizedBox(height: AppSpacing.sm),
              Text(
                body,
                style: AppTextStyles.body.copyWith(
                  color: Colors.white.withValues(alpha: 0.93),
                  fontSize: 14,
                  height: 1.5,
                ),
              ),
              if (footerLabel case final footerText?) ...[
                const SizedBox(height: AppSpacing.md),
                Container(
                  padding: const EdgeInsets.symmetric(
                    horizontal: 12,
                    vertical: 8,
                  ),
                  decoration: BoxDecoration(
                    color: const Color(0xFF173557).withValues(alpha: 0.22),
                    borderRadius: BorderRadius.circular(999),
                    border: Border.all(
                      color: Colors.white.withValues(alpha: 0.10),
                    ),
                  ),
                  child: Text(
                    footerText,
                    style: AppTextStyles.caption.copyWith(
                      color: Colors.white,
                      fontSize: 12,
                    ),
                  ),
                ),
              ],
            ],
          ),
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
    return Material(
      color: Colors.transparent,
      child: InkWell(
        onTap: onTap,
        borderRadius: BorderRadius.circular(AppRadius.md),
        child: Container(
          padding: const EdgeInsets.symmetric(
            vertical: AppSpacing.md,
            horizontal: AppSpacing.sm,
          ),
          decoration: BoxDecoration(
            color: const Color(0xFF1A355B).withValues(alpha: 0.96),
            borderRadius: BorderRadius.circular(AppRadius.md),
            border: Border.all(color: Colors.white.withValues(alpha: 0.12)),
            boxShadow: const [
              BoxShadow(
                color: Color(0x18000000),
                blurRadius: 8,
                offset: Offset(0, 2),
              ),
            ],
          ),
          child: Column(
            children: [
              Container(
                width: 40,
                height: 40,
                decoration: BoxDecoration(
                  color: const Color(0xFF9ED7C4).withValues(alpha: 0.14),
                  borderRadius: BorderRadius.circular(12),
                ),
                child: Icon(icon, color: const Color(0xFFD8F6E2), size: 22),
              ),
              const SizedBox(height: 8),
              Text(
                label,
                textAlign: TextAlign.center,
                style: AppTextStyles.caption.copyWith(
                  color: Colors.white,
                  fontSize: 12,
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
