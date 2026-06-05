# prodocs — Geliştirme referansları

> PetTrack projesinin **anayasası**, **mimari haritası** ve **ilerleme günlüğü**.  
> İnsan geliştiriciler, eğitmenler ve yapay zeka ajanları için tek kaynak klasör.

---

## 📚 Zorunlu belgeler

| # | Dosya | Ne işe yarar? |
|---|-------|----------------|
| 1 | [**PRD.md**](./PRD.md) | Çözülen problem, hedef kullanıcı, özellikler, API, kapsam |
| 2 | [**tech-stack.md**](./tech-stack.md) | Teknoloji seçimleri, Gemini entegrasyonu, AI kullanımı |
| 3 | [**Plan.md**](./Plan.md) | PRD'den türetilen adımlar, user story'ler, tamamlanma durumu |
| 4 | [**DesignSystem.md**](./DesignSystem.md) | Renk, tipografi, bileşen ve layout kuralları |
| 5 | [**Progress.md**](./Progress.md) | Tarihli ilerleme günlüğü, kararlar, hatalar |

---

## 🗂 Ek referanslar

| Yol | Açıklama |
|-----|----------|
| [er-diagram.md](./er-diagram.md) | Veritabanı modeli diyagramı |
| [agent/rules/](./agent/rules/) | Cursor / AI kodlama kuralları |
| [agent/commands/](./agent/commands/) | Sık kullanılan geliştirme komutları |
| [../docs/screenshots/](../docs/screenshots/) | README ekran görüntüleri |

---

## 🏗 Hızlı mimari

```
frontend/ (1575)  ──┐
mobile/ (Flutter) ──┼──► backend/ (1571) ──► PostgreSQL
                    │              └──► Google Gemini
```

---

## 🤖 AI ajanları için talimat

1. **API** → `backend/app/api/**` + `backend/prisma/schema.prisma`
2. **Web UI** → `frontend/app/**`, `frontend/lib/api.ts`
3. **Mobil** → `frontend/mobile/lib/**` — frontend'e Prisma ekleme
4. **Pati Dostu** → `backend/lib/pati-dostu-prompt.ts`, `chat/route.ts`
5. Fetch her zaman `apiUrl("/api/...")` — göreli `/api` yok
6. Anlamlı değişiklik → **Progress.md** güncelle

---

## 🔗 Dış bağlantılar

| Kaynak | URL |
|--------|-----|
| Kök README | [../README.md](../README.md) |
| Env şablonu | [../.env.example](../.env.example) |
| Gemini API key | https://aistudio.google.com/apikey |
