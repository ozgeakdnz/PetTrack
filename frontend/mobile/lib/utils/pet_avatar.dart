import 'package:flutter/material.dart';

import '../config/api_config.dart';

/// Tür bazlı varsayılan profil görselleri (web ile aynı Unsplash kaynakları, yerel asset).
class PetAvatar {
  PetAvatar._();

  static const _speciesAssets = {
    'CAT': 'assets/images/pet_cat.png',
    'DOG': 'assets/images/pet_dog.png',
    'BIRD': 'assets/images/pet_bird.png',
  };

  static String defaultAssetFor(String species) =>
      _speciesAssets[species] ?? _speciesAssets['CAT']!;

  static bool hasCustomPhoto(String? imageUrl) =>
      imageUrl != null && imageUrl.trim().isNotEmpty;

  static ImageProvider resolve({
    required String species,
    String? imageUrl,
  }) {
    if (hasCustomPhoto(imageUrl)) {
      final url = imageUrl!.trim();
      if (url.startsWith('http')) return NetworkImage(url);
      return NetworkImage('${ApiConfig.nextApiBase}$url');
    }
    return AssetImage(defaultAssetFor(species));
  }
}
