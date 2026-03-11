import 'package:flutter/material.dart';

import '../state/app_state.dart';
import '../theme/design_system.dart';

class EmergencyActiveScreen extends StatelessWidget {
  const EmergencyActiveScreen({super.key, required this.appState});

  final AppState appState;

  @override
  Widget build(BuildContext context) {
    return SafeArea(
      child: Container(
        width: double.infinity,
        decoration: const BoxDecoration(gradient: AppGradients.mainBackground),
        child: Center(
          child: Padding(
            padding: const EdgeInsets.symmetric(horizontal: AppSpacing.lg),
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                Text(
                  'ACIL DURUM',
                  style: AppTextStyles.headline.copyWith(
                    color: const Color(0xFFFF5A63),
                    fontSize: 34,
                    fontWeight: FontWeight.w800,
                  ),
                ),
                const SizedBox(height: AppSpacing.sm),
                Text(
                  'Yardim yolda',
                  style: AppTextStyles.body.copyWith(
                    color: Colors.white70,
                    fontSize: 16,
                    fontWeight: FontWeight.w600,
                  ),
                ),
                const SizedBox(height: AppSpacing.xl),
                Container(
                  width: 182,
                  height: 182,
                  decoration: BoxDecoration(
                    shape: BoxShape.circle,
                    gradient: const RadialGradient(
                      colors: [Color(0xFFFF4D59), Color(0xFFC21D34)],
                    ),
                    boxShadow: [
                      BoxShadow(
                        color: const Color(0xFFFF304D).withValues(alpha: 0.36),
                        blurRadius: 34,
                        spreadRadius: 4,
                      ),
                    ],
                  ),
                  child: Center(
                    child: Text(
                      'ACIL',
                      style: AppTextStyles.title.copyWith(
                        fontSize: 44,
                        fontWeight: FontWeight.w800,
                        color: Colors.white,
                      ),
                    ),
                  ),
                ),
                const SizedBox(height: AppSpacing.lg),
                SizedBox(
                  width: 210,
                  child: OutlinedButton(
                    onPressed: appState.deactivateEmergency,
                    style: OutlinedButton.styleFrom(
                      foregroundColor: Colors.white,
                      side: const BorderSide(color: Colors.white54),
                    ),
                    child: const Text('Durumu Kapat'),
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
