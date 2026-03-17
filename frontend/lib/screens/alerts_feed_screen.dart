import 'package:flutter/material.dart';

import '../state/app_state.dart';
import '../theme/design_system.dart';

class AlertsFeedScreen extends StatelessWidget {
  const AlertsFeedScreen({super.key, required this.appState});

  final AppState appState;

  @override
  Widget build(BuildContext context) {
    final hasLocal = appState.localReports.isNotEmpty;
    final hasNearby = appState.nearbyReports.isNotEmpty;

    return Scaffold(
      body: Container(
        decoration: const BoxDecoration(gradient: AppGradients.mainBackground),
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
                    _Header(onBack: () => Navigator.of(context).pop()),
                    const SizedBox(height: AppSpacing.md),
                    _LocationCard(location: appState.currentLocationName),
                    const SizedBox(height: AppSpacing.md),
                    Text(
                      'Güncel İhbarlar',
                      style: AppTextStyles.title.copyWith(fontSize: 20),
                    ),
                    const SizedBox(height: AppSpacing.sm),
                    if (!hasLocal) const _EmptyStateCard(),
                    if (hasLocal)
                      ...appState.localReports.map(
                        (item) => Padding(
                          padding: const EdgeInsets.only(bottom: AppSpacing.sm),
                          child: _AlertTile(
                            category: item.category,
                            location: item.locationLabel,
                            note: item.description,
                            createdAt: item.createdAt,
                          ),
                        ),
                      ),
                    const SizedBox(height: AppSpacing.sm),
                    Text(
                      'Bölgesel Akış',
                      style: AppTextStyles.title.copyWith(fontSize: 20),
                    ),
                    const SizedBox(height: AppSpacing.sm),
                    if (!hasNearby) const _EmptyNearbyCard(),
                    if (hasNearby)
                      ...appState.nearbyReports.map(
                        (report) => Padding(
                          padding: const EdgeInsets.only(bottom: AppSpacing.sm),
                          child: _NearbyAlertTile(report: report),
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
  }
}

class _Header extends StatelessWidget {
  const _Header({required this.onBack});

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
              'GÜNCEL BİLDİRİMLER',
              textAlign: TextAlign.center,
              style: AppTextStyles.title.copyWith(
                fontSize: 24,
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

class _LocationCard extends StatelessWidget {
  const _LocationCard({required this.location});

  final String location;

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(AppSpacing.md),
      decoration: BoxDecoration(
        color: const Color(0xFF0E2949).withValues(alpha: 0.94),
        borderRadius: BorderRadius.circular(AppRadius.md),
      ),
      child: Row(
        children: [
          const Icon(Icons.location_on_rounded, color: Color(0xFF5BF2A7)),
          const SizedBox(width: AppSpacing.xs),
          Expanded(
            child: Text(
              location,
              style: AppTextStyles.body.copyWith(fontSize: 16),
            ),
          ),
          Text(
            'Şimdi',
            style: AppTextStyles.caption.copyWith(color: Colors.white70),
          ),
        ],
      ),
    );
  }
}

class _AlertTile extends StatelessWidget {
  const _AlertTile({
    required this.category,
    required this.location,
    required this.note,
    required this.createdAt,
  });

  final String category;
  final String location;
  final String note;
  final DateTime createdAt;

  @override
  Widget build(BuildContext context) {
    final hh = createdAt.hour.toString().padLeft(2, '0');
    final mm = createdAt.minute.toString().padLeft(2, '0');
    final noteText = note.isEmpty ? 'Açıklama eklenmedi.' : note;

    return Container(
      padding: const EdgeInsets.all(AppSpacing.md),
      decoration: BoxDecoration(
        gradient: const LinearGradient(
          colors: [Color(0xFF2B4C79), Color(0xFF17355E)],
        ),
        borderRadius: BorderRadius.circular(AppRadius.md),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Text(category, style: AppTextStyles.title.copyWith(fontSize: 18)),
              const Spacer(),
              Text('$hh:$mm', style: AppTextStyles.caption),
            ],
          ),
          const SizedBox(height: 6),
          Text(
            location,
            style: AppTextStyles.body.copyWith(color: Colors.white70),
          ),
          const SizedBox(height: 6),
          Text(noteText, style: AppTextStyles.body),
        ],
      ),
    );
  }
}

class _NearbyAlertTile extends StatelessWidget {
  const _NearbyAlertTile({required this.report});

  final NearbyReport report;

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(AppSpacing.md),
      decoration: BoxDecoration(
        color: const Color(0xFF132E52).withValues(alpha: 0.9),
        borderRadius: BorderRadius.circular(AppRadius.md),
        border: Border.all(color: Colors.white10),
      ),
      child: Row(
        children: [
          Container(
            width: 36,
            height: 36,
            decoration: BoxDecoration(
              color: const Color(0xFF4B7A59),
              borderRadius: BorderRadius.circular(10),
            ),
            child: const Icon(Icons.campaign_rounded, size: 20),
          ),
          const SizedBox(width: AppSpacing.sm),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  report.category,
                  style: AppTextStyles.title.copyWith(fontSize: 16),
                ),
                const SizedBox(height: 2),
                Text(
                  '${report.latitude.toStringAsFixed(4)}, ${report.longitude.toStringAsFixed(4)}  - ${report.status}',
                  style: AppTextStyles.caption.copyWith(color: Colors.white70),
                ),
              ],
            ),
          ),
          Text(_formatTime(report.createdAt), style: AppTextStyles.caption),
        ],
      ),
    );
  }

  String _formatTime(DateTime? value) {
    if (value == null) {
      return '--:--';
    }
    final hh = value.hour.toString().padLeft(2, '0');
    final mm = value.minute.toString().padLeft(2, '0');
    return '$hh:$mm';
  }
}

class _EmptyStateCard extends StatelessWidget {
  const _EmptyStateCard();

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(AppSpacing.md),
      decoration: BoxDecoration(
        color: const Color(0xFF152F53).withValues(alpha: 0.82),
        borderRadius: BorderRadius.circular(AppRadius.md),
      ),
      child: Text(
        'Bulunduğun konum için henüz yeni ihbar yok. Harita ekranından ilk bildirimi sen oluşturabilirsin.',
        style: AppTextStyles.body.copyWith(color: Colors.white70),
      ),
    );
  }
}

class _EmptyNearbyCard extends StatelessWidget {
  const _EmptyNearbyCard();

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(AppSpacing.md),
      decoration: BoxDecoration(
        color: const Color(0xFF152F53).withValues(alpha: 0.82),
        borderRadius: BorderRadius.circular(AppRadius.md),
      ),
      child: Text(
        'Çevrede listelenecek ihbar bulunamadı.',
        style: AppTextStyles.body.copyWith(color: Colors.white70),
      ),
    );
  }
}
