import 'package:flutter/widgets.dart';

/// A Material 3 style zoom transition that scales and fades the incoming route
/// and subtly zooms and fades out the outgoing secondary route.
class Zoom extends StatelessWidget {
  Zoom({
    required this.primaryRouteAnimation,
    required this.secondaryRouteAnimation,
    required this.child,
    super.key,
  })  : _primaryScaleAnimation = CurvedAnimation(
          parent: primaryRouteAnimation,
          curve: Curves.fastEaseInToSlowEaseOut,
          reverseCurve: Curves.fastEaseInToSlowEaseOut.flipped,
        ).drive(
          Tween<double>(begin: 0.85, end: 1),
        ),
        _primaryFadeAnimation = CurvedAnimation(
          parent: primaryRouteAnimation,
          curve: const Interval(0, 0.4, curve: Curves.easeIn),
          reverseCurve: const Interval(0.6, 1, curve: Curves.easeOut),
        ),
        _secondaryScaleAnimation = CurvedAnimation(
          parent: secondaryRouteAnimation,
          curve: Curves.fastEaseInToSlowEaseOut,
          reverseCurve: Curves.fastEaseInToSlowEaseOut.flipped,
        ).drive(
          Tween<double>(begin: 1, end: 1.08),
        ),
        _secondaryFadeAnimation = CurvedAnimation(
          parent: secondaryRouteAnimation,
          curve: const Interval(0.6, 1, curve: Curves.easeOut),
          reverseCurve: const Interval(0, 0.4, curve: Curves.easeIn),
        ).drive(
          Tween<double>(begin: 1, end: 0),
        );

  final Animation<double> primaryRouteAnimation;
  final Animation<double> secondaryRouteAnimation;
  final Widget child;

  final Animation<double> _primaryScaleAnimation;
  final Animation<double> _primaryFadeAnimation;
  final Animation<double> _secondaryScaleAnimation;
  final Animation<double> _secondaryFadeAnimation;

  @override
  Widget build(BuildContext context) {
    return ScaleTransition(
      scale: _secondaryScaleAnimation,
      child: FadeTransition(
        opacity: _secondaryFadeAnimation,
        child: ScaleTransition(
          scale: _primaryScaleAnimation,
          child: FadeTransition(
            opacity: _primaryFadeAnimation,
            child: child,
          ),
        ),
      ),
    );
  }
}
