import 'package:flutter/material.dart';

import '../config/app_defaults.dart';
import '../state/app_state.dart';
import '../theme/design_system.dart';

class ProfileScreen extends StatefulWidget {
  const ProfileScreen({super.key, required this.appState});

  final AppState appState;

  @override
  State<ProfileScreen> createState() => _ProfileScreenState();
}

class _ProfileScreenState extends State<ProfileScreen> {
  Future<void> _openEmergencyHealthEditor() async {
    await Navigator.of(context).push(
      MaterialPageRoute<void>(
        builder: (context) => EmergencyHealthEditScreen(
          appState: widget.appState,
        ),
      ),
    );
    if (mounted) {
      setState(() {});
    }
  }

  @override
  Widget build(BuildContext context) {
    final appState = widget.appState;
    return AnimatedBuilder(
      animation: appState,
      builder: (context, _) {
        final user = appState.currentUser;
        final displayName = (user?.username.isNotEmpty ?? false)
            ? user!.username
            : AppDefaults.fallbackProfileName;
        final displayEmail = (user?.email.isNotEmpty ?? false)
            ? user!.email
            : AppDefaults.fallbackProfileEmail;
        final displayPhone =
            (user?.phone.isNotEmpty ?? false) ? user!.phone : '-';

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
                    _HeaderCard(
                      displayName: displayName,
                      displayEmail: displayEmail,
                      displayPhone: displayPhone,
                    ),
                    const SizedBox(height: AppSpacing.md),
                    _QuickStatsCard(reportCount: appState.localReports.length),
                    const SizedBox(height: AppSpacing.md),
                    _HealthInfoCard(
                      info: appState.emergencyHealthInfo,
                      onTap: _openEmergencyHealthEditor,
                    ),
                    const SizedBox(height: AppSpacing.md),
                    _SectionTitle('Bildirim Geçmişim'),
                    const SizedBox(height: AppSpacing.sm),
                    if (appState.localReports.isEmpty)
                      const _EmptyReportCard()
                    else
                      ...appState.localReports.map(
                        (report) => Padding(
                          padding: const EdgeInsets.only(bottom: AppSpacing.sm),
                          child: _ReportCard(report: report),
                        ),
                      ),
                    const SizedBox(height: AppSpacing.lg),
                    SizedBox(
                      width: double.infinity,
                      child: ElevatedButton(
                        onPressed: () {
                          appState.logout();
                        },
                        style: ElevatedButton.styleFrom(
                          backgroundColor: const Color(0xFF8B1F33),
                          foregroundColor: Colors.white,
                        ),
                        child: const Text('Çıkış Yap'),
                      ),
                    ),
                  ],
                ),
              ),
            ),
          ),
        );
      },
    );
  }
}

class _HealthInfoCard extends StatelessWidget {
  const _HealthInfoCard({
    required this.info,
    required this.onTap,
  });

  final EmergencyHealthInfo info;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    final hasInfo = info.hasContent;

    return Material(
      color: Colors.transparent,
      child: InkWell(
        borderRadius: BorderRadius.circular(AppRadius.md),
        onTap: onTap,
        child: Container(
          padding: const EdgeInsets.all(AppSpacing.md),
          decoration: BoxDecoration(
            color: const Color(0xFF10294A).withValues(alpha: 0.94),
            borderRadius: BorderRadius.circular(AppRadius.md),
            border: Border.all(color: Colors.white10),
            boxShadow: AppShadows.soft,
          ),
          child: Row(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Container(
                width: 48,
                height: 48,
                decoration: BoxDecoration(
                  color: AppColors.aquaGlow.withValues(alpha: 0.14),
                  borderRadius: BorderRadius.circular(AppRadius.md),
                ),
                child: const Icon(
                  Icons.medical_services_rounded,
                  color: AppColors.aquaGlow,
                ),
              ),
              const SizedBox(width: AppSpacing.md),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      'Acil Sağlık Bilgileri',
                      style: AppTextStyles.title.copyWith(
                        fontSize: 20,
                        fontWeight: FontWeight.w700,
                      ),
                    ),
                    const SizedBox(height: AppSpacing.sm),
                    if (hasInfo) ...[
                      _HealthInfoLine(label: 'Kan Grubu', value: info.bloodType),
                      const SizedBox(height: 6),
                      _HealthInfoLine(
                        label: 'Alerjiler',
                        value: info.allergyNotes,
                      ),
                      const SizedBox(height: 6),
                      _HealthInfoLine(
                        label: 'Acil Not',
                        value: info.emergencyNote,
                      ),
                    ] else
                      Text(
                        'Bilgi eklenmemis',
                        style: AppTextStyles.body.copyWith(
                          color: Colors.white70,
                        ),
                      ),
                  ],
                ),
              ),
              const SizedBox(width: AppSpacing.sm),
              TextButton(
                onPressed: onTap,
                child: Text(hasInfo ? 'Düzenle' : 'Ekle'),
              ),
            ],
          ),
        ),
      ),
    );
  }
}

class _HealthInfoLine extends StatelessWidget {
  const _HealthInfoLine({required this.label, required this.value});

  final String label;
  final String value;

  @override
  Widget build(BuildContext context) {
    final displayValue = value.trim().isEmpty ? '-' : value.trim();

    return RichText(
      text: TextSpan(
        text: '$label: ',
        style: AppTextStyles.body.copyWith(
          color: Colors.white,
          fontWeight: FontWeight.w700,
        ),
        children: [
          TextSpan(
            text: displayValue,
            style: AppTextStyles.body.copyWith(
              color: Colors.white70,
              fontWeight: FontWeight.w500,
            ),
          ),
        ],
      ),
    );
  }
}

class EmergencyHealthEditScreen extends StatefulWidget {
  const EmergencyHealthEditScreen({super.key, required this.appState});

  final AppState appState;

  @override
  State<EmergencyHealthEditScreen> createState() =>
      _EmergencyHealthEditScreenState();
}

class _EmergencyHealthEditScreenState extends State<EmergencyHealthEditScreen> {
  final _formKey = GlobalKey<FormState>();
  late final TextEditingController _bloodTypeController;
  late final TextEditingController _allergiesController;
  late final TextEditingController _emergencyNoteController;
  bool _isSaving = false;

  @override
  void initState() {
    super.initState();
    final info = widget.appState.emergencyHealthInfo;
    _bloodTypeController = TextEditingController(text: info.bloodType);
    _allergiesController = TextEditingController(text: info.allergyNotes);
    _emergencyNoteController = TextEditingController(text: info.emergencyNote);
  }

  @override
  void dispose() {
    _bloodTypeController.dispose();
    _allergiesController.dispose();
    _emergencyNoteController.dispose();
    super.dispose();
  }

  Future<void> _save() async {
    final bloodType = _bloodTypeController.text.trim();
    final allergies = _allergiesController.text.trim();
    final emergencyNote = _emergencyNoteController.text.trim();

    if (bloodType.isEmpty && allergies.isEmpty && emergencyNote.isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text(
            'Acil sağlık bilgisi girmek için en az bir alan doldurmalısınız',
          ),
        ),
      );
      return;
    }

    if (!(_formKey.currentState?.validate() ?? false)) {
      return;
    }

    setState(() {
      _isSaving = true;
    });

    try {
      await widget.appState.saveEmergencyHealthInfo(
        bloodType: bloodType,
        allergyNotes: allergies,
        emergencyNote: emergencyNote,
      );
      if (!mounted) {
        return;
      }
      Navigator.of(context).pop();
    } catch (_) {
      if (!mounted) {
        return;
      }
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('Acil sağlık bilgileri kaydedilemedi.'),
        ),
      );
      setState(() {
        _isSaving = false;
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.deepNavy,
      appBar: AppBar(
        title: const Text('Acil Sağlık Bilgileri'),
      ),
      body: DecoratedBox(
        decoration: const BoxDecoration(gradient: AppGradients.mainBackground),
        child: SizedBox.expand(
          child: SafeArea(
            child: SingleChildScrollView(
              padding: const EdgeInsets.all(AppSpacing.md),
              child: Center(
                child: ConstrainedBox(
                  constraints: const BoxConstraints(maxWidth: 520),
                  child: Container(
                    padding: const EdgeInsets.all(AppSpacing.md),
                    decoration: BoxDecoration(
                      color: AppColors.card,
                      borderRadius: BorderRadius.circular(AppRadius.lg),
                      border: Border.all(color: Colors.white10),
                      boxShadow: AppShadows.soft,
                    ),
                    child: Form(
                      key: _formKey,
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.stretch,
                        children: [
                          Text(
                            'Sağlık ekiplerinin ihtiyaç duyabileceği temel bilgileri ekleyin.',
                            style: AppTextStyles.body.copyWith(
                              color: Colors.white70,
                            ),
                          ),
                          const SizedBox(height: AppSpacing.md),
                          _EmergencyHealthFormField(
                            controller: _bloodTypeController,
                            label: 'Kan Grubu',
                            hintText: 'Orn. A Rh+',
                            textInputAction: TextInputAction.next,
                          ),
                          const SizedBox(height: AppSpacing.sm),
                          _EmergencyHealthFormField(
                            controller: _allergiesController,
                            label: 'Alerjiler',
                            hintText: 'Varsa belirtin',
                            textInputAction: TextInputAction.next,
                          ),
                          const SizedBox(height: AppSpacing.sm),
                          _EmergencyHealthFormField(
                            controller: _emergencyNoteController,
                            label: 'Acil Sağlık Notu',
                            hintText: 'Önemli bir sağlık bilgisi ekleyin',
                            maxLines: 4,
                            textInputAction: TextInputAction.done,
                          ),
                          const SizedBox(height: AppSpacing.md),
                          SizedBox(
                            width: double.infinity,
                            child: ElevatedButton(
                              onPressed: _isSaving ? null : _save,
                              child: Text(
                                _isSaving ? 'Kaydediliyor...' : 'Kaydet',
                              ),
                            ),
                          ),
                        ],
                      ),
                    ),
                  ),
                ),
              ),
            ),
          ),
        ),
      ),
    );
  }
}

class _EmergencyHealthFormField extends StatelessWidget {
  const _EmergencyHealthFormField({
    required this.controller,
    required this.label,
    required this.hintText,
    required this.textInputAction,
    this.maxLines = 1,
  });

  final TextEditingController controller;
  final String label;
  final String hintText;
  final TextInputAction textInputAction;
  final int maxLines;

  @override
  Widget build(BuildContext context) {
    return TextFormField(
      controller: controller,
      maxLines: maxLines,
      keyboardType: TextInputType.text,
      textInputAction: textInputAction,
      autocorrect: true,
      enableSuggestions: true,
      style: AppTextStyles.body,
      decoration: InputDecoration(
        labelText: label,
        hintText: hintText,
        labelStyle: AppTextStyles.caption.copyWith(color: Colors.white70),
        hintStyle: AppTextStyles.caption.copyWith(color: Colors.white38),
        filled: true,
        fillColor: AppColors.cardMuted,
        border: OutlineInputBorder(
          borderRadius: BorderRadius.circular(AppRadius.md),
          borderSide: BorderSide.none,
        ),
        focusedBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(AppRadius.md),
          borderSide: const BorderSide(color: AppColors.aquaGlow),
        ),
      ),
    );
  }
}

class _HeaderCard extends StatelessWidget {
  const _HeaderCard({
    required this.displayName,
    required this.displayEmail,
    required this.displayPhone,
  });

  final String displayName;
  final String displayEmail;
  final String displayPhone;

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(AppSpacing.md),
      decoration: BoxDecoration(
        gradient: const LinearGradient(
          colors: [Color(0xFF2D4E7B), Color(0xFF14355F)],
        ),
        borderRadius: BorderRadius.circular(AppRadius.lg),
        boxShadow: AppShadows.soft,
      ),
      child: Row(
        children: [
          Container(
            width: 64,
            height: 64,
            decoration: BoxDecoration(
              shape: BoxShape.circle,
              color: AppColors.aquaGlow.withValues(alpha: 0.2),
              border: Border.all(color: Colors.white24),
            ),
            child: const Icon(
              Icons.person_rounded,
              color: AppColors.aquaGlow,
              size: 36,
            ),
          ),
          const SizedBox(width: AppSpacing.md),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  displayName,
                  style: AppTextStyles.title.copyWith(
                    fontSize: 22,
                    fontWeight: FontWeight.w700,
                  ),
                ),
                const SizedBox(height: 4),
                Text(
                  displayEmail,
                  style: AppTextStyles.caption.copyWith(color: Colors.white70),
                ),
                const SizedBox(height: 3),
                Text(
                  'Telefon: $displayPhone',
                  style: AppTextStyles.body.copyWith(fontSize: 13),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}

class _QuickStatsCard extends StatelessWidget {
  const _QuickStatsCard({required this.reportCount});

  final int reportCount;

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(AppSpacing.md),
      decoration: BoxDecoration(
        color: const Color(0xFF10294A).withValues(alpha: 0.92),
        borderRadius: BorderRadius.circular(AppRadius.md),
        border: Border.all(color: Colors.white10),
      ),
      child: Row(
        children: [
          _StatChip(
            icon: Icons.campaign_rounded,
            value: '$reportCount',
            label: 'İhbar',
          ),
          const SizedBox(width: AppSpacing.sm),
          const _StatChip(
            icon: Icons.verified_rounded,
            value: 'Aktif',
            label: 'Profil',
          ),
          const SizedBox(width: AppSpacing.sm),
          const _StatChip(
            icon: Icons.shield_rounded,
            value: 'Acil',
            label: 'Hazır',
          ),
        ],
      ),
    );
  }
}

class _StatChip extends StatelessWidget {
  const _StatChip({
    required this.icon,
    required this.value,
    required this.label,
  });

  final IconData icon;
  final String value;
  final String label;

  @override
  Widget build(BuildContext context) {
    return Expanded(
      child: Container(
        padding: const EdgeInsets.symmetric(vertical: AppSpacing.sm),
        decoration: BoxDecoration(
          color: const Color(0xFF1D3E67),
          borderRadius: BorderRadius.circular(AppRadius.md),
        ),
        child: Column(
          children: [
            Icon(icon, size: 18, color: const Color(0xFFAFF2C9)),
            const SizedBox(height: 3),
            Text(value, style: AppTextStyles.title.copyWith(fontSize: 15)),
            Text(label, style: AppTextStyles.caption.copyWith(fontSize: 11)),
          ],
        ),
      ),
    );
  }
}

class _SectionTitle extends StatelessWidget {
  const _SectionTitle(this.text);

  final String text;

  @override
  Widget build(BuildContext context) {
    return Text(
      text,
      style: AppTextStyles.title.copyWith(
        fontSize: 22,
        fontWeight: FontWeight.w700,
      ),
    );
  }
}

class _EmptyReportCard extends StatelessWidget {
  const _EmptyReportCard();

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(AppSpacing.md),
      decoration: BoxDecoration(
        color: const Color(0xFF163157).withValues(alpha: 0.9),
        borderRadius: BorderRadius.circular(AppRadius.md),
      ),
      child: Text(
        'Henüz gönderdiğin bir bildirim yok. Harita ekranından ilk ihbarı oluşturabilirsin.',
        style: AppTextStyles.body.copyWith(color: Colors.white70),
      ),
    );
  }
}

class _ReportCard extends StatelessWidget {
  const _ReportCard({required this.report});

  final LocalReportNotification report;

  @override
  Widget build(BuildContext context) {
    final hh = report.createdAt.hour.toString().padLeft(2, '0');
    final mm = report.createdAt.minute.toString().padLeft(2, '0');

    return Container(
      padding: const EdgeInsets.all(AppSpacing.md),
      decoration: BoxDecoration(
        color: const Color(0xFF122C4E).withValues(alpha: 0.95),
        borderRadius: BorderRadius.circular(AppRadius.md),
        border: Border.all(color: Colors.white10),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Text(report.category, style: AppTextStyles.title),
              const Spacer(),
              Text('$hh:$mm', style: AppTextStyles.caption),
            ],
          ),
          const SizedBox(height: 4),
          Text(
            '${report.locationLabel} (${report.latLng})',
            style: AppTextStyles.caption.copyWith(color: Colors.white70),
          ),
          if (report.description.isNotEmpty) ...[
            const SizedBox(height: 6),
            Text(report.description, style: AppTextStyles.body),
          ],
        ],
      ),
    );
  }
}
