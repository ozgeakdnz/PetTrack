# PetTrack — Design System

> Web (`frontend/`) ve mobil (`frontend/mobile/`) için görsel dil, bileşen kuralları ve tutarlılık rehberi.

---

## Marka özü

| | |
|---|---|
| **His** | Sakin, güven veren, veteriner kliniği sıcaklığı — soğuk teknoloji değil |
| **Ana renk** | Teal / yeşilimsi mavi — sağlık, doğa, pati |
| **Destek** | Slate gri tonları — okunabilir, modern |
| **Köşeler** | Generous radius (`rounded-2xl`, `rounded-[2rem]`) — yumuşak, dostane |
| **İkonografi** | Lucide (web) · Material Icons (mobil) |

---

## Renk paleti

### Web (Tailwind)

| Rol | Sınıflar | Kullanım |
|-----|----------|----------|
| **Arka plan** | `bg-slate-100` | Ana gövde |
| **Yüzey** | `bg-white`, `border-slate-200` | Kartlar, header |
| **Metin birincil** | `text-slate-900` | Başlıklar |
| **Metin ikincil** | `text-slate-500`, `text-slate-700` | Alt metin, gövde |
| **Marka / CTA** | `bg-teal-700`, `hover:bg-teal-800`, `text-teal-700` | Butonlar, linkler |
| **Marka açık** | `bg-teal-50`, `border-teal-200` | Sidebar Pati Dostu kartı |
| **Başarı** | `text-emerald-600`, `bg-emerald-500` | Online göstergesi |
| **Uyarı** | `bg-amber-50`, `border-amber-200`, `text-amber-900` | AI disclaimer |
| **Hata** | `bg-rose-50`, `text-rose-700` | Form / API hataları |

### Mobil (Flutter)

Dosya: `frontend/mobile/lib/theme/app_colors.dart`

| Token | Hex | Kullanım |
|-------|-----|----------|
| `primary` | `#2D6A61` | Butonlar, kullanıcı balonu |
| `primaryLight` | `#6BCBBA` | Gradyan, vurgu |
| `background` | `#F8F9FA` | Ekran arka planı |
| `textPrimary` | `#333333` | Gövde metni |
| `textSecondary` | `#888888` | İkincil metin |
| `urgent` | `#E57373` | Acil durum |
| `warning` | `#FFCC80` | Disclaimer kutusu |

---

## Tipografi

### Web

| Seviye | Sınıf | Örnek |
|--------|-------|-------|
| Sayfa başlığı | `text-2xl md:text-3xl font-bold tracking-tight` | "Pati Dostu Yapay Zeka" |
| Bölüm başlığı | `text-xl font-semibold` | Kart başlıkları |
| Profil sayfası hero | `text-4xl font-bold` | "Hayvan Profilleri" |
| Gövde | `text-sm md:text-base leading-relaxed` | Paragraflar |
| Etiket / meta | `text-xs`, `text-[11px]` | Zaman damgası, disclaimer |
| Form etiketi | `text-sm font-medium text-slate-700` | Input label |

Font: **Geist** — `frontend/app/globals.css` `@theme` değişkenleri.

### Mobil

| Seviye | Stil |
|--------|------|
| Ekran başlığı | `fontWeight: w800, fontSize: 17` |
| Gövde | `fontSize: 14, height: 1.4` |
| Küçük etiket | `fontSize: 11–12, letterSpacing: 0.5–0.8` |

---

## Bileşen kuralları

### AppShell (web navigasyon)

- Sol sidebar (md+): logo, nav linkleri, altta **Pati Dostu** teaser kartı
- Mobil: hamburger menü
- Nav aktif: teal vurgu
- **Kural:** İkinci tam ekran navigasyon katmanı ekleme

### Aktif pet rozeti

Dosya: `frontend/components/active-pet-avatar.tsx`

```
┌─────────────────────────────┐
│ [foto]  Minnoş              │
│         8 kg • 4 Yaş        │
└─────────────────────────────┘
```

- Pill form: `rounded-full border border-slate-200`
- Her sayfada sağ üst (global navbar'da değil)
- Mobil: `PtHeader` içinde avatar

### Kartlar

```
rounded-2xl | rounded-[2rem]
border border-slate-200
bg-white shadow-sm
hover:border-teal-200 (tıklanabilir kartlar)
```

### Butonlar

| Tür | Stil |
|-----|------|
| Birincil | `bg-teal-700 text-white rounded-full` |
| İkincil | `border border-slate-200 bg-white` |
| İkon | `rounded-full p-2.5 border border-slate-200` |

### Form elemanları

- Input: `rounded-xl border-slate-200`, focus ring teal
- Select / textarea: aynı dil

---

## Sayfa bazlı notlar

### Pati Dostu AI (`/assistant`)

- **Layout:** Tam genişlik header → iki sütun (sol: hızlı sorular, sağ: sohbet)
- **Sol panel:** Hızlı soru kartları + amber disclaimer (lg+)
- **Sohbet balonu:** Kullanıcı `bg-teal-800`, AI `bg-slate-100`
- **Bot avatar:** Teal daire + Bot ikonu
- **Alt mobil:** Disclaimer ayrı kart (lg:hidden)

### Takvim

- Bekliyor / Tamamlandı badge renkleri
- Aylık grid; hatırlatıcı kartları

### Sağlık günlüğü

- Şiddet: Düşük (yeşilimsi) · Orta (amber) · Yüksek (rose/kırmızı)

### Beslenme

- Öğün görselleri: `meal_dry.png`, `meal_wet.png`, `meal_evening.png`
- Diyet hedefleri kartları

---

## Mobil bileşenler

| Widget | Rol |
|--------|-----|
| `PtHeader` | Geri, başlık, bildirim, aktif pet avatar |
| `PtBottomNav` | 4 sekme + profil |
| `PtGradientButton` | Birincil CTA |
| `PtScreenShell` | Ortak padding / scroll |
| `PetSwitcherBar` | Pet değiştirme |

### Pati Dostu mobil

- Üst: bot avatar + ONLINE yeşil nokta
- Amber disclaimer bandı
- Yatay kaydırmalı **HIZLI SORULAR** kartları (200px genişlik)
- Sohbet balonları: kullanıcı teal, AI `#F2F4F4`

---

## İkonlar

| Platform | Kütüphane | Boyut |
|----------|-----------|-------|
| Web | lucide-react | `16–22px` nav, `18px` buton |
| Mobil | Material Icons | `20–24px` |

---

## Spacing & layout

| Kural | Değer |
|-------|-------|
| Sayfa yatay padding | `px-4 sm:px-6` (web) · `20px` (mobil) |
| Kart iç padding | `p-4` – `p-6` |
| Bölüm arası | `gap-4` – `gap-6` |
| Max content width | `max-w-7xl mx-auto` |

---

## Erişilebilirlik

- Butonlarda `aria-label` (ikon-only)
- Form label ↔ input ilişkisi
- Disclaimer her zaman görünür (AI sayfası)
- Dokunma hedefi mobilde min ~44px

---

## Kaçınılacaklar

- Tailwind dışı büyük CSS modülleri
- Her bileşende sıfırdan renk paleti
- AppShell dışında paralel navigasyon
- Frontend'e Prisma / doğrudan DB
- Göreli `/api/...` fetch (her zaman `apiUrl`)

---

## Referans dosyalar

| Dosya | İçerik |
|-------|--------|
| `frontend/app/globals.css` | Tema değişkenleri |
| `frontend/components/app-shell.tsx` | Nav + sidebar |
| `frontend/app/assistant/page.tsx` | AI layout referansı |
| `frontend/mobile/lib/theme/app_theme.dart` | Mobil tema |
| `.cursor/rules/design-system.mdc` | AI ajan UI kuralları |
