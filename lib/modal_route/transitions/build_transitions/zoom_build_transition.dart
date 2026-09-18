import 'package:flutter/widgets.dart';

import 'build_transition.dart';
import 'widgets/zoom.dart';

final class ZoomBuildTransition implements BuildTransition {
  const ZoomBuildTransition();

  @override
  Widget call({
    required Animation<double> animation,
    required Widget child,
    required Animation<double> secondaryAnimation,
  }) {
    return Zoom(
      primaryRouteAnimation: animation,
      secondaryRouteAnimation: secondaryAnimation,
      child: child,
    );
  }
}
