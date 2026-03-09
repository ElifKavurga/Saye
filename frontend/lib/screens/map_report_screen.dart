import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';

import '../data/mock_data.dart';
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
                        widget.appState.currentLocationLabel,
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
                _MapPlaceholder(onTap: () {}),
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
                  children: MockData.reportCategories
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
                'Konum: ${widget.appState.currentLocationLabel} (${widget.appState.currentLatLng})',
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
                    widget.appState.addLocalReport(
                      category: _selectedCategory!,
                      locationLabel: widget.appState.currentLocationLabel,
                      latLng: widget.appState.currentLatLng,
                      description: noteController.text.trim(),
                    );

                    Navigator.of(context).pop();
                    if (!mounted) {
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

class _MapPlaceholder extends StatelessWidget {
  const _MapPlaceholder({required this.onTap});

  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    return InkWell(
      onTap: onTap,
      borderRadius: BorderRadius.circular(AppRadius.md),
      child: Container(
        height: 255,
        decoration: BoxDecoration(
          borderRadius: BorderRadius.circular(AppRadius.md),
          gradient: const LinearGradient(
            begin: Alignment.topCenter,
            end: Alignment.bottomCenter,
            colors: [Color(0xFFF0F0F0), Color(0xFFDDDDDD)],
          ),
        ),
        child: Stack(
          children: [
            Positioned.fill(child: CustomPaint(painter: _MapGridPainter())),
            const Positioned(
              left: 86,
              top: 78,
              child: Icon(
                Icons.location_on_rounded,
                color: Color(0xFFE43174),
                size: 40,
              ),
            ),
            const Positioned(
              right: 30,
              top: 84,
              child: Icon(
                Icons.do_not_disturb_on_rounded,
                color: Color(0xFFD43E3E),
                size: 24,
              ),
            ),
            const Positioned(
              left: 140,
              top: 146,
              child: Icon(Icons.circle, color: Color(0xFF1C7DFF), size: 12),
            ),
          ],
        ),
      ),
    );
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

class _MapGridPainter extends CustomPainter {
  @override
  void paint(Canvas canvas, Size size) {
    final roadPaint = Paint()
      ..color = const Color(0xFFB0B0B0)
      ..strokeWidth = 2;

    final minorPaint = Paint()
      ..color = const Color(0xFFC9C9C9)
      ..strokeWidth = 1;

    for (double y = 18; y < size.height; y += 24) {
      canvas.drawLine(Offset(0, y), Offset(size.width, y), minorPaint);
    }
    for (double x = 20; x < size.width; x += 28) {
      canvas.drawLine(Offset(x, 0), Offset(x, size.height), minorPaint);
    }

    canvas.drawLine(
      Offset(0, size.height * 0.22),
      Offset(size.width * 0.82, size.height * 0.12),
      roadPaint,
    );
    canvas.drawLine(
      Offset(size.width * 0.08, size.height),
      Offset(size.width * 0.48, size.height * 0.18),
      roadPaint,
    );
    canvas.drawLine(
      Offset(size.width * 0.62, size.height),
      Offset(size.width, size.height * 0.44),
      roadPaint,
    );
  }

  @override
  bool shouldRepaint(covariant CustomPainter oldDelegate) => false;
}
