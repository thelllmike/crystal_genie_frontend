import 'package:crystal_genie/ui/screens/home_screen.dart';
import 'package:crystal_genie/ui/screens/splash_screen.dart';
import 'package:flutter/material.dart';

void main() {
  runApp(const CrystalGenieApp());
}

class CrystalGenieApp extends StatelessWidget {
  const CrystalGenieApp({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Crystal Genie',
      theme: ThemeData(primarySwatch: Colors.blue),
      initialRoute: '/',
      routes: {
        '/': (ctx) => const SplashScreen(
              duration: Duration(seconds: 3),
              nextRoute: '/home',
            ),
        '/home': (ctx) => const HomeScreen(),
      },
      debugShowCheckedModeBanner: false,
    );
  }
}
