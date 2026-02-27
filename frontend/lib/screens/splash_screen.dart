import 'dart:math' as math;

import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';

import '../theme/design_system.dart';

class SplashScreen extends StatelessWidget {
  const SplashScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Container(
        decoration: const BoxDecoration(
          gradient: LinearGradient(
            begin: Alignment.topCenter,
            end: Alignment.bottomCenter,
            colors: [
              Color(0xFF00172F),
              Color(0xFF2E5F5A),
              Color(0xFF1C3A2A),
            ],
          ),
        ),
        child: Stack(
          children: [
            const _BackdropShapes(),
            SafeArea(
              child: Padding(
                padding: const EdgeInsets.symmetric(
                  horizontal: AppSpacing.lg,
                  vertical: AppSpacing.lg,
                ),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.stretch,
                  children: [
                    Text(
                      'Giris1',
                      style: AppTextStyles.caption.copyWith(
                        color: Colors.white70,
                        fontSize: 24,
                      ),
                    ),
                    const Spacer(),
                    Center(
                      child: Column(
                        mainAxisSize: MainAxisSize.min,
                        children: [
                          RichText(
                            text: TextSpan(
                              children: [
                                TextSpan(
                                  text: 'SAYE',
                                  style: GoogleFonts.spaceGrotesk(
                                    color: const Color(0xE6001114),
                                    fontWeight: FontWeight.w800,
                                    fontSize: 74,
                                    letterSpacing: 2,
                                  ),
                                ),
                                TextSpan(
                                  text: "'nde",
                                  style: GoogleFonts.allura(
                                    color: const Color(0xFFE2F3E9),
                                    fontSize: 54,
                                    fontWeight: FontWeight.w400,
                                  ),
                                ),
                              ],
                            ),
                          ),
                          const SizedBox(height: 10),
                          Text(
                            'Kesik Hatti',
                            style: GoogleFonts.allura(
                              color: const Color(0xFF051A45),
                              fontSize: 68,
                              fontWeight: FontWeight.w400,
                            ),
                          ),
                        ],
                      ),
                    ),
                    const Spacer(),
                    const Center(
                      child: SizedBox(
                        width: 18,
                        height: 18,
                        child: CircularProgressIndicator(
                          strokeWidth: 2,
                          valueColor: AlwaysStoppedAnimation<Color>(
                            Colors.white70,
                          ),
                        ),
                      ),
                    ),
                    const SizedBox(height: AppSpacing.md),
                  ],
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class _BackdropShapes extends StatelessWidget {
  const _BackdropShapes();

  @override
  Widget build(BuildContext context) {
    return Positioned.fill(
      child: IgnorePointer(
        child: Stack(
          children: [
            Positioned(
              top: -70,
              left: -85,
              child: Container(
                width: 290,
                height: 290,
                decoration: BoxDecoration(
                  color: const Color(0xFF001228).withValues(alpha: 0.75),
                  shape: BoxShape.circle,
                ),
              ),
            ),
            Positioned(
              top: -35,
              right: -120,
              child: Container(
                width: 420,
                height: 420,
                decoration: BoxDecoration(
                  color: const Color(0xFFB8CED6).withValues(alpha: 0.18),
                  shape: BoxShape.circle,
                ),
              ),
            ),
            Positioned(
              bottom: 0,
              left: 0,
              child: ClipPath(
                clipper: _TriangleClipper(),
                child: Container(
                  width: 330,
                  height: 190,
                  decoration: const BoxDecoration(
                    gradient: LinearGradient(
                      colors: [Color(0xFF16331E), Color(0x3315221D)],
                    ),
                  ),
                ),
              ),
            ),
            Positioned(
              bottom: 0,
              right: 0,
              child: Transform.rotate(
                angle: -math.pi / 8,
                child: ClipPath(
                  clipper: _TriangleClipper(),
                  child: Container(
                    width: 220,
                    height: 160,
                    color: const Color(0x55051410),
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

class _TriangleClipper extends CustomClipper<Path> {
  @override
  Path getClip(Size size) {
    return Path()
      ..moveTo(0, size.height)
      ..lineTo(size.width, size.height)
      ..lineTo(size.width * 0.68, 0)
      ..close();
  }

  @override
  bool shouldReclip(covariant CustomClipper<Path> oldClipper) => false;
}
