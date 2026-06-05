# PetTrack — Ekran görüntüleri

| Klasör | İçerik |
|--------|--------|
| `web/` | Masaüstü web arayüzü (Next.js, 1440px) |
| `mobile/` | Flutter iOS simülatörü |
| `mobile-web/` | Web arayüzü mobil viewport (390×844) |

Yeni görüntü almak için:

```bash
# Web (dev sunucusu çalışırken)
npx playwright screenshot --wait-for-timeout=3000 --full-page http://localhost:1575/pets docs/screenshots/web/pets.png

# iOS simülatör
xcrun simctl io booted screenshot docs/screenshots/mobile/ekran.png
```
