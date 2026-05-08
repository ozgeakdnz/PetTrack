# PetTrack (Flutter mobil)

Bu klasör, paylaştığınız mobil arayüz tasarımlarına göre oluşturulmuş bir Flutter uygulamasıdır. Marka adı **PetTrack** olarak kullanılmıştır.

## Gereksinimler

- [Flutter SDK](https://docs.flutter.dev/get-started/install) (Dart ile birlikte gelir)

## Çalıştırma

```bash
cd mobile
flutter pub get
flutter run
```

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
