import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';

import '../config/app_strings.dart';
import '../state/app_state.dart';
import '../theme/design_system.dart';
import 'alerts_feed_screen.dart';

class HomeScreen extends StatefulWidget {
  const HomeScreen({
    super.key,
    required this.appState,
    required this.onOpenMap,
    required this.onOpenProfile,
  });

  final AppState appState;
  final VoidCallback onOpenMap;
  final VoidCallback onOpenProfile;

  @override
  State<HomeScreen> createState() => _HomeScreenState();
}

class _HomeScreenState extends State<HomeScreen> {
  @override
  void initState() {
    super.initState();
    _fetchLocationIfNeeded();
  }

  Future<void> _fetchLocationIfNeeded() async {
    try {
      await widget.appState.ensureMapDataLoaded();
    } catch (e) {
      debugPrint('Failed to prepare map data: $e');
      if (!mounted) {
        return;
      }
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text(
            'Harita verileri şimdi yüklenemiyor. Lütfen tekrar deneyin.',
          ),
          behavior: SnackBarBehavior.floating,
        ),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    final risk = widget.appState.riskLevel;
    final riskLabel = _riskTitle(risk);
    final riskLevelLabel = _riskLevelLabel(risk);
    final riskColor = _riskColor(risk);

    return SafeArea(
      child: Stack(
        children: [
          SingleChildScrollView(
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
                    const SizedBox(height: AppSpacing.md),
                    _TopBar(
                      location: widget.appState.currentLocationName,
                      onProfileTap: widget.onOpenProfile,
                    ),
                    const SizedBox(height: AppSpacing.md),
                    _RiskSection(
                      riskLabel: riskLabel,
                      riskLevelLabel: riskLevelLabel,
                      color: riskColor,
                      onNotificationsTap: () => _openAlertsFeed(context),
                      onDebugCycle: widget.appState.cycleRiskLevel,
                    ),
                    const SizedBox(height: AppSpacing.md),
                    _MapPreviewCard(onTap: widget.onOpenMap),
                    const SizedBox(height: AppSpacing.md),
                    Text(
                      'BASILI TUT: YARDIM ÇAĞIR',
                      textAlign: TextAlign.center,
                      style: AppTextStyles.body.copyWith(
                        letterSpacing: 0.8,
                        color: Colors.white70,
                      ),
                    ),
                    const SizedBox(height: AppSpacing.xs),
                    const Divider(color: Colors.white24, height: 1),
                    const SizedBox(height: AppSpacing.md),
                    Center(
                      child: GestureDetector(
                        onLongPress: () async {
                          try {
                            await widget.appState.activateEmergencyDynamic();
                          } catch (e) {
                            if (!context.mounted) {
                              return;
                            }
                            final message = e is AppStateException
                                ? e.message
                                : e.toString();
                            if (message.trim().isEmpty) {
                              return;
                            }
                            ScaffoldMessenger.of(context).showSnackBar(
                              SnackBar(
                                content: Text(
                                  '${AppStrings.sosStartFailedPrefix}$message',
                                ),
                                behavior: SnackBarBehavior.floating,
                              ),
                            );
                          }
                        },
                        child: Container(
                          width: 122,
                          height: 122,
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
                                blurRadius: 26,
                                spreadRadius: 2,
                              ),
                            ],
                          ),
                          child: Center(
                            child: Text(
                              'ACIL',
                              style: AppTextStyles.title.copyWith(
                                fontSize: 34,
                                fontWeight: FontWeight.w800,
                                color: Colors.white,
                              ),
                            ),
                          ),
                        ),
                      ),
                    ),
                    const SizedBox(height: AppSpacing.sm),
                    Center(
                      child: SizedBox(
                        width: 220,
                        child: OutlinedButton.icon(
                          onPressed: () async {
                            try {
                              await widget.appState.activateEmergencyDynamic();
                            } catch (e) {
                              if (!context.mounted) {
                                return;
                              }
                              final message = e is AppStateException
                                  ? e.message
                                  : e.toString();
                              if (message.trim().isEmpty) {
                                return;
                              }
                              ScaffoldMessenger.of(context).showSnackBar(
                                SnackBar(
                                  content: Text(
                                    '${AppStrings.sosStartFailedPrefix}$message',
                                  ),
                                  behavior: SnackBarBehavior.floating,
                                ),
                              );
                            }
                          },
                          style: OutlinedButton.styleFrom(
                            foregroundColor: const Color(0xFFFFB6BC),
                            side: const BorderSide(color: Color(0xFFFF6B75)),
                          ),
                          icon: const Icon(Icons.touch_app_rounded),
                          label: const Text('Tek Tıkla Acil Aç'),
                        ),
                      ),
                    ),
                  ],
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }

  void _openAlertsFeed(BuildContext context) {
    Navigator.of(context).push(
      MaterialPageRoute<void>(
        builder: (_) => AlertsFeedScreen(appState: widget.appState),
      ),
    );
  }

  String _riskTitle(RiskLevel level) {
    switch (level) {
      case RiskLevel.low:
        return AppStrings.safeZone;
      case RiskLevel.medium:
      case RiskLevel.high:
      case RiskLevel.critical:
        return AppStrings.riskyArea;
    }
  }

  String _riskLevelLabel(RiskLevel level) {
    switch (level) {
      case RiskLevel.low:
        return AppStrings.lowRisk;
      case RiskLevel.medium:
        return 'Orta';
      case RiskLevel.high:
        return AppStrings.highRisk;
      case RiskLevel.critical:
        return AppStrings.criticalRisk;
    }
  }

  Color _riskColor(RiskLevel level) {
    switch (level) {
      case RiskLevel.low:
        return const Color(0xFF89F772);
      case RiskLevel.medium:
        return const Color(0xFFFF8A3A);
      case RiskLevel.high:
        return const Color(0xFFFF5D66);
      case RiskLevel.critical:
        return const Color(0xFFFF2638);
    }
  }

  // ignore: unused_element
  String _bluetoothMessage(RiskLevel level) {
    switch (level) {
      case RiskLevel.low:
        return 'Aktif Tarama: Şüpheli cihaz yakınlığı yok.';
      case RiskLevel.medium:
        return 'Aktif Tarama: Şüpheli cihaz yakınlığı tespit edildi.';
      case RiskLevel.high:
        return 'Aktif Tarama: Şüpheli cihaz yakınlığı var. Uzun süreli takip görünüyor.';
      case RiskLevel.critical:
        return 'Aktif Tarama: Kritik risk algılandı. Yardım akışı hazır.';
    }
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

class _TopBar extends StatelessWidget {
  const _TopBar({
    required this.location,
    required this.onProfileTap,
  });

  final String location;
  final VoidCallback onProfileTap;

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(
        horizontal: AppSpacing.md,
        vertical: AppSpacing.sm,
      ),
      decoration: BoxDecoration(
        color: const Color(0xFF112E54).withValues(alpha: 0.95),
        borderRadius: BorderRadius.circular(AppRadius.lg),
      ),
      child: Row(
        children: [
          const Icon(
            Icons.location_on_rounded,
            color: Color(0xFF52F3A6),
            size: 20,
          ),
          const SizedBox(width: AppSpacing.xs),
          Expanded(
            child: Text(
              location,
              style: AppTextStyles.title.copyWith(fontSize: 22),
            ),
          ),
          const Icon(Icons.keyboard_arrow_down_rounded, color: Colors.white70),
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
      ),
    );
  }
}

class _RiskSection extends StatelessWidget {
  const _RiskSection({
    required this.riskLabel,
    required this.riskLevelLabel,
    required this.color,
    required this.onNotificationsTap,
    required this.onDebugCycle,
  });

  final String riskLabel;
  final String riskLevelLabel;
  final Color color;
  final VoidCallback onNotificationsTap;
  final VoidCallback onDebugCycle;

  @override
  Widget build(BuildContext context) {
    return Container(
      decoration: BoxDecoration(
        gradient: const LinearGradient(
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
          colors: [Color(0xFF102A4C), Color(0xFF0C2240)],
        ),
        borderRadius: BorderRadius.circular(AppRadius.md),
        border: Border.all(color: Colors.white10),
      ),
      padding: const EdgeInsets.all(AppSpacing.md),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          Row(
            children: [
              const Spacer(),
              IconButton(
                onPressed: onNotificationsTap,
                icon: Icon(
                  Icons.notifications_rounded,
                  color: Colors.white.withValues(alpha: 0.9),
                ),
                tooltip: 'Güncel bildirimler',
              ),
            ],
          ),
          const SizedBox(height: AppSpacing.xs),
          Center(
            child: Container(
              width: 176,
              height: 176,
              decoration: BoxDecoration(
                shape: BoxShape.circle,
                border: Border.all(color: color, width: 4),
                boxShadow: [
                  BoxShadow(
                    color: color.withValues(alpha: 0.45),
                    blurRadius: 20,
                  ),
                ],
              ),
              child: Center(
                child: Column(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    Text(
                      riskLabel,
                      style: AppTextStyles.title.copyWith(
                        color: color,
                        fontSize: 23,
                        fontWeight: FontWeight.w700,
                      ),
                      textAlign: TextAlign.center,
                    ),
                    const SizedBox(height: AppSpacing.xs),
                    Text(
                      'Risk Seviyesi: $riskLevelLabel',
                      style: AppTextStyles.body.copyWith(
                        color: Colors.white,
                        fontWeight: FontWeight.w700,
                      ),
                      textAlign: TextAlign.center,
                    ),
                  ],
                ),
              ),
            ),
          ),
          Align(
            alignment: Alignment.bottomLeft,
            child: GestureDetector(
              onLongPress: onDebugCycle,
              child: const SizedBox(width: 28, height: 28),
            ),
          ),
        ],
      ),
    );
  }
}

class _MapPreviewCard extends StatelessWidget {
  const _MapPreviewCard({required this.onTap});

  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    return InkWell(
      borderRadius: BorderRadius.circular(AppRadius.md),
      onTap: onTap,
      child: Container(
        height: 160,
        decoration: BoxDecoration(
          borderRadius: BorderRadius.circular(AppRadius.md),
          gradient: const LinearGradient(
            begin: Alignment.topLeft,
            end: Alignment.bottomRight,
            colors: [Color(0xFFE8E8E8), Color(0xFFCBCBCB)],
          ),
        ),
        child: Stack(
          children: [
            Positioned.fill(child: CustomPaint(painter: _MapGridPainter())),
            const Positioned(
              left: 38,
              top: 54,
              child: Icon(
                Icons.place_rounded,
                color: Color(0xFFD81B60),
                size: 34,
              ),
            ),
            const Positioned(
              left: 100,
              top: 94,
              child: Icon(Icons.circle, color: Color(0xFF2682FF), size: 12),
            ),
            Positioned(
              right: 14,
              bottom: 14,
              child: Container(
                padding: const EdgeInsets.symmetric(
                  horizontal: 10,
                  vertical: 6,
                ),
                decoration: BoxDecoration(
                  color: Colors.black.withValues(alpha: 0.5),
                  borderRadius: BorderRadius.circular(AppRadius.sm),
                ),
                child: Text(
                  'Haritaya Git',
                  style: AppTextStyles.caption.copyWith(color: Colors.white),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class _MapGridPainter extends CustomPainter {
  @override
  void paint(Canvas canvas, Size size) {
    final paint = Paint()
      ..color = const Color(0xFF9B9B9B).withValues(alpha: 0.35)
      ..strokeWidth = 1;

    for (double y = 16; y < size.height; y += 18) {
      canvas.drawLine(Offset(0, y), Offset(size.width, y), paint);
    }
    for (double x = 14; x < size.width; x += 22) {
      canvas.drawLine(Offset(x, 0), Offset(x, size.height), paint);
    }
  }

  @override
  bool shouldRepaint(covariant CustomPainter oldDelegate) => false;
}
