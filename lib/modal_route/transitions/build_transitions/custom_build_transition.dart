import 'package:flutter/widgets.dart';

import 'build_transition.dart';

/// Function signature for custom transition builders.
typedef CustomTransitionBuilder = Widget Function(
  BuildContext context,
  Animation<double> animation,
  Animation<double> secondaryAnimation,
  Widget child,
);

/// A [BuildTransition] that delegates to a custom builder function.
final class CustomBuildTransition implements BuildTransition {
  const new(this.builder);

  final Widget Function({
    required Animation<double> animation,
    required Animation<double> secondaryAnimation,
    required Widget child,
  }) builder;

  @override
  Widget call({
    required Animation<double> animation,
    required Animation<double> secondaryAnimation,
    required Widget child,
  }) {
    return builder(
      animation: animation,
      secondaryAnimation: secondaryAnimation,
      child: child,
    );
  }
}
