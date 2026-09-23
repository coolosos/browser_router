import 'package:flutter/widgets.dart';

/// Modern Web & Material 3 Fade Scale Transition.
///
/// Entering surfaces scale smoothly from 0.95 -> 1.0 while fading in (0.0 -> 1.0).
/// Exiting surfaces scale down to 0.95 and fade out (1.0 -> 0.0).
class FadeScale extends StatelessWidget {
  new({
    required this.animation,
    required this.secondaryAnimation,
    required this.child,
    super.key,
  })  : _primaryOpacity = CurvedAnimation(
          parent: animation,
          curve: Curves.fastEaseInToSlowEaseOut,
          reverseCurve: Curves.fastEaseInToSlowEaseOut.flipped,
        ),
        _primaryScale = Tween<double>(begin: 0.95, end: 1).animate(
          CurvedAnimation(
            parent: animation,
            curve: Curves.fastEaseInToSlowEaseOut,
            reverseCurve: Curves.fastEaseInToSlowEaseOut.flipped,
          ),
        ),
        _secondaryOpacity = Tween<double>(begin: 1, end: 0).animate(
          CurvedAnimation(
            parent: secondaryAnimation,
            curve: Curves.fastEaseInToSlowEaseOut,
            reverseCurve: Curves.fastEaseInToSlowEaseOut.flipped,
          ),
        ),
        _secondaryScale = Tween<double>(begin: 1, end: 0.95).animate(
          CurvedAnimation(
            parent: secondaryAnimation,
            curve: Curves.fastEaseInToSlowEaseOut,
            reverseCurve: Curves.fastEaseInToSlowEaseOut.flipped,
          ),
        );

  final Animation<double> animation;
  final Animation<double> secondaryAnimation;
  final Widget child;

  final Animation<double> _primaryOpacity;
  final Animation<double> _primaryScale;
  final Animation<double> _secondaryOpacity;
  final Animation<double> _secondaryScale;

  @override
  Widget build(BuildContext context) {
    return FadeTransition(
      opacity: _secondaryOpacity,
      child: ScaleTransition(
        scale: _secondaryScale,
        child: FadeTransition(
          opacity: _primaryOpacity,
          child: ScaleTransition(
            scale: _primaryScale,
            child: child,
          ),
        ),
      ),
    );
  }
}
