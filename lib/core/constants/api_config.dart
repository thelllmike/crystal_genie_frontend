/// Where the FastAPI backend lives.
///
/// Every service reads [baseUrl] — detection, payments, order emails and
/// subscriptions. Change it here, or override it at build time without
/// touching this file:
///
/// ```sh
/// flutter run --dart-define=API_BASE_URL=http://187.127.213.241
/// ```
///
/// * Local dev on an emulator: `http://10.0.2.2:8000` (Android) or
///   `http://localhost:8000` (iOS simulator).
/// * Local dev on a USB device: `http://localhost:8000` plus
///   `adb reverse tcp:8000 tcp:8000`.
/// * Production: your server's HTTPS URL, e.g. `https://api.crystalgenie.com`.
///   Plain http:// is blocked by default on both Android and iOS, so a
///   released build needs the certificate.
class ApiConfig {
  static const String baseUrl = String.fromEnvironment(
    'API_BASE_URL',
    defaultValue: 'https://api.crystalgenie.com',
  );
}
