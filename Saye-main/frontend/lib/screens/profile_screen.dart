import 'package:flutter/material.dart';

import '../components/app_card.dart';
import '../components/screen_layout.dart';
import '../data/mock_data.dart';
import '../state/app_state.dart';
import '../theme/design_system.dart';

class ProfileScreen extends StatelessWidget {
  const ProfileScreen({super.key, required this.appState});

  final AppState appState;

  @override
  Widget build(BuildContext context) {
    final user = appState.currentUser;
    final displayName =
        (user?.username.isNotEmpty ?? false) ? user!.username : MockData.profile.name;
    final displayEmail =
        (user?.email.isNotEmpty ?? false) ? user!.email : MockData.profile.email;
    final displayPhone = (user?.phone.isNotEmpty ?? false) ? user!.phone : '-';

    return ScreenLayout(
      title: 'Profile',
      subtitle: 'Hesap ozeti ve bildirim gecmisi',
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          AppCard(
            child: Row(
              children: [
                CircleAvatar(
                  radius: 28,
                  backgroundColor: AppColors.aquaGlow.withValues(alpha: 0.2),
                  child: const Icon(Icons.person_rounded, color: AppColors.aquaGlow),
                ),
                const SizedBox(width: AppSpacing.md),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(displayName, style: AppTextStyles.title),
                      const SizedBox(height: 4),
                      Text(displayEmail, style: AppTextStyles.caption),
                      const SizedBox(height: 4),
                      Text('Telefon: $displayPhone', style: AppTextStyles.body),
                    ],
                  ),
                ),
              ],
            ),
          ),
          const SizedBox(height: AppSpacing.lg),
          Text('Bildirim Gecmisim', style: AppTextStyles.title),
          const SizedBox(height: AppSpacing.sm),
          if (appState.localReports.isEmpty)
            const AppCard(
              child: Text(
                'Henuz gonderdigin bir bildirim yok.',
                style: TextStyle(color: AppColors.textSecondary),
              ),
            ),
          if (appState.localReports.isNotEmpty)
            ...appState.localReports.map(
              (report) => Padding(
                padding: const EdgeInsets.only(bottom: AppSpacing.sm),
                child: AppCard(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(report.category, style: AppTextStyles.title),
                      const SizedBox(height: 4),
                      Text(
                        '${report.locationLabel} (${report.latLng})',
                        style: AppTextStyles.caption,
                      ),
                      if (report.description.isNotEmpty) ...[
                        const SizedBox(height: 4),
                        Text(report.description, style: AppTextStyles.body),
                      ],
                      const SizedBox(height: 6),
                      Text(
                        _formatTime(report.createdAt),
                        style: AppTextStyles.caption,
                      ),
                    ],
                  ),
                ),
              ),
            ),
          const SizedBox(height: AppSpacing.lg),
          SizedBox(
            width: double.infinity,
            child: ElevatedButton(
              onPressed: appState.logout,
              style: ElevatedButton.styleFrom(
                backgroundColor: const Color(0xFF8B1F33),
                foregroundColor: Colors.white,
              ),
              child: const Text('Cikis Yap'),
            ),
          ),
        ],
      ),
    );
  }

  String _formatTime(DateTime time) {
    final hh = time.hour.toString().padLeft(2, '0');
    final mm = time.minute.toString().padLeft(2, '0');
    return '$hh:$mm';
  }
}
