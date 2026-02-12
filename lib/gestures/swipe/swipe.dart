library;

import 'package:flutter/widgets.dart';

part 'swipe_animation.dart';
part 'swipe_gestures.dart';
part 'swipe_transition_builder.dart';

extension GenericAxis on AxisDirection {
  Axis generic() {
    switch (this) {
      case AxisDirection.up:
      case AxisDirection.down:
        return Axis.vertical;
      case AxisDirection.right:
      case AxisDirection.left:
        return Axis.horizontal;
    }
  }
}

class Swipe extends StatelessWidget {
  Swipe({
    required this.animation,
    required Widget child,
    required this.screenMaximumPercentage,
    required bool hasEnableGestures,
    required this.disableAnimations,
    this.gestures,
    this.animateChild = true,
    bool Function(DraggableScrollableNotification)? onNotification,
    this.direction = AxisDirection.up,
    super.key,
  }) : _child = hasEnableGestures
            ? NotificationListener<DraggableScrollableNotification>(
                onNotification: onNotification,
                child: GestureDetector(
                  excludeFromSemantics: true,
                  onVerticalDragStart: direction.generic() == Axis.vertical
                      ? gestures?.handleDragStart
                      : null,
                  onVerticalDragEnd: direction.generic() == Axis.vertical
                      ? gestures?.handleDragEnd
                      : null,
                  onVerticalDragUpdate: direction.generic() == Axis.vertical
                      ? gestures?.handleDragUpdate
                      : null,
                  onHorizontalDragStart: direction.generic() == Axis.horizontal
                      ? gestures?.handleDragStart
                      : null,
                  onHorizontalDragUpdate: direction.generic() == Axis.horizontal
                      ? gestures?.handleDragUpdate
                      : null,
                  onHorizontalDragEnd: direction.generic() == Axis.horizontal
                      ? gestures?.handleDragEnd
                      : null,
                  child: child,
                ),
              )
            : child;

  final Animation<double> animation;
  final Widget _child;
  final double screenMaximumPercentage;
  final bool disableAnimations;
  final SwipeGestures? gestures;
  final AxisDirection direction;
  final bool animateChild;

  @override
  Widget build(BuildContext context) {
    if (disableAnimations || !animateChild) {
      return _child;
    } else {
      return AnimatedBuilder(
        animation: animation,
        child: _child,
        builder: (context, child) {
          final animationValue = MediaQuery.accessibleNavigationOf(context)
              ? 1.0
              : animation.value;
          return ClipRRect(
            child: CustomSingleChildLayout(
              delegate: SwipeChildLayoutDelegate(
                animationValue,
                screenMaximumPercentage,
                direction,
              ),
              child: child,
            ),
          );
        },
      );
    }
  }
}
