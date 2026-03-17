import 'package:flutter/material.dart';

import '../screens/emergency_active_screen.dart';
import '../screens/home_screen.dart';
import '../screens/map_report_screen.dart';
import '../screens/medium_risk_home_screen.dart';
import '../screens/profile_screen.dart';
import '../screens/risk_alert_home_screen.dart';
import '../screens/settings_screen.dart';
import '../state/app_state.dart';
import '../theme/design_system.dart';

class MainShell extends StatelessWidget {
  const MainShell({super.key, required this.appState});

  final AppState appState;

  static const _navItems = [
    (
      icon: Icons.home_rounded,
      activeIcon: Icons.home_filled,
      label: 'Ana Sayfa',
    ),
    (
      icon: Icons.map_rounded,
      activeIcon: Icons.map,
      label: 'Bildirimler',
    ),
    (
      icon: Icons.settings_rounded,
      activeIcon: Icons.settings,
      label: 'Ayarlar',
    ),
    (
      icon: Icons.person_rounded,
      activeIcon: Icons.person,
      label: 'Profil',
    ),
  ];

  @override
  Widget build(BuildContext context) {
    final pages = [
      appState.emergencyActive
          ? EmergencyActiveScreen(appState: appState)
          : appState.riskLevel == RiskLevel.high
          ? RiskAlertHomeScreen(
              appState: appState,
              onOpenMap: () => appState.setIndex(1),
              onOpenProfile: () => appState.setIndex(3),
            )
          : appState.riskLevel == RiskLevel.medium
          ? MediumRiskHomeScreen(
              appState: appState,
              onOpenMap: () => appState.setIndex(1),
              onOpenProfile: () => appState.setIndex(3),
            )
          : HomeScreen(
              appState: appState,
              onOpenMap: () => appState.setIndex(1),
              onOpenProfile: () => appState.setIndex(3),
            ),
      appState.selectedIndex == 1
          ? MapReportScreen(
              appState: appState,
              onBack: () => appState.setIndex(0),
            )
          : const SizedBox.shrink(),
      SettingsScreen(appState: appState),
      ProfileScreen(appState: appState),
    ];

    return Scaffold(
      backgroundColor: AppColors.deepNavy,
      extendBody: true,
      body: Stack(
        children: [
          Container(
            decoration: const BoxDecoration(
              gradient: AppGradients.mainBackground,
            ),
            child: IndexedStack(index: appState.selectedIndex, children: pages),
          ),
          if (appState.isLoading)
            const Positioned.fill(
              child: ColoredBox(
                color: Color(0x55000000),
                child: Center(child: CircularProgressIndicator()),
              ),
            ),
        ],
      ),
      bottomNavigationBar: appState.emergencyActive
          ? null
          : IgnorePointer(
              ignoring: appState.isLoading,
              child: Padding(
                padding: const EdgeInsets.fromLTRB(
                  AppSpacing.md,
                  0,
                  AppSpacing.md,
                  AppSpacing.md,
                ),
                child: Container(
                  decoration: BoxDecoration(
                    color: AppColors.card.withValues(alpha: 0.95),
                    borderRadius: BorderRadius.circular(AppRadius.xl),
                    border: Border.all(
                      color: Colors.white.withValues(alpha: 0.08),
                    ),
                    boxShadow: AppShadows.soft,
                  ),
                  child: BottomNavigationBar(
                    currentIndex: appState.selectedIndex,
                    onTap: appState.setIndex,
                    backgroundColor: Colors.transparent,
                    type: BottomNavigationBarType.fixed,
                    elevation: 0,
                    selectedItemColor: AppColors.aquaGlow,
                    unselectedItemColor: AppColors.textSecondary,
                    showUnselectedLabels: true,
                    selectedFontSize: 12,
                    unselectedFontSize: 12,
                    selectedLabelStyle: AppTextStyles.caption.copyWith(
                      color: AppColors.aquaGlow,
                      fontWeight: FontWeight.w700,
                    ),
                    unselectedLabelStyle: AppTextStyles.caption.copyWith(
                      color: AppColors.textSecondary,
                    ),
                    items: [
                      for (var i = 0; i < _navItems.length; i++)
                        BottomNavigationBarItem(
                          icon: _NavIcon(
                            icon: _navItems[i].icon,
                            isSelected: i == appState.selectedIndex,
                          ),
                          activeIcon: _NavIcon(
                            icon: _navItems[i].activeIcon,
                            isSelected: true,
                          ),
                          label: _navItems[i].label,
                        ),
                    ],
                  ),
                ),
              ),
            ),
    );
  }
}

class _NavIcon extends StatelessWidget {
  const _NavIcon({required this.icon, required this.isSelected});

  final IconData icon;
  final bool isSelected;

  @override
  Widget build(BuildContext context) {
    return AnimatedContainer(
      duration: const Duration(milliseconds: 180),
      curve: Curves.easeOut,
      padding: const EdgeInsets.symmetric(
        horizontal: AppSpacing.sm,
        vertical: AppSpacing.xs,
      ),
      decoration: BoxDecoration(
        color: isSelected
            ? AppColors.aquaGlow.withValues(alpha: 0.14)
            : Colors.transparent,
        borderRadius: BorderRadius.circular(AppRadius.lg),
      ),
      child: Icon(icon),
    );
  }
}
