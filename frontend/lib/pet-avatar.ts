export type PetSpecies = "CAT" | "DOG" | "BIRD";

export type PetAvatarSource = {
  species: PetSpecies;
  imageUrl?: string | null;
};

export const SPECIES_FALLBACK_IMAGE: Record<PetSpecies, string> = {
  CAT: "https://images.unsplash.com/photo-1573865526739-10659fec78a5?auto=format&fit=crop&w=800&q=80",
  DOG: "https://images.unsplash.com/photo-1517849845537-4d257902454a?auto=format&fit=crop&w=800&q=80",
  BIRD: "https://images.unsplash.com/photo-1444464666168-49d633b86797?auto=format&fit=crop&w=800&q=80",
};

export function resolvePetImageSrc(
  pet: PetAvatarSource | null,
  species: PetSpecies | undefined,
  previewUrl: string | null,
): string {
  if (previewUrl) return previewUrl;
  if (pet?.imageUrl) {
    if (pet.imageUrl.startsWith("http")) return pet.imageUrl;
    return pet.imageUrl.startsWith("/") ? pet.imageUrl : `/${pet.imageUrl}`;
  }
  return SPECIES_FALLBACK_IMAGE[species ?? "CAT"];
}
