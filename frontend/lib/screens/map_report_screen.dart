import 'dart:async';

import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:flutter_map/flutter_map.dart';
import 'package:latlong2/latlong.dart';

import '../config/app_defaults.dart';
import '../config/app_strings.dart';
import '../state/app_state.dart';
import '../theme/design_system.dart';

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
  LatLng? _selectedPoint;

  static const Map<String, IconData> _categoryIcons = {
    'Trafik': Icons.traffic_rounded,
    'Aydınlatma': Icons.lightbulb_rounded,
    'Altyapı': Icons.construction_rounded,
    'Hayvan': Icons.pets_rounded,
    AppStrings.crimeCategory: Icons.gpp_bad_rounded,
  };

  @override
  void initState() {
    super.initState();

    WidgetsBinding.instance.addPostFrameCallback((_) {
      _syncLocationAndRisk();
    });

    final latitude = widget.appState.currentLatitude;
    final longitude = widget.appState.currentLongitude;
    if (latitude != null && longitude != null) {
      _selectedPoint = LatLng(latitude, longitude);
    }
  }

  @override
  Widget build(BuildContext context) {
    final latitude = widget.appState.currentLatitude;
    final longitude = widget.appState.currentLongitude;
    final hasLocation = latitude != null && longitude != null;
    final selectedPoint =
        _selectedPoint ?? (hasLocation ? LatLng(latitude, longitude) : null);

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
                        widget.appState.currentLocationName,
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
                hasLocation && selectedPoint != null
                    ? _LiveMap(
                        reports: widget.appState.nearbyReports,
                        centerLatitude: latitude,
                        centerLongitude: longitude,
                        selectedLocation: selectedPoint,
                        isLoading: widget.appState.isMapDataLoading,
                        onTap: _handleMapTap,
                      )
                    : _MapLoadingView(),
                const SizedBox(height: AppSpacing.sm),
                const _RiskLegend(),
                const SizedBox(height: AppSpacing.md),
                Text(
                  'Anahtar Kelime Seçerek Başka Kişileri Uyar!',
                  textAlign: TextAlign.center,
                  style: AppTextStyles.body.copyWith(
                    color: Colors.white70,
                    fontWeight: FontWeight.w700,
                  ),
                ),
                const SizedBox(height: AppSpacing.sm),
                LayoutBuilder(
                  builder: (context, constraints) {
                    const spacing = AppSpacing.sm;
                    final itemWidth = (constraints.maxWidth - (spacing * 2)) / 3;

                    return Wrap(
                      spacing: spacing,
                      runSpacing: spacing,
                      alignment: WrapAlignment.center,
                      children: AppDefaults.reportCategories
                          .map(
                            (category) => SizedBox(
                              width: itemWidth,
                              child: _CategoryChip(
                                icon:
                                    _categoryIcons[category] ??
                                    Icons.warning_amber_rounded,
                                label: category,
                                isSelected: _selectedCategory == category,
                                onTap: () {
                                  if (!mounted) return;
                                  setState(() {
                                    _selectedCategory = category;
                                  });
                                },
                              ),
                            ),
                          )
                          .toList(),
                    );
                  },
                ),
                const SizedBox(height: AppSpacing.lg),
                ElevatedButton(
                  onPressed: _selectedCategory == null || selectedPoint == null
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
    final selectedPoint = _selectedPoint;
    if (selectedPoint == null) {
      throw StateError('Konum seçimi bulunamadı.');
    }
    final parentContext = context;
    final formattedLocation = _formatLatLng(selectedPoint);
    final result = await showModalBottomSheet<_ReportSheetResult>(
      context: context,
      isScrollControlled: true,
      backgroundColor: const Color(0xFF10294A),
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(AppRadius.lg)),
      ),
      builder: (context) {
        return _ReportSheet(
          category: _selectedCategory ?? '-',
          formattedLocation: formattedLocation,
          onSubmit: (description) async {
            await widget.appState.addLocalReport(
              category: _selectedCategory!,
              locationLabel: widget.appState.currentLocationName,
              latLng: formattedLocation,
              description: description,
              reportLatitude: selectedPoint.latitude,
              reportLongitude: selectedPoint.longitude,
            );
          },
        );
      },
    );

    if (!mounted || !parentContext.mounted || result == null) {
      return;
    }
    if (!result.submitted) {
      return;
    }

    setState(() {
      _selectedCategory = null;
    });
    ScaffoldMessenger.of(parentContext)
      ..hideCurrentSnackBar()
      ..showSnackBar(
        const SnackBar(
          content: Text('İhbar başarıyla gönderildi ve harita güncellendi.'),
          behavior: SnackBarBehavior.floating,
        ),
      );
  }
  Future<void> _syncLocationAndRisk() async {
    try {
      await widget.appState.ensureMapDataLoaded(force: true);
      if (!mounted) {
        return;
      }
      final latitude = widget.appState.currentLatitude;
      final longitude = widget.appState.currentLongitude;
      if (latitude != null && longitude != null) {
        if (!mounted) return;
        setState(() {
          _selectedPoint = LatLng(latitude, longitude);
        });
      }
    } catch (error) {
      if (!mounted) {
        return;
      }
      final message = error is AppStateException
          ? error.message
          : error.toString();
      if (message.trim().isEmpty) {
        return;
      }
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text(message), behavior: SnackBarBehavior.floating),
      );
    }
  }

  void _handleMapTap(TapPosition _, LatLng point) {
    if (!mounted) return;
    setState(() {
      _selectedPoint = point;
    });
  }

  String _formatLatLng(LatLng point) {
    return '${point.latitude.toStringAsFixed(6)}, ${point.longitude.toStringAsFixed(6)}';
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

class _RiskLegend extends StatelessWidget {
  const _RiskLegend();

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(
        horizontal: AppSpacing.md,
        vertical: AppSpacing.sm,
      ),
      decoration: BoxDecoration(
        gradient: LinearGradient(
          colors: [
            const Color(0xFF183B61).withValues(alpha: 0.84),
            const Color(0xFF102C4B).withValues(alpha: 0.72),
          ],
        ),
        borderRadius: BorderRadius.circular(AppRadius.md),
        border: Border.all(color: Colors.white.withValues(alpha: 0.08)),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withValues(alpha: 0.14),
            blurRadius: 18,
            offset: const Offset(0, 6),
          ),
        ],
      ),
      child: Row(
        children: const [
          _LegendItem(color: Color(0xFF2E7D32), label: AppStrings.lowRisk),
          SizedBox(width: AppSpacing.sm),
          _LegendItem(color: Color(0xFFFF8F00), label: 'Orta'),
          SizedBox(width: AppSpacing.sm),
          _LegendItem(color: Color(0xFFC62828), label: AppStrings.highRisk),
        ],
      ),
    );
  }
}

class _LegendItem extends StatelessWidget {
  const _LegendItem({required this.color, required this.label});

  final Color color;
  final String label;

  @override
  Widget build(BuildContext context) {
    return Expanded(
      child: Row(
        children: [
          Container(
            width: 16,
            height: 16,
            decoration: BoxDecoration(color: color, shape: BoxShape.circle),
          ),
          const SizedBox(width: 6),
          Expanded(
            child: Text(
              label,
              style: AppTextStyles.caption.copyWith(
                color: Colors.white.withValues(alpha: 0.84),
                fontWeight: FontWeight.w700,
                letterSpacing: 0.15,
              ),
            ),
          ),
        ],
      ),
    );
  }
}

enum _RiskSeverity { low, medium, high }

class _LiveMap extends StatelessWidget {
  const _LiveMap({
    required this.reports,
    required this.centerLatitude,
    required this.centerLongitude,
    required this.selectedLocation,
    required this.isLoading,
    required this.onTap,
  });

  final List<NearbyReport> reports;
  final double centerLatitude;
  final double centerLongitude;
  final LatLng selectedLocation;
  final bool isLoading;
  final void Function(TapPosition, LatLng) onTap;

  @override
  Widget build(BuildContext context) {
    final centerPoint = LatLng(centerLatitude, centerLongitude);
    final sortedReports = _sortReportsForDisplay(reports);
    final riskCircles = _buildRiskCircles(sortedReports);

    return Container(
      height: 255,
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(AppRadius.md),
      ),
      clipBehavior: Clip.hardEdge,
      child: Stack(
        children: [
          FlutterMap(
            options: MapOptions(
              initialCenter: centerPoint,
              initialZoom: 15,
              onTap: onTap,
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
              CircleLayer(
                circles: [
                  for (final circle in riskCircles)
                    CircleMarker(
                      point: LatLng(
                        circle.centerLatitude,
                        circle.centerLongitude,
                      ),
                      radius: circle.radiusMeters,
                      useRadiusInMeter: true,
                      color: circle.strokeColor.withValues(alpha: 0.25),
                      borderColor: circle.strokeColor,
                      borderStrokeWidth: 2.0,
                    ),
                ],
              ),
              MarkerLayer(
                markers: [
                  for (final report in reports)
                    Marker(
                      width: 28,
                      height: 28,
                      point: LatLng(report.latitude, report.longitude),
                      child: Tooltip(
                        message:
                            '${_displayCategory(report.category)} - ${report.status.isEmpty ? 'Bildirildi' : report.status}',
                        child: Container(
                          decoration: BoxDecoration(
                            shape: BoxShape.circle,
                            color: const Color(
                              0xFF08111E,
                            ).withValues(alpha: 0.94),
                            border: Border.all(
                              color: _colorForReportCategory(
                                report.category,
                              ).withValues(alpha: 0.18),
                            ),
                            boxShadow: [
                              BoxShadow(
                                color: Colors.black.withValues(alpha: 0.24),
                                blurRadius: 10,
                                spreadRadius: 1,
                              ),
                            ],
                          ),
                          child: Center(
                            child: Icon(
                              _iconForReportCategory(report.category),
                              size: 13,
                              color: _colorForReportCategory(report.category),
                            ),
                          ),
                        ),
                      ),
                    ),
                  if (_isDifferentPoint(selectedLocation, centerPoint))
                    Marker(
                      width: 38,
                      height: 38,
                      point: selectedLocation,
                      child: Tooltip(
                        message: AppStrings.selectedMapLocation,
                        child: Container(
                          decoration: BoxDecoration(
                            shape: BoxShape.circle,
                            color: const Color(0xFF1C7DFF),
                            boxShadow: [
                              BoxShadow(
                                color: const Color(
                                  0xFF1C7DFF,
                                ).withValues(alpha: 0.26),
                                blurRadius: 18,
                                spreadRadius: 2,
                              ),
                            ],
                          ),
                          alignment: Alignment.center,
                          child: const Icon(
                            Icons.push_pin_rounded,
                            color: Colors.white,
                            size: 20,
                          ),
                        ),
                      ),
                    ),
                  Marker(
                    width: 34,
                    height: 34,
                    point: centerPoint,
                    child: Container(
                      decoration: BoxDecoration(
                        color: const Color(0xFF1C7DFF).withValues(alpha: 0.16),
                        shape: BoxShape.circle,
                        border: Border.all(
                          color: const Color(
                            0xFF8FC4FF,
                          ).withValues(alpha: 0.35),
                        ),
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

  static bool _isDifferentPoint(LatLng a, LatLng b) {
    return (a.latitude - b.latitude).abs() > 0.00001 ||
        (a.longitude - b.longitude).abs() > 0.00001;
  }

  List<_RiskCircleVisual> _buildRiskCircles(List<NearbyReport> reports) {
    final circlesById = <String, _RiskCircleVisual>{};

    for (final report in reports) {
      final circleId = report.riskCircleId;
      final radiusMeters = _effectiveRiskRadius(report);
      final nextCircle = _RiskCircleVisual(
        centerLatitude: report.riskCenterLatitude,
        centerLongitude: report.riskCenterLongitude,
        radiusMeters: radiusMeters,
        riskScore: report.riskScore,
        strokeColor: _colorForRiskLevel(report.riskLevel),
      );

      final existingCircle = circlesById[circleId];
      if (existingCircle == null) {
        circlesById[circleId] = nextCircle;
        continue;
      }

      circlesById[circleId] = existingCircle.merge(nextCircle);
    }

    final circles = circlesById.values.toList(growable: false);
    circles.sort((a, b) => b.riskScore.compareTo(a.riskScore));
    return circles;
  }

  static List<NearbyReport> _sortReportsForDisplay(List<NearbyReport> reports) {
    final ordered = List<NearbyReport>.from(reports);
    ordered.sort((a, b) {
      final aIsSecurity = _isSecurityReport(a);
      final bIsSecurity = _isSecurityReport(b);
      if (aIsSecurity != bIsSecurity) {
        return aIsSecurity ? 1 : -1;
      }

      final severityCompare = _severityForReport(
        a,
      ).index.compareTo(_severityForReport(b).index);
      if (severityCompare != 0) {
        return severityCompare;
      }

      return _riskIntensity(a).compareTo(_riskIntensity(b));
    });
    return ordered;
  }

  static bool _isSecurityReport(NearbyReport report) {
    switch (_normalizedCategory(report.category)) {
      case 'suc':
      case 'security':
        return true;
      default:
        return false;
    }
  }

  static String _normalizedCategory(String category) {
    var normalized = category.trim().toLowerCase();
    normalized = normalized
        .replaceAll('ç', 'c')
        .replaceAll('ğ', 'g')
        .replaceAll('ı', 'i')
        .replaceAll('ö', 'o')
        .replaceAll('ş', 's')
        .replaceAll('ü', 'u');
    switch (normalized) {
      case 'aydinlatma':
      case 'saglik':
      case 'health':
      case 'lighting':
        return 'lighting';
      case 'altyapi':
      case 'ariza':
      case 'takip':
      case 'tracking':
      case 'infrastructure':
        return 'infrastructure';
      case 'suc':
      case 'security':
        return 'security';
      case 'hayvan':
      case 'animals':
        return 'animals';
      case 'trafik':
      case 'traffic':
        return 'traffic';
      default:
        return normalized;
    }
  }

  static IconData _iconForReportCategory(String category) {
    switch (_normalizedCategory(category)) {
      case 'traffic':
        return Icons.traffic_rounded;
      case 'lighting':
        return Icons.lightbulb_rounded;
      case 'security':
        return Icons.gpp_bad_rounded;
      case 'animals':
        return Icons.pets_rounded;
      case 'infrastructure':
        return Icons.construction_rounded;
      default:
        return Icons.warning_amber_rounded;
    }
  }

  static Color _colorForReportCategory(String category) {
    switch (_normalizedCategory(category)) {
      case 'traffic':
        return const Color(0xFFFF9800);
      case 'lighting':
        return const Color(0xFFFFD54F);
      case 'infrastructure':
        return const Color(0xFFFF7043);
      case 'security':
        return const Color(0xFFE91E63);
      case 'animals':
        return const Color(0xFF8BC34A);
      default:
        return const Color(0xFFFF5722);
    }
  }

  static Color _colorForRiskLevel(String riskLevel) {
    switch (riskLevel.trim().toUpperCase()) {
      case 'HIGH':
        return const Color(0xFFE53935);
      case 'MEDIUM':
        return const Color(0xFFFFA000);
      case 'LOW':
        return const Color(0xFF43A047);
      default:
        return const Color(0xFFFFA000);
    }
  }

  static _RiskSeverity _severityForReport(NearbyReport report) {
    final normalizedRiskLevel = report.riskLevel.trim().toUpperCase();
    switch (normalizedRiskLevel) {
      case 'HIGH':
        return _RiskSeverity.high;
      case 'MEDIUM':
        return _RiskSeverity.medium;
      case 'LOW':
        return _RiskSeverity.low;
    }

    switch (_normalizedCategory(report.category)) {
      case 'security':
      case 'animals':
        return _RiskSeverity.high;
      case 'traffic':
      case 'lighting':
      case 'infrastructure':
        return _RiskSeverity.medium;
      default:
        return _RiskSeverity.low;
    }
  }

  static double _effectiveRiskRadius(NearbyReport report) {
    final severity = _severityForReport(report);
    final fallbackRadius = switch (severity) {
      _RiskSeverity.high => 400.0,
      _RiskSeverity.medium => 150.0,
      _RiskSeverity.low => 150.0,
    };
    final baseRadius = report.riskRadiusMeters > 0
        ? report.riskRadiusMeters
        : fallbackRadius;
    final createdAt = report.createdAt;
    if (createdAt == null) {
      return baseRadius;
    }
    final ageHours = DateTime.now().difference(createdAt).inMinutes / 60.0;
    final minimumDecay = switch (severity) {
      _RiskSeverity.high => 0.68,
      _RiskSeverity.medium => 0.60,
      _RiskSeverity.low => 0.55,
    };
    final decay = (1 - (ageHours / 24.0)).clamp(minimumDecay, 1.0);
    return baseRadius * decay;
  }

  static double _riskIntensity(NearbyReport report) {
    final severity = _severityForReport(report);
    final baseIntensity = switch (severity) {
      _RiskSeverity.high => 0.90,
      _RiskSeverity.medium => 0.76,
      _RiskSeverity.low => 0.62,
    };
    final createdAt = report.createdAt;
    if (createdAt == null) {
      return baseIntensity;
    }
    final ageHours = DateTime.now().difference(createdAt).inMinutes / 60.0;
    final fadeWindowHours = switch (severity) {
      _RiskSeverity.high => 30.0,
      _RiskSeverity.medium => 22.0,
      _RiskSeverity.low => 18.0,
    };
    final minimumIntensity = switch (severity) {
      _RiskSeverity.high => 0.62,
      _RiskSeverity.medium => 0.50,
      _RiskSeverity.low => 0.42,
    };
    return (baseIntensity - (ageHours / fadeWindowHours)).clamp(
      minimumIntensity,
      1.0,
    );
  }

  static String _displayCategory(String category) {
    switch (_normalizedCategory(category)) {
      case 'trafik':
      case 'traffic':
        return 'Trafik';
      case 'lighting':
        return 'Aydınlatma';
      case 'security':
        return 'Suç';
      case 'hayvan':
      case 'animals':
        return 'Hayvan';
      case 'ariza':
      case 'infrastructure':
        return 'Altyapı';
      default:
        return category;
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
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(icon, size: 17, color: Colors.white),
            const SizedBox(width: 7),
            Flexible(
              child: Text(
                label,
                textAlign: TextAlign.center,
                overflow: TextOverflow.ellipsis,
                style: AppTextStyles.body.copyWith(
                  color: Colors.white,
                  fontWeight: FontWeight.w600,
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class _ReportSheetResult {
  const _ReportSheetResult({required this.submitted});

  final bool submitted;
}

class _ReportSheet extends StatefulWidget {
  const _ReportSheet({
    required this.category,
    required this.formattedLocation,
    required this.onSubmit,
  });

  final String category;
  final String formattedLocation;
  final Future<void> Function(String description) onSubmit;

  @override
  State<_ReportSheet> createState() => _ReportSheetState();
}

class _ReportSheetState extends State<_ReportSheet> {
  late final TextEditingController _noteController;
  bool _isSubmitting = false;

  @override
  void initState() {
    super.initState();
    _noteController = TextEditingController();
  }

  @override
  void dispose() {
    FocusManager.instance.primaryFocus?.unfocus();
    _noteController.dispose();
    super.dispose();
  }

  void _close({required bool submitted}) {
    FocusManager.instance.primaryFocus?.unfocus();
    if (!mounted) {
      return;
    }
    Navigator.of(context).pop(_ReportSheetResult(submitted: submitted));
  }

  Future<void> _submit() async {
    if (_isSubmitting || !mounted) {
      return;
    }

    setState(() {
      _isSubmitting = true;
    });

    try {
      await widget.onSubmit(_noteController.text.trim());
    } catch (error) {
      if (!mounted) {
        return;
      }
      setState(() {
        _isSubmitting = false;
      });
      final message = error is AppStateException
          ? error.message
          : error.toString();
      if (message.trim().isEmpty) {
        return;
      }
      ScaffoldMessenger.of(context)
        ..hideCurrentSnackBar()
        ..showSnackBar(
          SnackBar(
            content: Text('İhbar gönderilemedi: $message'),
            behavior: SnackBarBehavior.floating,
          ),
        );
      return;
    }

    _close(submitted: true);
  }

  @override
  Widget build(BuildContext context) {
    final bottomInset = MediaQuery.of(context).viewInsets.bottom;

    return SafeArea(
      top: false,
      child: AnimatedPadding(
        duration: const Duration(milliseconds: 180),
        curve: Curves.easeOut,
        padding: EdgeInsets.fromLTRB(
          AppSpacing.md,
          AppSpacing.md,
          AppSpacing.md,
          bottomInset + AppSpacing.md,
        ),
        child: SingleChildScrollView(
          child: Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                'İhbar Gönder',
                style: AppTextStyles.title.copyWith(fontSize: 22),
              ),
              const SizedBox(height: AppSpacing.sm),
              Text(
                'Kategori: ${widget.category}',
                style: AppTextStyles.body.copyWith(color: Colors.white70),
              ),
              const SizedBox(height: AppSpacing.xs),
              Text(
                'Konum: ${widget.formattedLocation}',
                style: AppTextStyles.body.copyWith(color: Colors.white70),
              ),
              const SizedBox(height: AppSpacing.md),
              TextField(
                controller: _noteController,
                maxLines: 3,
                minLines: 3,
                enabled: !_isSubmitting,
                keyboardType: TextInputType.text,
                textInputAction: TextInputAction.done,
                autocorrect: true,
                enableSuggestions: true,
                decoration: const InputDecoration(
                  hintText: 'Kısa açıklama (opsiyonel)',
                  fillColor: Color(0xFF1A3D66),
                ),
              ),
              const SizedBox(height: AppSpacing.md),
              Row(
                children: [
                  Expanded(
                    child: OutlinedButton(
                      onPressed: _isSubmitting
                          ? null
                          : () => _close(submitted: false),
                      child: const Text('İptal'),
                    ),
                  ),
                  const SizedBox(width: AppSpacing.sm),
                  Expanded(
                    child: ElevatedButton(
                      onPressed: _isSubmitting ? null : _submit,
                      child: _isSubmitting
                          ? const SizedBox(
                              width: 20,
                              height: 20,
                              child: CircularProgressIndicator(strokeWidth: 2),
                            )
                          : const Text('Gönder'),
                    ),
                  ),
                ],
              ),
            ],
          ),
        ),
      ),
    );
  }
}

class _RiskCircleVisual {
  const _RiskCircleVisual({
    required this.centerLatitude,
    required this.centerLongitude,
    required this.radiusMeters,
    required this.riskScore,
    required this.strokeColor,
  });

  final double centerLatitude;
  final double centerLongitude;
  final double radiusMeters;
  final double riskScore;
  final Color strokeColor;

  _RiskCircleVisual merge(_RiskCircleVisual other) {
    return _RiskCircleVisual(
      centerLatitude: centerLatitude,
      centerLongitude: centerLongitude,
      radiusMeters: radiusMeters > other.radiusMeters
          ? radiusMeters
          : other.radiusMeters,
      riskScore: riskScore > other.riskScore ? riskScore : other.riskScore,
      strokeColor: riskScore >= other.riskScore
          ? strokeColor
          : other.strokeColor,
    );
  }
}
