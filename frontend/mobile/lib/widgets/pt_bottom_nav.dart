import 'package:flutter/material.dart';

import '../theme/app_colors.dart';

class PtBottomNav extends StatelessWidget {
  const PtBottomNav({
    super.key,
    required this.currentIndex,
    required this.onChanged,
    this.onCenterTap,
    this.nutritionLargePlus = false,
  });

  final int currentIndex;
  final ValueChanged<int> onChanged;
  final VoidCallback? onCenterTap;
  final bool nutritionLargePlus;

  @override
  Widget build(BuildContext context) {
    return Container(
      decoration: BoxDecoration(
        color: const Color(0xFFF2F3F5),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withValues(alpha: 0.06),
            blurRadius: 12,
            offset: const Offset(0, -2),
          ),
        ],
      ),
      padding: const EdgeInsets.fromLTRB(8, 10, 8, 0),
      child: SafeArea(
        top: false,
        minimum: const EdgeInsets.only(bottom: 8),
        child: Row(
          mainAxisAlignment: MainAxisAlignment.spaceAround,
          children: [
            _NavItem(
              icon: Icons.person_outline_rounded,
              label: 'Profil',
              active: currentIndex == 0,
              onTap: () => onChanged(0),
            ),
            _NavItem(
              icon: Icons.calendar_month_rounded,
              label: 'Takvim',
              active: currentIndex == 1,
              onTap: () => onChanged(1),
            ),
            _CenterRobot(onTap: onCenterTap ?? () {}),
            _NavItem(
              icon: Icons.health_and_safety_outlined,
              label: 'Günlük',
              active: currentIndex == 3,
              onTap: () => onChanged(3),
              iconBuilder: (c, a) => Stack(
                clipBehavior: Clip.none,
                children: [
                  Icon(Icons.health_and_safety_outlined, color: c, size: 26),
                  Positioned(
                    right: -2,
                    top: -2,
                    child: Icon(Icons.add, color: c, size: 14),
                  ),
                ],
              ),
            ),
            _NutritionNavItem(
              active: currentIndex == 4,
              largePlus: nutritionLargePlus,
              onTap: () => onChanged(4),
            ),
          ],
        ),
      ),
    );
  }
}

class _NavItem extends StatelessWidget {
  const _NavItem({
    required this.icon,
    required this.label,
    required this.active,
    required this.onTap,
    this.iconBuilder,
  });

  final IconData icon;
  final String label;
  final bool active;
  final VoidCallback onTap;
  final Widget Function(Color color, bool active)? iconBuilder;

  @override
  Widget build(BuildContext context) {
    final color = active ? AppColors.primary : AppColors.textSecondary;
    return InkWell(
      onTap: onTap,
      borderRadius: BorderRadius.circular(12),
      child: Padding(
        padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 4),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            iconBuilder != null
                ? iconBuilder!(color, active)
                : Icon(icon, color: color, size: 26),
            const SizedBox(height: 4),
            Text(
              label,
              style: TextStyle(
                fontSize: 11,
                fontWeight: active ? FontWeight.w700 : FontWeight.w500,
                color: active ? AppColors.textPrimary : AppColors.textSecondary,
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class _CenterRobot extends StatelessWidget {
  const _CenterRobot({required this.onTap});

  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    return Transform.translate(
      offset: const Offset(0, -18),
      child: Column(
        children: [
          Material(
            color: Colors.transparent,
            child: InkWell(
              customBorder: const CircleBorder(),
              onTap: onTap,
              child: Container(
                width: 56,
                height: 56,
                decoration: const BoxDecoration(
                  shape: BoxShape.circle,
                  gradient: LinearGradient(
                    colors: [AppColors.primary, AppColors.primaryLight],
                    begin: Alignment.topLeft,
                    end: Alignment.bottomRight,
                  ),
                ),
                child: const Icon(Icons.smart_toy_rounded, color: Colors.white, size: 28),
              ),
            ),
          ),
        ],
      ),
    );
  }
}

class _NutritionNavItem extends StatelessWidget {
  const _NutritionNavItem({
    required this.active,
    required this.largePlus,
    required this.onTap,
  });

  final bool active;
  final bool largePlus;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    return InkWell(
      onTap: onTap,
      borderRadius: BorderRadius.circular(16),
      child: Padding(
        padding: const EdgeInsets.symmetric(horizontal: 4, vertical: 4),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Container(
              width: largePlus ? 46 : 36,
              height: largePlus ? 46 : 36,
              decoration: BoxDecoration(
                shape: BoxShape.circle,
                color: active ? AppColors.primary : const Color(0xFFE8EAED),
              ),
              child: Icon(
                largePlus ? Icons.add : Icons.restaurant_rounded,
                color: Colors.white,
                size: largePlus ? 26 : 22,
              ),
            ),
            const SizedBox(height: 4),
            Text(
              'Beslenme',
              style: TextStyle(
                fontSize: 11,
                fontWeight: FontWeight.w700,
                color: active ? AppColors.textPrimary : AppColors.textSecondary,
              ),
            ),
          ],
        ),
      ),
    );
  }
}
