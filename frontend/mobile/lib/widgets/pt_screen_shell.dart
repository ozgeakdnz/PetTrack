import 'package:flutter/material.dart';

import '../theme/app_colors.dart';

/// Tam ekran sayfa sarmalayıcı — IndexedStack / Stack içinde boyut kaybını önler.
class PtScreenShell extends StatelessWidget {
  const PtScreenShell({super.key, required this.child});

  final Widget child;

  @override
  Widget build(BuildContext context) {
    return ColoredBox(
      color: AppColors.background,
      child: SizedBox.expand(child: child),
    );
  }
}
