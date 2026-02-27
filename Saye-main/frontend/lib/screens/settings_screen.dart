import 'package:flutter/material.dart';

import '../data/mock_data.dart';
import '../state/app_state.dart';
import '../theme/design_system.dart';
import 'emergency_info_screen.dart';
import 'permissions_screen.dart';

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
                      'Bilgilerini gozden gecirmeni ve hesabina ilave giris korumasi eklemeni tavsiye ediyoruz. Dogru bilgiler, hesabinda guvenlik sorunu olmasi durumunda iletisime gecmemize yardimci olur.',
                  onTap: () => _openSecurityRouteSelector(context),
                ),
                const SizedBox(height: AppSpacing.md),
                _InfoCard(
                  title: 'Hesap Bilgileri:',
                  body:
                      'Ad: ${user?.username.isNotEmpty == true ? user!.username : MockData.profile.name}\nE-mail: ${user?.email.isNotEmpty == true ? user!.email : MockData.profile.email}\nTelefon: ${user?.phone.isNotEmpty == true ? user!.phone : '-'}',
                  onTap: () => appState.setIndex(3),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }

  Future<void> _openSecurityRouteSelector(BuildContext context) async {
    await showModalBottomSheet<void>(
      context: context,
      backgroundColor: const Color(0xFF17365A),
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(AppRadius.lg)),
      ),
      builder: (context) {
        return SafeArea(
          child: Padding(
            padding: const EdgeInsets.all(AppSpacing.md),
            child: Column(
              mainAxisSize: MainAxisSize.min,
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text('Yonlendirme Sec', style: AppTextStyles.title),
                const SizedBox(height: AppSpacing.sm),
                ListTile(
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(AppRadius.md),
                  ),
                  tileColor: const Color(0xFF244A73),
                  leading: const Icon(Icons.verified_user_rounded),
                  title: const Text('Izinler Ekrani (Modul 7)'),
                  onTap: () {
                    Navigator.of(context).pop();
                    Navigator.of(context).push(
                      MaterialPageRoute<void>(
                        builder: (_) => PermissionsScreen(appState: appState),
                      ),
                    );
                  },
                ),
                const SizedBox(height: AppSpacing.sm),
                ListTile(
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(AppRadius.md),
                  ),
                  tileColor: const Color(0xFF244A73),
                  leading: const Icon(Icons.health_and_safety_rounded),
                  title: const Text('Acil Durum Bilgileri (Modul 6)'),
                  onTap: () {
                    Navigator.of(context).pop();
                    Navigator.of(context).push(
                      MaterialPageRoute<void>(
                        builder: (_) => EmergencyInfoScreen(appState: appState),
                      ),
                    );
                  },
                ),
              ],
            ),
          ),
        );
      },
    );
  }
}

class _SettingsHeader extends StatelessWidget {
  const _SettingsHeader({required this.onBack});

  final VoidCallback onBack;

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: AppSpacing.md, vertical: AppSpacing.sm),
      decoration: BoxDecoration(
        color: const Color(0xFF284872).withValues(alpha: 0.9),
        borderRadius: BorderRadius.circular(AppRadius.lg),
      ),
      child: Row(
        children: [
          IconButton(
            onPressed: onBack,
            icon: const Icon(Icons.chevron_left_rounded, color: Color(0xFF4D8EEB), size: 34),
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
  });

  final String title;
  final String body;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    return InkWell(
      onTap: onTap,
      borderRadius: BorderRadius.circular(AppRadius.md),
      child: Container(
        constraints: const BoxConstraints(minHeight: 190, maxHeight: 240),
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
            Text(
              title,
              style: AppTextStyles.title.copyWith(
                color: Colors.white,
                fontSize: 36,
                fontWeight: FontWeight.w500,
              ),
            ),
            const SizedBox(height: AppSpacing.sm),
            Expanded(
              child: SingleChildScrollView(
                child: Text(
                  body,
                  style: AppTextStyles.body.copyWith(
                    color: Colors.white.withValues(alpha: 0.92),
                    fontSize: 23,
                    height: 1.35,
                  ),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
