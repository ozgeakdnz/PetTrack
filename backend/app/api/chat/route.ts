import {
  buildActivePetContext,
  buildPersonalizedSuggestions,
  buildPersonalizedTagline,
  buildPersonalizedWelcome,
  fetchPetPersonaSummary,
  PATIDOSTU_DISCLAIMER,
  PATIDOSTU_SYSTEM,
  PATIDOSTU_TAGLINE,
} from "@/lib/pati-dostu-prompt";
import { NextResponse } from "next/server";

type ChatHistoryItem = {
  role?: string;
  content?: string;
};

type ChatRequest = {
  message?: string;
  history?: ChatHistoryItem[];
  petId?: string;
};

const DEFAULT_MODEL = "gemini-2.5-flash";
const DEFAULT_MAX_INPUT_CHARS = 500;
const DEFAULT_MAX_REQUESTS_PER_MINUTE = 4;
const DEFAULT_MAX_DAILY_GEMINI_CALLS = 15;
const DEFAULT_MAX_OUTPUT_TOKENS = 640;
const WINDOW_MS = 60 * 1000;

const requestLog = new Map<string, number[]>();
let dailyGeminiUsage = { dateKey: "", count: 0 };

function readEnvInt(name: string, fallback: number): number {
  const raw = process.env[name]?.trim();
  if (!raw) return fallback;
  const n = Number.parseInt(raw, 10);
  return Number.isFinite(n) && n > 0 ? n : fallback;
}

function getGeminiModel() {
  return process.env.GEMINI_MODEL?.trim() || DEFAULT_MODEL;
}

function getMaxInputChars() {
  return readEnvInt("GEMINI_MAX_INPUT_CHARS", DEFAULT_MAX_INPUT_CHARS);
}

function getMaxRequestsPerMinute() {
  return readEnvInt("GEMINI_MAX_REQUESTS_PER_MINUTE", DEFAULT_MAX_REQUESTS_PER_MINUTE);
}

function getMaxDailyGeminiCalls() {
  return readEnvInt("GEMINI_MAX_DAILY_REQUESTS", DEFAULT_MAX_DAILY_GEMINI_CALLS);
}

function getMaxOutputTokens() {
  return readEnvInt("GEMINI_MAX_OUTPUT_TOKENS", DEFAULT_MAX_OUTPUT_TOKENS);
}

function todayKey() {
  return new Date().toISOString().slice(0, 10);
}

function getDailyGeminiCount() {
  const key = todayKey();
  if (dailyGeminiUsage.dateKey !== key) {
    dailyGeminiUsage = { dateKey: key, count: 0 };
  }
  return dailyGeminiUsage.count;
}

function incrementDailyGeminiCount() {
  const key = todayKey();
  if (dailyGeminiUsage.dateKey !== key) {
    dailyGeminiUsage = { dateKey: key, count: 1 };
    return;
  }
  dailyGeminiUsage.count += 1;
}

function getThinkingBudget(): number {
  const raw = process.env.GEMINI_THINKING_BUDGET?.trim();
  if (raw === undefined || raw === "") return 0;
  const n = Number.parseInt(raw, 10);
  return Number.isFinite(n) ? n : 0;
}

function isDailyGeminiQuotaExceeded() {
  return getDailyGeminiCount() >= getMaxDailyGeminiCalls();
}

function buildReply(input: string) {
  const text = input.toLowerCase();

  if (
    text.includes("halsiz") &&
    (text.includes("su") || text.includes("içm") || text.includes("icm")) &&
    (text.includes("acil") || text.includes("içmiyor") || text.includes("icmiyor"))
  ) {
    return "Halsizlik ve su içmeme birlikte görüldüğünde bu acil sayılabilir; vakit kaybetmeden veterinere başvurmanı öneririm. Bu arada evcil hayvanını serin ve sakin bir ortamda tut, zorla su içirmeye çalışma ve belirtileri Sağlık Günlüğü'ne tarih ve yüksek şiddetle kaydet. Kusma, diş etlerinde kuruluk, nefes darlığı veya bilinç değişikliği varsa doğrudan en yakın acil veteriner kliniğine git. PetTrack'te Takvim'den acil randevu hatırlatıcısı da ekleyebilirsin.";
  }

  if (
    (text.includes("asi") || text.includes("aşı")) &&
    (text.includes("halsiz") || text.includes("normal"))
  ) {
    return "Evet, köpeklerde aşı sonrası 24–48 saat hafif halsizlik, uyku hali veya iştah azalması sık görülür ve genelde normal kabul edilir. Dinlenmesi için sakin bir ortam sağla, suyunun taze olduğundan emin ol ve belirtileri Sağlık Günlüğü'ne not et. Halsizlik 2 günden uzun sürerse, kusma, ishal, şişlik veya nefes darlığı olursa hemen veterinere başvur. Gelecek aşıları unutmamak için Takvim sayfasından hatırlatıcı ekleyebilirsin.";
  }

  if (text.includes("pettrack") || text.includes("uygulama") || text.includes("nasıl ekler") || text.includes("nereye")) {
    if (text.includes("asi") || text.includes("aşı") || text.includes("takvim") || text.includes("hatırlat")) {
      return "Takvim sayfasına git, evcil hayvanını seç ve «Yeni Hatırlatıcı Ekle» ile aşı veya randevu planla. Durumu Bekliyor/Tamamlandı olarak güncelleyebilirsin.";
    }
    if (text.includes("belirti") || text.includes("günlük") || text.includes("gunluk")) {
      return "Sağlık Günlüğü sayfasında tarih, belirti türü ve şiddet (Düşük/Orta/Yüksek) seçip kaydı kaydet. Geçmiş kayıtları CSV olarak dışa aktarabilirsin.";
    }
    if (text.includes("beslen") || text.includes("mama") || text.includes("öğün") || text.includes("ogun")) {
      return "Beslenme sayfasında diyet hedeflerini ayarla, Öğün Planlayıcı ile yeni öğün ekle ve tamamlanan öğünleri onayla. Günlük kalori hedefini takip edebilirsin.";
    }
    if (text.includes("profil")) {
      return "Profil sayfasından evcil hayvan ekleyebilir, fotoğraf yükleyebilir, kilo/ırk/doğum tarihi güncelleyebilirsin. Üstten aktif profili değiştirebilirsin.";
    }
    return "PetTrack'te Profil, Takvim, Sağlık Günlüğü, Beslenme ve Pati Dostu AI bölümleri var. Hangi konuda yardım istediğini yaz, adım adım yönlendireyim.";
  }

  if (text.includes("kus") || text.includes("istah") || text.includes("iştah") || text.includes("halsiz")) {
    return "Sağlık Günlüğü'ne belirtiyi tarih ve şiddet seviyesiyle kaydet. Kusma/iştahsızlık 24 saati aşarsa veya halsizlik artarsa veterinerle görüşmeni öneririm.";
  }

  if (text.includes("tüy") || text.includes("tüy") || text.includes("dökül") || text.includes("dokul")) {
    return "Tüy dökülmesinde beslenme ve su tüketimini Beslenme sayfasından takip et. Belirgin değişimleri Sağlık Günlüğü'ne not al; kaşıntı varsa veterinere danış.";
  }

  if (text.includes("asi") || text.includes("aşı") || text.includes("randevu") || text.includes("takvim")) {
    return "Takvim sayfasından yeni hatırlatıcı ekleyip tarih-saat belirtebilirsin. Önemli aşıları bir hafta önceden hatırlatacak şekilde planlamak iyi olur.";
  }

  if (text.includes("kuduz")) {
    return "Kuduz aşısı takibini Takvim'de düzenli tut. Son uygulama tarihi ve tekrar dozuna göre gecikmeden randevu planlamanı öneririm.";
  }

  if (text.includes("mama") || text.includes("beslen") || text.includes("kalori") || text.includes("öğün")) {
    return "Beslenme tablosunda öğün saatlerini düzenli tut; Diyet Hedefleri ile kilo koruma/verme/alma planını güncelle. Ani mama değişimlerini kademeli yap.";
  }

  if (text.includes("yemek")) {
    return "Beslenme sayfasında öğün saatlerini sabitlemek sindirimi destekler. İştah azalması veya kusma olursa Sağlık Günlüğü'ne kaydet.";
  }

  if (text.includes("kuş") || text.includes("kus ") || text.includes("yavru")) {
    return "Yavru kuşlarda kısa aralıklarla az miktarda mama ver. Sıcaklık ve aktivite değişimlerini Sağlık Günlüğü'ne kaydet; halsizlikte veterinere danış.";
  }

  if (text.includes("genel muayene") || text.includes("muayene") || text.includes("kontrol")) {
    return "Genel muayene için yılda en az 1 rutin kontrol iyi bir pratiktir. Randevuyu Takvim'e ekleyerek hatırlatıcı kurabilirsin.";
  }

  if (text.includes("su") || text.includes("tuvalet") || text.includes("idrar")) {
    return "Su tüketimi değişimlerini Sağlık Günlüğü'ne not et. Belirgin azalma veya idrar alışkanlığı değişirse veterinerle paylaş.";
  }

  if (text.includes("merhaba") || text.includes("selam") || text.includes("nasılsın")) {
    return "Merhaba! Ben Pati Dostu, PetTrack asistanıyım. Evcil hayvan bakımı, uygulama kullanımı veya kayıtların hakkında sorabilirsin.";
  }

  if (text.includes("teşekkür") || text.includes("sag ol") || text.includes("sağ ol")) {
    return "Rica ederim! Başka bir konuda da yardımcı olabilirim.";
  }

  return "PetTrack bağlamında yardımcı olabilirim. Sorunu biraz daha detaylandırırsan ilgili sayfayı ve adımları söyleyebilirim.";
}

function getClientKey(req: Request) {
  const forwarded = req.headers.get("x-forwarded-for");
  if (forwarded) {
    return forwarded.split(",")[0]?.trim() || "unknown";
  }
  return req.headers.get("x-real-ip") || "unknown";
}

function getRateLimitState(clientKey: string, now: number) {
  const maxPerMinute = getMaxRequestsPerMinute();
  const existing = requestLog.get(clientKey) ?? [];
  const withinWindow = existing.filter((ts) => now - ts < WINDOW_MS);
  if (withinWindow.length < maxPerMinute) {
    withinWindow.push(now);
    requestLog.set(clientKey, withinWindow);
    return { limited: false, retryAfterSec: 0 };
  }

  const oldest = withinWindow[0] ?? now;
  const retryAfterMs = Math.max(WINDOW_MS - (now - oldest), 1000);
  requestLog.set(clientKey, withinWindow);
  return { limited: true, retryAfterSec: Math.ceil(retryAfterMs / 1000) };
}

function formatHistoryForPrompt(history: ChatHistoryItem[]) {
  return history
    .filter((item) => item.content?.trim() && (item.role === "user" || item.role === "assistant"))
    .slice(-8)
    .map((item) => `${item.role === "user" ? "Kullanıcı" : "Asistan"}: ${item.content!.trim()}`)
    .join("\n");
}

async function askGemini(
  message: string,
  apiKey: string,
  history: ChatHistoryItem[],
  petContext: string,
) {
  const model = getGeminiModel();
  const historyBlock = formatHistoryForPrompt(history);
  const prompt = [
    PATIDOSTU_SYSTEM,
    petContext ? `\n${petContext}` : "",
    historyBlock ? `\nÖnceki konuşma:\n${historyBlock}` : "",
    `\nKullanıcı mesajı: ${message}`,
  ]
    .filter(Boolean)
    .join("\n");

  const res = await fetch(
    `https://generativelanguage.googleapis.com/v1beta/models/${model}:generateContent?key=${apiKey}`,
    {
      method: "POST",
      headers: { "Content-Type": "application/json" },
      body: JSON.stringify({
        contents: [{ parts: [{ text: prompt }] }],
        generationConfig: {
          temperature: 0.55,
          maxOutputTokens: getMaxOutputTokens(),
          topP: 0.9,
          thinkingConfig: {
            thinkingBudget: getThinkingBudget(),
          },
        },
      }),
    },
  );

  if (!res.ok) {
    const errText = await res.text().catch(() => "");
    throw new Error(`Gemini isteği başarısız: ${res.status} ${errText.slice(0, 120)}`);
  }

  const data = (await res.json()) as {
    candidates?: Array<{
      content?: { parts?: Array<{ text?: string }> };
    }>;
  };

  const text = data.candidates?.[0]?.content?.parts?.[0]?.text?.trim();
  if (!text) {
    throw new Error("Gemini boş yanıt döndürdü.");
  }

  return text;
}

export async function GET(req: Request) {
  const { searchParams } = new URL(req.url);
  const petId = searchParams.get("petId") ?? undefined;
  const pet = await fetchPetPersonaSummary(petId);

  return NextResponse.json({
    assistant: "Pati Dostu",
    tagline: buildPersonalizedTagline(pet),
    welcome: buildPersonalizedWelcome(pet),
    suggestions: buildPersonalizedSuggestions(pet),
    disclaimer: PATIDOSTU_DISCLAIMER,
    subtitle: PATIDOSTU_TAGLINE,
  });
}

export async function POST(req: Request) {
  try {
    const body = (await req.json()) as ChatRequest;
    const message = (body.message ?? "").trim();
    const history = Array.isArray(body.history) ? body.history : [];
    const petId = typeof body.petId === "string" ? body.petId.trim() : undefined;

    if (!message) {
      return NextResponse.json({ error: "Mesaj boş olamaz." }, { status: 400 });
    }

    if (message.length > getMaxInputChars()) {
      return NextResponse.json(
        { error: `Mesaj en fazla ${getMaxInputChars()} karakter olabilir.` },
        { status: 400 },
      );
    }

    const now = Date.now();
    const clientKey = getClientKey(req);
    const limit = getRateLimitState(clientKey, now);
    if (limit.limited) {
      return NextResponse.json(
        { error: `Mesaj sınırına ulaştın. Lütfen ${limit.retryAfterSec} saniye sonra tekrar dene.` },
        { status: 429 },
      );
    }

    const petContext = await buildActivePetContext(petId);
    const geminiApiKey = process.env.GEMINI_API_KEY?.replace(/^["']|["']$/g, "");
    let reply: string;
    if (geminiApiKey && !isDailyGeminiQuotaExceeded()) {
      try {
        incrementDailyGeminiCount();
        reply = await askGemini(message, geminiApiKey, history, petContext);
      } catch {
        reply = buildReply(message);
      }
    } else if (geminiApiKey && isDailyGeminiQuotaExceeded()) {
      reply = `${buildReply(message)}\n\n(Bugünkü AI kotası doldu; yarın tekrar deneyebilirsin.)`;
    } else {
      reply = buildReply(message);
    }

    return NextResponse.json({ reply });
  } catch {
    return NextResponse.json({ error: "Yanıt üretilemedi." }, { status: 500 });
  }
}
