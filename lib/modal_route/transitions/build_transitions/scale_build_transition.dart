import 'package:flutter/widgets.dart';

import 'build_transition.dart';
import 'widgets/scale.dart';

final class ScaleBuildTransition implements BuildTransition {
  const new({this.initialScale = 0.85});

  final double initialScale;

  @override
  Widget call({
    required Animation<double> animation,
    required Animation<double> secondaryAnimation,
    required Widget child,
  }) {
    return Scale(
      animation: animation,
      secondaryAnimation: secondaryAnimation,
      initialScale: initialScale,
      child: child,
    );
  }
}
