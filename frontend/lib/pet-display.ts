export function formatPetAge(birthDate: string | null | undefined): string {
  if (!birthDate) return "—";
  const birth = new Date(birthDate);
  if (Number.isNaN(birth.getTime())) return "—";

  const now = new Date();
  let years = now.getFullYear() - birth.getFullYear();
  const monthDiff = now.getMonth() - birth.getMonth();
  if (monthDiff < 0 || (monthDiff === 0 && now.getDate() < birth.getDate())) {
    years--;
  }
  if (years < 1) return "1 yaş altı";
  return `${years} Yaş`;
}

export function formatPetWeight(weight: number | null | undefined): string {
  if (weight == null || Number.isNaN(weight)) return "—";
  const rounded = Number.isInteger(weight) ? weight : Number(weight.toFixed(1));
  return `${rounded} kg`;
}
