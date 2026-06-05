# PetTrack — Yürütme Planı

> PRD'den türetilmiş teknik adımlar, user story eşlemesi ve **tamamlanma durumu**.  
> LLM veya geliştirici bu sırayla ilerleyebilir.

**Kaynak:** [`PRD.md`](./PRD.md) · **İlerleme:** [`Progress.md`](./Progress.md)

---

## 1. Bağlam özeti

| Konu | Hedef | Durum |
|------|-------|-------|
| Ürün kapsamı | Profil, takvim, belirti, beslenme, AI asistan | ✅ |
| Web istemci | Next.js, port 1575 | ✅ |
| Mobil istemci | Flutter iOS/Android | ✅ |
| Backend API | Next.js Route Handlers, port 1571 | ✅ |
| Veritabanı | PostgreSQL + Prisma | ✅ |
| AI (Gemini) | `/api/chat` — Pati Dostu | ✅ |
| Canlı deploy | Vercel + Supabase | ⏳ |

**Monorepo:** Kök `npm run dev` → backend (1571) + frontend (1575) birlikte.  
**API bağlantısı:** `frontend/lib/api.ts` → `NEXT_PUBLIC_API_URL` · CORS: `backend/middleware.ts`

---

## 2. Kod haritası

### Backend (`backend/`)

| Yol | Rol |
|-----|-----|
| `prisma/schema.prisma` | Veri modeli |
| `lib/prisma.ts` | DB istemcisi |
| `lib/pati-dostu-prompt.ts` | AI prompt & kişiselleştirme |
| `app/api/pets/**` | Hayvan CRUD + özet |
| `app/api/calendar/**` | Aşı & randevu |
| `app/api/symptoms/**` | Belirti + CSV export |
| `app/api/nutrition/**` | Beslenme + summary |
| `app/api/uploads/route.ts` | Fotoğraf yükleme |
| `app/api/chat/route.ts` | Pati Dostu (Gemini) |
| `middleware.ts` | CORS |

### Frontend web (`frontend/`)

| Yol | Rol |
|-----|-----|
| `app/pets/page.tsx` | Hayvan profilleri |
| `app/calendar/page.tsx` | Takvim |
| `app/symptoms/page.tsx` | Sağlık günlüğü |
| `app/nutrition/page.tsx` | Beslenme |
| `app/assistant/page.tsx` | Pati Dostu AI |
| `components/app-shell.tsx` | Sidebar navigasyon |
| `components/active-pet-avatar.tsx` | Aktif pet rozeti |
| `lib/active-pet-context.tsx` | Aktif pet state |
| `lib/api.ts` | API base URL |

### Mobil (`frontend/mobile/`)

| Yol | Rol |
|-----|-----|
| `screens/profile_screen.dart` | Profiller |
| `screens/calendar_screen.dart` | Takvim |
| `screens/health_diary_screen.dart` | Belirti |
| `screens/nutrition_screen.dart` | Beslenme |
| `screens/assistant_screen.dart` | Pati Dostu |
| `services/api_service.dart` | HTTP istemci |
| `state/active_pet_scope.dart` | Aktif pet |
| `widgets/pt_header.dart` | Üst bar + avatar |

---

## 3. Yürütme adımları

### Adım 0 — Ortam kurulumu

- [x] Node 20+, npm workspaces
- [x] PostgreSQL + `DATABASE_URL`
- [x] `npm run prisma:generate` && `prisma:migrate`
- [x] `.env.example` şablonu
- **Bitti:** `npm run dev` ile web + API ayakta

### Adım 1 — Backend API

- [x] Pet CRUD (`/api/pets`, `/api/pets/[id]`)
- [x] Takvim (`/api/calendar`) — PRD'deki vaccinations yerine
- [x] Belirti (`/api/symptoms`, export)
- [x] Beslenme (`/api/nutrition`, summary)
- [x] Upload (`/api/uploads`)
- [x] Chat (`/api/chat`) — Gemini
- [x] CORS middleware
- **Bitti:** REST checklist PRD §6 ile uyumlu

### Adım 2 — Frontend web

- [x] AppShell + 5 sayfa
- [x] Aktif pet context + sayfa bazlı rozet
- [x] API entegrasyonu (`apiUrl`)
- [x] Pati Dostu sohbet + hızlı sorular
- **Bitti:** Tüm modüller canlı API ile çalışır

### Adım 3 — Mobil Flutter

- [x] 5 ekran + alt navigasyon
- [x] ApiService → backend
- [x] Aktif pet scope
- [x] PtHeader avatar tüm sayfalarda
- [x] Pati Dostu ekranı + kişiselleştirilmiş meta
- [x] Profil silme, tür bazlı varsayılan avatar
- **Bitti:** iOS simülatörde uçtan uca akış

### Adım 4 — EPIC 1: Hayvan profili (US 1.1–1.3)

- [x] US 1.1 — Yeni hayvan ekleme (web + mobil)
- [x] US 1.2 — Aktif pet seçimi
- [x] US 1.3 — Profil silme
- [x] Fotoğraf yükleme + species fallback avatar
- **Bitti:** Çoklu pet desteği

### Adım 5 — EPIC 2: Aşı & randevu (US 2.1)

- [x] Hatırlatıcı ekleme / düzenleme
- [x] Bekliyor / Tamamlandı durumu
- [x] Aylık takvim görünümü
- **Bitti:** Takvim modülü

### Adım 6 — EPIC 3: Belirti & beslenme (US 3.1–3.3)

- [x] Belirti CRUD + şiddet seviyesi
- [x] CSV export
- [x] Beslenme planı + öğün onaylama
- [x] Diyet hedefleri & kalori
- **Bitti:** Sağlık + beslenme modülleri

### Adım 7 — EPIC 4: Pati Dostu AI (US 4.1–4.2)

- [x] Gemini entegrasyonu (`GEMINI_API_KEY`)
- [x] Pet bağlamlı prompt (belirti, aşı, öğün)
- [x] Kişiselleştirilmiş karşılama & hızlı sorular
- [x] Kota limitleri (günlük/dakika/token)
- [x] Thinking budget kapatma (yarım yanıt fix)
- [x] Web + mobil aynı API
- **Bitti:** AI çekirdek özellik olarak entegre

### Adım 8 — Kimlik & güvenlik (MVP sınırlı)

- [ ] `ownerId` tutarlılık denetimi
- [ ] Başka owner'ın petId'sine erişim engeli
- [ ] Auth (JWT / Apple Sign-In) — Faz 2
- **Durum:** MVP'de sabit ownerId; Faz 2'ye ertelendi

### Adım 9 — Kalite & dokümantasyon

- [x] ESLint (frontend + backend)
- [x] prodocs/ zorunlu belgeler
- [x] README onepager
- [x] Progress.md güncel
- **Bitti:** Teslim dokümantasyonu hazır

### Adım 10 — Canlı deploy

- [ ] Supabase / Neon PostgreSQL
- [ ] Vercel: backend projesi
- [ ] Vercel: frontend projesi (`NEXT_PUBLIC_API_URL`)
- [ ] `prisma migrate deploy`
- [ ] Canlı URL README'ye ekle
- **Durum:** ⏳ Bekliyor — teslim için kritik

---

## 4. PRD endpoint uyumluluk tablosu

| PRD taslağı | Repo | Not |
|-------------|------|-----|
| `GET /api/vaccinations` | `GET /api/calendar?petId=` | Aynı model |
| `POST /api/vaccinations` | `POST /api/calendar` | — |
| — | `GET /api/chat` | AI meta (PRD sonrası) |
| — | `POST /api/chat` | AI sohbet (PRD sonrası) |
| — | `DELETE /api/pets/[id]` | Silme (PRD sonrası) |

---

## 5. Kapsam dışı — bu plana ekleme

PRD §9: marketplace, IoT, otomatik teşhis motoru, enterprise RBAC.

---

## 6. LLM geliştirici ipuçları

1. API değişikliği → önce `schema.prisma`, sonra route, sonra frontend/mobile
2. Asla `frontend/` içinde Prisma kullanma
3. Fetch her zaman `apiUrl("/api/...")` — göreli `/api` yok
4. Pati Dostu değişikliği → `pati-dostu-prompt.ts` + `chat/route.ts`
5. `.env` değişince backend restart gerekir
6. Her sprint → `Progress.md` güncelle
