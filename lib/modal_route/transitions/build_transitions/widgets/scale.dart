import 'package:flutter/widgets.dart';

/// Clean Scale & Zoom transition for dialogs and popups.
class Scale extends StatelessWidget {
  new({
    required this.animation,
    required this.secondaryAnimation,
    required this.child,
    this.initialScale = 0.85,
    super.key,
  })  : _scale = Tween<double>(begin: initialScale, end: 1).animate(
          CurvedAnimation(
            parent: animation,
            curve: Curves.fastEaseInToSlowEaseOut,
            reverseCurve: Curves.fastEaseInToSlowEaseOut.flipped,
          ),
        ),
        _opacity = CurvedAnimation(
          parent: animation,
          curve: Curves.easeOut,
          reverseCurve: Curves.easeIn,
        ),
        _secondaryOpacity = Tween<double>(begin: 1, end: 0).animate(
          CurvedAnimation(
            parent: secondaryAnimation,
            curve: Curves.easeOut,
            reverseCurve: Curves.easeIn,
          ),
        );

  final Animation<double> animation;
  final Animation<double> secondaryAnimation;
  final Widget child;
  final double initialScale;

  final Animation<double> _scale;
  final Animation<double> _opacity;
  final Animation<double> _secondaryOpacity;

  @override
  Widget build(BuildContext context) {
    return FadeTransition(
      opacity: _secondaryOpacity,
      child: FadeTransition(
        opacity: _opacity,
        child: ScaleTransition(
          scale: _scale,
          child: child,
        ),
      ),
    );
  }
}
