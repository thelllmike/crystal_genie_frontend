import 'package:crystal_genie/ui/screens/cart_screen.dart';
import 'package:crystal_genie/ui/screens/login_screen.dart';
import 'package:crystal_genie/ui/screens/profile_screen.dart';
import 'package:crystal_genie/ui/screens/saved_crystals_screen.dart';
import 'package:crystal_genie/ui/screens/shop_screen.dart';
import 'package:crystal_genie/ui/screens/signup_screen.dart';
import 'package:flutter/widgets.dart';
import 'ui/screens/main_shell.dart';
import 'ui/screens/splash_screen.dart';
import 'ui/widgets/page_transitions.dart';

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
        // The three nav-bar destinations all resolve to the same shell route;
        // switching between them never pushes a page (see [MainShell]).
        home: (_) => const MainShell(),
        takePhoto: (_) => const MainShell(initialIndex: MainShell.cameraTab),
        explore: (_) => const MainShell(initialIndex: MainShell.exploreTab),
        profile: (_) => const ProfileScreen(),
        savedCrystals: (_) => const SavedCrystalsScreen(),
        shop: (_) => const ShopScreen(),
        cart: (_) => const CartScreen(),
      };

  /// Drill-down pages slide in from the right; everything else cross-fades.
  static const Set<String> _slideRoutes = {
    signup,
    profile,
    savedCrystals,
    shop,
    cart,
  };

  /// Wraps every named route in a [SmoothPageRoute] so all navigation is
  /// animated. Used by `MaterialApp.onGenerateRoute`.
  static Route<dynamic>? onGenerateRoute(RouteSettings settings) {
    final builder = routes[settings.name];
    if (builder == null) return null;
    return SmoothPageRoute<void>(
      builder: builder,
      settings: settings,
      transition: _slideRoutes.contains(settings.name)
          ? SmoothTransition.slide
          : SmoothTransition.fade,
    );
  }
}
