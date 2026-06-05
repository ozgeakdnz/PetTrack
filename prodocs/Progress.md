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

## 2026-06-05 — Repo yapısı ve teslim düzeni

- **Karar:** Teslim gereksinimine uygun klasör yapısı: `frontend/`, `backend/`, `prodocs/`.
- **Yapıldı:** `mobile/` → `frontend/mobile/` (Flutter iOS/Android).
- **Yapıldı:** `backend-py/` → `backend/py/` (FastAPI diary servisi).
- **Yapıldı:** Zorunlu dokümanlar `prodocs/` altında.
- **Yapıldı:** AI ajan referansları `prodocs/agent/` altına taşındı.

---

## 2026-06-05 — Veritabanı kurulumu

- **Problem:** "Evcil hayvan oluşturulamadı" — `DATABASE_URL` placeholder, tablolar yoktu.
- **Çözüm:** `pettrack` PostgreSQL veritabanı; Prisma migration `20260605164016_init`.
- **Env:** `backend/.env` → yerel Homebrew PostgreSQL.
- **Ek:** `backend/docker-compose.yml` (Docker PostgreSQL, port 5433).

---

## 2026-06-05 — Marka ve port

- **Marka:** "Vet-Health" → **PetTrack**.
- **Portlar:** Web **1575** · API **1571** · Python API **1572**.

---

## 2026-06-05 — Monorepo & CORS

- **Yapıldı:** npm workspaces; kök `npm run dev` her iki paketi başlatır.
- **Yapıldı:** `frontend/lib/api.ts` — `NEXT_PUBLIC_API_URL` zorunlu.
- **Yapıldı:** `backend/middleware.ts` — `FRONTEND_ORIGIN` CORS.

---

## 2026-06-06 — Web modülleri

- **Yapıldı:** Hayvan profilleri, takvim, belirti günlüğü, beslenme sayfaları.
- **Yapıldı:** AppShell sidebar + mobil hamburger.
- **Yapıldı:** Aktif pet context (`active-pet-context.tsx`) + localStorage.
- **Yapıldı:** Sayfa bazlı aktif pet rozeti (pill: foto, ad, kilo • yaş).
- **Yapıldı:** Profil silme (üstte tek "Profili Sil" butonu).
- **Karar:** Global navbar'dan aktif pet kaldırıldı; her sayfa kendi rozetini gösterir.

---

## 2026-06-06 — Mobil Flutter entegrasyonu

- **Yapıldı:** 5 ekran — profil, takvim, sağlık, beslenme, asistan.
- **Yapıldı:** `ApiService` → tüm backend uçları.
- **Yapıldı:** `ActivePetScope` — pet değişince API çağrıları güncellenir.
- **Yapıldı:** `PtHeader` — aktif pet avatar tüm sayfalarda.
- **Yapıldı:** Tür bazlı varsayılan avatar (kedi/köpek/kuş).
- **Yapıldı:** Profil fotoğrafı değiştirme + pet silme.
- **Problem:** iOS layout taşması (Column + IndexedStack).
- **Çözüm:** `MainShell` yapısı düzeltildi; `Expanded` + `IndexedStack`.

---

## 2026-06-06 — Beslenme & takvim UX

- **Yapıldı:** Diyet hedefleri, öğün planlayıcı (web + mobil).
- **Yapıldı:** Öğün görselleri (`meal_dry`, `meal_wet`, `meal_evening`).
- **Yapıldı:** Takvim hatırlatıcıları — Bekliyor / Tamamlandı.
- **Yapıldı:** Belirti şiddet seviyesi (Düşük / Orta / Yüksek).
- **Yapıldı:** `/api/nutrition/summary`, `/api/pets/[id]/summary`.

---

## 2026-06-06 — Pati Dostu AI (Gemini)

- **Yapıldı:** `backend/app/api/chat/route.ts` — POST sohbet, GET meta.
- **Yapıldı:** `backend/lib/pati-dostu-prompt.ts` — system prompt, pet bağlamı, kişiselleştirme.
- **Yapıldı:** Gemini `gemini-2.5-flash` entegrasyonu (`GEMINI_API_KEY`).
- **Yapıldı:** Web `/assistant` — iki sütun layout, hızlı sorular, sohbet geçmişi (localStorage).
- **Yapıldı:** Mobil `assistant_screen.dart` — aynı API.
- **Yapıldı:** Kişiselleştirilmiş karşılama, tagline, tür bazlı hızlı sorular.
- **Yapıldı:** Kota: günlük 15, dakikada 4, mesaj 500 karakter, çıktı 640 token.
- **Yapıldı:** Keyword fallback (`buildReply`) — API yoksa veya hata.

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
