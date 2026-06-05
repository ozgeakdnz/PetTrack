import 'package:flutter/material.dart';

import '../state/active_pet_scope.dart';
import '../theme/app_colors.dart';
import '../utils/pet_avatar.dart';

/// Üst bar: sol PetTrack, sağ bildirim + aktif evcil hayvan avatarı.
class PtHeader extends StatelessWidget {
  const PtHeader({
    super.key,
    this.onNotificationsTap,
  });

  final VoidCallback? onNotificationsTap;

  @override
  Widget build(BuildContext context) {
    final scope = ActivePetScopeWidget.maybeOf(context);

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
          if (scope != null)
            ListenableBuilder(
              listenable: scope,
              builder: (context, _) {
                final pet = scope.activePet;
                if (pet == null) {
                  return const SizedBox(width: 36, height: 36);
                }
                return CircleAvatar(
                  radius: 18,
                  backgroundColor: const Color(0xFFE8EAED),
                  backgroundImage: PetAvatar.resolve(
                    species: pet.species,
                    imageUrl: pet.imageUrl,
                  ),
                );
              },
            ),
        ],
      ),
    );
  }
}
