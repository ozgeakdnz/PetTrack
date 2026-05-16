/// PetTrack API taban adresleri.
///
/// - [nextApiBase]: Next.js + Prisma (varsayılan 1571)
/// - [pyApiBase]: FastAPI diary / günlük soru (varsayılan 1572)
///
/// Fiziksel cihazda `localhost` yerine bilgisayarınızın LAN IP'sini kullanın.
class ApiConfig {
  ApiConfig._();

  static const String nextApiBase = String.fromEnvironment(
    'NEXT_API_BASE',
    defaultValue: 'http://localhost:1571',
  );

  static const String pyApiBase = String.fromEnvironment(
    'PY_API_BASE',
    defaultValue: 'http://localhost:1572',
  );

  static String nextApi(String path) {
    final normalized = path.startsWith('/') ? path : '/$path';
    return '$nextApiBase$normalized';
  }

  static String pyApi(String path) {
    final normalized = path.startsWith('/') ? path : '/$path';
    return '$pyApiBase$normalized';
  }
}
