import { NextResponse } from "next/server";

type ChatHistoryItem = {
  role?: string;
  content?: string;
};

type ChatRequest = {
  message?: string;
  history?: ChatHistoryItem[];
};

const MODEL = "gemini-1.5-flash";
const MAX_INPUT_CHARS = 500;
const MAX_REQUESTS_PER_WINDOW = 10;
const WINDOW_MS = 60 * 1000;
const requestLog = new Map<string, number[]>();

const SUGGESTIONS = [
  "Kedim bugün çok iştahsız, ne yapmalıyım?",
  "Köpeklerde aşı sonrası halsizlik normal mi?",
  "Yavru kuşların beslenme sıklığı nedir?",
];

const DISCLAIMER =
  "Bu yapay zeka tavsiyeleri profesyonel teşhis ile yer değiştiremez. Acil durumlarda lütfen en yakın veteriner kliniğine başvurun.";

function buildReply(input: string) {
  const text = input.toLowerCase();

  if (text.includes("kus") || text.includes("istah") || text.includes("iştah") || text.includes("halsiz")) {
    return "Belirtiyi günlüğe tarih ve şiddet seviyesiyle kaydet. Kusma/iştahsızlık 24 saati aşarsa veya halsizlik artarsa veterinerle görüşmeni öneririm.";
  }

  if (text.includes("tüy") || text.includes("tüy") || text.includes("dökül") || text.includes("dokul")) {
    return "Tüy dökülmesinde önce beslenme kalitesini, su tüketimini ve parazit kontrolünü gözden geçir. Düzenli tarama yap, ani bölgesel açılma/kaşıntı varsa mantar veya alerji ihtimali için veteriner kontrolü planla.";
  }

  if (text.includes("asi") || text.includes("aşı") || text.includes("randevu") || text.includes("takvim")) {
    return "Takvim sayfasından yeni hatırlatıcı ekleyip tarih-saat belirtebilirsin. Önemli aşıları bir hafta önceden hatırlatacak şekilde planlamak iyi olur.";
  }

  if (text.includes("kuduz")) {
    return "Kuduz aşısı takibini takvimde düzenli tut. Son uygulama tarihi, tekrar dozu ve veteriner önerisine göre gecikmeden randevu planlamanı öneririm.";
  }

  if (text.includes("mama") || text.includes("beslen") || text.includes("kalori") || text.includes("öğün")) {
    return "Beslenme tablosunda öğün saatlerini düzenli tutup porsiyonu kiloya göre ayarlamak önemli. Ani mama değişimlerini kademeli yapmanı öneririm.";
  }

  if (text.includes("yemek")) {
    return "Yemek düzeninde aynı saatleri korumak sindirimi destekler. İştah azalması, kusma veya dışkıda belirgin değişim olursa günlük kayda alıp veterinerle paylaş.";
  }

  if (text.includes("kuş") || text.includes("kus ") || text.includes("yavru")) {
    return "Yavru kuşlarda kısa aralıklarla az miktarda mama vermek daha güvenlidir. Sıcaklık, dışkı ve aktivite değişimlerini günlük kayda al; belirgin halsizlikte veterinere danış.";
  }

  if (text.includes("genel muayene") || text.includes("muayene") || text.includes("kontrol")) {
    return "Genel muayene için yılda en az 1 rutin kontrol iyi bir pratiktir. Yaşlı veya kronik rahatsızlığı olan dostlarda kontrol sıklığı veteriner önerisine göre artırılabilir.";
  }

  if (text.includes("su") || text.includes("tuvalet") || text.includes("idrar")) {
    return "Su tüketimini günlük takip et. Su içme azalırsa veya idrar alışkanlığı değişirse bu durumu belirti günlüğüne not edip veterinerle paylaş.";
  }

  if (text.includes("merhaba") || text.includes("selam") || text.includes("nasılsın")) {
    return "Merhaba! İyiyim, teşekkür ederim. Evcil hayvan bakımı, uygulama kullanımı veya genel bir konuda sorunu yazabilirsin.";
  }

  if (text.includes("teşekkür") || text.includes("sag ol") || text.includes("sağ ol")) {
    return "Rica ederim! Başka bir konuda da yardımcı olabilirim.";
  }

  return "Bu konuda genel bir yönlendirme yapabilirim. Sorunu biraz daha detaylandırırsan daha net ve faydalı bir yanıt verebilirim.";
}

function getClientKey(req: Request) {
  const forwarded = req.headers.get("x-forwarded-for");
  if (forwarded) {
    return forwarded.split(",")[0]?.trim() || "unknown";
  }
  return req.headers.get("x-real-ip") || "unknown";
}

function getRateLimitState(clientKey: string, now: number) {
  const existing = requestLog.get(clientKey) ?? [];
  const withinWindow = existing.filter((ts) => now - ts < WINDOW_MS);
  if (withinWindow.length < MAX_REQUESTS_PER_WINDOW) {
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

async function askGemini(message: string, apiKey: string, history: ChatHistoryItem[]) {
  const historyBlock = formatHistoryForPrompt(history);
  const prompt = [
    "Sen Türkçe konuşan Pati Dostu adlı bir evcil hayvan bakım asistansın.",
    "Evcil hayvan sağlığı, beslenme, aşı takibi ve uygulama kullanımında yardımcı ol.",
    "Kısa, sıcak, güvenli ve pratik öneriler ver (en fazla 3-4 cümle).",
    "Tıbbi teşhis koyma; acil risk varsa veterinere yönlendir.",
    historyBlock ? `\nÖnceki konuşma:\n${historyBlock}` : "",
    `\nKullanıcı mesajı: ${message}`,
  ]
    .filter(Boolean)
    .join("\n");

  const res = await fetch(
    `https://generativelanguage.googleapis.com/v1beta/models/${MODEL}:generateContent?key=${apiKey}`,
    {
      method: "POST",
      headers: { "Content-Type": "application/json" },
      body: JSON.stringify({
        contents: [{ parts: [{ text: prompt }] }],
        generationConfig: {
          temperature: 0.5,
          maxOutputTokens: 280,
          topP: 0.9,
        },
      }),
    },
  );

  if (!res.ok) {
    throw new Error(`Gemini isteği başarısız: ${res.status}`);
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

export async function GET() {
  return NextResponse.json({
    assistant: "Pati Dostu",
    suggestions: SUGGESTIONS,
    disclaimer: DISCLAIMER,
  });
}

export async function POST(req: Request) {
  try {
    const body = (await req.json()) as ChatRequest;
    const message = (body.message ?? "").trim();
    const history = Array.isArray(body.history) ? body.history : [];

    if (!message) {
      return NextResponse.json({ error: "Mesaj boş olamaz." }, { status: 400 });
    }

    if (message.length > MAX_INPUT_CHARS) {
      return NextResponse.json({ error: `Mesaj en fazla ${MAX_INPUT_CHARS} karakter olabilir.` }, { status: 400 });
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

    const geminiApiKey = process.env.GEMINI_API_KEY;
    let reply: string;
    if (geminiApiKey) {
      try {
        reply = await askGemini(message, geminiApiKey, history);
      } catch {
        reply = buildReply(message);
      }
    } else {
      reply = buildReply(message);
    }

    return NextResponse.json({ reply });
  } catch {
    return NextResponse.json({ error: "Yanıt üretilemedi." }, { status: 500 });
  }
}
