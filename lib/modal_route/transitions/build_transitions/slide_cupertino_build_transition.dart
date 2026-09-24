import 'package:flutter/widgets.dart';

import 'build_transition.dart';
import 'widgets/slide_cupertino.dart';

final class SlideCupertinoBuildTransition implements BuildTransition {
  const new({this.hasShadow = true});

  final bool hasShadow;

  @override
  Widget call({
    required Animation<double> animation,
    required Animation<double> secondaryAnimation,
    required Widget child,
  }) {
    return SlideCupertino(
      animation: animation,
      secondaryAnimation: secondaryAnimation,
      hasShadow: hasShadow,
      child: child,
    );
  }
}
