part of 'trace_route.dart';

final class PageTraceRoute extends TraceRoute {
  PageTraceRoute({
    super.routeTransition,
    super.opaque = true,
    super.maintainState = true,
    super.filter,
    super.traversalEdgeBehavior,
    super.barrierColor,
    super.reverseTransitionDuration,
    super.transitionDuration,
    super.barrierLabel,
    super.semanticsLabel,
    this.fullScreenDialog = false,
    super.allowSnapshotting = true,
    super.barrierDismissible = false,
    this.popGestureEnabled = true,
  });

  /// {@template flutter.widgets.PageRoute.fullscreenDialog}
  /// Whether this page route is a full-screen dialog.
  ///
  /// In Material and Cupertino, being fullscreen has the effects of making
  /// the app bars have a close button instead of a back button. On
  /// iOS, dialogs transitions animate differently and are also not closeable
  /// with the back swipe gesture.
  /// {@endtemplate}
  final bool fullScreenDialog;

  //disable for ios gesture
  final bool popGestureEnabled;
}
