import 'package:flutter/material.dart';

import '../state/app_state.dart';
import '../theme/design_system.dart';

class SafeContactsScreen extends StatelessWidget {
  const SafeContactsScreen({super.key, required this.appState});

  final AppState appState;

  @override
  Widget build(BuildContext context) {
    return AnimatedBuilder(
      animation: appState,
      builder: (context, _) {
        return Scaffold(
          body: Container(
            decoration: const BoxDecoration(
              gradient: AppGradients.mainBackground,
            ),
            child: SafeArea(
              child: Padding(
                padding: const EdgeInsets.fromLTRB(
                  AppSpacing.md,
                  AppSpacing.md,
                  AppSpacing.md,
                  AppSpacing.lg,
                ),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.stretch,
                  children: [
                    Row(
                      children: [
                        IconButton(
                          onPressed: () => Navigator.of(context).pop(),
                          icon: const Icon(
                            Icons.chevron_left_rounded,
                            size: 34,
                          ),
                        ),
                        Expanded(
                          child: Text(
                            'Acil Durum Kisileri',
                            textAlign: TextAlign.center,
                            style: AppTextStyles.title.copyWith(fontSize: 30),
                          ),
                        ),
                        const SizedBox(width: 42),
                      ],
                    ),
                    const SizedBox(height: AppSpacing.md),
                    Expanded(
                      child: appState.emergencyContacts.isEmpty
                          ? Center(
                              child: Text(
                                'Henuz kisi eklenmedi',
                                style: AppTextStyles.body,
                              ),
                            )
                          : ListView.separated(
                              itemCount: appState.emergencyContacts.length,
                              separatorBuilder: (context, index) =>
                                  const SizedBox(height: AppSpacing.sm),
                              itemBuilder: (context, index) {
                                final item = appState.emergencyContacts[index];
                                return Dismissible(
                                  key: ValueKey(item.id),
                                  direction: DismissDirection.endToStart,
                                  background: Container(
                                    decoration: BoxDecoration(
                                      color: const Color(0xFF8B1F33),
                                      borderRadius: BorderRadius.circular(
                                        AppRadius.md,
                                      ),
                                    ),
                                    alignment: Alignment.centerRight,
                                    padding: const EdgeInsets.only(
                                      right: AppSpacing.md,
                                    ),
                                    child: const Icon(
                                      Icons.delete_outline_rounded,
                                      color: Colors.white,
                                    ),
                                  ),
                                  onDismissed: (_) =>
                                      appState.removeEmergencyContact(item.id),
                                  child: Container(
                                    padding: const EdgeInsets.all(
                                      AppSpacing.md,
                                    ),
                                    decoration: BoxDecoration(
                                      color: AppColors.card.withValues(
                                        alpha: 0.92,
                                      ),
                                      borderRadius: BorderRadius.circular(
                                        AppRadius.md,
                                      ),
                                    ),
                                    child: Row(
                                      children: [
                                        const CircleAvatar(
                                          radius: 22,
                                          child: Icon(Icons.person_rounded),
                                        ),
                                        const SizedBox(width: AppSpacing.sm),
                                        Expanded(
                                          child: Column(
                                            crossAxisAlignment:
                                                CrossAxisAlignment.start,
                                            children: [
                                              Text(
                                                item.name,
                                                style: AppTextStyles.title
                                                    .copyWith(fontSize: 20),
                                              ),
                                              const SizedBox(height: 2),
                                              Text(
                                                item.phone,
                                                style: AppTextStyles.caption
                                                    .copyWith(fontSize: 16),
                                              ),
                                            ],
                                          ),
                                        ),
                                        IconButton(
                                          tooltip: 'Birincil kisi sec',
                                          onPressed: () => appState
                                              .setPrimaryEmergencyContact(
                                                item.id,
                                              ),
                                          icon: Icon(
                                            item.isPrimary
                                                ? Icons.star_rounded
                                                : Icons.star_border_rounded,
                                            color: item.isPrimary
                                                ? const Color(0xFFFFD54F)
                                                : Colors.white70,
                                          ),
                                        ),
                                        IconButton(
                                          onPressed: () => appState
                                              .removeEmergencyContact(item.id),
                                          icon: const Icon(
                                            Icons.delete_outline_rounded,
                                            color: Colors.redAccent,
                                          ),
                                        ),
                                      ],
                                    ),
                                  ),
                                );
                              },
                            ),
                    ),
                    const SizedBox(height: AppSpacing.sm),
                    ElevatedButton.icon(
                      onPressed: () => _openAddContactSheet(context),
                      icon: const Icon(Icons.person_add_alt_1_rounded),
                      label: const Text('Kisi Ekle'),
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

  Future<void> _openAddContactSheet(BuildContext context) async {
    final parentContext = context;
    final nameController = TextEditingController();
    final phoneController = TextEditingController();
    final formKey = GlobalKey<FormState>();

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
          child: Form(
            key: formKey,
            child: Column(
              mainAxisSize: MainAxisSize.min,
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text('Kisi Ekle', style: AppTextStyles.title),
                const SizedBox(height: AppSpacing.sm),
                TextFormField(
                  controller: nameController,
                  decoration: const InputDecoration(hintText: 'Kisi adi'),
                  validator: (value) {
                    if ((value ?? '').trim().isEmpty) {
                      return 'Ad bos gecilemez';
                    }
                    return null;
                  },
                ),
                const SizedBox(height: AppSpacing.sm),
                TextFormField(
                  controller: phoneController,
                  keyboardType: TextInputType.phone,
                  decoration: const InputDecoration(hintText: 'Telefon'),
                  validator: (value) {
                    if ((value ?? '').trim().isEmpty) {
                      return 'Telefon bos gecilemez';
                    }
                    return null;
                  },
                ),
                const SizedBox(height: AppSpacing.md),
                SizedBox(
                  width: double.infinity,
                  child: ElevatedButton(
                    onPressed: () {
                      if (formKey.currentState?.validate() ?? false) {
                        final name = nameController.text.trim();
                        final phone = phoneController.text.trim();
                        Navigator.of(context).pop();
                        WidgetsBinding.instance.addPostFrameCallback((_) {
                          if (!parentContext.mounted) {
                            return;
                          }
                          appState.addEmergencyContact(
                            name: name,
                            phone: phone,
                          );
                        });
                      }
                    },
                    child: const Text('Ekle'),
                  ),
                ),
              ],
            ),
          ),
        );
      },
    );
  }
}
