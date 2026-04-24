# Pet Track — MVP Ürün Gereksinimleri Dokümanı

**Minimum Viable Product — Faz 1**  
**Kaynak:** `Teknik PRD_ Pet Track iOS.md` (Taslak v1) + mevcut repo (`frontend/`, `backend/`).  
**Durum:** Geliştirme / doğrulama (web pilot + API; iOS hedef PRD ile uyumlu olacak şekilde)

| Alan | Değer |
|------|--------|
| **Platform (PRD hedef)** | iOS native (SwiftUI) — TestFlight |
| **Platform (bu repo MVP pilot)** | Web uygulaması (responsive, mobile-first; `AppShell` + `md:` kırılımı) |
| **Frontend** | Next.js 16 (App Router) + React 19 + Tailwind CSS 4 + Lucide React |
| **Backend** | Next.js 16 Route Handlers (`backend/app/api/*`) — FastAPI **kullanılmıyor** |
| **Veritabanı** | PostgreSQL + Prisma ORM 7 (`@prisma/adapter-pg`) |
| **Kimlik (MVP)** | `ownerId` string alanı (PRD: basit sahiplik); JWT / Apple Sign-In Faz 2 |
| **AI (Pati Dostu)** | Hibrit: kural tabanlı `buildReply` + isteğe bağlı **Google Gemini** (`GEMINI_API_KEY`, model `gemini-1.5-flash`); yoksa yalnız kurallar |
| **Para birimi** | Uygulanmıyor (sağlık takibi; fiyatlandırma MVP dışı) |
| **Dil** | Arayüz ve API hata mesajları Türkçe öncelikli |
| **Monorepo** | Kök `npm` workspaces: `frontend` (port **1570**), `backend` (port **1571**) |
| **CORS** | `backend/middleware.ts` — `FRONTEND_ORIGIN` (varsayılan `http://localhost:1570`) |

---

## İçindekiler

1. [Mimari Karar Kayıtları (ADR)](#1-mimari-karar-kayıtları-adr)  
2. [Veri Modeli](#2-veri-modeli)  
3. [API Kontratı](#3-api-kontratı)  
4. [Ekran Kataloğu (Web MVP)](#4-ekran-kataloğu-web-mvp)  
5. [User Story’ler ve Kabul Kriterleri](#5-user-storyler-ve-kabul-kriterleri)  
6. [Definition of Done](#6-definition-of-done)  
7. [Hata ve Edge Case Kataloğu](#7-hata-ve-edge-case-kataloğu)  
8. [Pati Dostu / AI Katmanı](#8-pati-dostu--ai-katmanı)  
9. [Performans ve Güvenlik](#9-performans-ve-güvenlik)  
10. [Sprint Planı (Öneri)](#10-sprint-planı-öneri)  
11. [PRD ↔ Repo Sapma Notları](#11-prd--repo-sapma-notları)  
12. [MVP Felsefesi ve Kapsam Matrisi](#12-mvp-felsefesi-ve-kapsam-matrisi)  
13. [Sözlük](#13-sözlük)

---

## 1. Mimari Karar Kayıtları (ADR)

| ADR # | Konu | Karar | Gerekçe |
|-------|------|--------|---------|
| **ADR-001** | Monorepo | `frontend/` + `backend/` ayrı `package.json`, kök workspaces | Ödev ve ölçek için API ile UI ayrı çalıştırılabilir |
| **ADR-002** | Backend çatısı | Next.js Route Handlers (Python/FastAPI yok) | PRD §2 ile uyum; tek dil (TypeScript), Vercel’e uygun |
| **ADR-003** | ORM | Prisma 7 + `pg` Pool + `PrismaPg` adapter | PostgreSQL (Supabase) ile tip güvenli erişim |
| **ADR-004** | İstemci → API | `frontend/lib/api.ts` → `NEXT_PUBLIC_API_URL` (varsayılan `http://localhost:1571`) | Cross-origin; CORS middleware ile |
| **ADR-005** | Auth MVP | `ownerId` gövde/query; merkezi JWT yok | PRD MVP; Faz 2’de Apple Sign-In + JWT |
| **ADR-006** | Aşı / randevu API’si | PRD’de `/api/vaccinations` iken repo **`/api/calendar`** + `Vaccination` modeli | Takvim UI’si ile birleşik; iOS entegrasyonu için kontrat dokümante edilmeli |
| **ADR-007** | Belirti dışa aktarma | `GET /api/symptoms/export` → **CSV** (`text/csv`, `belirti-kayitlari.csv`) | UI metni “PDF” diyebilir; gerçek çıktı CSV |
| **ADR-008** | Dosya yükleme | `POST /api/uploads` → `backend/public/uploads/`, max tip kontrolü | Makbuz/görsel için; URL göreli `/uploads/...` |
| **ADR-009** | Chat | Rate limit: 5 istek / IP / 60 sn; Gemini varsa önce LLM, hata olunca `buildReply` | Maliyet ve kötüye kullanım sınırı |
| **ADR-010** | iOS | MVP web ile API doğrulanır; SwiftUI istemci ayrı milestone | PRD platform hedefi korunur |

---

## 2. Veri Modeli

Tüm birincil anahtarlar **UUID** (`@db.Uuid`). Zaman alanları Prisma `DateTime` (PostgreSQL `TIMESTAMPTZ` ile eşlenir). **Soft delete yok** (MVP); silme pet için `DELETE /api/pets/[id]` ile kalıcı.

### 2.1 Enum’lar

| Enum | Değerler |
|------|-----------|
| `Species` | `CAT`, `DOG`, `BIRD` |
| `Gender` | `MALE`, `FEMALE`, `UNKNOWN` |
| `VaccinationStatus` | `COMPLETED`, `PENDING` |
| `SymptomSeverity` | `LOW`, `MEDIUM`, `HIGH` |
| `MealStatus` | `COMPLETED`, `PENDING` |

### 2.2 Tablo: `Pet`

| Kolon | Tip (Prisma) | Kısıt / Not |
|-------|----------------|-------------|
| `id` | `String` `@id` `@default(uuid())` `@db.Uuid` | PK |
| `name` | `String` | NOT NULL |
| `species` | `Species` | NOT NULL |
| `breed` | `String?` | Opsiyonel |
| `imageUrl` | `String?` | Opsiyonel (URL) |
| `gender` | `Gender` | NOT NULL |
| `birthDate` | `DateTime?` | Opsiyonel |
| `weight` | `Float?` | Opsiyonel |
| `ownerId` | `String` | NOT NULL — MVP “sahiplik” |
| `vaccinations` | İlişki | `Vaccination[]` |
| `symptomLogs` | İlişki | `SymptomLog[]` |
| `nutritions` | İlişki | `Nutrition[]` |

### 2.3 Tablo: `Vaccination`

| Kolon | Tip | Kısıt / Not |
|-------|-----|-------------|
| `id` | UUID | PK |
| `petId` | UUID | FK → `Pet.id`, **onDelete: Cascade** |
| `name` | String | NOT NULL |
| `date` | DateTime | NOT NULL |
| `nextDate` | DateTime? | Opsiyonel |
| `status` | `VaccinationStatus` | NOT NULL |
| `notes` | String? | Opsiyonel |

### 2.4 Tablo: `SymptomLog`

| Kolon | Tip | Kısıt / Not |
|-------|-----|-------------|
| `id` | UUID | PK |
| `petId` | UUID | FK → `Pet`, Cascade |
| `symptom` | String | NOT NULL |
| `description` | String? | Opsiyonel |
| `severity` | `SymptomSeverity` | NOT NULL |
| `createdAt` | DateTime | `@default(now())` |

### 2.5 Tablo: `Nutrition`

| Kolon | Tip | Kısıt / Not |
|-------|-----|-------------|
| `id` | UUID | PK |
| `petId` | UUID | FK → `Pet`, Cascade |
| `foodName` | String | NOT NULL |
| `amount` | String | NOT NULL (örn. `80g`) |
| `frequency` | Int | NOT NULL (günlük tekrar) |
| `feedTime` | String | `@default("08:30")` |
| `status` | `MealStatus` | `@default(PENDING)` |
| `notes` | String? | Opsiyonel |
| `createdAt` | DateTime | `@default(now())` |

### 2.6 İndeksler (öneri — şema üzerinde tanımlı değilse migrasyonla)

| İndeks | Tablo | Kolonlar | Amaç |
|--------|-------|----------|------|
| (Prisma varsayılan) | — | PK UUID | Birincil erişim |
| Önerilir `@@index([petId])` | `Vaccination`, `SymptomLog`, `Nutrition` | `petId` | Pet başına listeleme |
| Önerilir `@@index([ownerId])` | `Pet` | `ownerId` | PRD `GET /api/pets?ownerId=` için (API’de filtre eklenmeli) |

> **Not:** Mevcut `GET /api/pets` tüm pet’leri döndürüyor olabilir; PRD’ye tam uyum için `ownerId` query zorunluluğu ayrı story olarak işlenmeli.

---

## 3. API Kontratı

**Base URL (yerel):** `http://localhost:1571`  
**Auth (MVP):** Yok; isteğe bağlı ileride `Authorization: Bearer`.  
**OpenAPI:** Otomatik üretilmiyor; bu doküman ve kod tek kaynak.

### 3.1 Hayvanlar (`/api/pets`)

| Method | Endpoint | Açıklama | Request | Response (özet) |
|--------|----------|----------|---------|-----------------|
| `GET` | `/api/pets` | Liste | — | `{ pets: Pet[] }` veya hata |
| `POST` | `/api/pets` | Oluştur | JSON: `name`, `species`, `gender`, `ownerId`, opsiyonel `breed`, `imageUrl`, `birthDate`, `weight` | `{ pet }` / `400` / `500` |
| `GET` | `/api/pets/[id]` | Tekil | — | `{ pet }` / `404` |
| `PATCH` | `/api/pets/[id]` | Güncelle | JSON (kısmi alanlar) | `{ pet }` |
| `DELETE` | `/api/pets/[id]` | Sil | — | Başarı gövdesi / hata |
| `GET` | `/api/pets/[id]/summary` | Özet metinleri | — | `{ summary: { lastVaccine, weightStatus, upcomingAppointment } }` |

### 3.2 Takvim / Aşı (`/api/calendar`) — PRD’deki `vaccinations` ile işlevsel eşdeğer

| Method | Endpoint | Query / Body | Response |
|--------|----------|--------------|----------|
| `GET` | `/api/calendar` | `month=YYYY-MM` zorunlu; `petId` opsiyonel | `{ events, reminders }` — `Vaccination[]` |
| `POST` | `/api/calendar` | `petId`, `name`, `date`, opsiyonel `notes`, `status` (`PENDING`/`COMPLETED`) | `201` `{ event }` |
| `PATCH` | `/api/calendar/[id]` | JSON (güncellenebilir alanlar) | Güncellenmiş kayıt |

### 3.3 Belirtiler (`/api/symptoms`)

| Method | Endpoint | Query / Body | Response |
|--------|----------|--------------|----------|
| `GET` | `/api/symptoms` | `petId`, `limit`, `offset` | Liste + meta |
| `POST` | `/api/symptoms` | `petId`, `symptom`, `severity`, opsiyonel `description` | Oluşturulan kayıt |
| `GET` | `/api/symptoms/export` | Opsiyonel `petId` | **CSV** dosyası |

### 3.4 Beslenme (`/api/nutrition`)

| Method | Endpoint | Query / Body | Response |
|--------|----------|--------------|----------|
| `GET` | `/api/nutrition` | `petId` zorunlu | Kayıtlar |
| `POST` | `/api/nutrition` | Pet ve öğün alanları | `201` |
| `PATCH` | `/api/nutrition/[id]` | Durum / alan güncelleme | Güncellenmiş kayıt |

### 3.5 Diğer

| Method | Endpoint | Açıklama |
|--------|----------|----------|
| `POST` | `/api/uploads` | `multipart/form-data` `file`; izinli MIME: jpeg, png, webp, gif, pdf |
| `POST` | `/api/chat` | `{ message: string }` → `{ reply: string }` veya `429` / `400` |

### 3.6 Hata gövdesi (genel desen)

Çoğu uç: `{ error: string }` ve uygun HTTP status (`400`, `404`, `429`, `500`).

| HTTP | Senaryo |
|------|---------|
| `400` | Eksik/invalid parametre veya gövde |
| `404` | Pet veya kayıt yok |
| `429` | Chat rate limit |
| `500` | Sunucu / DB / beklenmeyen |

---

## 4. Ekran Kataloğu (Web MVP)

| ID | Ekran | Route | Bileşenler / API (özet) |
|----|--------|-------|-------------------------|
| **SCR-001** | Giriş yönlendirme | `/` | `redirect("/pets")` |
| **SCR-002** | Hayvan profilleri | `/pets` | Liste, özet kartları, formlar; `GET/POST/PATCH` pets, `GET` summary |
| **SCR-003** | Takvim / aşı hatırlatıcıları | `/calendar` | Ay navigasyonu; `GET /api/calendar`; ekleme `POST`; güncelleme `PATCH` |
| **SCR-004** | Sağlık günlüğü (belirti) | `/symptoms` | Liste, form, CSV indirme linki; `GET/POST` symptoms, `GET` export |
| **SCR-005** | Beslenme | `/nutrition` | Plan satırları; `GET/POST` nutrition, `PATCH` satır |
| **SCR-006** | Global kabuk | `layout.tsx` | `AppShell` (sidebar + mobil drawer), `PatiDostuChatbox` |

**Ortak:** Header mobil (`md:hidden`), sidebar `md:flex`, ana alan `bg-slate-100`.

---

## 5. User Story’ler ve Kabul Kriterleri

### EPIC 1 — Hayvan profili

| ID | Story | SP (tahmini) | Kabul kriterleri |
|----|--------|--------------|------------------|
| **US-1.1** | Yeni hayvan ekleme | 3 | Dashboard/pets üzerinden `POST /api/pets` ile kayıt oluşur; liste yenilenir; zorunlu alanlar boşsa anlamlı Türkçe hata |
| **US-1.2** | Profil düzenleme | 2 | `PATCH /api/pets/[id]` ile alanlar güncellenir; UI senkron |
| **US-1.3** | Özet kartları | 2 | `GET .../summary` ile son aşı / kilo / randevu metinleri gösterilir; hata durumunda kullanıcıya yumuşak fallback |

### EPIC 2 — Takvim / aşı

| ID | Story | SP | Kabul kriterleri |
|----|--------|-----|------------------|
| **US-2.1** | Aylık görünüm | 3 | `month=YYYY-MM` ile doğru ay yüklenir; `petId` ile filtre opsiyonel |
| **US-2.2** | Hatırlatıcı ekleme | 3 | `POST /api/calendar` ile `Vaccination` oluşur; geçersiz tarihte `400` |
| **US-2.3** | Kayıt güncelleme | 2 | `PATCH /api/calendar/[id]` ile durum/not güncellenir |

### EPIC 3 — Belirti

| ID | Story | SP | Kabul kriterleri |
|----|--------|-----|------------------|
| **US-3.1** | Belirti kaydı | 3 | `POST /api/symptoms` ile `createdAt` set; şiddet enum doğrulanır |
| **US-3.2** | Geçmiş listesi | 2 | Sayfalama veya limit ile liste; boş durum mesajı |
| **US-3.3** | Dışa aktarma | 1 | İndirme CSV açılır; `petId` query ile filtre |

### EPIC 4 — Beslenme

| ID | Story | SP | Kabul kriterleri |
|----|--------|-----|------------------|
| **US-4.1** | Öğün ekleme | 2 | `POST /api/nutrition` ile `PENDING` varsayılan |
| **US-4.2** | Tamamlandı işaretleme | 2 | `PATCH` ile `COMPLETED` / güncelleme |

### EPIC 5 — Yardımcı

| ID | Story | SP | Kabul kriterleri |
|----|--------|-----|------------------|
| **US-5.1** | Pati Dostu sohbet | 2 | Mesaj gönderilir; `429` mesajı gösterilir; Gemini yoksa kural yanıtı |
| **US-5.2** | Dosya yükleme (opsiyonel MVP) | 2 | İzinli tipte yükleme; hata mesajları Türkçe |

**Toplam (kabaca):** ~30 SP + altyapı (monorepo, CORS, env) ~8 SP.

---

## 6. Definition of Done

| Kategori | Kriter |
|----------|--------|
| **Kod** | İlgili `frontend` ve/veya `backend` dosyaları; gereksiz refactor yok |
| **Tip** | `npm run lint` (workspace) hatasız veya gerekçeli ignore |
| **API** | Yeni/deǧişen uç bu doküman §3 ile uyumlu veya doküman güncellendi |
| **UI** | `.cursor/rules/design-system*.mdc` ile çelişmeyen stil |
| **Güvenlik** | `ownerId` ile başka pet verisine erişim MVP kararına göre kontrol edildi (henüz yoksa teknik borç olarak issue açıldı) |
| **Test** | En az manuel happy path (tarayıcı) veya otomasyon notu |
| **Dokümantasyon** | `README.md` / `mvp.md` etkilendiyse güncellendi |

---

## 7. Hata ve Edge Case Kataloğu

| ID | Senaryo | Beklenen davranış |
|----|---------|-------------------|
| **EC-001** | `DATABASE_URL` yok | Backend build/import: açık hata mesajı (`lib/prisma.ts`) |
| **EC-002** | Frontend backend kapalı | `fetch` hata; UI’da kullanıcı mesajı (ağ/ sunucu) |
| **EC-003** | `month` formatı hatalı | `GET /api/calendar` → `400` + açıklama |
| **EC-004** | Olmayan `petId` ile takvim POST | `404` Profil bulunamadı |
| **EC-005** | Chat boş mesaj | `400` |
| **EC-006** | Chat rate limit | `429` + saniye bilgisi |
| **EC-007** | Gemini key yok veya API hata | Sessiz düşüş → `buildReply` kural yanıtı |
| **EC-008** | CSV export; veri yok | Başlık satırı + boş gövde veya yalnız başlık |
| **EC-009** | Büyük dosya yükleme | Tip veya boyut reddi (`uploads` route) |
| **EC-010** | CORS yanlış origin | Tarayıcı bloklar; `FRONTEND_ORIGIN` kontrol |

---

## 8. Pati Dostu / AI Katmanı

### 8.1 Akış

1. İstemci: `POST /api/chat` + `{ message }` (`frontend` → `apiUrl`).  
2. Rate limit: IP başına 5 istek / 60 sn.  
3. `GEMINI_API_KEY` varsa Gemini REST çağrısı; başarısızsa veya key yoksa `buildReply` (anahtar kelime kuralları, Türkçe).  
4. Yanıt: `{ reply }` — tıbbi teşhis iddiası yok; veteriner yönlendirmesi.

### 8.2 Parametreler (Gemini kullanıldığında)

| Parametre | Değer (kod) |
|-----------|-------------|
| Model | `gemini-1.5-flash` |
| `temperature` | `0.4` |
| `maxOutputTokens` | `180` |

### 8.3 MVP sınırı

- Pati Dostu **tanı koymaz**; acil durumda veteriner önerisi.  
- Üretimde API anahtarı **sunucuda**; istemciye sızdırılmaz.

---

## 9. Performans ve Güvenlik

### 9.1 Performans hedefleri (MVP rehber)

| Metrik | Hedef |
|--------|--------|
| Sayfa ilk yükleme (yerel) | &lt; ~3 sn (geliştirme ortamı) |
| API `GET` listeleri | Mümkünse &lt; 500 ms p95 (ölçüm sonradı) |
| Chat | Tek istek &lt; 3 sn (Gemini ağına bağlı) |

### 9.2 Güvenlik

| Konu | Uygulama |
|------|----------|
| **HTTPS** | Üretimde zorunlu |
| **CORS** | Whitelist origin (`FRONTEND_ORIGIN`) |
| **Rate limit** | Chat IP bazlı (bellek içi; çok instance’da merkezi limit gerekir) |
| **Dosya** | MIME allowlist; dosya adı UUID ile disk yazımı |
| **KVKK / silme** | PRD Faz 2; MVP’de `ownerId` ve silme uçları bilinçli kullanılmalı |
| **Sırlar** | `.env` / Vercel env; repo içine commit yok |

---

## 10. Sprint Planı (Öneri)

2 haftalık sprint varsayımı; ekip 1–2 geliştirici.

| Sprint | Odak | Çıktı |
|--------|------|--------|
| **S1** | Monorepo, env, CORS, `apiUrl`, pets CRUD stabil | Web + API birlikte çalışır |
| **S2** | Takvim + `Vaccination` akışı tam PRD sözlüğüyle dokümante | iOS için kontrat netliği |
| **S3** | Belirti + export + beslenme PATCH | EPIC 3–4 kapanır |
| **S4** | `ownerId` filtreleme + yetkisiz erişim önlemi | Güvenlik borcu kapanır |
| **S5** | iOS iskelet (URLSession) veya polish + lint/CI | TestFlight’a hazırlık |

---

## 11. PRD ↔ Repo Sapma Notları

| PRD | Repo | Aksiyon |
|-----|------|---------|
| `GET/POST /api/vaccinations` | `/api/calendar` (+ `Vaccination` modeli) | iOS client veya OpenAPI tek kaynakta birleştir |
| `GET /api/pets?ownerId=` | Liste ucu owner filtresiz olabilir | Query parametresi ve doğrulama ekle |
| Splash / onboarding | Web MVP’de yok veya minimal | PRD §5 ile backlog |
| Belirti export “PDF” (UI metni) | Sunucu **CSV** | UI metnini CSV ile uyumlu yap veya PDF üret |

---

## 12. MVP Felsefesi ve Kapsam Matrisi

### 12.1 Tek cümle

> **Evcil hayvanın profilini, aşı/takvim kayıtlarını, belirtilerini ve beslenmesini tek yerden yönet.**

### 12.2 Eisenhower özeti

| | **Acil** | **Acil değil** |
|--|----------|----------------|
| **Önemli** | Pet CRUD, takvim POST/GET, belirti POST, beslenme CRUD, DB + Prisma | PRD onboarding, iOS TestFlight |
| **Önemli değil** | Chat rate limit ince ayarı | Karanlık tema, rozetler |
| **Önemsiz / lüks** | — | IoT, marketplace, gelişmiş AI tanı (PRD §7) |

### 12.3 MVP’ye giren (must-have)

1. PostgreSQL + Prisma şema ile **Pet**, **Vaccination**, **SymptomLog**, **Nutrition**  
2. REST uçları ile CRUD / liste (yukarıdaki §3)  
3. Web arayüzü: pets, calendar, symptoms, nutrition  
4. `ownerId` alanı (en azından veri modeli ve formlar)  
5. Çalıştırma dokümantasyonu (`README.md`)

### 12.4 MVP dışı (PRD ile uyumlu)

- Apple Sign-In, JWT, push, offline-first, çoklu rol  
- PRD §7 maddeleri  
- Tam onboarding, admin paneli, ödeme

---

## 13. Sözlük

| Terim | Açıklama |
|-------|----------|
| **ADR** | Architecture Decision Record |
| **DoD** | Definition of Done |
| **MVP** | Minimum Viable Product |
| **PRD** | Product Requirements Document (`Teknik PRD_ Pet Track iOS.md`) |
| **Route Handler** | Next.js `app/api/.../route.ts` sunucu fonksiyonları |
| **SP** | Story Point (kabaca iş büyüklüğü) |
| **Vaccination** | PRD’deki aşı/randevu veri modeli; API yolu takvim altında |

---

## İlgili dosyalar

- `Teknik PRD_ Pet Track iOS.md` — ürün otoritesi  
- `plan.md` — adım adım yürütme  
- `README.md` — kurulum ve ortam  

---

*Bu doküman Pet Track kod tabanı ve PRD taslak v1 ile hizalanmıştır; sapmalar §11’de açıkça listelenmiştir.*
