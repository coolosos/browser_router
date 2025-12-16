part of 'trace_route.dart';

class SwipeTraceRoute extends PopupTraceRoute {
  SwipeTraceRoute({
    super.routeTransition,
    super.opaque,
    super.maintainState,
    super.allowSnapshotting,
    super.filter,
    super.traversalEdgeBehavior,
    super.barrierColor,
    super.reverseTransitionDuration,
    super.transitionDuration,
    super.barrierDismissible,
    super.barrierLabel,
    super.semanticsLabel,
    this.useSafeArea = false,
    this.animationDirection = AxisDirection.up,
    this.enableDrag = true,
    this.screenMaximumPercentage = 1,
    this.anchorPoint,
  });

  /// If useSafeArea is true, a [SafeArea] is inserted.
  ///
  /// If useSafeArea is false, the bottom sheet is aligned to the bottom of the page
  /// and isn't exposed to the top padding of the MediaQuery.
  ///
  /// Default is false.
  final bool useSafeArea;

  final AxisDirection animationDirection;

  final double screenMaximumPercentage;

  /// Specifies whether the bottom sheet can be dragged
  /// and dismissed by swiping downwards.
  ///
  /// If true, the bottom sheet can be dragged and dismissed by
  /// swiping downwards.
  ///
  /// Defaults is true.
  final bool enableDrag;

  /// {@macro flutter.widgets.DisplayFeatureSubScreen.anchorPoint}
  final Offset? anchorPoint;
}
