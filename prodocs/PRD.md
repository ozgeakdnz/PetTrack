# PetTrack — Ürün Gereksinim Dokümanı (PRD)

| | |
|---|---|
| **Proje** | PetTrack |
| **Aşama** | Faz 1 — MVP (Minimum Uygulanabilir Ürün) |
| **Platform** | Web (Next.js) + Mobil (Flutter, iOS & Android) |
| **Durum** | ✅ MVP canlıda — [pettrack-frontend.vercel.app](https://pettrack-frontend.vercel.app) |
| **Son güncelleme** | 13 Haziran 2026 |

---

## 1. Problem ve vizyon

### Çözülen problem

Evcil hayvan sahipleri sağlık bilgilerini dağınık tutuyor: aşı tarihleri telefon notlarında, belirtiler hafızada, mama saatleri kafada. Veteriner randevusuna giderken geçmişi toparlamak zor; acil belirtilerde ne yapılacağı belirsiz kalıyor.

### Vizyon

**PetTrack**, evcil hayvan sahibinin tek uygulamada profil, aşı/randevu, belirti günlüğü ve beslenmeyi yönetmesini sağlar. **Pati Dostu** yapay zeka asistanı, kayıtlı verilere dayanarak semptom analizi ve bakım tavsiyesi sunar — profesyonel teşhisin yerini almaz, yönlendirir.

### Kuzey yıldızı metrikleri

| Metrik | Açıklama |
|--------|----------|
| **MAA kayıt** | Aylık aktif hayvan başına tamamlanan sağlık kaydı |
| **Kayıt yoğunluğu** | Kullanıcı başına aylık aşı + belirti + beslenme kaydı |
| **Retention** | 30 gün içinde geri dönen kullanıcı oranı |

---

## 2. Hedef kullanıcı

| Persona | İhtiyaç |
|---------|---------|
| **Çok evcil hayvan sahibi** | Minnoş (kedi) ve Leo (köpek) gibi profiller arasında geçiş; her biri için ayrı takvim ve belirti |
| **İlk kez sahip olan** | Aşı takvimi kurma, belirti kaydetme, ne zaman veterinere gitmeli sorusuna Pati Dostu ile yanıt |
| **Düzenli takip eden** | Beslenme planı, CSV export ile veteriner paylaşımı |

---

## 3. Temel özellikler (MVP)

### 3.1 Hayvan profilleri

- Tür: kedi, köpek, kuş
- Ad, ırk, cinsiyet, doğum tarihi, kilo, profil fotoğrafı
- Birden fazla pet; **aktif pet** seçimi (web + mobil)
- Profil silme (web + mobil)

### 3.2 Takvim (aşı & randevu)

- Hatırlatıcı ekleme: ad, tarih, isteğe bağlı sonraki tarih, not
- Durum: **Bekliyor** / **Tamamlandı**
- Aylık takvim görünümü; pet bazlı filtreleme

> **Not:** PRD taslağındaki `/api/vaccinations` uç noktası repoda **`/api/calendar`** olarak uygulandı (aynı `Vaccination` modeli).

### 3.3 Sağlık günlüğü (belirtiler)

- Belirti türü, açıklama, şiddet (Düşük / Orta / Yüksek), tarih
- Sayfalı liste; pet bazlı filtre
- **CSV dışa aktarma** (`belirti-kayitlari.csv`) — PDF yerine CSV (MVP kararı)

### 3.4 Beslenme

- Günlük kalori hedefi ve diyet hedefleri (kilo koruma / verme / alma)
- Öğün planlayıcı: mama adı, miktar, saat, tekrar
- Öğün onaylama (Tamamlandı / Bekliyor)
- Beslenme özeti API (`/api/nutrition/summary`)

### 3.5 Pati Dostu — Yapay Zeka Asistanı

| Özellik | Detay |
|---------|--------|
| **Motor** | Google Gemini (`gemini-2.5-flash`) — REST API |
| **Entegrasyon** | `POST /api/chat` — backend üzerinden; API key sunucuda |
| **Kişiselleştirme** | Aktif pet adı, kilo, yaş; son belirtiler, aşılar, öğünler prompt'a eklenir |
| **Arayüz** | Web `/assistant` + mobil `AssistantScreen` |
| **Güvenlik** | Günlük/dakikalık kota, mesaj uzunluğu sınırı, tıbbi disclaimer |
| **Fallback** | API key yoksa veya kota dolunca anahtar kelime tabanlı yanıt |

---

## 4. Teknoloji yığını

| Katman | Teknoloji |
|--------|-----------|
| Web istemci | Next.js 16, React 19, Tailwind CSS 4 |
| Mobil istemci | Flutter (iOS & Android) |
| Backend API | Next.js Route Handlers, TypeScript |
| Veritabanı | PostgreSQL + Prisma 7 |
| Yapay zeka | Google Gemini API |
| Kimlik (MVP) | `ownerId` string — Faz 2'de JWT / Apple Sign-In |
| Barındırma | Vercel (web + API) + Neon PostgreSQL |

Detay: [`tech-stack.md`](./tech-stack.md)

---

## 5. Veri modeli

```
Pet ──┬── Vaccination (takvim)
      ├── SymptomLog (belirti)
      └── Nutrition (beslenme)
```

| Model | Önemli alanlar |
|-------|----------------|
| **Pet** | name, species, breed, imageUrl, gender, birthDate, weight, ownerId |
| **Vaccination** | name, date, nextDate, status, notes |
| **SymptomLog** | symptom, description, severity, createdAt |
| **Nutrition** | foodName, amount, frequency, feedTime, status, notes |

Tam şema: `backend/prisma/schema.prisma` · Diyagram: [`er-diagram.md`](./er-diagram.md)

---

## 6. API uç noktaları

| Method | Uç | Açıklama |
|--------|-----|----------|
| GET/POST | `/api/pets` | Liste / oluştur |
| GET/PATCH/DELETE | `/api/pets/[id]` | Detay / güncelle / sil |
| GET | `/api/pets/[id]/summary` | Dashboard özeti |
| GET/POST | `/api/calendar` | Aşı & randevu |
| PATCH/DELETE | `/api/calendar/[id]` | Tekil takvim |
| GET/POST | `/api/symptoms` | Belirti listesi / ekle |
| GET | `/api/symptoms/export` | CSV indir |
| GET/POST | `/api/nutrition` | Beslenme |
| PATCH/DELETE | `/api/nutrition/[id]` | Öğün güncelle |
| GET | `/api/nutrition/summary` | Beslenme özeti |
| POST | `/api/uploads` | Profil fotoğrafı |
| GET | `/api/chat?petId=` | Pati Dostu meta (karşılama, öneriler) |
| POST | `/api/chat` | Sohbet mesajı → Gemini yanıtı |

Tüm istekler JSON. Web: `frontend/lib/api.ts` · Mobil: `ApiService`

---

## 7. Ekranlar ve kullanıcı akışı

### Web (`frontend/app/`)

| Sayfa | Rota | İşlev |
|-------|------|-------|
| Hayvan profilleri | `/pets` | CRUD, aktif pet, profil sil |
| Takvim | `/calendar` | Aylık görünüm, hatırlatıcı |
| Sağlık günlüğü | `/symptoms` | Belirti listesi, ekle, CSV |
| Beslenme | `/nutrition` | Diyet hedefleri, öğün planı |
| Pati Dostu AI | `/assistant` | Sohbet, hızlı sorular |

Her sayfada sağ üstte **aktif pet rozeti** (foto, ad, kilo • yaş).

### Mobil (`frontend/mobile/lib/screens/`)

| Ekran | İşlev |
|-------|-------|
| `profile_screen` | Pet listesi, fotoğraf, sil |
| `calendar_screen` | Takvim, hatırlatıcı kartları |
| `health_diary_screen` | Belirti günlüğü |
| `nutrition_screen` | Beslenme & öğünler |
| `assistant_screen` | Pati Dostu sohbet |

Alt navigasyon + `PtHeader` (aktif pet avatarı).

---

## 8. User stories & kabul kriterleri

### EPIC 1 — Hayvan profili

**US 1.1 — Yeni hayvan ekle**

- **Hikâye:** Evcil hayvanımı sisteme ekleyerek takibini düzenli yapmak istiyorum.
- **Kabul:** Ad + tür + cinsiyet girilince `Pet` oluşur; listede görünür. Zorunlu alan boşsa hata mesajı.

**US 1.2 — Aktif pet seçimi** *(MVP genişlemesi)*

- **Kabul:** Seçilen pet tüm modüllerde filtre olarak kullanılır; localStorage (web) / scope (mobil) ile hatırlanır.

**US 1.3 — Profil silme** *(MVP genişlemesi)*

- **Kabul:** Onay sonrası pet ve ilişkili kayıtlar cascade silinir.

### EPIC 2 — Aşı & randevu

**US 2.1 — Hatırlatıcı ekle**

- **Kabul:** Takvim sayfasından aşı/randevu eklenir; Bekliyor/Tamamlandı güncellenir.

### EPIC 3 — Belirti & beslenme

**US 3.1 — Belirti kaydı**

- **Kabul:** Tarih, tür, şiddet ile `SymptomLog` oluşur; listede görünür.

**US 3.2 — Beslenme planı**

- **Kabul:** Öğün eklenir (PENDING); tamamlandı işaretlenebilir.

**US 3.3 — CSV export**

- **Kabul:** Belirtiler pet bazlı CSV olarak indirilir.

### EPIC 4 — Pati Dostu AI *(çekirdek AI özelliği)*

**US 4.1 — Semptom sorusu**

- **Hikâye:** Kedim iştahsız, ne yapmalıyım diye sormak istiyorum.
- **Kabul:** Gemini yanıt verir; aktif pet adı kullanılır; Sağlık Günlüğü'ne yönlendirme içerir; disclaimer görünür.

**US 4.2 — Kişiselleştirilmiş karşılama**

- **Kabul:** `GET /api/chat?petId=` ile pet adı, kilo, yaşa göre karşılama ve hızlı sorular döner.

---

## 9. Kapsam dışı (Faz 1)

- Veteriner randevu marketplace'i
- IoT / akıllı tasma entegrasyonu
- Otomatik AI teşhis motoru (Pati Dostu tavsiye verir, teşhis koymaz)
- Çoklu owner / rol-izin yönetimi
- Push notification (Faz 2)
- Tam kimlik doğrulama / JWT (Faz 2)

---

## 10. Faz 2 adayları

- Apple Sign-In + JWT
- Push hatırlatıcıları
- Offline-first mobil cache
- Üretim deploy + CI/CD
- Belirti export PDF
- iOS native (SwiftUI) — şu an Flutter pilot

---

## 11. Teslim kriterleri eşlemesi (8 hafta projesi)

| Kriter | PetTrack durumu |
|--------|-----------------|
| Etkileşimli uygulama | ✅ CRUD + DB + web + mobil |
| LLM API entegrasyonu | ✅ Gemini `/api/chat` |
| Frontend / Backend ayrımı | ✅ npm workspaces, REST API |
| Canlı deploy | ✅ [pettrack-frontend.vercel.app](https://pettrack-frontend.vercel.app) |
