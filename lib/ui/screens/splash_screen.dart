import 'dart:async';
import 'package:flutter/material.dart';

import '../../app_router.dart';
import '../../core/services/auth_service.dart';
import '../widgets/cg.dart';

class SplashScreen extends StatefulWidget {
  /// How long to show the splash before navigating on
  final Duration duration;

  const SplashScreen({
    Key? key,
    this.duration = const Duration(seconds: 3),
  }) : super(key: key);

  @override
  _SplashScreenState createState() => _SplashScreenState();
}

class _SplashScreenState extends State<SplashScreen>
    with TickerProviderStateMixin {
  late final AnimationController _animController;
  late final Animation<double> _fadeAnim;
  late final AnimationController _progress;

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
    _progress = AnimationController(vsync: this, duration: widget.duration)
      ..forward();

    // After [duration], go home when a session exists, otherwise to login
    Timer(widget.duration, () {
      if (!mounted) return;
      Navigator.of(context).pushReplacementNamed(
        AuthService.isLoggedIn ? AppRouter.home : AppRouter.login,
      );
    });
  }

  @override
  void dispose() {
    _animController.dispose();
    _progress.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return CGPage(
      glow: CG.violet,
      glowTop: 80,
      glowSize: 760,
      rings: true,
      ringsTop: 230,
      child: FadeTransition(
        opacity: _fadeAnim,
        child: SafeArea(
          child: Column(
            children: [
              const Spacer(),
              const GemCluster(color: Color(0xFFA98BFF), width: 170, height: 200),
              const SizedBox(height: 36),
              Text('Crystal Genie', style: CG.display(46)),
              const SizedBox(height: 12),
              Text(
                'Hold a stone to the light.\nWe\'ll tell you what it is.',
                textAlign: TextAlign.center,
                style: CG.sub(16),
              ),
              const Spacer(),
              ClipRRect(
                borderRadius: BorderRadius.circular(2),
                child: SizedBox(
                  width: 56,
                  height: 3,
                  child: AnimatedBuilder(
                    animation: _progress,
                    builder: (_, __) => LinearProgressIndicator(
                      value: _progress.value,
                      backgroundColor: CG.s3,
                      color: CG.brand,
                    ),
                  ),
                ),
              ),
              const SizedBox(height: 56),
            ],
          ),
        ),
      ),
    );
  }
}
