# prodocs — Geliştirme referansları

> PetTrack projesinin **anayasası**, **mimari haritası** ve **ilerleme günlüğü** burada yaşar.  
> İnsan geliştiriciler, eğitmenler ve yapay zeka ajanları için tek kaynak klasör.

---

## Zorunlu belgeler

| Dosya | Ne işe yarar? | Okuma sırası |
|-------|---------------|--------------|
| [**PRD.md**](./PRD.md) | Çözülen problem, hedef kullanıcı, özellikler, API ve kapsam | 1 |
| [**tech-stack.md**](./tech-stack.md) | Teknoloji seçimleri, Gemini entegrasyonu, AI kullanımı | 2 |
| [**Plan.md**](./Plan.md) | PRD'den türetilen adımlar, user story'ler, tamamlanma durumu | 3 |
| [**DesignSystem.md**](./DesignSystem.md) | Renk, tipografi, bileşen ve layout kuralları | 4 |
| [**Progress.md**](./Progress.md) | Yapılan işler, kararlar, hatalar, bilinen sapmalar | 5 |

---

## Ek referanslar

| Yol | Açıklama |
|-----|----------|
| [er-diagram.md](./er-diagram.md) | Veritabanı modeli ve ilişki diyagramı |
| [agent/rules/](./agent/rules/) | Cursor / AI kodlama kuralları |
| [agent/commands/](./agent/commands/) | Sık kullanılan geliştirme komutları |

---

## Hızlı mimari özeti

```
┌─────────────────┐     ┌─────────────────┐
│  frontend/      │     │ frontend/mobile/│
│  Next.js (1575) │     │ Flutter iOS/Android
└────────┬────────┘     └────────┬────────┘
         │    NEXT_PUBLIC_API_URL
         └──────────┬────────────┘
                    ▼
         ┌──────────────────────┐
         │  backend/ (1571)     │
         │  REST API + Prisma   │
         └──────────┬───────────┘
                    │
         ┌──────────┴───────────┐
         ▼                      ▼
   PostgreSQL            Google Gemini
   (yerel / Supabase)    (Pati Dostu AI)
```

---

## AI ajanları için kısa talimat

1. **API değişikliği** → `backend/app/api/**` + `backend/prisma/schema.prisma`
2. **Web UI** → `frontend/app/**`, `frontend/components/**`, `frontend/lib/api.ts`
3. **Mobil** → `frontend/mobile/lib/**`, asla frontend'e Prisma ekleme
4. **Pati Dostu** → `backend/lib/pati-dostu-prompt.ts`, `backend/app/api/chat/route.ts`
5. Her anlamlı değişiklikten sonra **Progress.md** güncelle
