# PetTrack — Vercel Deploy Rehberi

## AŞAMA 1 — Backend hazırlığı ✅

Repo'da yapılanlar:

| Dosya | Açıklama |
|-------|----------|
| `backend/vercel.json` | Next.js API + Python FastAPI birlikte build |
| `backend/py/main.py` | Vercel CORS + `/api/ai/*` mount |
| `backend/py/requirements.txt` | FastAPI + Gemini bağımlılıkları |

### `vercel.json` özeti

- **`/api/ai/*`** → Python FastAPI (`py/main.py`)
- **Diğer tüm istekler** → Next.js (Prisma API: `/api/pets`, `/api/chat`, …)

> Ana Pati Dostu sohbeti **Next.js** `/api/chat` üzerindedir (Gemini). Python katmanı opsiyonel (`/api/ai/questions/daily`, `/api/ai/entries`).

### Python uç noktaları (Vercel)

| Method | Uç |
|--------|-----|
| GET | `/api/ai/health` |
| GET | `/api/ai/questions/daily` |
| CRUD | `/api/ai/entries` |

Yerelde (port 1572) eski yollar da çalışır: `/api/questions/daily`, `/api/entries`.

---

## Vercel Dashboard — Backend projesi

1. [vercel.com](https://vercel.com) → **Add New Project** → GitHub `PetTrack`
2. **Root Directory:** `backend`
3. **Install Command:** `cd .. && npm install`
4. **Build Command:** `npm run build` (varsayılan)
5. **Environment Variables:**

| Değişken | Değer |
|----------|--------|
| `DATABASE_URL` | Supabase/Neon PostgreSQL URI |
| `FRONTEND_ORIGIN` | *(Aşama 2 sonrası frontend URL)* |
| `GEMINI_API_KEY` | Google AI Studio key |
| `GEMINI_MODEL` | `gemini-2.5-flash` |
| `GEMINI_THINKING_BUDGET` | `0` |

6. Deploy sonrası migration:

```bash
cd backend
DATABASE_URL="postgresql://..." npx prisma migrate deploy
```

---

## Sonraki aşamalar

- **AŞAMA 2:** Frontend Vercel projesi (`frontend/`, `NEXT_PUBLIC_API_URL`)
- **AŞAMA 3:** `FRONTEND_ORIGIN` güncelle + backend redeploy
