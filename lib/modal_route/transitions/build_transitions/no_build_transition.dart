import 'package:flutter/widgets.dart';
import 'build_transition.dart';

final class NoBuildTransition implements BuildTransition {
  const new();
  @override
  Widget call({
    required Animation<double> animation,
    required Animation<double> secondaryAnimation,
    required Widget child,
  }) {
    //!popGestureEnabled
    return child;
  }
}
