import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';

import '../config/app_defaults.dart';
import '../state/app_state.dart';
import '../theme/design_system.dart';

class MediumRiskHomeScreen extends StatelessWidget {
  const MediumRiskHomeScreen({
    super.key,
    required this.appState,
    required this.onOpenMap,
    required this.onOpenProfile,
  });

  final AppState appState;
  final VoidCallback onOpenMap;
  final VoidCallback onOpenProfile;

  @override
  Widget build(BuildContext context) {
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
                const _LogoStrip(),
                const SizedBox(height: AppSpacing.sm),
                _LocationRow(onProfileTap: onOpenProfile),
                const SizedBox(height: AppSpacing.md),
                const _RiskCircle(),
                const SizedBox(height: AppSpacing.md),
                _MapCard(onTap: onOpenMap),
                const SizedBox(height: AppSpacing.md),
                const _BluetoothWarningCard(),
                const SizedBox(height: AppSpacing.md),
                Text(
                  'BASILI TUT: YARDIM CAGIR',
                  textAlign: TextAlign.center,
                  style: AppTextStyles.body.copyWith(color: Colors.white70),
                ),
                const SizedBox(height: AppSpacing.xs),
                const Divider(color: Colors.white24),
                const SizedBox(height: AppSpacing.sm),
                Center(
                  child: GestureDetector(
                    onTap: () async {
                      try {
                        await appState.activateEmergency();
                      } catch (e) {
                        if (!context.mounted) {
                          return;
                        }
                        ScaffoldMessenger.of(context).showSnackBar(
                          SnackBar(
                            content: Text('SOS baslatilamadi: $e'),
                            behavior: SnackBarBehavior.floating,
                          ),
                        );
                      }
                    },
                    onLongPress: () async {
                      try {
                        await appState.activateEmergency();
                      } catch (e) {
                        if (!context.mounted) {
                          return;
                        }
                        ScaffoldMessenger.of(context).showSnackBar(
                          SnackBar(
                            content: Text('SOS baslatilamadi: $e'),
                            behavior: SnackBarBehavior.floating,
                          ),
                        );
                      }
                    },
                    child: Container(
                      width: 118,
                      height: 118,
                      decoration: BoxDecoration(
                        shape: BoxShape.circle,
                        gradient: const RadialGradient(
                          colors: [Color(0xFFFF4D59), Color(0xFFC21D34)],
                        ),
                        boxShadow: [
                          BoxShadow(
                            color: const Color(
                              0xFFFF304D,
                            ).withValues(alpha: 0.35),
                            blurRadius: 24,
                            spreadRadius: 2,
                          ),
                        ],
                      ),
                      child: Center(
                        child: Text(
                          'ACIL',
                          style: AppTextStyles.title.copyWith(
                            color: Colors.white,
                            fontSize: 34,
                            fontWeight: FontWeight.w800,
                          ),
                        ),
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
  }
}

class _LogoStrip extends StatelessWidget {
  const _LogoStrip();

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(
        horizontal: AppSpacing.md,
        vertical: AppSpacing.sm,
      ),
      decoration: BoxDecoration(
        color: const Color(0xFF284872).withValues(alpha: 0.86),
        borderRadius: BorderRadius.circular(AppRadius.lg),
      ),
      child: Center(
        child: RichText(
          text: TextSpan(
            children: [
              TextSpan(
                text: 'SAYE',
                style: GoogleFonts.spaceGrotesk(
                  color: Colors.white.withValues(alpha: 0.75),
                  fontWeight: FontWeight.w800,
                  fontSize: 48,
                  letterSpacing: 1.4,
                ),
              ),
              TextSpan(
                text: "'nde",
                style: GoogleFonts.allura(
                  color: Colors.white.withValues(alpha: 0.95),
                  fontSize: 38,
                  fontWeight: FontWeight.w400,
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}

class _LocationRow extends StatelessWidget {
  const _LocationRow({required this.onProfileTap});

  final VoidCallback onProfileTap;

  @override
  Widget build(BuildContext context) {
    return Row(
      children: [
        const Icon(
          Icons.location_on_rounded,
          color: Color(0xFF52F3A6),
          size: 22,
        ),
        const SizedBox(width: AppSpacing.xs),
        Expanded(
          child: Text(
            AppDefaults.campusLocation,
            style: AppTextStyles.title.copyWith(fontSize: 22),
          ),
        ),
        const Icon(Icons.notifications_rounded, color: Colors.white),
        const SizedBox(width: AppSpacing.sm),
        GestureDetector(
          onTap: onProfileTap,
          child: Container(
            width: 34,
            height: 34,
            decoration: BoxDecoration(
              shape: BoxShape.circle,
              color: Colors.white.withValues(alpha: 0.28),
            ),
            child: const Icon(
              Icons.person_rounded,
              color: Colors.white,
              size: 22,
            ),
          ),
        ),
      ],
    );
  }
}

class _RiskCircle extends StatelessWidget {
  const _RiskCircle();

  @override
  Widget build(BuildContext context) {
    return Center(
      child: Container(
        width: 170,
        height: 170,
        decoration: BoxDecoration(
          shape: BoxShape.circle,
          border: Border.all(color: const Color(0xFFFFA14A), width: 4),
          boxShadow: [
            BoxShadow(
              color: const Color(0xFFFFA14A).withValues(alpha: 0.4),
              blurRadius: 20,
            ),
          ],
        ),
        child: Center(
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              Text(
                'RISKLI ALAN',
                style: AppTextStyles.title.copyWith(
                  color: const Color(0xFFFFB065),
                  fontSize: 23,
                  fontWeight: FontWeight.w700,
                ),
              ),
              const SizedBox(height: AppSpacing.xs),
              Text(
                'Risk Seviyesi: Orta',
                style: AppTextStyles.body.copyWith(
                  color: Colors.white,
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

class _MapCard extends StatelessWidget {
  const _MapCard({required this.onTap});

  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    return InkWell(
      onTap: onTap,
      borderRadius: BorderRadius.circular(AppRadius.md),
      child: Container(
        height: 150,
        decoration: BoxDecoration(
          borderRadius: BorderRadius.circular(AppRadius.md),
          gradient: const LinearGradient(
            colors: [Color(0xFFEAEAEA), Color(0xFFD0D0D0)],
          ),
        ),
        child: const Center(
          child: Icon(Icons.map_rounded, color: Color(0xFF4A4A4A), size: 48),
        ),
      ),
    );
  }
}

class _BluetoothWarningCard extends StatelessWidget {
  const _BluetoothWarningCard();

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(AppSpacing.md),
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(AppRadius.md),
        gradient: const LinearGradient(
          colors: [Color(0xFF2A4D87), Color(0xFF8F4A16)],
        ),
      ),
      child: Row(
        children: [
          Container(
            width: 54,
            height: 54,
            decoration: BoxDecoration(
              shape: BoxShape.circle,
              color: const Color(0xFF0A2D55),
              border: Border.all(color: Colors.white24),
            ),
            child: const Icon(Icons.radar_rounded, color: Color(0xFF26D0FF)),
          ),
          const SizedBox(width: AppSpacing.sm),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  'Bluetooth Takip Analizi',
                  style: AppTextStyles.title.copyWith(fontSize: 18),
                ),
                const SizedBox(height: 4),
                Text(
                  'Aktif Tarama: Supheli cihaz yakinligi orta riskte. Dikkatli ol.',
                  style: AppTextStyles.body.copyWith(
                    color: Colors.white.withValues(alpha: 0.95),
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}
