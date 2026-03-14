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
                    if (appState.isLoading)
                      const Padding(
                        padding: EdgeInsets.only(bottom: AppSpacing.sm),
                        child: LinearProgressIndicator(),
                      ),
                    Expanded(child: _buildBody(context)),
                    const SizedBox(height: AppSpacing.sm),
                    ElevatedButton.icon(
                      onPressed: appState.isLoading
                          ? null
                          : () => _openAddContactSheet(context),
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

  Widget _buildBody(BuildContext context) {
    if (appState.isLoading && appState.emergencyContacts.isEmpty) {
      return const Center(child: CircularProgressIndicator());
    }

    if (appState.emergencyContacts.isEmpty) {
      return Center(
        child: Text('Henuz kisi eklenmedi', style: AppTextStyles.body),
      );
    }

    return ListView.separated(
      itemCount: appState.emergencyContacts.length,
      separatorBuilder: (context, index) =>
          const SizedBox(height: AppSpacing.sm),
      itemBuilder: (context, index) {
        final item = appState.emergencyContacts[index];
        return Dismissible(
          key: ValueKey(item.id),
          direction: appState.isLoading
              ? DismissDirection.none
              : DismissDirection.endToStart,
          confirmDismiss: (_) => _deleteContact(context, item.id),
          background: Container(
            decoration: BoxDecoration(
              color: const Color(0xFF8B1F33),
              borderRadius: BorderRadius.circular(AppRadius.md),
            ),
            alignment: Alignment.centerRight,
            padding: const EdgeInsets.only(right: AppSpacing.md),
            child: const Icon(
              Icons.delete_outline_rounded,
              color: Colors.white,
            ),
          ),
          child: Container(
            padding: const EdgeInsets.all(AppSpacing.md),
            decoration: BoxDecoration(
              color: AppColors.card.withValues(alpha: 0.92),
              borderRadius: BorderRadius.circular(AppRadius.md),
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
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        item.name,
                        style: AppTextStyles.title.copyWith(fontSize: 20),
                      ),
                      const SizedBox(height: 2),
                      Text(
                        item.phone,
                        style: AppTextStyles.caption.copyWith(fontSize: 16),
                      ),
                    ],
                  ),
                ),
                IconButton(
                  tooltip: 'Birincil kisi sec',
                  onPressed: appState.isLoading || item.isPrimary
                      ? null
                      : () => _setPrimaryContact(context, item.id),
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
                  onPressed: appState.isLoading
                      ? null
                      : () async {
                          await _deleteContact(context, item.id);
                        },
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
    );
  }

  Future<void> _openAddContactSheet(BuildContext context) async {
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
        return AnimatedBuilder(
          animation: appState,
          builder: (context, _) {
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
                        onPressed: appState.isLoading
                            ? null
                            : () async {
                                if (!(formKey.currentState?.validate() ??
                                    false)) {
                                  return;
                                }

                                try {
                                  await appState.addEmergencyContact(
                                    name: nameController.text.trim(),
                                    phone: phoneController.text.trim(),
                                  );
                                  if (!context.mounted) {
                                    return;
                                  }
                                  Navigator.of(context).pop();
                                } catch (error) {
                                  _showError(context, error);
                                }
                              },
                        child: appState.isLoading
                            ? const SizedBox(
                                width: 20,
                                height: 20,
                                child: CircularProgressIndicator(
                                  strokeWidth: 2,
                                ),
                              )
                            : const Text('Ekle'),
                      ),
                    ),
                  ],
                ),
              ),
            );
          },
        );
      },
    );
  }

  Future<bool> _deleteContact(BuildContext context, String id) async {
    try {
      await appState.removeEmergencyContact(id);
      return true;
    } catch (error) {
      if (!context.mounted) {
        return false;
      }
      _showError(context, error);
      return false;
    }
  }

  Future<void> _setPrimaryContact(BuildContext context, String id) async {
    try {
      await appState.setPrimaryEmergencyContact(id);
    } catch (error) {
      if (!context.mounted) {
        return;
      }
      _showError(context, error);
    }
  }

  void _showError(BuildContext context, Object error) {
    if (!context.mounted) {
      return;
    }

    final message = error is AppStateException
        ? error.message
        : error.toString();
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(content: Text(message), behavior: SnackBarBehavior.floating),
    );
  }
}
