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
/// * Production: the VPS, reachable over HTTPS at its Hostinger hostname.
///   Plain http:// is blocked by default on both Android and iOS, so a
///   released build needs the certificate.
///
/// Once `api.crystalgenie.com` has an A record pointing at 187.127.213.241,
/// run `certbot --nginx -d api.crystalgenie.com` on the server and change the
/// default below — nothing else needs to move.
class ApiConfig {
  static const String baseUrl = String.fromEnvironment(
    'API_BASE_URL',
    defaultValue: 'https://srv1866657.hstgr.cloud',
  );
}
