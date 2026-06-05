# PetTrack — Design System

Web arayüzü (`frontend/`) için renk, tipografi ve bileşen kuralları.

## Renk

- **Arka plan:** `bg-slate-100` (ana gövde), kart ve header için `bg-white`.
- **Kenarlık:** `border-slate-200`; metin `text-slate-700` / `text-slate-900`; ikincil `text-slate-500`.
- **Marka / aksiyon:** teal — `text-teal-700`, `bg-teal-600`, `hover:bg-teal-700`, vurgu gölgeleri `shadow-teal-500/25`.
- **Durum:** başarı `emerald`, uyarı `amber`, hata `rose`.

## Yüzey ve derinlik

- Kartlar: `rounded-[2rem]` veya `rounded-3xl`, ince `border border-slate-200`, hafif gölge (`shadow-sm`).
- Bölüm başlıkları: `text-xl` / `text-2xl` / `text-3xl` + `font-semibold`.

## Tipografi

- Gövde: `text-sm` / `text-base`; form etiketleri `text-sm font-medium text-slate-700`.
- Layout’ta **Geist** font değişkenleri (`globals.css` `@theme`) korunmalı.

## İkonlar

- **lucide-react**; boyut `h-4 w-4` / `h-5 w-5` / `h-16 w-16` (hero).

## Layout

- Tüm sayfalar `AppShell` içinde: sidebar (md+) ve mobil hamburger menü.
- İkinci tam ekran navigasyon katmanı eklenmez.

## Mobil (Flutter)

- Tema: `frontend/mobile/lib/theme/app_colors.dart`
- Paylaşılan widget’lar: `frontend/mobile/lib/widgets/`

## Kaçınılacaklar

- Tailwind dışı büyük CSS modülleri veya her bileşende sıfırdan palet.
- `AppShell` dışında paralel navigasyon yapısı.
