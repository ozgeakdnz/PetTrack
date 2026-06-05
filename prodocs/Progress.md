# PetTrack — Progress Log

> Yapılan işler, alınan kararlar, karşılaşılan hatalar ve bilinen sapmalar.  
> Her anlamlı sprint sonunda bu dosya güncellenir.

---

## Durum özeti (6 Haziran 2026)

| Alan | Durum |
|------|-------|
| Backend API | ✅ Tamamlandı |
| Web arayüz | ✅ Tamamlandı |
| Mobil (Flutter) | ✅ Tamamlandı |
| Pati Dostu AI (Gemini) | ✅ Tamamlandı |
| Dokümantasyon (prodocs) | ✅ Güncellendi |
| Canlı deploy | ⏳ Bekliyor |

---

## 2026-05-03 — Proje kickoff

- **Karar:** 8 haftalık teslim kapsamında evcil hayvan sağlık takibi ürünü geliştirilecek.
- **Yapıldı:** İlk PRD taslağı (`prodocs/PRD.md`) — problem tanımı, hedef kullanıcı, MVP özellikleri.
- **Yapıldı:** Repo oluşturuldu; `prodocs/` zorunlu belge klasörü açıldı.

---

## 2026-05-07 — Marka ve monorepo

- **Marka:** "Vet-Health" → **PetTrack**.
- **Karar:** Teslim gereksinimine uygun klasör yapısı: `frontend/`, `backend/`, `prodocs/`.
- **Yapıldı:** npm workspaces; kök `npm run dev` her iki paketi başlatır.
- **Portlar:** Web **1575** · API **1571** · Python API **1572**.
- **Yapıldı:** `frontend/lib/api.ts` — `NEXT_PUBLIC_API_URL` zorunlu.
- **Yapıldı:** `backend/middleware.ts` — `FRONTEND_ORIGIN` CORS.

---

## 2026-05-11 — Backend iskelet & Prisma

- **Yapıldı:** `backend/prisma/schema.prisma` — Pet, Vaccination, SymptomLog, Nutrition modelleri.
- **Yapıldı:** İlk API route'ları: `/api/pets`, `/api/calendar`, `/api/symptoms`, `/api/nutrition`.
- **Yapıldı:** `backend-py/` → `backend/py/` (FastAPI diary servisi, opsiyonel).
- **Yapıldı:** AI ajan referansları `prodocs/agent/` altına taşındı.

---

## 2026-05-14 — Veritabanı kurulumu

- **Problem:** "Evcil hayvan oluşturulamadı" — `DATABASE_URL` placeholder, tablolar yoktu.
- **Çözüm:** `pettrack` PostgreSQL veritabanı oluşturuldu; Prisma init migration uygulandı.
- **Env:** `backend/.env` → yerel Homebrew PostgreSQL.
- **Ek:** `backend/docker-compose.yml` (isteğe bağlı Docker PostgreSQL, port 5433).

---

## 2026-05-18 — Web arayüzü (1. dalga)

- **Yapıldı:** AppShell sidebar + mobil hamburger menü.
- **Yapıldı:** Hayvan profilleri sayfası (`/pets`) — liste, ekleme, düzenleme.
- **Yapıldı:** Takvim sayfası (`/calendar`) — aylık görünüm, hatırlatıcı ekleme.
- **Yapıldı:** DesignSystem taslağı — teal/slate paleti, `rounded-2xl` kart dili.

---

## 2026-05-22 — Web arayüzü (2. dalga)

- **Yapıldı:** Sağlık günlüğü (`/symptoms`) — belirti listesi, şiddet seviyesi, CSV export.
- **Yapıldı:** Beslenme (`/nutrition`) — diyet hedefleri, öğün planlayıcı.
- **Yapıldı:** `/api/symptoms/export`, `/api/uploads` (profil fotoğrafı).
- **Yapıldı:** `mobile/` → `frontend/mobile/` taşınması planlandı ve başlatıldı.

---

## 2026-05-26 — Mobil Flutter (1. dalga)

- **Yapıldı:** Flutter proje iskeleti; tema (`app_colors.dart`, `app_theme.dart`).
- **Yapıldı:** `ApiService` — pets, calendar, symptoms, nutrition uçları.
- **Yapıldı:** Profil ve takvim ekranları.
- **Yapıldı:** Alt navigasyon (`PtBottomNav`) + `MainShell`.

---

## 2026-05-29 — Mobil Flutter (2. dalga)

- **Yapıldı:** Sağlık günlüğü ve beslenme ekranları.
- **Yapıldı:** `ActivePetScope` — pet değişince API çağrıları güncellenir.
- **Yapıldı:** `PtHeader` — aktif pet avatar tüm sayfalarda.
- **Yapıldı:** Tür bazlı varsayılan avatar (kedi / köpek / kuş).
- **Problem:** iOS layout taşması (Column + IndexedStack).
- **Çözüm:** `MainShell` yapısı düzeltildi; `Expanded` + `IndexedStack`.

---

## 2026-06-01 — UX iyileştirmeleri (web + mobil)

- **Yapıldı:** Aktif pet context (`active-pet-context.tsx`) + localStorage (web).
- **Yapıldı:** Sayfa bazlı aktif pet rozeti (pill: foto, ad, kilo • yaş).
- **Karar:** Global navbar'dan aktif pet kaldırıldı; her sayfa kendi rozetini gösterir.
- **Yapıldı:** Profil silme (web + mobil).
- **Yapıldı:** Öğün görselleri (`meal_dry`, `meal_wet`, `meal_evening`).
- **Yapıldı:** Takvim — Bekliyor / Tamamlandı durumları.
- **Yapıldı:** `/api/nutrition/summary`, `/api/pets/[id]/summary`.

---

## 2026-06-03 — Pati Dostu AI (Gemini)

- **Yapıldı:** `backend/app/api/chat/route.ts` — POST sohbet, GET meta.
- **Yapıldı:** `backend/lib/pati-dostu-prompt.ts` — system prompt, pet bağlamı, kişiselleştirme.
- **Yapıldı:** Gemini entegrasyonu (`GEMINI_API_KEY`, `gemini-2.5-flash`).
- **Yapıldı:** Web `/assistant` — iki sütun layout, hızlı sorular, sohbet geçmişi (localStorage).
- **Yapıldı:** Mobil `assistant_screen.dart` — aynı API.
- **Yapıldı:** Kişiselleştirilmiş karşılama, tagline, tür bazlı hızlı sorular.
- **Yapıldı:** Kota: günlük 15, dakikada 4, mesaj 500 karakter.
- **Yapıldı:** Keyword fallback (`buildReply`) — API yoksa veya hata.

---

## 2026-06-05 — AI yanıt kalitesi düzeltmeleri

### Hata: Yarım AI yanıtları

- **Belirti:** "Köpeğim halsiz..." sorusuna cümle ortasında kesik yanıt.
- **Kök neden 1:** `maxOutputTokens=280` çok düşüktü.
- **Kök neden 2:** Gemini 2.5 Flash "thinking" token'ları `maxOutputTokens` içinden düşüyordu.
- **Çözüm:** `GEMINI_MAX_OUTPUT_TOKENS=640`, `GEMINI_THINKING_BUDGET=0`.
- **Ek:** System prompt — "yarım cümle verme, 4–6 tam cümle".

### Hata: Eski model

- **Problem:** `gemini-2.0-flash` 1 Haziran 2026'da kapatıldı.
- **Çözüm:** Varsayılan model `gemini-2.5-flash`.

---

## 2026-06-06 — Dokümantasyon yenileme

- **Yapıldı:** PRD, tech-stack, Plan, DesignSystem, Progress, README, `.env.example` güncellendi.
- **Yapıldı:** Gerçek repo durumu yansıtıldı (Flutter, Gemini, calendar API).
- **Yapıldı:** Teslim kriterleri eşlemesi PRD'ye eklendi.

---

## Bilinen sapmalar (PRD ↔ repo)

| PRD taslağı | Repo | Gerekçe |
|-------------|------|---------|
| iOS native (SwiftUI) | Flutter + Next.js web | MVP hızı, çift platform |
| `/api/vaccinations` | `/api/calendar` | Aynı Vaccination modeli |
| Belirti export PDF | CSV export | MVP basitlik |
| Gelişmiş AI tanı | Pati Dostu tavsiye asistanı | Teşhis koymaz, yönlendirir |
| Push notification | Yok | Faz 2 |
| Auth / JWT | Sabit ownerId | Faz 2 |

---

## Sonraki adımlar

- [ ] **Canlı deploy** — Vercel (frontend + backend) + Supabase/Neon PostgreSQL
- [ ] Canlı URL'yi README'ye ekle
- [ ] `ownerId` erişim kontrolleri
- [ ] Auth (Apple Sign-In / JWT) — Faz 2
- [ ] Push hatırlatıcıları — Faz 2
- [ ] E2E testler (isteğe bağlı)

---

## Env checklist (geliştirici)

```bash
# backend/.env
DATABASE_URL=postgresql://...
FRONTEND_ORIGIN=http://localhost:1575
GEMINI_API_KEY=...
GEMINI_MODEL=gemini-2.5-flash
GEMINI_MAX_DAILY_REQUESTS=15
GEMINI_MAX_OUTPUT_TOKENS=640
GEMINI_THINKING_BUDGET=0

# frontend/.env
NEXT_PUBLIC_API_URL=http://localhost:1571
```

`.env` değişince → `npm run dev` yeniden başlat.
