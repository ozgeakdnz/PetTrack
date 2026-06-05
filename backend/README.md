# PetTrack — Backend

Next.js **Route Handlers** (`app/api/*`), Prisma (`prisma/`), veri erişimi (`lib/prisma.ts`).

**Geliştirme:** `npm run dev` (kökten) veya bu dizinde `npm run dev` — port **1571**.

`DATABASE_URL` zorunludur. CORS için `FRONTEND_ORIGIN` (varsayılan `http://localhost:1575`).

Yüklenen dosyalar `public/uploads/` altına yazılır.

**Python API (opsiyonel):** `py/` — FastAPI, port 1572.  
**Veritabanı (Docker):** kökten `npm run db:up` → `docker-compose.yml` bu dizinde.
