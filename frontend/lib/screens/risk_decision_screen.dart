import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';

import '../state/app_state.dart';
import '../theme/design_system.dart';

class RiskDecisionScreen extends StatelessWidget {
  const RiskDecisionScreen({
    super.key,
    required this.appState,
    required this.onOpenProfile,
  });

  final AppState appState;
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
                _TopHeader(onProfileTap: onOpenProfile),
                const SizedBox(height: AppSpacing.md),
                _LocationRow(location: appState.currentLocationLabel),
                const SizedBox(height: AppSpacing.md),
                const _RiskCircle(),
                const SizedBox(height: AppSpacing.md),
                _InfoCard(
                  title: 'ACIL DURUM AKTIF',
                  text: 'Sana en yakin guvenli bolge rotasi olusturuluyor...',
                ),
                const SizedBox(height: AppSpacing.sm),
                _InfoCard(
                  text: 'Acil durum kisileri ile bilgilerin paylasildi!',
                  trailing: const Icon(
                    Icons.check_box_rounded,
                    color: Color(0xFF8CF0A6),
                  ),
                ),
                const SizedBox(height: AppSpacing.sm),
                Container(
                  padding: const EdgeInsets.all(AppSpacing.md),
                  decoration: BoxDecoration(
                    color: const Color(0xFF163760).withValues(alpha: 0.88),
                    borderRadius: BorderRadius.circular(AppRadius.md),
                    border: Border.all(color: Colors.white24),
                  ),
                  child: Text(
                    'Yuksek risk alanina gecmek ister misin?',
                    textAlign: TextAlign.center,
                    style: AppTextStyles.body.copyWith(
                      color: Colors.white.withValues(alpha: 0.95),
                      fontSize: 20,
                    ),
                  ),
                ),
                const SizedBox(height: AppSpacing.md),
                Row(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    const Icon(
                      Icons.chevron_left_rounded,
                      color: Color(0xFF4D8EEB),
                      size: 36,
                    ),
                    const SizedBox(width: AppSpacing.sm),
                    GestureDetector(
                      onTap: appState.acceptRiskDecision,
                      child: Container(
                        width: 124,
                        height: 124,
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
                            'EVET',
                            style: AppTextStyles.title.copyWith(
                              color: Colors.white,
                              fontSize: 34,
                              fontWeight: FontWeight.w800,
                            ),
                          ),
                        ),
                      ),
                    ),
                    const SizedBox(width: AppSpacing.sm),
                    const Icon(
                      Icons.chevron_right_rounded,
                      color: Color(0xFF4D8EEB),
                      size: 36,
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

class _TopHeader extends StatelessWidget {
  const _TopHeader({required this.onProfileTap});

  final VoidCallback onProfileTap;

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
      child: Row(
        children: [
          const Icon(
            Icons.chevron_left_rounded,
            color: Color(0xFF4D8EEB),
            size: 34,
          ),
          Expanded(
            child: Center(
              child: RichText(
                text: TextSpan(
                  children: [
                    TextSpan(
                      text: 'SAYE',
                      style: GoogleFonts.spaceGrotesk(
                        color: Colors.white.withValues(alpha: 0.72),
                        fontWeight: FontWeight.w800,
                        fontSize: 44,
                        letterSpacing: 1.4,
                      ),
                    ),
                    TextSpan(
                      text: "'nde",
                      style: GoogleFonts.allura(
                        color: Colors.white,
                        fontSize: 34,
                        fontWeight: FontWeight.w400,
                      ),
                    ),
                  ],
                ),
              ),
            ),
          ),
          GestureDetector(
            onTap: onProfileTap,
            child: Container(
              width: 34,
              height: 34,
              decoration: BoxDecoration(
                shape: BoxShape.circle,
                color: Colors.white.withValues(alpha: 0.3),
              ),
              child: const Icon(Icons.person_rounded, color: Colors.white),
            ),
          ),
        ],
      ),
    );
  }
}

class _LocationRow extends StatelessWidget {
  const _LocationRow({required this.location});

  final String location;

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
            location,
            style: AppTextStyles.title.copyWith(fontSize: 22),
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

class _InfoCard extends StatelessWidget {
  const _InfoCard({required this.text, this.title, this.trailing});

  final String text;
  final String? title;
  final Widget? trailing;

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(
        horizontal: AppSpacing.md,
        vertical: AppSpacing.md,
      ),
      decoration: BoxDecoration(
        color: const Color(0xFF2B4E7A).withValues(alpha: 0.92),
        borderRadius: BorderRadius.circular(AppRadius.md),
        border: Border.all(color: Colors.white24),
      ),
      child: Row(
        children: [
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                if (title != null) ...[
                  Text(
                    title!,
                    style: AppTextStyles.title.copyWith(
                      color: const Color(0xFFFF5A63),
                      fontSize: 22,
                      fontWeight: FontWeight.w800,
                    ),
                  ),
                  const SizedBox(height: 4),
                ],
                Text(
                  text,
                  style: AppTextStyles.body.copyWith(
                    color: Colors.white.withValues(alpha: 0.95),
                    fontSize: 17,
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
      ),
    );
  }
}
