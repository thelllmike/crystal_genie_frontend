import 'dart:async';
import 'package:flutter/material.dart';

class SplashScreen extends StatefulWidget {
  /// How long to show the splash before navigating on
  final Duration duration;
  /// The route name to push after the splash
  final String nextRoute;

  const SplashScreen({
    Key? key,
    this.duration = const Duration(seconds: 3),
    this.nextRoute = '/TakePhotoScreen',
  }) : super(key: key);

  @override
  _SplashScreenState createState() => _SplashScreenState();
}

class _SplashScreenState extends State<SplashScreen>
    with SingleTickerProviderStateMixin {
  late final AnimationController _animController;
  late final Animation<double> _fadeAnim;

  @override
  void initState() {
    super.initState();

    // Fade‐in animation for logo
    _animController = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 800),
    );
    _fadeAnim = CurvedAnimation(
      parent: _animController,
      curve: Curves.easeIn,
    );
    _animController.forward();

    // After [duration], navigate to next screen
    Timer(widget.duration, () {
      Navigator.of(context).pushReplacementNamed(widget.nextRoute);
    });
  }

  @override
  void dispose() {
    _animController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Stack(
        fit: StackFit.expand,
        children: [
          // Background image
          Image.asset(
            'assets/images/bg.png',
            fit: BoxFit.cover,
          ),

          // Semi‐transparent overlay (optional)
          Container(
            color: Colors.black.withOpacity(0.2),
          ),

          // Centered logo + title
          FadeTransition(
            opacity: _fadeAnim,
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                Image.asset(
                  'assets/images/logo.png',
                  width: 120,
                  height: 120,
                ),
                // const SizedBox(height: 24),
               
              ],
            ),
          ),
        ],
      ),
    );
  }
}
