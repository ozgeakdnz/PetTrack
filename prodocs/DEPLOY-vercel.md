# PetTrack — Vercel Deploy Rehberi

> Bu rehber, projenin **canlı ortama** alınması için izlenen adımları özetler.  
> Canlı adresler: [pettrack-frontend.vercel.app](https://pettrack-frontend.vercel.app) · [pettrack-backend.vercel.app](https://pettrack-backend.vercel.app)

---

## Canlı ortam özeti

| Bileşen | Platform | Proje adı | URL |
|---------|----------|-----------|-----|
| Web arayüz | Vercel | `pettrack-frontend` | https://pettrack-frontend.vercel.app |
| REST API | Vercel | `pettrack-backend` | https://pettrack-backend.vercel.app |
| Veritabanı | Neon | `pettrack-db` | eu-central-1 (Frankfurt) |

---

## ADIM 1 — Repo hazırlığı (backend)

Repo'da backend Vercel deploy için şu dosyalar bulunur:

| Dosya | Açıklama |
|-------|----------|
| `backend/vercel.json` | Next.js API + Python FastAPI birlikte build |
| `backend/py/main.py` | Vercel CORS + `/api/ai/*` mount |
| `backend/py/requirements.txt` | FastAPI bağımlılıkları |
| `backend/package.json` | `"build": "prisma generate && next build"` |

### `vercel.json` özeti

- **`/api/ai/*`** → Python FastAPI (`py/main.py`)
- **Diğer tüm istekler** → Next.js (Prisma API: `/api/pets`, `/api/chat`, …)

> Ana Pati Dostu sohbeti **Next.js** `/api/chat` üzerindedir (Gemini). Python katmanı opsiyonel.

---

## ADIM 2 — Neon PostgreSQL (canlı veritabanı)

1. [neon.tech](https://neon.tech) → GitHub ile giriş
2. **Create a project**
   - **Project Name:** `pettrack-db`
   - **Region:** `eu-central-1` (Frankfurt — Vercel'e yakın, düşük gecikme)
3. **Connection Details** → bağlantı türü **Prisma** seç
4. Çıkan URI'yi kopyala (örnek format):

```txt
postgresql://alex:password@ep-cool-darkness-123456.eu-central-1.aws.neon.tech/neondb?sslmode=require
```

Bu değer canlı **`DATABASE_URL`**'dir.

---

## ADIM 3 — Şemayı Neon'a yükleme

Bulut veritabanı boşken yerel şemayı basmak için:

```bash
cd backend
# Geçici olarak backend/.env içindeki DATABASE_URL'yi Neon URI ile değiştir
npx prisma db push
```

Doğrulama (isteğe bağlı):

```bash
npx prisma studio
```

> Migration geçmişi tutmak istersen `npx prisma migrate deploy` de kullanılabilir; MVP kurulumunda `db push` yeterli olabilir.

---

## ADIM 4 — Backend'i Vercel'e deploy etme

1. [vercel.com](https://vercel.com) → **Add New… → Project**
2. GitHub `PetTrack` reposunu **Import** et
3. Ayarlar:

| Alan | Değer |
|------|--------|
| **Project Name** | `pettrack-backend` |
| **Root Directory** | `backend` |
| **Install Command** | `cd .. && npm install` *(monorepo)* |
| **Build Command** | `npm run build` |

4. **Environment Variables** (backend projesi):

| Değişken | Değer |
|----------|--------|
| `DATABASE_URL` | Neon'dan aldığın Prisma URI |
| `GEMINI_API_KEY` | Google AI Studio anahtarı |
| `GEMINI_MODEL` | `gemini-2.5-flash` |
| `GEMINI_THINKING_BUDGET` | `0` |
| `FRONTEND_ORIGIN` | `https://pettrack-frontend.vercel.app` |

5. **Deploy** → canlı API: `https://pettrack-backend.vercel.app`

---

## ADIM 5 — Frontend'i Vercel'e deploy etme

1. Vercel Dashboard → tekrar **Add New… → Project**
2. Aynı GitHub reposunu **Import** et
3. Ayarlar:

| Alan | Değer |
|------|--------|
| **Project Name** | `pettrack-frontend` |
| **Root Directory** | `frontend` |

4. **Environment Variables** (frontend projesi):

| Değişken | Değer |
|----------|--------|
| `NEXT_PUBLIC_API_URL` | `https://pettrack-backend.vercel.app` |

5. **Deploy** → canlı web: `https://pettrack-frontend.vercel.app`

---

## ADIM 6 — CORS ve redeploy

Frontend URL'i belli olduktan sonra backend'de `FRONTEND_ORIGIN=https://pettrack-frontend.vercel.app` olduğundan emin ol ve **backend'i yeniden deploy et**. Aksi halde tarayıcı CORS hatası verebilir.

---

## ADIM 7 — Profil fotoğrafı (Vercel Blob) *(opsiyonel ama önerilir)*

Vercel sunucusuz ortamda disk **salt okunur**; `/api/uploads` yerel `public/uploads/` yazamaz. Profil fotoğrafı için Blob gerekir.

### Blob store oluşturma

1. Vercel Dashboard → **pettrack-backend** projesi
2. Üst menüden **Storage** sekmesi
3. **Create Database** → **Blob** → **Continue**
4. **Access:** **Public** *(profil fotoğrafları herkese açık URL ile servis edilir)*
5. Store adı (ör. `pettrack-uploads`) → **Create**
6. **Connect to Project** → `pettrack-backend` seç → Production (+ Preview isteğe bağlı)
7. Vercel otomatik şu değişkenleri ekler:
   - `BLOB_READ_WRITE_TOKEN` *(veya yeni projelerde OIDC: `BLOB_STORE_ID` + `VERCEL_OIDC_TOKEN`)*
8. **Redeploy** — env değişkenleri yalnız yeni deploy'da yüklenir

### Doğrulama

Deploy sonrası profil sayfasından fotoğraf yükle. Başarılı olursa `imageUrl` şuna benzer bir URL olur:

```txt
https://....public.blob.vercel-storage.com/uploads/....
```

Detay: [Vercel Blob dokümantasyonu](https://vercel.com/docs/vercel-blob)

---

## Ortam değişkenleri checklist

### Backend (`pettrack-backend`)

```env
DATABASE_URL=postgresql://...@....neon.tech/neondb?sslmode=require
FRONTEND_ORIGIN=https://pettrack-frontend.vercel.app
GEMINI_API_KEY=...
GEMINI_MODEL=gemini-2.5-flash
GEMINI_THINKING_BUDGET=0
# Blob bağlandıysa otomatik:
# BLOB_READ_WRITE_TOKEN=...
```

### Frontend (`pettrack-frontend`)

```env
NEXT_PUBLIC_API_URL=https://pettrack-backend.vercel.app
```

---

## Sorun giderme

| Belirti | Olası neden | Çözüm |
|---------|-------------|--------|
| "Kayıt bulunamadı" / boş profil | Neon'da henüz pet yok | Canlı siteden yeni hayvan ekle |
| CORS hatası | `FRONTEND_ORIGIN` yanlış | Backend env güncelle + redeploy |
| API 500 / DB hatası | `DATABASE_URL` eksik veya şema yok | Neon URI + `prisma db push` |
| "Dosya yükleme başarısız oldu" | Blob kurulmamış | ADIM 7 — Storage → Blob |
| AI yanıt vermiyor | `GEMINI_API_KEY` eksik | Backend env + redeploy |

---

## Python uç noktaları (Vercel, opsiyonel)

| Method | Uç |
|--------|-----|
| GET | `/api/ai/health` |
| GET | `/api/ai/questions/daily` |
| CRUD | `/api/ai/entries` |

Yerelde (port 1572): `/api/questions/daily`, `/api/entries`
