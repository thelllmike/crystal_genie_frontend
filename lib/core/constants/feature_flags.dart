/// On/off switches for features that are built but not shown yet.
class FeatureFlags {
  /// Crystal photos uploaded from the admin panel. Off for now: Explore and
  /// crystal details show no picture. Set to true to show them.
  static const bool showCrystalPhotos = false;

  /// The picture on "Recent finds" (home) and "Saved crystals" cards. Off for
  /// now: the cards show text only. Set to true to bring the picture back.
  static const bool showFindImages = false;
}
