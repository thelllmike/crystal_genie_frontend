/// App Store settings and the legal links Apple requires next to a
/// subscription offer (guideline 3.1.2) and inside the app (5.1.1).
class AppStoreConfig {
  /// Auto-renewable subscription created in App Store Connect → your app →
  /// Monetization → Subscriptions. Must match exactly.
  static const String premiumProductId = 'com.crystalgenie.app.premium.monthly';

  /// Must be a live page before submitting — App Review opens it.
  static const String privacyPolicyUrl =
      'https://crystalgenie.com/privacy-policy';

  /// Apple's standard licence agreement, which covers apps that don't ship
  /// their own terms.
  static const String termsOfUseUrl =
      'https://www.apple.com/legal/internet-services/itunes/dev/stdeula/';

  /// Where iPhone users cancel; Apple doesn't let apps cancel for them.
  static const String manageSubscriptionsUrl =
      'https://apps.apple.com/account/subscriptions';
}
