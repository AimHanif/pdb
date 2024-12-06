// route_transitions.dart
import 'package:flutter/material.dart';

enum TransitionType { fade, slide, scale, rotation }

Route createRoute(Widget page, {TransitionType type = TransitionType.fade}) {
  return PageRouteBuilder(
    pageBuilder: (context, animation, secondaryAnimation) => page,
    transitionsBuilder: (context, animation, secondaryAnimation, child) {
      const curve = Curves.easeInOut; // Smoother animation with easeInOut

      final curvedAnimation = CurvedAnimation(
        parent: animation,
        curve: curve,
      );

      switch (type) {
        case TransitionType.slide:
          const begin = Offset(1.0, 0.0); // Slide in from the right
          const end = Offset.zero;

          var tween = Tween(begin: begin, end: end).chain(CurveTween(curve: curve));
          return SlideTransition(
            position: animation.drive(tween),
            child: child,
          );

        case TransitionType.scale:
          return ScaleTransition(
            scale: curvedAnimation, // Use CurvedAnimation for smoother scaling
            child: child,
          );

        case TransitionType.rotation:
          return RotationTransition(
            turns: curvedAnimation, // Use CurvedAnimation for smoother rotation
            child: child,
          );

        case TransitionType.fade:
        default:
          return FadeTransition(
            opacity: curvedAnimation, // Use CurvedAnimation for smoother fade
            child: child,
          );
      }
    },
    transitionDuration: const Duration(milliseconds: 500), // Slightly longer duration for smoother effect
  );
}
