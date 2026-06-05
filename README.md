# PetTrack

**Evcil hayvan sağlığını tek yerden takip et.** Profil, aşı takvimi, belirti günlüğü, beslenme planı — ve **Pati Dostu**, Gemini destekli yapay zeka asistanı.

| Web | Mobil | API |
|-----|-------|-----|
| Next.js · port **1575** | Flutter · iOS & Android | Next.js + Prisma · port **1571** |

---

## Ne yapar?

- **Hayvan profilleri** — Kedi, köpek, kuş; fotoğraf, kilo, yaş, ırk; birden fazla pet
- **Takvim** — Aşı ve randevu hatırlatıcıları; Bekliyor / Tamamlandı
- **Sağlık günlüğü** — Belirti türü, şiddet (Düşük / Orta / Yüksek), CSV dışa aktarma
- **Beslenme** — Diyet hedefleri, öğün planlayıcı, kalori takibi
- **Pati Dostu AI** — Semptom analizi ve bakım tavsiyesi; aktif pet'e göre kişiselleştirilmiş yanıtlar (Google Gemini)

---

## Hızlı başlangıç

```bash
npm install
cp .env.example backend/.env      # DATABASE_URL + isteğe bağlı GEMINI_API_KEY
cp .env.example frontend/.env     # NEXT_PUBLIC_API_URL
npm run prisma:generate
npm run prisma:migrate
npm run dev
```

| Adres | Açıklama |
|-------|----------|
| http://localhost:1575 | Web arayüzü |
| http://localhost:1571/api | REST API |

### Veritabanı

```bash
createdb pettrack
# veya: npm run db:up   # Docker PostgreSQL, port 5433
npm run prisma:migrate
npm run prisma:studio   # tablo görüntüleyici
```

### Mobil

```bash
cd frontend/mobile
flutter pub get
flutter run
```

Mobil uygulama `frontend/.env` içindeki `NEXT_PUBLIC_API_URL` ile backend'e bağlanır.

---

## Klasör yapısı

```
frontend/          Web arayüzü (Next.js)
  mobile/          Flutter mobil uygulama
backend/           REST API + Prisma + PostgreSQL
  py/              Opsiyonel FastAPI servisi
prodocs/           PRD, plan, tasarım sistemi, ilerleme kaydı
```

---

## Deploy

| Bileşen | Önerilen platform | Ortam değişkenleri |
|---------|-------------------|---------------------|
| `frontend/` | Vercel | `NEXT_PUBLIC_API_URL` |
| `backend/` | Vercel | `DATABASE_URL`, `FRONTEND_ORIGIN`, `GEMINI_API_KEY` |
| PostgreSQL | Supabase / Neon | Connection string |
| `frontend/mobile/` | TestFlight / Play Store | API base URL build-time |

```bash
DATABASE_URL="postgresql://..." npm run build
```

---

## Dokümantasyon

Tüm zorunlu belgeler [`prodocs/`](./prodocs/) altında:

| Dosya | İçerik |
|-------|--------|
| [PRD.md](./prodocs/PRD.md) | Ürün gereksinimleri |
| [tech-stack.md](./prodocs/tech-stack.md) | Teknoloji ve AI entegrasyonu |
| [Plan.md](./prodocs/Plan.md) | Teknik adımlar ve user story'ler |
| [DesignSystem.md](./prodocs/DesignSystem.md) | UI kuralları |
| [Progress.md](./prodocs/Progress.md) | İlerleme günlüğü |

Ortam şablonu: [`.env.example`](./.env.example) — gerçek API anahtarları commit edilmez.
