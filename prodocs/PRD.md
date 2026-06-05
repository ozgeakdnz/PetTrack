# **TEKNIK URUN GEREKSINIM DOKUMANI (TECH PRD)**

**Proje Adi:** Pet Track

**Asama:** Faz 1 - MVP (Minimum Uygulanabilir Urun)

**Platform:** Sadece iOS (Native)

**Hazirlayan:** Teknik Product Owner

**Durum:** Taslak v1

## **1. Urun Vizyonu ve Is Hedefleri (Ozet)**

Pet Track, evcil hayvan sahiplerinin tek bir uygulama uzerinden hayvan profili, asi/randevu takibi, belirti gunlugu ve beslenme planini yonetmesini saglayan iOS odakli bir saglik takip urunudur.

* **Kuzey Yildizi Metrigi:** Aylik aktif hayvan (MAA) basi tamamlanan saglik kaydi adedi.
* **Basari Metrigi 1:** Kullanici basina aylik eklenen asi + belirti + beslenme kaydi sayisi.
* **Basari Metrigi 2:** 30 gun icinde geri donen kullanici orani (retention).

## **2. Teknoloji Yigini (Tech Stack) & Mimari**

MVP asamasinda hizli gelistirme, bakimi kolay bir backend ve premium iOS deneyimi icin asagidaki yapi hedeflenir:

* **Mobil Istemci (Frontend):** iOS Native (SwiftUI + Combine/async-await).  
* **Backend (API Katmani):** Next.js 16 (Route Handlers) - mevcut projedeki App Router altyapisi kullanilir.  
* **Veritabani:** PostgreSQL (Supabase) + Prisma ORM.  
* **Kimlik Dogrulama:** MVP'de ownerId tabanli basit oturum (faz 2'de Apple Sign-In/JWT).  
* **Barindirma:** Vercel (API) + Supabase (DB).  
* **Test Ortami:** Apple TestFlight.

## **3. VERITABANI SEMASI (POSTGRESQL / PRISMA)**

Mevcut Prisma semasina dayanan cekirdek veri modeli:

| **Tablo/Model** | **Alan** | **Tip** | **Kisitlar** | **Aciklama** |
| --- | --- | --- | --- | --- |
| **Pet** | id | UUID | PK, auto-gen | Evcil hayvan benzersiz kimligi |
|  | name | String | Not Null | Hayvan adi |
|  | species | Enum | CAT/DOG/BIRD | Tur bilgisi |
|  | breed | String? | Nullable | Irk bilgisi |
|  | imageUrl | String? | Nullable | Profil gorseli |
|  | gender | Enum | MALE/FEMALE/UNKNOWN | Cinsiyet |
|  | birthDate | DateTime? | Nullable | Yas hesaplama |
|  | weight | Float? | Nullable | Kilo takibi |
|  | ownerId | String | Not Null | Kaydin sahibi kullanici |
| **Vaccination** | id | UUID | PK, auto-gen | Asi kaydi kimligi |
|  | petId | UUID | FK -> Pet(id), Cascade | Hangi hayvana ait oldugu |
|  | name | String | Not Null | Asi/randevu adi |
|  | date | DateTime | Not Null | Uygulama tarihi |
|  | nextDate | DateTime? | Nullable | Sonraki tarih |
|  | status | Enum | COMPLETED/PENDING | Durum |
| **SymptomLog** | id | UUID | PK, auto-gen | Belirti kaydi kimligi |
|  | petId | UUID | FK -> Pet(id), Cascade | Ilgili hayvan |
|  | symptom | String | Not Null | Belirti basligi |
|  | description | String? | Nullable | Detay aciklama |
|  | severity | Enum | LOW/MEDIUM/HIGH | Siddet seviyesi |
|  | createdAt | DateTime | Default now() | Kayit zamani |
| **Nutrition** | id | UUID | PK, auto-gen | Beslenme kaydi kimligi |
|  | petId | UUID | FK -> Pet(id), Cascade | Ilgili hayvan |
|  | foodName | String | Not Null | Mama/ogun adi |
|  | amount | String | Not Null | Miktar |
|  | frequency | Int | Not Null | Gunluk tekrar sayisi |
|  | feedTime | String | Default "08:30" | Beslenme saati |
|  | status | Enum | COMPLETED/PENDING | O anki durum |

## **4. API UC NOKTALARI (NEXT.JS ROUTE HANDLERS - REST/JSON)**

iOS uygulamasinin haberlesecegi temel endpoint seti:

* **GET /api/pets?ownerId={ownerId}**  
  * **Islem:** Owner'a ait tum hayvan profillerini listeler.
* **POST /api/pets**  
  * **Payload:** `{ "name": "Luna", "species": "CAT", "gender": "FEMALE", "ownerId": "owner_123" }`  
  * **Islem:** Yeni hayvan profili olusturur.
* **GET /api/vaccinations?petId={petId}**  
  * **Islem:** Hayvanin asi/randevu kayitlarini getirir.
* **POST /api/vaccinations**  
  * **Payload:** `{ "petId": "uuid", "name": "Kuduz Asisi", "date": "2026-04-20T09:00:00Z", "status": "PENDING" }`
* **POST /api/symptoms**  
  * **Payload:** `{ "petId": "uuid", "symptom": "Istahsizlik", "severity": "MEDIUM", "description": "2 gundur az yiyor" }`
* **POST /api/nutrition**  
  * **Payload:** `{ "petId": "uuid", "foodName": "Somonlu Mama", "amount": "80g", "frequency": 2, "feedTime": "08:30" }`

## **5. EKRANLAR (SCREENS) VE KULLANICI AKISI (UI/UX)**

Arayuz hedefi: temiz, modern, iOS tasarim rehberlerine uygun, tek elle kullanim kolayligi yuksek bir deneyim.

1. **Splash & Onboarding**
   * Uygulama vaadini net anlatan 2-3 adimli onboarding.
   * "Basla" aksiyonu ile ana akisa gecis.
2. **Pet List / Dashboard**
   * Owner'a ait tum hayvan kartlari.
   * Ustte hizli ozet: bugunku planlanan asi/randevu ve beslenme durumu.
3. **Pet Detail**
   * Sekmeli yapi: `Asilar`, `Belirtiler`, `Beslenme`.
   * Son kayitlar, durum badge'leri ve hizli ekleme butonlari.
4. **Vaccination Add/Edit**
   * Tarih secici, durum secimi, not alani.
   * Gelecek randevu (`nextDate`) tanimi.
5. **Symptom Log Screen**
   * Belirti, siddet seviyesi ve aciklama girisi.
   * Zaman cizelgesi gorunumu.
6. **Nutrition Planner**
   * Ogun saati, miktar ve tekrar sayisi tanimlama.
   * Tamamlandi/Pending isaretleme.

## **6. USER STORIES & ACCEPTANCE CRITERIA (BACKLOG)**

### **EPIC 1: Hayvan Profili Yonetimi**

**US 1.1 - Yeni Hayvan Ekleme**

* **Hikaye:** Bir hayvan sahibi olarak evcil hayvanimi sisteme eklemek istiyorum ki takibini duzenli yapabileyim.  
* **Kabul Kriterleri:**  
  * **Given:** Kullanici dashboard ekranindadir.  
  * **When:** `Ad`, `Tur`, `Cinsiyet` ve `ownerId` bilgilerini girip kaydederse;  
  * **Then:** Sistem yeni `Pet` kaydini olusturur ve listeyi gunceller.  
  * **Hata Durumu:** Zorunlu alanlar bos ise inline hata mesaji gorunur.

### **EPIC 2: Asi ve Randevu Takibi**

**US 2.1 - Asi Kaydi Girme**

* **Hikaye:** Hayvanimin asi gecmisini ve gelecek randevusunu tek yerden takip etmek istiyorum.  
* **Kabul Kriterleri:**  
  * **Given:** Kullanici pet detay ekraninda `Asilar` sekmesindedir.  
  * **When:** Asi adi, tarih ve durum secip kaydederse;  
  * **Then:** `Vaccination` tablosuna kayit atilir ve listede gorunur.  
  * **And:** `nextDate` girildiyse gelecek planlarda isaretlenir.

### **EPIC 3: Belirti ve Beslenme Kaydi**

**US 3.1 - Belirti Gunlugu Kaydi**

* **Hikaye:** Belirti gecmisini kaydedip veteriner randevusunda daha net bilgi vermek istiyorum.  
* **Kabul Kriterleri:**  
  * **Given:** Kullanici belirtiler ekranindadir.  
  * **When:** Belirti ve siddet secip kaydederse;  
  * **Then:** Kayit `SymptomLog` tablosuna `createdAt` ile eklenir.

**US 3.2 - Beslenme Plani Kaydi**

* **Hikaye:** Gunluk ogun rutinini takip ederek beslenme duzenini kacirmamak istiyorum.  
* **Kabul Kriterleri:**  
  * **Given:** Kullanici beslenme ekranindadir.  
  * **When:** Yemek adi, miktar, saat ve frekans girerse;  
  * **Then:** Kayit `Nutrition` tablosuna eklenir ve varsayilan durum `PENDING` olur.  
  * **And:** Kullanici durumu `COMPLETED` olarak guncelleyebilir.

## **7. Kapsam Disi (Out of Scope - Faz 1 Icin)**

* Gercek zamanli veteriner randevu rezervasyon marketplace'i.
* IoT/smart collar cihaz entegrasyonlari.
* Gelismis AI tani/tedavi oneri motoru.
* Coklu owner rol-izin yonetimi (aile/klinigi kapsayan enterprise model).

## **8. Teknik Notlar ve Faz 2 Adaylari**

* Faz 2'de Apple Sign-In + JWT tabanli guclu kimlik dogrulama.
* Push notification ile asi ve beslenme hatirlaticilari.
* Offline-first cache (Core Data/SQLite) ve arka plan senkronizasyonu.
* Test kapsaminda unit + integration + UI test paketinin genisletilmesi.
