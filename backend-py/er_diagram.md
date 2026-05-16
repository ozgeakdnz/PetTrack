# PetTrack — Veri modeli (ER diyagramı)

Bu diyagram **PetTrack** projesinin hedef veri modelini tanımlar: sahip hesabı, evcil hayvan kayıtları (Next.js + Prisma, port **1571**), günlük diary / AI katmanı (`backend-py`, port **1572**).

| Katman | Konum | Durum |
|--------|--------|--------|
| `Pet`, `Vaccination`, `SymptomLog`, `Nutrition` | `backend/prisma/schema.prisma` | PostgreSQL’de uygulanmış |
| `User`, `Entry`, `AiInteraction` | `backend-py` + ileride Prisma | Hedef şema (aşağıdaki diyagram) |

---

## ER diyagramı

```mermaid
erDiagram
    USERS {
        uuid id PK
        varchar email
        varchar display_name
        boolean biometric_enabled
        time notification_time
        timestamp created_at
        timestamp updated_at
    }

    PETS {
        uuid id PK
        uuid owner_id FK
        varchar name
        enum species "CAT | DOG | BIRD"
        varchar breed
        varchar image_url
        enum gender "MALE | FEMALE | UNKNOWN"
        date birth_date
        float weight
    }

    VACCINATIONS {
        uuid id PK
        uuid pet_id FK
        varchar name
        timestamp date
        timestamp next_date
        enum status "COMPLETED | PENDING"
        text notes
    }

    SYMPTOM_LOGS {
        uuid id PK
        uuid pet_id FK
        varchar symptom
        text description
        enum severity "LOW | MEDIUM | HIGH"
        timestamp created_at
    }

    NUTRITIONS {
        uuid id PK
        uuid pet_id FK
        varchar food_name
        varchar amount
        int frequency
        varchar feed_time
        enum status "COMPLETED | PENDING"
        text notes
        timestamp created_at
    }

    ENTRIES {
        uuid id PK
        uuid user_id FK
        uuid pet_id FK "nullable — hangi hayvan için"
        date date
        text question
        text raw_text
        text enriched_text
        varchar tone
        int mood
        timestamp created_at
        timestamp updated_at
    }

    AI_INTERACTIONS {
        uuid id PK
        uuid user_id FK
        uuid pet_id FK "nullable"
        varchar prompt_type "daily_question | chat | enrich_entry"
        int token_usage
        timestamp created_at
    }

    USERS ||--o{ PETS : "sahiplenir"
    USERS ||--o{ ENTRIES : "yazar"
    USERS ||--o{ AI_INTERACTIONS : "üretir"
    PETS ||--o{ VACCINATIONS : "aşı kaydı"
    PETS ||--o{ SYMPTOM_LOGS : "semptom kaydı"
    PETS ||--o{ NUTRITIONS : "beslenme kaydı"
    PETS ||--o{ ENTRIES : "günlük bağlantısı"
    PETS ||--o{ AI_INTERACTIONS : "bağlam"
```

---

## Prisma ile eşleme (`backend/`)

| Diyagram | Prisma modeli | Not |
|----------|---------------|-----|
| `PETS` | `Pet` | `owner_id` → şemada `ownerId` (string; `User` tablosu henüz yok) |
| `VACCINATIONS` | `Vaccination` | |
| `SYMPTOM_LOGS` | `SymptomLog` | |
| `NUTRITIONS` | `Nutrition` | |

`USERS`, `ENTRIES` ve `AI_INTERACTIONS` henüz Prisma’da yok; `ownerId` şimdilik serbest metin / harici kimlik olarak kullanılıyor.

---

## `backend-py` ile eşleme

### Hedef (`ENTRIES` + günlük soru)

| Alan | Kaynak |
|------|--------|
| `question` | `GET /api/questions/daily` → `ai_service.generate_daily_question()` |
| `raw_text` | Kullanıcının günlük cevabı |
| `enriched_text` | AI ile zenginleştirilmiş metin (ileride) |
| `tone`, `mood` | AI çıktısı / kullanıcı seçimi |
| `pet_id` | İsteğe bağlı; hangi evcil hayvan için yazıldığı |

### Şu anki demo API (`routers/entries.py`)

Bellek içi kayıt; hedef şemaya geçişte alan eşlemesi:

| Demo alanı | Hedef alan |
|------------|------------|
| `title` | Kısa özet veya `question` özeti |
| `body` | `raw_text` |
| `pet_id` | `pet_id` |
| — | `user_id`, `date`, `enriched_text`, `tone`, `mood` eklenecek |

### AI etkileşimleri

| `prompt_type` | Servis |
|---------------|--------|
| `daily_question` | `backend-py` → `/api/questions/daily` |
| `chat` | `backend` → `/api/chat` (Pati Dostu) |
| `enrich_entry` | `backend-py` → `ai_service` (planlanan) |

---

## Endpoint özeti

### Next.js API (`:1571`)

| Kaynak | Örnek yol |
|--------|-----------|
| Evcil hayvan | `/api/pets` |
| Takvim / aşı | `/api/calendar` |
| Semptom | `/api/symptoms` |
| Beslenme | `/api/nutrition` |
| Sohbet | `/api/chat` |

### Python API (`:1572`)

| Metot | Yol | Açıklama |
|-------|-----|----------|
| GET | `/health` | Sağlık kontrolü |
| GET/POST | `/api/entries` | Günlük kayıtları (demo) |
| GET/PATCH/DELETE | `/api/entries/{id}` | Tek kayıt |
| GET | `/api/questions/daily` | Günlük soru → `ENTRIES.question` adayı |
