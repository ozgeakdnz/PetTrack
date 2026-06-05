import 'package:flutter/material.dart';

import '../theme/app_colors.dart';

/// Üst bar: sol PetTrack, sağ bildirim (+ isteğe bağlı avatar).
class PtHeader extends StatelessWidget {
  const PtHeader({
    super.key,
    this.showProfileAvatar = false,
    this.profileImageAsset = 'assets/images/user_avatar.png',
    this.onNotificationsTap,
  });

  final bool showProfileAvatar;
  final String profileImageAsset;
  final VoidCallback? onNotificationsTap;

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: EdgeInsets.fromLTRB(20, MediaQuery.paddingOf(context).top + 12, 20, 8),
      child: Row(
        children: [
          Text(
            'PetTrack',
            style: Theme.of(context).textTheme.titleLarge?.copyWith(
                  color: AppColors.primary,
                  fontWeight: FontWeight.w800,
                  fontSize: 22,
                ),
          ),
          const Spacer(),
          IconButton(
            onPressed: onNotificationsTap ??
                () {
                  ScaffoldMessenger.of(context).showSnackBar(
                    const SnackBar(content: Text('Bildirim bulunmuyor')),
                  );
                },
            icon: const Icon(Icons.notifications_none_rounded),
            color: AppColors.textSecondary,
          ),
          if (showProfileAvatar) ...[
            const SizedBox(width: 4),
            CircleAvatar(
              radius: 18,
              backgroundImage: AssetImage(profileImageAsset),
            ),
          ],
        ],
      ),
    );
  }
}
