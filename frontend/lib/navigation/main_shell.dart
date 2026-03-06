import 'package:flutter/material.dart';

import '../screens/emergency_active_screen.dart';
import '../screens/home_screen.dart';
import '../screens/map_report_screen.dart';
import '../screens/medium_risk_home_screen.dart';
import '../screens/profile_screen.dart';
import '../screens/risk_alert_home_screen.dart';
import '../screens/risk_decision_screen.dart';
import '../screens/settings_screen.dart';
import '../state/app_state.dart';
import '../theme/design_system.dart';

class MainShell extends StatelessWidget {
  const MainShell({super.key, required this.appState});

  final AppState appState;

  @override
  Widget build(BuildContext context) {
    final pages = [
      appState.emergencyActive
          ? EmergencyActiveScreen(appState: appState)
          : appState.showRiskDecision
          ? RiskDecisionScreen(
              appState: appState,
              onOpenProfile: () => appState.setIndex(3),
            )
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
          ? MapReportScreen(appState: appState, onBack: () => appState.setIndex(0))
          : const SizedBox.shrink(),
      SettingsScreen(appState: appState),
      ProfileScreen(appState: appState),
    ];

    return Scaffold(
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
                    items: const [
                      BottomNavigationBarItem(
                        icon: Icon(Icons.home_rounded),
                        label: 'Home',
                      ),
                      BottomNavigationBarItem(
                        icon: Icon(Icons.map_rounded),
                        label: 'Map/Report',
                      ),
                      BottomNavigationBarItem(
                        icon: Icon(Icons.settings_rounded),
                        label: 'Settings',
                      ),
                      BottomNavigationBarItem(
                        icon: Icon(Icons.person_rounded),
                        label: 'Profile',
                      ),
                    ],
                  ),
                ),
              ),
            ),
    );
  }
}
