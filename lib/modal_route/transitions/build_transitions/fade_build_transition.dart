import 'package:flutter/widgets.dart';
import 'build_transition.dart';
import 'widgets/fade.dart';

final class FadeBuildTransition implements BuildTransition {
  const new();
  @override
  Widget call({
    required Animation<double> animation,
    required Widget child,
    required Animation<double> secondaryAnimation,
  }) {
    return Fade(
      animation: animation,
      //!popGestureEnabled
      child: child,
    );
  }
}
