/// Stripe client configuration.
///
/// The **publishable** key is safe to ship in the app — it can only create
/// tokens, never move money. The matching **secret** key lives only in the
/// backend `.env` (STRIPE_SECRET_KEY) and must never appear here.
class StripeConfig {
  /// From the Stripe dashboard → Developers → API keys. Use the `pk_test_…`
  /// key while developing and swap to `pk_live_…` for production.
  static const String publishableKey =
      'pk_live_51THzYKQga9B5kuEuENICW1y4wTWRt9ZvW3tS88daK619fTRaZm1P496CntpTStx182AtjlffZ5osxk1b0Sbaumhi00tswD7s2V';

  /// Shown on the payment sheet and in the customer's card statement line.
  static const String merchantDisplayName = 'Crystal Genie';
}
