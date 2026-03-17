import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';

import '../theme/design_system.dart';

class RulesScreen extends StatelessWidget {
  const RulesScreen({super.key});

  static const _rules = [
    (
      title: 'Doğru ve gerekli bildirim gönderin',
      description:
          'Gereksiz meşguliyet oluşturan veya asılsız ihbarların tekrarı durumunda hesap geçici olarak kısıtlanabilir.',
    ),
    (
      title: 'Sahte ihbarlar yaptırıma tabidir',
      description:
          'Aynı gün içinde üç kez sahte ihbar tespit edilmesi halinde sistem tarafından geçici ban uygulanabilir.',
    ),
    (
      title: 'Topluluk diline özen gösterin',
      description:
          'Tehdit, hakaret ve kötü niyetli içerikler otomatik olarak filtrelenir ve moderasyona gönderilir.',
    ),
    (
      title: 'Veriler güvenlik amacıyla kullanılır',
      description:
          'Konum ve izin bilgileri yalnızca güvenlik süreçleri için kullanılır, üçüncü taraflarla paylaşılmaz.',
    ),
    (
      title: 'Spam bildirim puanınızı etkiler',
      description:
          'Acil durum dışı tekrar eden spam bildirimler, topluluk güvenliği puanınızın düşmesine neden olabilir.',
    ),
  ];

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
                          const _IntroCard(),
                          const SizedBox(height: AppSpacing.md),
                          ...List.generate(
                            _rules.length,
                            (index) => Padding(
                              padding: const EdgeInsets.only(
                                bottom: AppSpacing.md,
                              ),
                              child: _RuleCard(
                                index: index + 1,
                                title: _rules[index].title,
                                description: _rules[index].description,
                              ),
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
        border: Border.all(color: Colors.white.withValues(alpha: 0.08)),
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
              'Ayarlar / Kurallar',
              textAlign: TextAlign.center,
              style: GoogleFonts.spaceGrotesk(
                color: Colors.white,
                fontSize: 20,
                fontWeight: FontWeight.w700,
              ),
            ),
          ),
          const SizedBox(width: 42),
        ],
      ),
    );
  }
}

class _IntroCard extends StatelessWidget {
  const _IntroCard();

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(AppSpacing.lg),
      decoration: BoxDecoration(
        gradient: const LinearGradient(
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
          colors: [Color(0xFF133A52), Color(0xFF3B8B72)],
        ),
        borderRadius: BorderRadius.circular(AppRadius.lg),
        boxShadow: AppShadows.soft,
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Container(
            padding: const EdgeInsets.symmetric(
              horizontal: AppSpacing.sm,
              vertical: AppSpacing.xs,
            ),
            decoration: BoxDecoration(
              color: Colors.white.withValues(alpha: 0.14),
              borderRadius: BorderRadius.circular(AppRadius.lg),
            ),
            child: Text(
              'Topluluk Güvenliği',
              style: AppTextStyles.caption.copyWith(
                color: Colors.white,
                fontWeight: FontWeight.w700,
              ),
            ),
          ),
          const SizedBox(height: AppSpacing.md),
          Text(
            'Kurallar',
            style: GoogleFonts.spaceGrotesk(
              color: Colors.white,
              fontSize: 32,
              fontWeight: FontWeight.w700,
              letterSpacing: -0.4,
            ),
          ),
          const SizedBox(height: AppSpacing.xs),
          Text(
            'Bu ilkeler, uygulamanın herkes için güvenli, hızlı ve faydalı kalmasına yardımcı olur.',
            style: AppTextStyles.body.copyWith(
              color: AppColors.textSecondary.withValues(alpha: 0.96),
              fontSize: 14,
              height: 1.45,
            ),
          ),
        ],
      ),
    );
  }
}

class _RuleCard extends StatelessWidget {
  const _RuleCard({
    required this.index,
    required this.title,
    required this.description,
  });

  final int index;
  final String title;
  final String description;

  @override
  Widget build(BuildContext context) {
    return Material(
      color: Colors.transparent,
      child: InkWell(
        onTap: () {},
        borderRadius: BorderRadius.circular(AppRadius.md),
        splashColor: AppColors.aquaGlow.withValues(alpha: 0.08),
        highlightColor: AppColors.aquaGlow.withValues(alpha: 0.04),
        child: Container(
          padding: const EdgeInsets.all(AppSpacing.md),
          decoration: BoxDecoration(
            color: AppColors.card.withValues(alpha: 0.88),
            borderRadius: BorderRadius.circular(AppRadius.md),
            border: Border.all(color: Colors.white.withValues(alpha: 0.08)),
          ),
          child: Row(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Container(
                width: 42,
                height: 42,
                alignment: Alignment.center,
                decoration: BoxDecoration(
                  shape: BoxShape.circle,
                  gradient: LinearGradient(
                    begin: Alignment.topLeft,
                    end: Alignment.bottomRight,
                    colors: [
                      AppColors.aquaGlow.withValues(alpha: 0.95),
                      AppColors.oceanTeal.withValues(alpha: 0.92),
                    ],
                  ),
                  boxShadow: [
                    BoxShadow(
                      color: AppColors.aquaGlow.withValues(alpha: 0.18),
                      blurRadius: 14,
                      offset: const Offset(0, 6),
                    ),
                  ],
                ),
                child: Text(
                  '$index',
                  style: GoogleFonts.spaceGrotesk(
                    color: AppColors.deepNavy,
                    fontWeight: FontWeight.w700,
                    fontSize: 17,
                  ),
                ),
              ),
              const SizedBox(width: AppSpacing.md),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      title,
                      style: AppTextStyles.title.copyWith(fontSize: 16),
                    ),
                    const SizedBox(height: 6),
                    Text(
                      description,
                      style: AppTextStyles.body.copyWith(
                        color: Colors.white.withValues(alpha: 0.84),
                        fontSize: 14,
                        height: 1.5,
                      ),
                    ),
                  ],
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
