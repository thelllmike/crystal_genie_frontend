import 'package:flutter/material.dart';

/// How a [SmoothPageRoute] animates itself in.
enum SmoothTransition {
  /// Cross-fade with a gentle scale-up. Used for top-level pages (the ones
  /// reachable from the bottom nav) where there is no sense of hierarchy.
  fade,

  /// Slides in from the right while fading. Used for drill-down pages such as
  /// crystal details, the shop or the cart.
  slide,
}

/// Replaces [MaterialPageRoute] app-wide so navigation feels soft instead of
/// snapping between screens.
class SmoothPageRoute<T> extends PageRouteBuilder<T> {
  SmoothPageRoute({
    required WidgetBuilder builder,
    super.settings,
    SmoothTransition transition = SmoothTransition.fade,
  }) : super(
          transitionDuration: const Duration(milliseconds: 350),
          reverseTransitionDuration: const Duration(milliseconds: 280),
          pageBuilder: (context, _, __) => builder(context),
          transitionsBuilder: (_, animation, __, child) =>
              _transition(transition, animation, child),
        );

  static Widget _transition(
    SmoothTransition transition,
    Animation<double> animation,
    Widget child,
  ) {
    final curved = CurvedAnimation(
      parent: animation,
      curve: Curves.easeOutCubic,
      reverseCurve: Curves.easeInCubic,
    );

    switch (transition) {
      case SmoothTransition.fade:
        return FadeTransition(
          opacity: curved,
          child: ScaleTransition(
            scale: Tween<double>(begin: 0.96, end: 1.0).animate(curved),
            child: child,
          ),
        );
      case SmoothTransition.slide:
        return SlideTransition(
          position: Tween<Offset>(
            begin: const Offset(0.15, 0),
            end: Offset.zero,
          ).animate(curved),
          child: FadeTransition(opacity: curved, child: child),
        );
    }
  }
}
