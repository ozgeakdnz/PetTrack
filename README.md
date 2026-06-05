# PetTrack

Evcil hayvan sahipleri için profil, aşı/randevu, belirti günlüğü ve beslenme takibi. Web arayüzü (Next.js) + REST API (Next.js + Prisma + PostgreSQL) + opsiyonel Flutter mobil istemci.

## Klasör yapısı

```
frontend/          Web arayüzü (Next.js)
  mobile/          Flutter mobil uygulama (iOS / Android)
backend/           REST API + Prisma + PostgreSQL
  py/              Opsiyonel FastAPI (günlük soru / AI)
prodocs/           PRD, plan, tasarım sistemi, ilerleme kaydı, AI referansları
```

## Gereksinimler

- Node.js 20+
- PostgreSQL
- (Mobil) Flutter SDK
- (Opsiyonel Python API) Python 3.11+

## Kurulum

```bash
npm install
cp .env.example backend/.env      # DATABASE_URL düzenle
cp .env.example frontend/.env     # NEXT_PUBLIC_* satırlarını kopyala
npm run prisma:generate
npm run prisma:migrate
npm run dev
```

- **Arayüz:** http://localhost:1575  
- **API:** http://localhost:1571/api  

## Veritabanı

```bash
createdb pettrack                    # yerel PostgreSQL
# veya
npm run db:up                        # Docker (backend/docker-compose.yml, port 5433)
npm run prisma:migrate
npm run prisma:studio                # tabloları görüntüle
```

## Mobil uygulama

```bash
cd frontend/mobile
flutter pub get
flutter run
```

## Deploy (özet)

| Bileşen | Öneri |
|---------|--------|
| `frontend/` | Vercel — `NEXT_PUBLIC_API_URL` = canlı API URL |
| `backend/` | Vercel — `DATABASE_URL`, `FRONTEND_ORIGIN` set |
| PostgreSQL | Supabase veya yönetilen PostgreSQL |
| `frontend/mobile/` | TestFlight / Play Store build |
| `backend/py/` | Railway / Render (opsiyonel) |

Üretim build:

```bash
DATABASE_URL="postgresql://..." npm run build
```

## Dokümantasyon

Tüm zorunlu belgeler `prodocs/` altında:

| Dosya | İçerik |
|-------|--------|
| `PRD.md` | Ürün gereksinimleri |
| `tech-stack.md` | Teknoloji seçimleri ve AI kullanımı |
| `Plan.md` | Teknik adımlar ve user story’ler |
| `DesignSystem.md` | UI kuralları |
| `Progress.md` | İlerleme ve karar kaydı |

Ortam şablonu: kök `.env.example` (gerçek anahtarlar commit edilmez).
