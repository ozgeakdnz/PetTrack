# PetTrack — Tech Stack

## Özet

| Katman | Teknoloji | Port (yerel) |
|--------|-----------|--------------|
| Web arayüz | Next.js 16, React 19, Tailwind CSS 4, Lucide React | 1575 |
| REST API | Next.js 16 Route Handlers, Prisma 7, PostgreSQL | 1571 |
| Mobil istemci | Flutter (iOS / Android) | — |
| Diary / AI API (opsiyonel) | Python FastAPI, Uvicorn | 1572 |

## Seçim gerekçeleri

| Karar | Gerekçe |
|-------|---------|
| **Monorepo (npm workspaces)** | `frontend/` ve `backend/` ayrı çalıştırılabilir; tek `npm run dev` ile geliştirme |
| **Next.js Route Handlers** | PRD ile uyum; TypeScript tek dil; Vercel dağıtımına uygun |
| **Prisma + PostgreSQL** | Tip güvenli ORM; Supabase / yerel PostgreSQL ile uyumlu |
| **Flutter mobil** | Tek kod tabanı ile iOS ve Android; hızlı MVP prototipi |
| **FastAPI (backend/py)** | Günlük soru ve AI diary katmanı için hafif Python servisi |

## Geliştirmede yapay zeka kullanımı

- **Planlama:** `prodocs/PRD.md` ve `prodocs/Plan.md` referans alınarak adım adım yürütme.
- **Kod üretimi:** Cursor ajan kuralları `prodocs/agent/rules/` altında; UI için `DesignSystem.md`, API için `backend-api` kuralları.
- **Tasarım tutarlılığı:** Tailwind + mevcut bileşen dili; yeni ekranlar `AppShell` ve teal/slate paleti ile hizalanır.
- **Hata ayıklama:** Prisma migration, CORS ve env (`DATABASE_URL`, `NEXT_PUBLIC_API_URL`) kontrol listesi `prodocs/Progress.md` içinde kayıtlı.

## Ortam değişkenleri

Kök `.env.example` dosyasına bakın. Gerçek anahtarlar repoya commit edilmez.

## Dağıtım (önerilen)

| Bileşen | Hedef |
|---------|--------|
| `frontend/` | Vercel (statik + SSR) |
| `backend/` | Vercel veya Node hosting |
| PostgreSQL | Supabase veya yönetilen PostgreSQL |
| `frontend/mobile/` | TestFlight (iOS) / Play Store (Android) |
| `backend/py/` | Railway, Render veya ayrı container |
