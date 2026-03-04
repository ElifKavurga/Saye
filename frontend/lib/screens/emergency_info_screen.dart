import 'package:flutter/material.dart';

import '../state/app_state.dart';
import '../theme/design_system.dart';

class EmergencyInfoScreen extends StatefulWidget {
  const EmergencyInfoScreen({super.key, required this.appState});

  final AppState appState;

  @override
  State<EmergencyInfoScreen> createState() => _EmergencyInfoScreenState();
}

class _EmergencyInfoScreenState extends State<EmergencyInfoScreen> {
  late final TextEditingController _bloodTypeController;
  late final TextEditingController _allergyController;
  late final TextEditingController _emergencyNoteController;

  @override
  void initState() {
    super.initState();
    final info = widget.appState.emergencyHealthInfo;
    _bloodTypeController = TextEditingController(text: info.bloodType);
    _allergyController = TextEditingController(text: info.allergyNotes);
    _emergencyNoteController = TextEditingController(text: info.emergencyNote);
  }

  @override
  void dispose() {
    _bloodTypeController.dispose();
    _allergyController.dispose();
    _emergencyNoteController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Container(
        decoration: const BoxDecoration(gradient: AppGradients.mainBackground),
        child: SafeArea(
          child: LayoutBuilder(
            builder: (context, constraints) {
              return SingleChildScrollView(
                padding: const EdgeInsets.fromLTRB(
                  AppSpacing.md,
                  AppSpacing.md,
                  AppSpacing.md,
                  AppSpacing.lg,
                ),
                child: ConstrainedBox(
                  constraints: BoxConstraints(minHeight: constraints.maxHeight),
                  child: Center(
                    child: ConstrainedBox(
                      constraints: const BoxConstraints(maxWidth: 520),
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.stretch,
                        children: [
                          _TopHeader(onBack: () => Navigator.of(context).pop()),
                          const SizedBox(height: AppSpacing.lg),
                          Container(
                            padding: const EdgeInsets.all(AppSpacing.md),
                            decoration: BoxDecoration(
                              gradient: const LinearGradient(
                                begin: Alignment.topLeft,
                                end: Alignment.bottomRight,
                                colors: [Color(0xFF8EA599), Color(0xFF467447)],
                              ),
                              borderRadius: BorderRadius.circular(AppRadius.md),
                              boxShadow: AppShadows.soft,
                            ),
                            child: Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                Text(
                                  'ACIL DURUM Bilgileri',
                                  style: AppTextStyles.title.copyWith(
                                    fontSize: 32,
                                  ),
                                ),
                                const SizedBox(height: AppSpacing.xs),
                                Text(
                                  'Acil durumlarda sana yardimci olmamiz icin lutfen bilgilerini doldur.',
                                  style: AppTextStyles.body.copyWith(
                                    color: Colors.white.withValues(alpha: 0.9),
                                    fontSize: 21,
                                    height: 1.35,
                                  ),
                                ),
                                const SizedBox(height: AppSpacing.md),
                                _LabeledField(
                                  label: 'Kan grubu (opsiyonel)',
                                  controller: _bloodTypeController,
                                ),
                                const SizedBox(height: AppSpacing.sm),
                                _LabeledField(
                                  label: 'Alerji / Notlar (opsiyonel)',
                                  controller: _allergyController,
                                  maxLines: 2,
                                ),
                                const SizedBox(height: AppSpacing.sm),
                                _LabeledField(
                                  label: 'Acil not',
                                  controller: _emergencyNoteController,
                                  maxLines: 3,
                                ),
                                const SizedBox(height: AppSpacing.md),
                                SizedBox(
                                  width: double.infinity,
                                  child: ElevatedButton(
                                    onPressed: () {
                                      widget.appState.saveEmergencyHealthInfo(
                                        bloodType: _bloodTypeController.text,
                                        allergyNotes: _allergyController.text,
                                        emergencyNote:
                                            _emergencyNoteController.text,
                                      );
                                      ScaffoldMessenger.of(
                                        context,
                                      ).showSnackBar(
                                        const SnackBar(
                                          content: Text('Bilgiler kaydedildi'),
                                        ),
                                      );
                                    },
                                    style: ElevatedButton.styleFrom(
                                      backgroundColor: const Color(0xFF214E86),
                                      foregroundColor: Colors.white,
                                    ),
                                    child: const Text('Kaydet'),
                                  ),
                                ),
                              ],
                            ),
                          ),
                        ],
                      ),
                    ),
                  ),
                ),
              );
            },
          ),
        ),
      ),
    );
  }
}

class _TopHeader extends StatelessWidget {
  const _TopHeader({required this.onBack});

  final VoidCallback onBack;

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(
        horizontal: AppSpacing.md,
        vertical: AppSpacing.sm,
      ),
      decoration: BoxDecoration(
        color: const Color(0xFF284872).withValues(alpha: 0.9),
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
            child: Text(
              'AYARLAR / GENEL',
              textAlign: TextAlign.center,
              style: AppTextStyles.title.copyWith(fontSize: 30),
            ),
          ),
          const SizedBox(width: 42),
        ],
      ),
    );
  }
}

class _LabeledField extends StatelessWidget {
  const _LabeledField({
    required this.label,
    required this.controller,
    this.maxLines = 1,
  });

  final String label;
  final TextEditingController controller;
  final int maxLines;

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          label,
          style: AppTextStyles.body.copyWith(
            color: Colors.white,
            fontWeight: FontWeight.w700,
            fontSize: 18,
          ),
        ),
        const SizedBox(height: 6),
        TextField(
          controller: controller,
          maxLines: maxLines,
          style: AppTextStyles.body.copyWith(color: const Color(0xFF2A3640)),
          decoration: InputDecoration(
            fillColor: Colors.white,
            filled: true,
            hintText: 'Yaziniz...',
            hintStyle: AppTextStyles.caption.copyWith(
              color: const Color(0xFF5B6672),
            ),
            border: OutlineInputBorder(
              borderRadius: BorderRadius.circular(AppRadius.md),
              borderSide: BorderSide.none,
            ),
          ),
        ),
      ],
    );
  }
}
