import 'package:flutter/widgets.dart';

import 'build_transition.dart';
import 'widgets/fade_through.dart';

final class FadeThroughBuildTransition implements BuildTransition {
  const new({this.fillColor});

  final Color? fillColor;

  @override
  Widget call({
    required Animation<double> animation,
    required Animation<double> secondaryAnimation,
    required Widget child,
  }) {
    return FadeThrough(
      animation: animation,
      secondaryAnimation: secondaryAnimation,
      fillColor: fillColor,
      child: child,
    );
  }
}
