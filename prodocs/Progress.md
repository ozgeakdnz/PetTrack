# PetTrack — Progress Log

Yapılan işler, alınan kararlar ve karşılaşılan hataların kaydı.

## 2026-06-05 — Repo yapısı ve teslim düzeni

- **Karar:** Teslim gereksinimine uygun klasör yapısı: `frontend/`, `backend/`, `prodocs/`.
- **Yapıldı:** `mobile/` → `frontend/mobile/` (Flutter iOS/Android).
- **Yapıldı:** `backend-py/` → `backend/py/` (FastAPI diary servisi).
- **Yapıldı:** Zorunlu dokümanlar `prodocs/` altında: PRD, tech-stack, Plan, DesignSystem, Progress.
- **Yapıldı:** AI ajan referansları `prodocs/agent/` altına taşındı.

## 2026-06-05 — Veritabanı kurulumu

- **Problem:** “Evcil hayvan oluşturulamadı” — `DATABASE_URL` placeholder ve tablolar yoktu.
- **Çözüm:** `pettrack` PostgreSQL veritabanı oluşturuldu; Prisma migration (`20260605164016_init`) uygulandı.
- **Env:** `backend/.env` → `postgresql://ozge@localhost:5432/pettrack` (yerel Homebrew PostgreSQL).
- **Ek:** `backend/docker-compose.yml` (isteğe bağlı Docker PostgreSQL, port 5433).

## 2026-06-05 — Marka ve port

- **Marka:** Tüm “Vet-Health” referansları “PetTrack” olarak güncellendi.
- **Port:** Web arayüzü **1575**, API **1571**, Python API **1572**.

## Bilinen sapmalar (PRD ↔ repo)

| PRD | Repo |
|-----|------|
| iOS native (SwiftUI) hedef | Flutter pilot (`frontend/mobile/`) + Next.js web |
| `/api/vaccinations` | `/api/calendar` (Vaccination modeli) |
| Belirti export PDF | CSV export (`belirti-kayitlari.csv`) |

## Sonraki adımlar

- [ ] `ownerId` ile çok kiracılı erişim kontrolleri
- [ ] Auth (Apple Sign-In / JWT) — Faz 2
- [ ] Mobil uygulamanın canlı API ile entegrasyon testi
- [ ] Üretim deploy (Vercel + Supabase)
