import 'package:flutter/material.dart';

import '../state/app_state.dart';
import '../theme/design_system.dart';

enum RouteChoice { safe, risky }

class EmergencyActiveScreen extends StatefulWidget {
  const EmergencyActiveScreen({super.key, required this.appState});

  final AppState appState;

  @override
  State<EmergencyActiveScreen> createState() => _EmergencyActiveScreenState();
}

class _EmergencyActiveScreenState extends State<EmergencyActiveScreen> {
  RouteChoice _selectedChoice = RouteChoice.safe;

  @override
  Widget build(BuildContext context) {
    return SafeArea(
      child: SingleChildScrollView(
        padding: const EdgeInsets.fromLTRB(AppSpacing.md, AppSpacing.md, AppSpacing.md, 120),
        child: Center(
          child: ConstrainedBox(
            constraints: const BoxConstraints(maxWidth: 520),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.stretch,
              children: [
                _InfoCard(
                  title: 'ACIL DURUM AKTIF',
                  titleColor: const Color(0xFFFF444D),
                  text: 'Sana en yakin guvenli bolge rotasi olusturuluyor...',
                ),
                const SizedBox(height: AppSpacing.sm),
                _InfoCard(
                  text: _sharedWithText(),
                  trailing: const Icon(Icons.check_box_rounded, color: Color(0xFF8CF0A6)),
                ),
                const SizedBox(height: AppSpacing.md),
                _ChoiceCard(
                  text: 'Guvenli Rotayi Sec',
                  selected: _selectedChoice == RouteChoice.safe,
                  onTap: () => _selectRoute(RouteChoice.safe),
                ),
                const SizedBox(height: AppSpacing.sm),
                _ChoiceCard(
                  text: 'Daha Kisa ama Riskli Rotayi Sec',
                  selected: _selectedChoice == RouteChoice.risky,
                  onTap: () => _selectRoute(RouteChoice.risky),
                ),
                const SizedBox(height: AppSpacing.lg),
                ElevatedButton(
                  onPressed: widget.appState.deactivateEmergency,
                  style: ElevatedButton.styleFrom(
                    backgroundColor: const Color(0xFF15335A),
                    foregroundColor: Colors.white,
                  ),
                  child: const Text('Durumu Kapat'),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }

  void _selectRoute(RouteChoice choice) {
    setState(() {
      _selectedChoice = choice;
    });

    final message = choice == RouteChoice.safe
        ? 'Guvenli rota secildi.'
        : 'Daha kisa ama riskli rota secildi.';

    // TODO: Backend entegrasyonunda burada gercek rota motoru ve acil mesajlasma tetiklenecek.
    ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text(message)));
  }

  String _sharedWithText() {
    final contacts = List.of(widget.appState.emergencyContacts)
      ..sort((a, b) {
        if (a.isPrimary == b.isPrimary) {
          return 0;
        }
        return a.isPrimary ? -1 : 1;
      });
    if (contacts.isEmpty) {
      return 'Acil durum kisileri tanimli degil. Kisi yonetiminden ekleyebilirsin.';
    }

    final names = contacts.map((item) => item.name).take(3).join(', ');
    final hasMore = contacts.length > 3;
    final suffix = hasMore ? ' ve diger kisiler' : '';
    return 'Acil durum kisileri ile bilgilerin paylasildi: $names$suffix.';
  }
}

class _InfoCard extends StatelessWidget {
  const _InfoCard({
    required this.text,
    this.title,
    this.titleColor,
    this.trailing,
  });

  final String text;
  final String? title;
  final Color? titleColor;
  final Widget? trailing;

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: AppSpacing.md, vertical: AppSpacing.md),
      decoration: BoxDecoration(
        color: const Color(0xFF284C79).withValues(alpha: 0.92),
        borderRadius: BorderRadius.circular(AppRadius.md),
        border: Border.all(color: Colors.white24),
      ),
      child: Row(
        children: [
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                if (title != null) ...[
                  Text(
                    title!,
                    style: AppTextStyles.title.copyWith(
                      color: titleColor ?? Colors.white,
                      fontSize: 20,
                      fontWeight: FontWeight.w800,
                    ),
                  ),
                  const SizedBox(height: 4),
                ],
                Text(
                  text,
                  style: AppTextStyles.body.copyWith(
                    color: Colors.white.withValues(alpha: 0.95),
                    fontSize: 18,
                  ),
                ),
              ],
            ),
          ),
          if (trailing != null) ...[
            const SizedBox(width: AppSpacing.sm),
            trailing!,
          ],
        ],
      ),
    );
  }
}

class _ChoiceCard extends StatelessWidget {
  const _ChoiceCard({
    required this.text,
    required this.selected,
    required this.onTap,
  });

  final String text;
  final bool selected;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    return InkWell(
      onTap: onTap,
      borderRadius: BorderRadius.circular(AppRadius.md),
      child: Container(
        padding: const EdgeInsets.all(AppSpacing.md),
        decoration: BoxDecoration(
          color: selected ? const Color(0xFF2F5B93) : const Color(0xFF19395F),
          borderRadius: BorderRadius.circular(AppRadius.md),
          border: Border.all(
            color: selected ? const Color(0xFF8FBFFF) : Colors.white24,
            width: selected ? 2 : 1,
          ),
        ),
        child: Row(
          children: [
            Expanded(
              child: Text(
                text,
                style: AppTextStyles.body.copyWith(
                  color: Colors.white,
                  fontSize: 18,
                  fontWeight: FontWeight.w700,
                ),
              ),
            ),
            Icon(
              selected ? Icons.radio_button_checked : Icons.radio_button_off,
              color: Colors.white,
            ),
          ],
        ),
      ),
    );
  }
}
