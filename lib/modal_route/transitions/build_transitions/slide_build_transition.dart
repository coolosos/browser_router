import 'package:flutter/widgets.dart';
import 'build_transition.dart';
import 'widgets/slide.dart';

class SlideBuildTransition implements BuildTransition {
  const SlideBuildTransition({
    required this.position,
  });

  final Positions position;

  @override
  Widget call({
    required Animation<double> animation,
    required Widget child,
    required Animation<double> secondaryAnimation,
  }) {
    return Slide(
      primaryRouteAnimation: animation,
      secondaryRouteAnimation: secondaryAnimation,
      drive: position,
      //!popGestureEnabled meter swipe
      child: child,
    );
  }
}
