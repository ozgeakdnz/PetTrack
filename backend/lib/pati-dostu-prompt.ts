import { prisma } from "@/lib/prisma";

export const PATIDOSTU_DISCLAIMER =
  "Bu yapay zeka tavsiyeleri profesyonel teşhis ile yer değiştiremez. Acil durumlarda lütfen en yakın veteriner kliniğine başvurun.";

export const PATIDOSTU_TAGLINE =
  "Semptom analizi ve bakım tavsiyesi için yanınızdayım.";

export const PATIDOSTU_SYSTEM = `Sen "Pati Dostu" adlı PetTrack uygulamasının Türkçe yapay zeka asistanısın.

Kişilik ve üslup:
- Sıcak, empatik ve güven veren bir pati dostu gibi konuş; kullanıcıya "sen" diye hitap et.
- Aktif profil varsa evcil hayvanın adını doğal biçimde kullan (ör. "Minnoş için…").
- Her yanıt 4–6 tam cümle olsun; yarım cümle veya kesik yanıt asla verme, mutlaka noktalama ile bitir.
- Önce soruya doğrudan cevap ver, sonra pratik bakım adımlarını ve PetTrack'te hangi sayfayı kullanacağını açıkla.
- Ara sıra 🐾 kullanabilirsin ama abartma.
- Her yanıt PetTrack bağlamında kalmalı: semptom analizi, bakım tavsiyesi, uygulama yönlendirmesi.

PetTrack modülleri:
- Profil: Kedi/köpek/kuş profili, fotoğraf, kilo, ırk, doğum tarihi; birden fazla evcil hayvan.
- Takvim: Aşı ve randevu hatırlatıcıları; Bekliyor/Tamamlandı.
- Sağlık Günlüğü: Belirti türü, şiddet (Düşük/Orta/Yüksek), tarih, açıklama; CSV dışa aktarma.
- Beslenme: Kalori hedefi, diyet hedefleri, öğün planlayıcı, öğün onaylama.
- Pati Dostu AI: Bu sohbet ekranı.

Kurallar:
- Tıbbi teşhis koyma; acil belirtilerde veterinere yönlendir.
- Yanıtlarda ilgili PetTrack sayfasını ve yapılacak adımı söyle.
- Kayıtlı belirti, aşı veya öğün verilmişse bunlara atıf yaparak kişiselleştir.
- Genel veteriner bilgisi verebilirsin ama öncelik PetTrack kayıtları ve pratik adımlar olsun.`;

const speciesLabel: Record<string, string> = {
  CAT: "Kedi",
  DOG: "Köpek",
  BIRD: "Kuş",
};

const genderLabel: Record<string, string> = {
  MALE: "Erkek",
  FEMALE: "Dişi",
  UNKNOWN: "Bilinmiyor",
};

const severityLabel: Record<string, string> = {
  LOW: "Düşük",
  MEDIUM: "Orta",
  HIGH: "Yüksek",
};

const DEFAULT_SUGGESTIONS = [
  "Kedim bugün çok iştahsız, ne yapmalıyım?",
  "Köpeklerde aşı sonrası halsizlik normal mi?",
  "PetTrack'te aşı hatırlatıcısı nasıl eklerim?",
];

export type PetPersonaSummary = {
  name: string;
  species: string;
  weight: number | null;
  birthDate: Date | null;
};

export function formatPetAge(birthDate: Date | null): string {
  if (!birthDate) return "bilinmiyor";
  const now = new Date();
  let years = now.getFullYear() - birthDate.getFullYear();
  const m = now.getMonth() - birthDate.getMonth();
  if (m < 0 || (m === 0 && now.getDate() < birthDate.getDate())) years--;
  if (years < 1) return "1 yaş altı";
  return `${years} Yaş`;
}

function formatPetStats(weight: number | null, birthDate: Date | null): string {
  const parts: string[] = [];
  if (weight != null) parts.push(`${weight} kg`);
  const age = formatPetAge(birthDate);
  if (age !== "bilinmiyor") parts.push(age);
  return parts.join(" • ");
}

export function buildPersonalizedWelcome(pet: PetPersonaSummary | null): string {
  if (!pet) {
    return "Merhaba! Ben Pati Dostu 🐾 PetTrack'teki pati dostunuzun sağlığı, beslenmesi ve aşı takibi için buradayım. Semptom analizi ve bakım tavsiyesi için sorunuzu yazın.";
  }

  const species = speciesLabel[pet.species] ?? "evcil hayvan";
  const stats = formatPetStats(pet.weight, pet.birthDate);
  const statsPart = stats ? ` (${stats})` : "";

  return `Merhaba! Ben Pati Dostu 🐾 ${pet.name}${statsPart} için buradayım. ${species} dostunuzun belirtilerini birlikte değerlendirebilir, PetTrack'te hangi adımı atman gerektiğini söyleyebilirim. Nasıl yardımcı olayım?`;
}

export function buildPersonalizedTagline(pet: PetPersonaSummary | null): string {
  if (!pet) {
    return "Dostunuzun semptomları hakkında detay yazarak analiz edin ve bakım tavsiyesi alın.";
  }
  return `${pet.name} için semptom analizi ve bakım tavsiyesi alın.`;
}

export function buildPersonalizedSuggestions(pet: PetPersonaSummary | null): string[] {
  if (!pet) return DEFAULT_SUGGESTIONS;

  const { name, species } = pet;
  switch (species) {
    case "CAT":
      return [
        `${name} bugün iştahsız, ne yapmalıyım?`,
        `${name} için Sağlık Günlüğü'ne belirti nasıl eklerim?`,
        `${name}'un aşı takvimini nasıl planlarım?`,
      ];
    case "DOG":
      return [
        `${name} aşı sonrası halsiz, bu normal mi?`,
        `${name} için günlük beslenme planı nasıl ayarlanır?`,
        `${name}'un son belirtilerini nasıl değerlendiririm?`,
      ];
    case "BIRD":
      return [
        `${name} için beslenme sıklığı nasıl olmalı?`,
        `${name}'da halsizlik görürsem ne yapmalıyım?`,
        `PetTrack'te ${name} profilini nasıl güncellerim?`,
      ];
    default:
      return [
        `${name} bugün iştahsız, ne yapmalıyım?`,
        `${name} için belirti kaydı nasıl eklenir?`,
        `${name}'un bakım planını nasıl takip ederim?`,
      ];
  }
}

export async function fetchPetPersonaSummary(petId: string | undefined): Promise<PetPersonaSummary | null> {
  if (!petId?.trim()) return null;
  const pet = await prisma.pet.findUnique({
    where: { id: petId },
    select: { name: true, species: true, weight: true, birthDate: true },
  });
  if (!pet) return null;
  return {
    name: pet.name,
    species: pet.species,
    weight: pet.weight,
    birthDate: pet.birthDate,
  };
}

export async function buildActivePetContext(petId: string | undefined): Promise<string> {
  if (!petId?.trim()) return "";

  const pet = await prisma.pet.findUnique({
    where: { id: petId },
    include: {
      symptomLogs: { orderBy: { createdAt: "desc" }, take: 3 },
      vaccinations: { orderBy: { date: "asc" }, take: 5 },
      nutritions: { orderBy: { feedTime: "asc" }, take: 5 },
    },
  });

  if (!pet) return "";

  const lines: string[] = [
    "Aktif evcil hayvan profili:",
    `- İsim: ${pet.name}`,
    `- Tür: ${speciesLabel[pet.species] ?? pet.species}`,
    `- Cinsiyet: ${genderLabel[pet.gender] ?? pet.gender}`,
    `- Irk: ${pet.breed ?? "belirtilmedi"}`,
    `- Kilo: ${pet.weight != null ? `${pet.weight} kg` : "belirtilmedi"}`,
    `- Yaş: ${formatPetAge(pet.birthDate)}`,
  ];

  if (pet.symptomLogs.length > 0) {
    lines.push("Son belirti kayıtları:");
    for (const log of pet.symptomLogs) {
      const date = log.createdAt.toLocaleDateString("tr-TR");
      lines.push(
        `  • ${date}: ${log.symptom} (${severityLabel[log.severity] ?? log.severity})${log.description ? ` — ${log.description}` : ""}`,
      );
    }
  }

  const upcoming = pet.vaccinations.filter((v) => v.status === "PENDING");
  if (upcoming.length > 0) {
    lines.push("Yaklaşan/bekleyen takvim kayıtları:");
    for (const v of upcoming.slice(0, 3)) {
      const date = v.date.toLocaleDateString("tr-TR");
      lines.push(`  • ${v.name} — ${date}${v.notes ? ` (${v.notes})` : ""}`);
    }
  }

  if (pet.nutritions.length > 0) {
    lines.push("Beslenme planı (öğünler):");
    for (const meal of pet.nutritions) {
      lines.push(
        `  • ${meal.feedTime}: ${meal.foodName} ${meal.amount} — ${meal.status === "COMPLETED" ? "Tamamlandı" : "Bekliyor"}`,
      );
    }
  }

  return lines.join("\n");
}
