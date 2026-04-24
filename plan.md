# Pet Track — LLM ve geliştirici için yürütme planı

Bu belge, `Teknik PRD_ Pet Track iOS.md` içindeki **Faz 1 / MVP** kapsamı ve teknik PRD bölümlerinden türetilmiştir. Amaç: projeyi yeterince küçük, sıralı ve izlenebilir adımlara bölmek; bir LLM veya geliştiricinin aynı sırayla ilerleyebilmesini sağlamak.

**Kaynak dokümanlar:** `Teknik PRD_ Pet Track iOS.md` (ürün vizyonu, tech stack, şema, API uçları, ekranlar, user stories, kapsam dışı). Ayrı bir “MVP Kapsamı” dosyası repoda yoksa MVP sınırları PRD §1, §2, §5–§7 ile kabul edilir.

---

## 1. Bağlam özeti (PRD’den)

| Konu | MVP hedefi |
|------|------------|
| Ürün | Evcil hayvan profili, aşı/randevu, belirti günlüğü, beslenme planı |
| İstemci (hedef PRD) | iOS native (SwiftUI) |
| Backend (PRD) | REST/JSON API — PRD’de Next.js 16 Route Handlers |
| Veri | PostgreSQL + Prisma; `ownerId` ile basit sahiplik (MVP) |
| Dağıtım (PRD) | Vercel (API) + Supabase (DB); TestFlight (iOS) |

**Not:** Repo **npm workspaces** monorepo: `backend/` (API + Prisma, varsayılan port **1571**) ve `frontend/` (UI, port **1570**). Kök `npm run dev` her iki paketi birlikte çalıştırır. Arayüz, `frontend/lib/api.ts` üzerinden `NEXT_PUBLIC_API_URL` ile API’ye bağlanır; CORS `backend/middleware.ts` ile ayarlanır.

---

## 2. Kod yapısı — Backend / Frontend (fiziksel dizinler)

`node_modules`, `.git`, derleme çıktıları listelenmez.

### 2.1 Backend (`backend/`)

| Yol | Rol |
|-----|-----|
| `backend/prisma/schema.prisma` | Veritabanı modeli |
| `backend/prisma.config.ts` | Prisma 7 yapılandırması |
| `backend/lib/prisma.ts` | Prisma istemcisi |
| `backend/lib/generated/prisma/**` | `prisma generate` çıktısı |
| `backend/app/api/pets/route.ts` | Hayvan listesi / oluşturma |
| `backend/app/api/pets/[id]/route.ts` | Tek hayvan CRUD |
| `backend/app/api/pets/[id]/summary/route.ts` | Özet |
| `backend/app/api/calendar/route.ts` | Takvim koleksiyonu |
| `backend/app/api/calendar/[id]/route.ts` | Takvim öğesi |
| `backend/app/api/nutrition/route.ts` | Beslenme |
| `backend/app/api/nutrition/[id]/route.ts` | Beslenme tekil |
| `backend/app/api/symptoms/route.ts` | Belirti |
| `backend/app/api/symptoms/export/route.ts` | Dışa aktarma |
| `backend/app/api/uploads/route.ts` | Yükleme |
| `backend/app/api/chat/route.ts` | Sohbet |
| `backend/middleware.ts` | CORS (API için) |
| `backend/package.json`, `next.config.ts`, `tsconfig.json` | Backend paketi |

### 2.2 Frontend (`frontend/`)

| Yol | Rol |
|-----|-----|
| `frontend/app/layout.tsx` | Kök layout |
| `frontend/app/page.tsx` | Ana sayfa (yönlendirme) |
| `frontend/app/globals.css` | Global stiller |
| `frontend/app/pets/page.tsx` | Hayvanlar |
| `frontend/app/calendar/page.tsx` | Takvim |
| `frontend/app/nutrition/page.tsx` | Beslenme |
| `frontend/app/symptoms/page.tsx` | Belirtiler |
| `frontend/components/*` | Kabuk, navigasyon, chatbox |
| `frontend/lib/api.ts` | API taban URL (`NEXT_PUBLIC_API_URL`) |
| `frontend/public/` | Statik varlıklar |
| `frontend/package.json`, `postcss.config.mjs`, `next.config.ts` | Frontend paketi |

### 2.3 Kök / paylaşılan

| Yol | Rol |
|-----|-----|
| `package.json` | Workspaces + ortak script’ler (`dev`, `build`, `prisma:*`) |
| `README.md`, `plan.md`, `Teknik PRD_ Pet Track iOS.md`, `AGENTS.md` | Dokümantasyon |

---

## 3. Sonraki mimari adımlar (isteğe bağlı)

**Tam ayrı depo veya farklı runtime:** `backend/` şu an Next route handlers kullanıyor; ileride aynı Prisma şemasıyla ayrı bir Node (Hono/Fastify) veya sunucusuz dağıtım seçilebilir. **iOS (SwiftUI)** istemcisi aynı REST uçlarını `NEXT_PUBLIC_API_URL` benzeri bir taban URL ile kullanır.

**Geçiş özeti:**

1. ~~Faz A — Mantıksal ayrım~~ (önceki taslak).
2. **Faz B — Tamamlandı:** `backend/` ve `frontend/` ayrı `package.json`, kök `npm run dev`.
3. **Faz C:** Üretimde iki ayrı URL (ör. Vercel iki proje veya API alt alan adı); env ile taban URL’ler.

---

## 4. Yürütme adımları (yeterince küçük parçalar)

Her adımda “Bitti sayılır” kriteri kısaca yazılmıştır.

### Adım 0 — Çevre ve repoyu anlama

- [ ] Node sürümünü `package.json` / ekip standardına göre sabitle (`.nvmrc` vb. isteğe bağlı).
- [ ] `npm install` ile bağımlılıkları kur; `prisma:generate` hatasız çalışıyor mu kontrol et.
- [ ] `.env` / `DATABASE_URL` ile PostgreSQL bağlantısını doğrula (PRD: Supabase uyumlu).
- **Bitti:** `npm run dev` ve veritabanı bağlantısı dokümante edildi.

### Adım 1 — Backend kurulumu (ayrı dizin)

- [x] `backend/` paketi: `README.md`, `package.json`, Prisma, `app/api/*`, port **1571**.
- [ ] REST uçlarını PRD §4 ile karşılaştır; eksik uçları listele (ör. `GET /api/vaccinations` vs takvim API’si).
- **Bitti:** Backend çalışır; API checklist güncel.

### Adım 2 — Frontend kurulumu (ayrı dizin)

- [x] `frontend/` paketi: sayfalar, `components/`, `lib/api.ts`, `NEXT_PUBLIC_API_URL`, port **1570**.
- [ ] PRD §5 ekranları ile mevcut sayfaları eşleştir; eksik ekranları backlog’a yaz.
- **Bitti:** Frontend API’ye CORS ile bağlanır; ekran eşlemesi yazılı.

### Adım 3 — Veri modeli ve migrasyonlar

- [ ] `backend/prisma/schema.prisma` modellerinin PRD §3 tablosu ile birebir uyumunu gözden geçir.
- [ ] `prisma migrate` veya `db push` ile şemayı ortama uygula; örnek seed (isteğe bağlı).
- **Bitti:** Şema üretimi ve DB şeması ortamda doğrulandı.

### Adım 4 — Kimlik ve çok kiracılık (MVP)

- [ ] `ownerId`’nin tüm API’lerde tutarlı kullanımını doğrula (query/body).
- [ ] Basit kötüye kullanım senaryoları: başka owner’a ait `petId` ile erişim engeli.
- **Bitti:** MVP kimlik modeli dokümante ve kritik uçlarda kontrol var.

### Adım 5 — EPIC 1: Hayvan profili (US 1.1)

- [ ] `GET/POST /api/pets` ve detay uçlarının PRD acceptance criteria ile testi.
- [ ] UI: liste + ekleme formu (validasyon, zorunlu alan hataları).
- **Bitti:** Yeni hayvan eklenebilir ve listede görünür.

### Adım 6 — EPIC 2: Aşı ve randevu (US 2.1)

- [ ] Aşı modeli ve API’lerin PRD’deki isimlendirme ile hizalanması (gerekirse redirect veya alias).
- [ ] `nextDate`, durum badge’leri, pet detay sekmesi.
- **Bitti:** Aşı kaydı oluşturulur ve listede / planda görünür.

### Adım 7 — EPIC 3: Belirti ve beslenme (US 3.1, 3.2)

- [ ] Belirti günlüğü: oluşturma + zaman çizelgesi görünümü (MVP basit liste kabul).
- [ ] Beslenme: PENDING/COMPLETED güncellemesi.
- **Bitti:** İki modül için happy path tamam.

### Adım 8 — Dışa aktarma, yükleme, sohbet (mevcut kod)

- [ ] `symptoms/export`, `uploads`, `chat` uçlarının PRD’de “MVP zorunlu mu?” kararı; değilse “Faz 2 / opsiyonel” işaretle.
- **Bitti:** Kapsam net; gereksiz MVP yükü azaltıldı veya testlendi.

### Adım 9 — Kalite ve teslim

- [ ] ESLint temiz; kritik API için manuel veya otomatik test.
- [ ] README: çalıştırma, env değişkenleri, `backend`/`frontend` ayrımı sonrası komutlar.
- **Bitti:** Repo yeni geliştirici + LLM ile açıklanabilir durumda.

### Adım 10 — iOS istemci (PRD hedefi)

- [ ] Xcode projesi; ağ katmanı (URLSession); modellerin Swift tarafında eşlenmesi.
- [ ] TestFlight dağıtım checklist’i.
- **Bitti:** MVP akışları cihazda doğrulanabilir.

---

## 5. PRD “kapsam dışı” hatırlatması (Faz 1’e girme)

Şunları bu planın adımlarına **ekleme** (PRD §7): marketplace randevu, IoT, gelişmiş AI tanı motoru, enterprise rol/izin modeli.

---

## 6. LLM kullanım ipuçları

- **§2** tablolarıyla dosya seç: API ve Prisma için `backend/app/api/**`, `backend/lib/prisma.ts`, `backend/prisma/schema.prisma`; UI için `frontend/app/**`, `frontend/components/**`.
- PRD §4 endpoint isimleri ile repo farklıysa **uyumluluk tablosu** üret.
- Üretim `next build` (backend) için ortamda `DATABASE_URL` tanımlı olmalı (`lib/prisma.ts` import anında doğrular).

---

