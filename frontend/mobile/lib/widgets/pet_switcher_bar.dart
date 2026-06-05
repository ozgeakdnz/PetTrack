import 'package:flutter/material.dart';

import '../theme/app_colors.dart';
import '../models/pet_models.dart';

/// Yatay evcil hayvan seçici — web'deki aktif profil dropdown'ının mobil karşılığı.
class PetSwitcherBar extends StatelessWidget {
  const PetSwitcherBar({
    super.key,
    required this.pets,
    required this.activePetId,
    required this.onSelected,
    this.onAddPet,
  });

  final List<Pet> pets;
  final String? activePetId;
  final ValueChanged<String> onSelected;
  final VoidCallback? onAddPet;

  @override
  Widget build(BuildContext context) {
    if (pets.isEmpty) {
      return Padding(
        padding: const EdgeInsets.fromLTRB(20, 0, 20, 8),
        child: Text(
          'Henüz evcil hayvan yok',
          style: TextStyle(color: AppColors.textSecondary, fontSize: 13),
        ),
      );
    }

    return Padding(
      padding: const EdgeInsets.fromLTRB(20, 0, 20, 12),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            'AKTİF PROFİL',
            style: TextStyle(
              fontSize: 10,
              letterSpacing: 0.8,
              fontWeight: FontWeight.w800,
              color: AppColors.textSecondary.withValues(alpha: 0.95),
            ),
          ),
          const SizedBox(height: 8),
          SizedBox(
            height: 40,
            child: ListView.separated(
              scrollDirection: Axis.horizontal,
              itemCount: pets.length + (onAddPet != null ? 1 : 0),
              separatorBuilder: (_, __) => const SizedBox(width: 8),
              itemBuilder: (context, i) {
                if (onAddPet != null && i == pets.length) {
                  return ActionChip(
                    avatar: const Icon(Icons.add, size: 16, color: AppColors.primary),
                    label: const Text('Ekle'),
                    onPressed: onAddPet,
                    backgroundColor: const Color(0xFFEEF1F3),
                    side: BorderSide.none,
                  );
                }
                final pet = pets[i];
                final active = pet.id == activePetId;
                return ChoiceChip(
                  label: Text(pet.name),
                  selected: active,
                  onSelected: (_) => onSelected(pet.id),
                  selectedColor: AppColors.primary.withValues(alpha: 0.15),
                  labelStyle: TextStyle(
                    fontWeight: FontWeight.w700,
                    color: active ? AppColors.primary : AppColors.textPrimary,
                  ),
                  side: BorderSide(
                    color: active ? AppColors.primary : AppColors.borderSoft,
                  ),
                );
              },
            ),
          ),
        ],
      ),
    );
  }
}
