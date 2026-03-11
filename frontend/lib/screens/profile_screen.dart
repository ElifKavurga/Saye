import 'package:flutter/material.dart';

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
                _HeaderCard(
                  displayName: displayName,
                  displayEmail: displayEmail,
                  displayPhone: displayPhone,
                ),
                const SizedBox(height: AppSpacing.md),
                _QuickStatsCard(reportCount: appState.localReports.length),
                const SizedBox(height: AppSpacing.md),
                _SectionTitle('Bildirim Gecmisim'),
                const SizedBox(height: AppSpacing.sm),
                if (appState.localReports.isEmpty)
                  const _EmptyReportCard()
                else
                  ...appState.localReports.map(
                    (report) => Padding(
                      padding: const EdgeInsets.only(bottom: AppSpacing.sm),
                      child: _ReportCard(report: report),
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
          ),
        ),
      ),
    );
  }
}

class _HeaderCard extends StatelessWidget {
  const _HeaderCard({
    required this.displayName,
    required this.displayEmail,
    required this.displayPhone,
  });

  final String displayName;
  final String displayEmail;
  final String displayPhone;

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(AppSpacing.md),
      decoration: BoxDecoration(
        gradient: const LinearGradient(
          colors: [Color(0xFF2D4E7B), Color(0xFF14355F)],
        ),
        borderRadius: BorderRadius.circular(AppRadius.lg),
        boxShadow: AppShadows.soft,
      ),
      child: Row(
        children: [
          Container(
            width: 64,
            height: 64,
            decoration: BoxDecoration(
              shape: BoxShape.circle,
              color: AppColors.aquaGlow.withValues(alpha: 0.2),
              border: Border.all(color: Colors.white24),
            ),
            child: const Icon(Icons.person_rounded, color: AppColors.aquaGlow, size: 36),
          ),
          const SizedBox(width: AppSpacing.md),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  displayName,
                  style: AppTextStyles.title.copyWith(fontSize: 22, fontWeight: FontWeight.w700),
                ),
                const SizedBox(height: 4),
                Text(displayEmail, style: AppTextStyles.caption.copyWith(color: Colors.white70)),
                const SizedBox(height: 3),
                Text('Telefon: $displayPhone', style: AppTextStyles.body.copyWith(fontSize: 13)),
              ],
            ),
          ),
        ],
      ),
    );
  }
}

class _QuickStatsCard extends StatelessWidget {
  const _QuickStatsCard({required this.reportCount});

  final int reportCount;

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(AppSpacing.md),
      decoration: BoxDecoration(
        color: const Color(0xFF10294A).withValues(alpha: 0.92),
        borderRadius: BorderRadius.circular(AppRadius.md),
        border: Border.all(color: Colors.white10),
      ),
      child: Row(
        children: [
          _StatChip(
            icon: Icons.campaign_rounded,
            value: '$reportCount',
            label: 'Ihbar',
          ),
          const SizedBox(width: AppSpacing.sm),
          const _StatChip(
            icon: Icons.verified_rounded,
            value: 'Aktif',
            label: 'Profil',
          ),
          const SizedBox(width: AppSpacing.sm),
          const _StatChip(
            icon: Icons.shield_rounded,
            value: 'Acil',
            label: 'Hazir',
          ),
        ],
      ),
    );
  }
}

class _StatChip extends StatelessWidget {
  const _StatChip({
    required this.icon,
    required this.value,
    required this.label,
  });

  final IconData icon;
  final String value;
  final String label;

  @override
  Widget build(BuildContext context) {
    return Expanded(
      child: Container(
        padding: const EdgeInsets.symmetric(vertical: AppSpacing.sm),
        decoration: BoxDecoration(
          color: const Color(0xFF1D3E67),
          borderRadius: BorderRadius.circular(AppRadius.md),
        ),
        child: Column(
          children: [
            Icon(icon, size: 18, color: const Color(0xFFAFF2C9)),
            const SizedBox(height: 3),
            Text(value, style: AppTextStyles.title.copyWith(fontSize: 15)),
            Text(label, style: AppTextStyles.caption.copyWith(fontSize: 11)),
          ],
        ),
      ),
    );
  }
}

class _SectionTitle extends StatelessWidget {
  const _SectionTitle(this.text);

  final String text;

  @override
  Widget build(BuildContext context) {
    return Text(
      text,
      style: AppTextStyles.title.copyWith(fontSize: 22, fontWeight: FontWeight.w700),
    );
  }
}

class _EmptyReportCard extends StatelessWidget {
  const _EmptyReportCard();

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(AppSpacing.md),
      decoration: BoxDecoration(
        color: const Color(0xFF163157).withValues(alpha: 0.9),
        borderRadius: BorderRadius.circular(AppRadius.md),
      ),
      child: Text(
        'Henuz gonderdigin bir bildirim yok. Harita ekranindan ilk ihbari olusturabilirsin.',
        style: AppTextStyles.body.copyWith(color: Colors.white70),
      ),
    );
  }
}

class _ReportCard extends StatelessWidget {
  const _ReportCard({required this.report});

  final LocalReportNotification report;

  @override
  Widget build(BuildContext context) {
    final hh = report.createdAt.hour.toString().padLeft(2, '0');
    final mm = report.createdAt.minute.toString().padLeft(2, '0');

    return Container(
      padding: const EdgeInsets.all(AppSpacing.md),
      decoration: BoxDecoration(
        color: const Color(0xFF122C4E).withValues(alpha: 0.95),
        borderRadius: BorderRadius.circular(AppRadius.md),
        border: Border.all(color: Colors.white10),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Text(report.category, style: AppTextStyles.title),
              const Spacer(),
              Text('$hh:$mm', style: AppTextStyles.caption),
            ],
          ),
          const SizedBox(height: 4),
          Text(
            '${report.locationLabel} (${report.latLng})',
            style: AppTextStyles.caption.copyWith(color: Colors.white70),
          ),
          if (report.description.isNotEmpty) ...[
            const SizedBox(height: 6),
            Text(report.description, style: AppTextStyles.body),
          ],
        ],
      ),
    );
  }
}
