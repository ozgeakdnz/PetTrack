# ⚙️ PetTrack — Backend API

Next.js Route Handlers ile REST API — Prisma ORM, PostgreSQL, **Google Gemini** (Pati Dostu).

| | |
|---|---|
| **Port** | 1571 |
| **Stack** | Next.js · TypeScript · Prisma 7 · PostgreSQL |
| **AI** | Gemini `gemini-2.5-flash` |

---

## API modülleri

| Uç | Dosya |
|----|--------|
| `/api/pets` | `app/api/pets/route.ts` |
| `/api/calendar` | `app/api/calendar/route.ts` |
| `/api/symptoms` | `app/api/symptoms/route.ts` |
| `/api/nutrition` | `app/api/nutrition/route.ts` |
| `/api/chat` | `app/api/chat/route.ts` |
| `/api/uploads` | `app/api/uploads/route.ts` |

AI prompt: `lib/pati-dostu-prompt.ts`

---

## Ortam değişkenleri

```env
DATABASE_URL=postgresql://...
FRONTEND_ORIGIN=http://localhost:1575
GEMINI_API_KEY=
GEMINI_MODEL=gemini-2.5-flash
GEMINI_MAX_DAILY_REQUESTS=15
GEMINI_THINKING_BUDGET=0
```

---

## Çalıştırma

```bash
npm run dev -w backend

# Veritabanı
npm run prisma:migrate    # kökten
npm run prisma:studio
npm run db:up             # Docker PostgreSQL (port 5433)
```

---

## Mimari not

Frontend ve mobil **doğrudan Gemini veya DB'ye bağlanmaz** — tüm istekler bu API üzerinden gider.

```
İstemci → /api/* → Prisma → PostgreSQL
                 → Gemini (chat)
```

---

Ana README: [../README.md](../README.md) · Tech stack: [../prodocs/tech-stack.md](../prodocs/tech-stack.md)
