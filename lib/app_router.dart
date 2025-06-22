import 'package:crystal_genie/ui/screens/TakePhotoScreen.dart';
import 'package:flutter/widgets.dart';
import 'ui/screens/home_screen.dart';
import 'ui/screens/splash_screen.dart';


/// Centralized route configuration for the Crystal Genie app.
class AppRouter {
  // Route names
  static const String splash     = '/';
  static const String home       = '/home';
  static const String takePhoto  = '/take-photo';
  // add more route names here...

  /// A centralized [routes] map
  static Map<String, WidgetBuilder> get routes => {
        splash:   (_) => const SplashScreen(
                      duration: Duration(seconds: 3),
                      nextRoute: takePhoto,
                    ),
        home:     (_) => const HomeScreen(),
        takePhoto:(_) => const TakePhotoScreen(),
        // new screen: (_) => const AnotherScreen(),
      };
}