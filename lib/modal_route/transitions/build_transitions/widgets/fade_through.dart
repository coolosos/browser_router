import 'package:flutter/widgets.dart';

/// Material 3 & Modern Web Fade Through Transition.
///
/// Top-level destinations fade out while scaling down slightly (1.0 -> 0.96),
/// and incoming destinations fade in while scaling up (0.92 -> 1.0).
class FadeThrough extends StatelessWidget {
  new({
    required this.animation,
    required this.secondaryAnimation,
    required this.child,
    this.fillColor,
    super.key,
  })  : _primaryOpacity = CurvedAnimation(
          parent: animation,
          curve: const Interval(0.35, 1, curve: Curves.fastEaseInToSlowEaseOut),
        ),
        _primaryScale = Tween<double>(begin: 0.92, end: 1).animate(
          CurvedAnimation(
            parent: animation,
            curve: const Interval(0.35, 1, curve: Curves.fastEaseInToSlowEaseOut),
          ),
        ),
        _secondaryOpacity = Tween<double>(begin: 1, end: 0).animate(
          CurvedAnimation(
            parent: secondaryAnimation,
            curve: const Interval(0, 0.35, curve: Curves.fastEaseInToSlowEaseOut),
          ),
        ),
        _secondaryScale = Tween<double>(begin: 1, end: 0.96).animate(
          CurvedAnimation(
            parent: secondaryAnimation,
            curve: const Interval(0, 0.35, curve: Curves.fastEaseInToSlowEaseOut),
          ),
        );

  final Animation<double> animation;
  final Animation<double> secondaryAnimation;
  final Widget child;
  final Color? fillColor;

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
