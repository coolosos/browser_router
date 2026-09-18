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
    this.backGestureWidth,
    this.popClosePercentage = 0.35,
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

  /// Whether the interactive back swipe gesture is enabled for this route.
  final bool popGestureEnabled;

  /// The width in logical pixels from the leading edge where the back gesture can start.
  /// If `null`, the back gesture can be initiated from anywhere across the screen.
  final double? backGestureWidth;

  /// The fraction of screen width that must be dragged to trigger a pop when there is
  /// no fling velocity. Defaults to `0.35` (35%).
  final double popClosePercentage;
}
