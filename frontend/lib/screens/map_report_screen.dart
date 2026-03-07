import 'dart:async';

import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:flutter_map/flutter_map.dart';
import 'package:latlong2/latlong.dart';

import '../config/app_defaults.dart';
import '../state/app_state.dart';
import '../theme/design_system.dart';
import 'report_sent_screen.dart';

class MapReportScreen extends StatefulWidget {
  const MapReportScreen({
    super.key,
    required this.appState,
    required this.onBack,
  });

  final AppState appState;
  final VoidCallback onBack;

  @override
  State<MapReportScreen> createState() => _MapReportScreenState();
}

class _MapReportScreenState extends State<MapReportScreen> {
  String? _selectedCategory;

  static const Map<String, IconData> _categoryIcons = {
    'Trafik': Icons.traffic_rounded,
    'Ariza': Icons.build_circle_rounded,
    'Saglik': Icons.medical_information_rounded,
    'Takip': Icons.remove_red_eye_rounded,
    'Hayvan': Icons.pets_rounded,
    'Suc': Icons.gpp_bad_rounded,
  };

  @override
  void initState() {
    super.initState();

    WidgetsBinding.instance.addPostFrameCallback((_) {
      _syncLocationAndRisk();
    });
  }

  @override
  Widget build(BuildContext context) {
    final latitude = widget.appState.currentLatitude;
    final longitude = widget.appState.currentLongitude;
    final hasLocation = latitude != null && longitude != null;

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
                _HeaderBar(onBack: widget.onBack),
                const SizedBox(height: AppSpacing.sm),
                Row(
                  children: [
                    const Icon(
                      Icons.location_on_rounded,
                      color: Color(0xFF52F3A6),
                      size: 24,
                    ),
                    const SizedBox(width: AppSpacing.xs),
                    Expanded(
                      child: Text(
                        AppDefaults.campusLocation,
                        style: AppTextStyles.title.copyWith(fontSize: 22),
                      ),
                    ),
                    const Icon(
                      Icons.keyboard_arrow_down_rounded,
                      color: Colors.white70,
                    ),
                  ],
                ),
                const SizedBox(height: AppSpacing.md),
                hasLocation
                    ? _LiveMap(
                        reports: widget.appState.nearbyReports,
                        centerLatitude: latitude!,
                        centerLongitude: longitude!,
                        isLoading: widget.appState.isMapDataLoading,
                      )
                    : _MapLoadingView(),
                const SizedBox(height: AppSpacing.md),
                Text(
                  'Anahtar Kelime Secerek Baska Kisileri Uyar!',
                  textAlign: TextAlign.center,
                  style: AppTextStyles.body.copyWith(
                    color: Colors.white70,
                    fontWeight: FontWeight.w700,
                  ),
                ),
                const SizedBox(height: AppSpacing.sm),
                Wrap(
                  spacing: AppSpacing.sm,
                  runSpacing: AppSpacing.sm,
                  children: AppDefaults.reportCategories
                      .map(
                        (category) => _CategoryChip(
                          icon:
                              _categoryIcons[category] ??
                              Icons.warning_amber_rounded,
                          label: category,
                          isSelected: _selectedCategory == category,
                          onTap: () {
                            setState(() {
                              _selectedCategory = category;
                            });
                          },
                        ),
                      )
                      .toList(),
                ),
                const SizedBox(height: AppSpacing.lg),
                ElevatedButton(
                  onPressed: _selectedCategory == null
                      ? null
                      : _openReportSheet,
                  style: ElevatedButton.styleFrom(
                    backgroundColor: const Color(0xFF3E4D65),
                    disabledBackgroundColor: const Color(
                      0xFF42506A,
                    ).withValues(alpha: 0.6),
                    foregroundColor: Colors.white,
                  ),
                  child: const Text('Bize Durumu Bildir!'),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }

  Future<void> _openReportSheet() async {
    final noteController = TextEditingController();
    final parentContext = context;

    await showModalBottomSheet<void>(
      context: context,
      isScrollControlled: true,
      backgroundColor: const Color(0xFF10294A),
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(AppRadius.lg)),
      ),
      builder: (context) {
        return Padding(
          padding: EdgeInsets.fromLTRB(
            AppSpacing.md,
            AppSpacing.md,
            AppSpacing.md,
            MediaQuery.of(context).viewInsets.bottom + AppSpacing.md,
          ),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                'Ihbar Gonder',
                style: AppTextStyles.title.copyWith(fontSize: 22),
              ),
              const SizedBox(height: AppSpacing.sm),
              Text(
                'Kategori: ${_selectedCategory ?? '-'}',
                style: AppTextStyles.body.copyWith(color: Colors.white70),
              ),
              const SizedBox(height: AppSpacing.xs),
              Text(
                'Konum: ${AppDefaults.selectedLocationLabel} (${AppDefaults.selectedLatLng})',
                style: AppTextStyles.body.copyWith(color: Colors.white70),
              ),
              const SizedBox(height: AppSpacing.md),
              TextField(
                controller: noteController,
                maxLines: 3,
                decoration: const InputDecoration(
                  hintText: 'Kisa aciklama (opsiyonel)',
                  fillColor: Color(0xFF1A3D66),
                ),
              ),
              const SizedBox(height: AppSpacing.md),
              SizedBox(
                width: double.infinity,
                child: ElevatedButton(
                  onPressed: () async {
                    try {
                      await widget.appState.addLocalReport(
                        category: _selectedCategory!,
                        locationLabel: AppDefaults.selectedLocationLabel,
                        latLng: AppDefaults.selectedLatLng,
                        description: noteController.text.trim(),
                      );
                    } catch (e) {
                      if (!parentContext.mounted) {
                        return;
                      }
                      ScaffoldMessenger.of(parentContext).showSnackBar(
                        SnackBar(
                          content: Text('Ihbar gonderilemedi: $e'),
                          behavior: SnackBarBehavior.floating,
                        ),
                      );
                      return;
                    }

                    if (!parentContext.mounted) {
                      return;
                    }
                    Navigator.of(parentContext).pop();
                    if (!mounted) {
                      return;
                    }
                    if (!parentContext.mounted) {
                      return;
                    }
                    await Navigator.of(parentContext).push(
                      MaterialPageRoute<void>(
                        builder: (_) => const ReportSentScreen(),
                      ),
                    );
                    if (!mounted) {
                      return;
                    }
                    setState(() {
                      _selectedCategory = null;
                    });
                  },
                  child: const Text('Gonder'),
                ),
              ),
            ],
          ),
        );
      },
    );

    noteController.dispose();
  }

  Future<void> _syncLocationAndRisk() async {
    try {
      await widget.appState.fetchRealLocation();
    } catch (e) {
      if (!mounted) {
        return;
      }
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text(e.toString()),
          behavior: SnackBarBehavior.floating,
        ),
      );
    }
  }
}

class _HeaderBar extends StatelessWidget {
  const _HeaderBar({required this.onBack});

  final VoidCallback onBack;

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
          IconButton(
            onPressed: onBack,
            icon: const Icon(
              Icons.chevron_left_rounded,
              color: Color(0xFF4D8EEB),
              size: 34,
            ),
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
          Container(
            width: 34,
            height: 34,
            decoration: BoxDecoration(
              shape: BoxShape.circle,
              color: Colors.white.withValues(alpha: 0.3),
            ),
            child: const Icon(Icons.person_rounded, color: Colors.white),
          ),
        ],
      ),
    );
  }
}

class _MapLoadingView extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return Container(
      height: 255,
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(AppRadius.md),
        color: const Color(0xFF10294A),
      ),
      child: const Center(
        child: CircularProgressIndicator(
          valueColor: AlwaysStoppedAnimation<Color>(Color(0xFF52F3A6)),
        ),
      ),
    );
  }
}

class _LiveMap extends StatelessWidget {
  const _LiveMap({
    required this.reports,
    required this.centerLatitude,
    required this.centerLongitude,
    required this.isLoading,
  });

  final List<NearbyReport> reports;
  final double centerLatitude;
  final double centerLongitude;
  final bool isLoading;

  @override
  Widget build(BuildContext context) {
    return Container(
      height: 255,
      decoration: BoxDecoration(borderRadius: BorderRadius.circular(AppRadius.md)),
      clipBehavior: Clip.hardEdge,
      child: Stack(
        children: [
          FlutterMap(
            options: MapOptions(
              initialCenter: LatLng(centerLatitude, centerLongitude),
                    initialZoom: 15,
            ),
            children: [
              TileLayer(
                urlTemplate: 'https://tile.openstreetmap.org/{z}/{x}/{y}.png',
                userAgentPackageName: 'com.elifkavurga.frontend',
                tileProvider: NetworkTileProvider(
                  headers: {
                    'User-Agent': 'Saye/1.0 (com.elifkavurga.frontend)',
                  },
                ),
              ),
              MarkerLayer(
                markers: [
                  for (final report in reports)
                    Marker(
                      width: 38,
                      height: 38,
                      point: LatLng(report.latitude, report.longitude),
                      child: Tooltip(
                        message:
                            '${report.category} - ${report.status.isEmpty ? 'Bildirildi' : report.status}',
                        child: Container(
                          decoration: const BoxDecoration(
                            shape: BoxShape.circle,
                            color: Color(0xFF151515),
                          ),
                          alignment: Alignment.center,
                          child: Icon(
                            _iconForReportCategory(report.category),
                            size: 20,
                            color: _colorForReportCategory(report.category),
                          ),
                        ),
                      ),
                    ),
                  Marker(
                    width: 36,
                    height: 36,
                    point: LatLng(centerLatitude, centerLongitude),
                    child: Container(
                      decoration: BoxDecoration(
                        color: const Color(0xFF1C7DFF).withValues(alpha: 0.2),
                        shape: BoxShape.circle,
                      ),
                      child: const Icon(
                        Icons.my_location_rounded,
                        color: Color(0xFF1C7DFF),
                        size: 24,
                      ),
                    ),
                  ),
                ],
              ),
            ],
          ),
          if (isLoading)
            const Positioned.fill(
              child: ColoredBox(
                color: Color(0x66000000),
                child: Center(child: CircularProgressIndicator()),
              ),
            ),
        ],
      ),
    );
  }

  static IconData _iconForReportCategory(String category) {
    switch (category.toUpperCase()) {
      case 'TRAFIK':
      case 'TRAFİK':
        return Icons.traffic_rounded;
      case 'SAGLIK':
      case 'SAĞLIK':
        return Icons.medical_services_rounded;
      case 'SUC':
      case 'SUÇ':
        return Icons.gpp_bad_rounded;
      case 'TAKIP':
        return Icons.remove_red_eye_rounded;
      case 'HAYVAN':
        return Icons.pets_rounded;
      case 'ARIZA':
        return Icons.build_rounded;
      default:
        return Icons.warning_amber_rounded;
    }
  }

  static Color _colorForReportCategory(String category) {
    switch (category.toUpperCase()) {
      case 'TRAFIK':
      case 'TRAFİK':
      case 'ARIZA':
        return const Color(0xFFFF9800);
      case 'SAGLIK':
      case 'SAĞLIK':
        return const Color(0xFFF44336);
      case 'SUC':
      case 'SUÇ':
        return const Color(0xFFE91E63);
      case 'TAKIP':
        return const Color(0xFF9C27B0);
      case 'HAYVAN':
        return const Color(0xFF8BC34A);
      default:
        return const Color(0xFFFF5722);
    }
  }
}

class _CategoryChip extends StatelessWidget {
  const _CategoryChip({
    required this.icon,
    required this.label,
    required this.isSelected,
    required this.onTap,
  });

  final IconData icon;
  final String label;
  final bool isSelected;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    return InkWell(
      onTap: onTap,
      borderRadius: BorderRadius.circular(AppRadius.md),
      child: AnimatedContainer(
        duration: const Duration(milliseconds: 180),
        constraints: const BoxConstraints(minWidth: 102),
        padding: const EdgeInsets.symmetric(
          horizontal: AppSpacing.md,
          vertical: AppSpacing.sm,
        ),
        decoration: BoxDecoration(
          gradient: isSelected
              ? const LinearGradient(
                  colors: [Color(0xFF5EAF6E), Color(0xFF3D7D49)],
                )
              : const LinearGradient(
                  colors: [Color(0xFF477B52), Color(0xFF355E3C)],
                ),
          borderRadius: BorderRadius.circular(AppRadius.md),
          border: Border.all(
            color: isSelected ? const Color(0xFFD4FFE4) : Colors.transparent,
          ),
        ),
        child: Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            Icon(icon, size: 17, color: Colors.white),
            const SizedBox(width: 7),
            Text(
              label,
              textAlign: TextAlign.center,
              style: AppTextStyles.body.copyWith(
                color: Colors.white,
                fontWeight: FontWeight.w600,
              ),
            ),
          ],
        ),
      ),
    );
  }
}

