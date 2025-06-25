import 'package:crystal_genie/ui/screens/TakePhotoScreen.dart';
import 'package:crystal_genie/ui/screens/explore_screen.dart';
import 'package:crystal_genie/ui/screens/profile_screen.dart';
import 'package:crystal_genie/ui/screens/result_screen.dart';
import 'package:crystal_genie/ui/screens/saved_crystals_screen.dart';
import 'package:flutter/widgets.dart';
import 'ui/screens/home_screen.dart';
import 'ui/screens/splash_screen.dart';


/// Centralized route configuration for the Crystal Genie app.
class AppRouter {
  // Route names
  static const String splash     = '/';
  static const String home       = '/home';
  static const String takePhoto  = '/take-photo';
  static const String reslut  = '/reslut';
  static const String explore  = '/explore';
  static const String profile  = '/profile';
  static const String SavedCrystals  = '/SavedCrystals';
  // add more route names here...


  /// A centralized [routes] map
  static Map<String, WidgetBuilder> get routes => {
        splash:   (_) => const SplashScreen(
                      duration: Duration(seconds: 3),
                      nextRoute: SavedCrystals,
                    ),
        home:     (_) => const HomeScreen(),
        takePhoto:(_) => const TakePhotoScreen(),
        reslut:(_) => const ResultScreen(),
        explore:(_) => const ExploreScreen(),
        profile:(_) => const ProfileScreen(),
        SavedCrystals:(_) => const SavedCrystalsScreen(),
        
        // new screen: (_) => const AnotherScreen(),
      };
}