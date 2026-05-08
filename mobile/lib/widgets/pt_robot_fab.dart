import 'package:flutter/material.dart';

import '../theme/app_colors.dart';

/// Yuvarlak teal FAB — robot / pati dostu.
class PtRobotFab extends StatelessWidget {
  const PtRobotFab({
    super.key,
    this.bottomOffset = 88,
    this.rightOffset = 20,
    this.label,
    this.onPressed,
  });

  final double bottomOffset;
  final double rightOffset;
  final String? label;
  final VoidCallback? onPressed;

  @override
  Widget build(BuildContext context) {
    return Positioned(
      right: rightOffset,
      bottom: bottomOffset,
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          DecoratedBox(
            decoration: BoxDecoration(
              shape: BoxShape.circle,
              gradient: const LinearGradient(
                colors: [AppColors.primary, AppColors.primaryLight],
                begin: Alignment.topLeft,
                end: Alignment.bottomRight,
              ),
              boxShadow: [
                BoxShadow(
                  color: AppColors.primary.withValues(alpha: 0.35),
                  blurRadius: 14,
                  offset: const Offset(0, 6),
                ),
              ],
            ),
            child: Material(
              color: Colors.transparent,
              child: InkWell(
                customBorder: const CircleBorder(),
                onTap: onPressed,
                child: const SizedBox(
                  width: 58,
                  height: 58,
                  child: Icon(Icons.smart_toy_rounded, color: Colors.white, size: 28),
                ),
              ),
            ),
          ),
          if (label != null) ...[
            const SizedBox(height: 6),
            Text(
              label!,
              style: const TextStyle(
                color: AppColors.primary,
                fontSize: 11,
                fontWeight: FontWeight.w700,
              ),
            ),
          ],
        ],
      ),
    );
  }
}
