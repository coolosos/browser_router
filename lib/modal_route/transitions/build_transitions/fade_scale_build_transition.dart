import 'package:flutter/widgets.dart';

import 'build_transition.dart';
import 'widgets/fade_scale.dart';

final class FadeScaleBuildTransition implements BuildTransition {
  const new();

  @override
  Widget call({
    required Animation<double> animation,
    required Animation<double> secondaryAnimation,
    required Widget child,
  }) {
    return FadeScale(
      animation: animation,
      secondaryAnimation: secondaryAnimation,
      child: child,
    );
  }
}
