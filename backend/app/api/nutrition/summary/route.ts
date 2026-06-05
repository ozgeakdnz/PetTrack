import { prisma } from "@/lib/prisma";
import { NextResponse } from "next/server";

function parseGrams(amount: string): number {
  const match = amount.match(/(\d+(?:[.,]\d+)?)/);
  if (!match) return 0;
  return Number(match[1].replace(",", ".")) || 0;
}

function estimateKcal(foodName: string, grams: number): number {
  const lower = foodName.toLowerCase();
  const perGram = lower.includes("konserve") || lower.includes("wet") ? 1.1 : 3.8;
  return Math.round(grams * perGram);
}

export async function GET(req: Request) {
  try {
    const { searchParams } = new URL(req.url);
    const petId = searchParams.get("petId");

    if (!petId) {
      return NextResponse.json({ error: "petId zorunludur." }, { status: 400 });
    }

    const pet = await prisma.pet.findUnique({
      where: { id: petId },
      select: { id: true, name: true, weight: true },
    });

    if (!pet) {
      return NextResponse.json({ error: "Profil bulunamadı." }, { status: 404 });
    }

    const items = await prisma.nutrition.findMany({
      where: { petId },
      orderBy: [{ feedTime: "asc" }, { createdAt: "asc" }],
    });

    const dailyTargetKcal = pet.weight ? Math.round(pet.weight * 30) : 840;
    let completedKcal = 0;
    let totalKcal = 0;

    for (const item of items) {
      const grams = parseGrams(item.amount);
      const kcal = estimateKcal(item.foodName, grams);
      totalKcal += kcal;
      if (item.status === "COMPLETED") {
        completedKcal += kcal;
      }
    }

    const progressPercent =
      dailyTargetKcal > 0 ? Math.min(100, Math.round((completedKcal / dailyTargetKcal) * 100)) : 0;

    const proteinG = Math.round(completedKcal * 0.055);
    const fatG = Math.round(completedKcal * 0.022);
    const fiberG = Math.round(completedKcal * 0.014);

    let tip = `${pet.name} için öğün saatlerini düzenli tutmak sindirimi destekler.`;
    if (progressPercent < 50) {
      tip = `${pet.name} bugün hedefin yarısından azını tamamladı. Akşam öğününü zamanında vermeyi unutmayın.`;
    } else if (progressPercent >= 100) {
      tip = `${pet.name} günlük beslenme hedefini tamamladı. Fazla mama vermekten kaçının.`;
    } else {
      tip = `${pet.name}'ın aktivite düzeyi normal görünüyor. Kalan öğünleri planlanan saatlerde tamamlayın.`;
    }

    return NextResponse.json({
      summary: {
        petName: pet.name,
        dailyTargetKcal,
        completedKcal,
        progressPercent,
        proteinG,
        fatG,
        fiberG,
        tip,
        mealCount: items.length,
        completedMealCount: items.filter((i) => i.status === "COMPLETED").length,
      },
    });
  } catch (error) {
    const message = error instanceof Error ? error.message : "Beslenme özeti alınamadı.";
    return NextResponse.json({ error: message }, { status: 500 });
  }
}
