part of 'trace_route.dart';

base class PopupTraceRoute extends TraceRoute {
  PopupTraceRoute({
    super.routeTransition,
    super.opaque = false,
    super.maintainState = true,
    super.allowSnapshotting = false,
    super.filter,
    super.traversalEdgeBehavior,
    super.barrierColor,
    super.reverseTransitionDuration,
    super.transitionDuration,
    super.barrierLabel,
    super.semanticsLabel,
    super.barrierDismissible = true,
  });
}
