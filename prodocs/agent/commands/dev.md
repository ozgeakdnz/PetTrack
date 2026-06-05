# Yerel geliştirme

1. `backend/.env` içinde `DATABASE_URL` tanımla (ve isteğe bağlı `FRONTEND_ORIGIN=http://localhost:1575`).
2. `npm run dev` — Next.js API **1571**, frontend **1575**.
3. İsteğe bağlı: `frontend/.env` içinde `NEXT_PUBLIC_API_URL=http://localhost:1571` (varsayılan zaten bu).

Tarayıcı: http://localhost:1575

## Python API (`backend/py/`)

1. `cd backend/py && python3 -m venv .venv && source .venv/bin/activate`
2. `pip install -r requirements.txt`
3. `npm run dev:py` — FastAPI **1572** (`/health`, `/api/entries`, `/api/questions/daily`)
4. Üç servis birden: `npm run dev:all` (1575 + 1571 + 1572)

## Veritabanı

```bash
npm run db:up          # Docker PostgreSQL (port 5433)
npm run prisma:migrate
```

Detay: `prodocs/Plan.md`, `prodocs/Progress.md`
