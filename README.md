## PetTrack 

Monorepo: **`frontend/`** (Next.js + Tailwind + arayüz) ve **`backend/`** (Next.js Route Handlers + Prisma + PostgreSQL) ayrı paketlerdir.

### Gereksinimler

- Node.js 20+
- PostgreSQL (`DATABASE_URL`)

### Ortam değişkenleri

**`backend/.env`** (veya kökten çalıştırırken backend sürecinin gördüğü env):

- `DATABASE_URL` — PostgreSQL bağlantı dizesi

**`frontend/.env.local`** (isteğe bağlı; varsayılanlar yerel geliştirme içindir):

- `NEXT_PUBLIC_API_URL` — API tabanı (varsayılan: `http://localhost:1571`)
- Backend CORS için **`backend/.env`** içinde `FRONTEND_ORIGIN=http://localhost:1570` (varsayılan zaten bu)

### Kurulum

```bash
npm install
npm run prisma:generate
```

### Geliştirme

İki servisi birlikte çalıştırır (`backend` :1571, `frontend` :1570):

```bash
npm run dev
```

Ayrı ayrı:

```bash
npm run dev:backend
npm run dev:frontend
```

Arayüz: [http://localhost:1570](http://localhost:1570) — API: [http://localhost:1571/api](http://localhost:1571/api)

### Üretim derlemesi

`npm run build` kökten çalıştırılmadan önce **`DATABASE_URL`** ortam değişkeninin set edilmiş olması gerekir (backend paketi `lib/prisma.ts` içinde doğrular). Örnek:

```bash
DATABASE_URL="postgresql://..." npm run build
```

### Prisma (sadece backend)

```bash
npm run prisma:generate
npm run prisma:migrate
npm run prisma:studio
```

### Teknolojiler

- Next.js 16 (App Router) — iki workspace
- Tailwind CSS 4, Lucide-React (frontend)
- Prisma ORM, `pg` (backend)

Detaylı yürütme adımları için kökteki `plan.md` dosyasına bakın.
