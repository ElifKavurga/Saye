import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';

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
    if (message.trim().isEmpty) {
      return;
    }
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(content: Text(message), behavior: SnackBarBehavior.floating),
    );
  }

  @override
  Widget build(BuildContext context) {
    final user = appState.currentUser;
    final isBusy = appState.isUserSettingsBusy;
    final displayName = user?.username.isNotEmpty == true
        ? user!.username
        : AppDefaults.fallbackProfileName;
    final displayEmail = user?.email.isNotEmpty == true
        ? user!.email
        : AppDefaults.fallbackProfileEmail;
    final displayPhone = user?.phone.isNotEmpty == true ? user!.phone : '-';

    return SafeArea(
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
                      _SettingsHeader(onBack: () => appState.setIndex(0)),
                      const SizedBox(height: AppSpacing.lg),
                      _SettingsHeroCard(
                        onOpenEmergencyContacts: () {
                          Navigator.of(context).push(
                            MaterialPageRoute<void>(
                              builder: (_) =>
                                  SafeContactsScreen(appState: appState),
                            ),
                          );
                        },
                      ),
                      const SizedBox(height: AppSpacing.md),
                      _SettingsCard(
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            _CardTitle(
                              title: 'Hesap Bilgileri',
                              description:
                                  'Profil bilgilerini gözden geçir ve hesabının iletişim detaylarını doğrula.',
                            ),
                            const SizedBox(height: AppSpacing.md),
                            _AccountInfoRow(
                              label: 'Ad',
                              value: displayName,
                              icon: Icons.person_rounded,
                            ),
                            const SizedBox(height: AppSpacing.sm),
                            _AccountInfoRow(
                              label: 'E-posta',
                              value: displayEmail,
                              icon: Icons.mail_rounded,
                            ),
                            const SizedBox(height: AppSpacing.sm),
                            _AccountInfoRow(
                              label: 'Telefon',
                              value: displayPhone,
                              icon: Icons.phone_rounded,
                            ),
                            const SizedBox(height: AppSpacing.md),
                            Align(
                              alignment: Alignment.centerLeft,
                              child: FilledButton.tonalIcon(
                                onPressed: () => appState.setIndex(3),
                                style: FilledButton.styleFrom(
                                  backgroundColor: AppColors.aquaGlow
                                      .withValues(alpha: 0.16),
                                  foregroundColor: Colors.white,
                                  padding: const EdgeInsets.symmetric(
                                    horizontal: AppSpacing.md,
                                    vertical: AppSpacing.sm,
                                  ),
                                  shape: RoundedRectangleBorder(
                                    borderRadius: BorderRadius.circular(999),
                                  ),
                                ),
                                icon: const Icon(Icons.arrow_forward_rounded),
                                label: const Text('Profil ekranına git'),
                              ),
                            ),
                          ],
                        ),
                      ),
                      const SizedBox(height: AppSpacing.md),
                      _SettingsCard(
                        child: SettingsOptionTile(
                          icon: Icons.visibility_rounded,
                          title: 'Profil Görünürlüğü',
                          description:
                              'Yapılan ihbarlarda profil adın görünsün mü? Bu ayar açık olduğunda bildirim geçmişinde hesabın ilişkilendirilir.',
                          trailing: Switch.adaptive(
                            value: appState.isProfileVisibleInAlerts,
                            onChanged: isBusy
                                ? null
                                : _handleProfileVisibilityChanged,
                          ),
                        ),
                      ),
                      if (isBusy) ...[
                        const SizedBox(height: AppSpacing.md),
                        const Padding(
                          padding: EdgeInsets.symmetric(horizontal: AppSpacing.xs),
                          child: LinearProgressIndicator(),
                        ),
                      ],
                      const SizedBox(height: AppSpacing.md),
                      Row(
                        children: [
                          Expanded(
                            child: _SettingsActionCard(
                              icon: Icons.health_and_safety_rounded,
                              label: 'Acil Bilgiler',
                              onTap: () {
                                Navigator.of(context).push(
                                  MaterialPageRoute<void>(
                                    builder: (_) => EmergencyHealthEditScreen(
                                      appState: appState,
                                    ),
                                  ),
                                );
                              },
                            ),
                          ),
                          const SizedBox(width: AppSpacing.sm),
                          Expanded(
                            child: _SettingsActionCard(
                              icon: Icons.verified_user_rounded,
                              label: 'İzinler',
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
                            child: _SettingsActionCard(
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
        },
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
              'Ayarlar / Genel',
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

class _SettingsHeroCard extends StatelessWidget {
  const _SettingsHeroCard({required this.onOpenEmergencyContacts});

  final VoidCallback onOpenEmergencyContacts;

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
              'Hesap Güvenliği',
              style: AppTextStyles.caption.copyWith(
                color: Colors.white,
                fontWeight: FontWeight.w700,
              ),
            ),
          ),
          const SizedBox(height: AppSpacing.md),
          Text(
            'Hesabını güvene almamıza yardımcı ol!',
            style: GoogleFonts.spaceGrotesk(
              color: Colors.white,
              fontSize: 30,
              fontWeight: FontWeight.w700,
              letterSpacing: -0.4,
            ),
          ),
          const SizedBox(height: AppSpacing.xs),
          Text(
            'Bilgilerini gözden geçirmeni ve hesabına ilave giriş koruması eklemeni tavsiye ediyoruz. Doğru bilgiler, güvenlik sorunu durumunda iletişime geçmemize yardımcı olur.',
            style: AppTextStyles.body.copyWith(
              color: AppColors.textSecondary.withValues(alpha: 0.96),
              fontSize: 14,
              height: 1.45,
            ),
          ),
          const SizedBox(height: AppSpacing.md),
          FilledButton.tonalIcon(
            onPressed: onOpenEmergencyContacts,
            style: FilledButton.styleFrom(
              backgroundColor: Colors.white.withValues(alpha: 0.14),
              foregroundColor: Colors.white,
              padding: const EdgeInsets.symmetric(
                horizontal: AppSpacing.md,
                vertical: AppSpacing.sm,
              ),
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(999),
              ),
            ),
            icon: const Icon(Icons.group_rounded),
            label: const Text('Acil Durum İlk Çağrı Kişileri'),
          ),
        ],
      ),
    );
  }
}

class _SettingsCard extends StatelessWidget {
  const _SettingsCard({required this.child});

  final Widget child;

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(AppSpacing.md),
      decoration: BoxDecoration(
        color: AppColors.card.withValues(alpha: 0.88),
        borderRadius: BorderRadius.circular(AppRadius.md),
        border: Border.all(color: Colors.white.withValues(alpha: 0.08)),
        boxShadow: AppShadows.soft,
      ),
      child: child,
    );
  }
}

class SettingsOptionTile extends StatelessWidget {
  const SettingsOptionTile({
    super.key,
    required this.icon,
    required this.title,
    required this.description,
    this.trailing,
  });

  final IconData icon;
  final String title;
  final String description;
  final Widget? trailing;

  @override
  Widget build(BuildContext context) {
    return Row(
      crossAxisAlignment: CrossAxisAlignment.start,
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
        if (trailing != null) ...[
          const SizedBox(width: AppSpacing.sm),
          trailing!,
        ],
      ],
    );
  }
}

class _CardTitle extends StatelessWidget {
  const _CardTitle({required this.title, required this.description});

  final String title;
  final String description;

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          title,
          style: GoogleFonts.spaceGrotesk(
            color: Colors.white,
            fontSize: 24,
            fontWeight: FontWeight.w700,
            letterSpacing: -0.3,
          ),
        ),
        const SizedBox(height: AppSpacing.xs),
        Text(
          description,
          style: AppTextStyles.body.copyWith(
            color: AppColors.textSecondary.withValues(alpha: 0.96),
            fontSize: 14,
            height: 1.45,
          ),
        ),
      ],
    );
  }
}

class _AccountInfoRow extends StatelessWidget {
  const _AccountInfoRow({
    required this.label,
    required this.value,
    required this.icon,
  });

  final String label;
  final String value;
  final IconData icon;

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(AppSpacing.sm),
      decoration: BoxDecoration(
        color: Colors.white.withValues(alpha: 0.04),
        borderRadius: BorderRadius.circular(AppRadius.md),
        border: Border.all(color: Colors.white.withValues(alpha: 0.06)),
      ),
      child: Row(
        children: [
          Icon(icon, color: AppColors.aquaGlow, size: 20),
          const SizedBox(width: AppSpacing.sm),
          Expanded(
            child: Text(
              label,
              style: AppTextStyles.caption.copyWith(
                color: Colors.white70,
                fontSize: 12,
              ),
            ),
          ),
          const SizedBox(width: AppSpacing.sm),
          Flexible(
            child: Text(
              value,
              textAlign: TextAlign.right,
              style: AppTextStyles.body.copyWith(
                color: Colors.white,
                fontSize: 14,
                fontWeight: FontWeight.w600,
              ),
            ),
          ),
        ],
      ),
    );
  }
}

class _SettingsActionCard extends StatelessWidget {
  const _SettingsActionCard({
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
        splashColor: AppColors.aquaGlow.withValues(alpha: 0.08),
        highlightColor: AppColors.aquaGlow.withValues(alpha: 0.04),
        child: Container(
          padding: const EdgeInsets.symmetric(
            vertical: AppSpacing.md,
            horizontal: AppSpacing.sm,
          ),
          decoration: BoxDecoration(
            color: AppColors.card.withValues(alpha: 0.88),
            borderRadius: BorderRadius.circular(AppRadius.md),
            border: Border.all(color: Colors.white.withValues(alpha: 0.08)),
            boxShadow: AppShadows.soft,
          ),
          child: Column(
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
              const SizedBox(height: AppSpacing.sm),
              Text(
                label,
                textAlign: TextAlign.center,
                style: AppTextStyles.body.copyWith(
                  color: Colors.white,
                  fontSize: 13,
                  fontWeight: FontWeight.w700,
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
