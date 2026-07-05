import 'package:crystal_genie/ui/screens/TakePhotoScreen.dart';
import 'package:crystal_genie/ui/screens/cart_screen.dart';
import 'package:crystal_genie/ui/screens/explore_screen.dart';
import 'package:crystal_genie/ui/screens/login_screen.dart';
import 'package:crystal_genie/ui/screens/profile_screen.dart';
import 'package:crystal_genie/ui/screens/saved_crystals_screen.dart';
import 'package:crystal_genie/ui/screens/shop_screen.dart';
import 'package:crystal_genie/ui/screens/signup_screen.dart';
import 'package:flutter/widgets.dart';
import 'ui/screens/home_screen.dart';
import 'ui/screens/splash_screen.dart';

/// Centralized route configuration for the Crystal Genie app.
class AppRouter {
  // Route names
  static const String splash = '/';
  static const String login = '/login';
  static const String signup = '/signup';
  static const String home = '/home';
  static const String takePhoto = '/take-photo';
  static const String explore = '/explore';
  static const String profile = '/profile';
  static const String savedCrystals = '/saved-crystals';
  static const String shop = '/shop';
  static const String cart = '/cart';

  /// A centralized [routes] map
  static Map<String, WidgetBuilder> get routes => {
        splash: (_) => const SplashScreen(duration: Duration(seconds: 3)),
        login: (_) => const LoginScreen(),
        signup: (_) => const SignupScreen(),
        home: (_) => const HomeScreen(),
        takePhoto: (_) => const TakePhotoScreen(),
        explore: (_) => const ExploreScreen(),
        profile: (_) => const ProfileScreen(),
        savedCrystals: (_) => const SavedCrystalsScreen(),
        shop: (_) => const ShopScreen(),
        cart: (_) => const CartScreen(),
      };
}
