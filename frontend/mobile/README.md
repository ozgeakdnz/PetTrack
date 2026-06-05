# PetTrack (Flutter mobil)

Bu klasör, paylaştığınız mobil arayüz tasarımlarına göre oluşturulmuş bir Flutter uygulamasıdır. Marka adı **PetTrack** olarak kullanılmıştır.

## Gereksinimler

- [Flutter SDK](https://docs.flutter.dev/get-started/install) (Dart ile birlikte gelir)

## Çalıştırma

```bash
cd frontend/mobile
flutter pub get
flutter run
```

Backend API'nin çalışıyor olması gerekir (`npm run dev` — port **1571**). Simülatörde varsayılan `http://localhost:1571` kullanılır; fiziksel cihazda `--dart-define=NEXT_API_BASE=http://BILGISAYAR_IP:1571` geçin.

## Ekranlar

| Ekran | Dosya | API |
|-------|-------|-----|
| Profil | `screens/profile_screen.dart` | `/api/pets`, `/api/uploads` |
| Aşı Takvimi | `screens/calendar_screen.dart` | (mock + takvim UI) |
| Sağlık Günlüğü | `screens/health_diary_screen.dart` | `/api/symptoms` |
| Beslenme | `screens/nutrition_screen.dart` | (mock UI) |
| Pati Dostu AI | `screens/assistant_screen.dart` | `/api/chat` |

Alt navigasyon ortasındaki robot veya sağ alttaki **Pati Dostu** FAB → AI sayfası.

## Platform klasörleri (`android/`, `ios/`, …)

Bu projede `flutter create` ile **Android, iOS, Linux, macOS, Windows ve Web** için standart Flutter iskeleti oluşturulmuştur (repo örneğindeki gibi `settings.gradle.kts`, `Runner`, `gradle/wrapper`, vb.).

Eksik dosya görürseniz (başka bir makinede klonladıysanız):

```bash
cd mobile
flutter create . --platforms=android,ios,linux,macos,windows,web
flutter pub get
```

`pubspec.yaml` içinde `intl` sürümü, `flutter_localizations` ile uyumlu olacak şekilde **^0.20.2** tutulur.

## Görseller

Tasarımdaki fotoğrafların birebir aynısı için `assets/images/` altındaki dosyaları kendi görsellerinizle değiştirebilirsiniz:

- `pamuk_avatar.png` — profil avatarı  
- `user_avatar.png` — üst bar avatar  
- `meal_dry.png`, `meal_wet.png`, `meal_evening.png` — öğün küçük görselleri  

Şu an klasörde düzen için düz renk yer tutucu PNG’ler bulunur.
