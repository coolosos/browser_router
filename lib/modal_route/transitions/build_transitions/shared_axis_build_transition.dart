import 'package:flutter/widgets.dart';

import 'build_transition.dart';
import 'widgets/shared_axis.dart';

export 'widgets/shared_axis.dart' show SharedAxisDirection;

final class SharedAxisBuildTransition implements BuildTransition {
  const new({this.direction = SharedAxisDirection.horizontal});

  final SharedAxisDirection direction;

  @override
  Widget call({
    required Animation<double> animation,
    required Animation<double> secondaryAnimation,
    required Widget child,
  }) {
    return SharedAxis(
      animation: animation,
      secondaryAnimation: secondaryAnimation,
      direction: direction,
      child: child,
    );
  }
}
