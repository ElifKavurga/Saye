import 'package:flutter/material.dart';

import '../theme/design_system.dart';

class SectionTitle extends StatelessWidget {
  const SectionTitle({super.key, required this.label, this.trailing});

  final String label;
  final Widget? trailing;

  @override
  Widget build(BuildContext context) {
    return Row(
      children: [
        Expanded(child: Text(label, style: AppTextStyles.title)),
        trailing ?? const SizedBox.shrink(),
      ],
    );
  }
}
