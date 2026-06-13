# PetTrack — Tech Stack

> Hangi teknolojiler kullanıldı, neden seçildi ve yapay zeka hem **üründe** hem **geliştirmede** nasıl devreye girdi.

---

## Mimari özeti

```
┌──────────────────────────────────────────────────────────────┐
│                        İstemciler                            │
├─────────────────────────┬────────────────────────────────────┤
│  frontend/ (1575)       │  frontend/mobile/ (Flutter)        │
│  Next.js · React 19     │  iOS Simulator · Android Emulator  │
└────────────┬────────────┴─────────────────┬──────────────────┘
             │  fetch(apiUrl("/api/..."))   │  ApiService → HTTP
             └──────────────┬───────────────┘
                            ▼
             ┌──────────────────────────────┐
             │  backend/ (1571)             │
             │  Next.js Route Handlers      │
             │  Prisma 7 · middleware CORS  │
             └──────────────┬───────────────┘
                            │
              ┌─────────────┴─────────────┐
              ▼                           ▼
        PostgreSQL                  Google Gemini API
   (yerel / Docker / Neon)     (Pati Dostu asistanı)
```

---

## Katman tablosu

| Katman | Teknoloji | Port | Rol |
|--------|-----------|------|-----|
| **Web arayüz** | Next.js 16, React 19, Tailwind CSS 4, Lucide React | 1575 | SSR/CSR sayfalar, AppShell navigasyon |
| **REST API** | Next.js Route Handlers, TypeScript | 1571 | CRUD, dosya yükleme, AI proxy |
| **ORM** | Prisma 7 | — | Tip güvenli DB erişimi |
| **Veritabanı** | PostgreSQL 15+ | 5432 / 5433 | Kalıcı veri |
| **Mobil** | Flutter 3.x, Dart | — | iOS & Android tek kod tabanı |
| **AI (ürün)** | Google Gemini `gemini-2.5-flash` | — | Pati Dostu sohbet |
| **AI (geliştirme)** | Cursor + ajan kuralları | — | Kod üretimi, refaktör |
| **Opsiyonel** | FastAPI (`backend/py/`) | 1572 | Diary / ek AI katmanı (kullanılmıyorsa kapalı) |

---

## Seçim gerekçeleri

| Karar | Neden? |
|-------|--------|
| **npm workspaces monorepo** | `frontend/` ve `backend/` bağımsız deploy; tek `npm run dev` ile geliştirme |
| **Next.js Route Handlers** | Tek dil (TypeScript), Vercel uyumu, hızlı REST API |
| **Prisma + PostgreSQL** | Şema-first, migration, Neon ile canlı deploy |
| **Flutter (SwiftUI yerine)** | Tek kod → iOS + Android; MVP hızı; PRD sapması bilinçli |
| **Gemini (OpenRouter alternatifi)** | Ücretsiz tier, Türkçe kalitesi, basit REST |
| **API key sunucuda** | `GEMINI_API_KEY` yalnız `backend/.env` — istemciye sızmaz |

---

## Pati Dostu — AI entegrasyonu (ürün)

### Akış

1. Kullanıcı web veya mobilde mesaj yazar
2. İstemci `POST /api/chat` — `{ message, history, petId? }`
3. Backend `buildActivePetContext(petId)` ile Prisma'dan pet + son belirtiler + aşılar + öğünler okur
4. `PATIDOSTU_SYSTEM` + pet bağlamı + geçmiş → Gemini `generateContent`
5. Yanıt JSON `{ reply }` olarak döner

### Dosyalar

| Dosya | Rol |
|-------|-----|
| `backend/app/api/chat/route.ts` | POST/GET handler, kota, Gemini çağrısı |
| `backend/lib/pati-dostu-prompt.ts` | System prompt, kişiselleştirme, pet bağlamı |
| `frontend/app/assistant/page.tsx` | Web sohbet UI |
| `frontend/mobile/lib/screens/assistant_screen.dart` | Mobil sohbet UI |

### Kota & güvenlik

| Ayar | Varsayılan | Env |
|------|------------|-----|
| Günlük Gemini çağrısı | 15 | `GEMINI_MAX_DAILY_REQUESTS` |
| Dakikada istek (IP) | 4 | `GEMINI_MAX_REQUESTS_PER_MINUTE` |
| Mesaj uzunluğu | 500 karakter | `GEMINI_MAX_INPUT_CHARS` |
| Yanıt token | 640 | `GEMINI_MAX_OUTPUT_TOKENS` |
| Thinking budget | 0 (kapalı) | `GEMINI_THINKING_BUDGET` |

> **Önemli:** Gemini 2.5 Flash varsayılan "thinking" modu `maxOutputTokens` içinden yer kaplar; `thinkingBudget: 0` ile kapatıldı — aksi halde yanıtlar yarım kalır.

### Fallback

API key yok, kota dolmuş veya Gemini hata verirse → `buildReply()` anahtar kelime tabanlı Türkçe yanıt.

---

## Geliştirmede yapay zeka kullanımı

| Aşama | Nasıl? |
|-------|--------|
| **Planlama** | PRD + Plan.md referans; Cursor Agent ile adım adım |
| **Kod üretimi** | `prodocs/agent/rules/` — workspace, react, backend-api, responsive kuralları |
| **UI tutarlılığı** | DesignSystem.md + mevcut bileşen dili (teal/slate, rounded-2xl) |
| **Hata ayıklama** | Progress.md kayıtları; env checklist (DATABASE_URL, CORS, GEMINI) |
| **Dokümantasyon** | prodocs/ klasörü; her sprint sonu Progress güncellemesi |

---

## Ortam değişkenleri

Şablon: kök [`.env.example`](../.env.example)

| Değişken | Paket | Zorunlu |
|----------|-------|---------|
| `DATABASE_URL` | backend | ✅ |
| `FRONTEND_ORIGIN` | backend | ✅ (CORS) |
| `GEMINI_API_KEY` | backend | Pati Dostu için |
| `GEMINI_MODEL` | backend | Varsayılan: `gemini-2.5-flash` |
| `NEXT_PUBLIC_API_URL` | frontend | ✅ |
| `NEXT_PUBLIC_PY_API_URL` | frontend | Opsiyonel (py API) |

---

## Dağıtım (canlı)

| Bileşen | Platform | URL / Not |
|---------|----------|-----------|
| `frontend/` | Vercel `pettrack-frontend` | https://pettrack-frontend.vercel.app |
| `backend/` | Vercel `pettrack-backend` | https://pettrack-backend.vercel.app |
| PostgreSQL | Neon `pettrack-db` | eu-central-1 · `prisma db push` |
| Profil fotoğrafları | Vercel Blob | Storage → backend projesine bağla |
| `frontend/mobile/` | TestFlight / APK | `NEXT_PUBLIC_API_URL` = canlı backend |

Rehber: [`DEPLOY-vercel.md`](./DEPLOY-vercel.md)

Build: `DATABASE_URL="..." npm run build` (backend import anında doğrular)

---

## PRD sapmaları (bilinçli)

| PRD taslağı | Gerçek uygulama |
|-------------|-----------------|
| iOS native (SwiftUI) | Flutter + Next.js web |
| `/api/vaccinations` | `/api/calendar` |
| PDF belirti export | CSV export |
| Gelişmiş AI tanı | Pati Dostu tavsiye asistanı (Gemini) |

Detay: [`Progress.md`](./Progress.md)
