library;

import 'dart:ui' as ui;

import 'package:flutter/material.dart' show Colors;
import 'package:flutter/widgets.dart' show AxisDirection, Offset;
import 'package:flutter/widgets.dart' show Color, TraversalEdgeBehavior;

import '../transitions/route_transition.dart';

part 'overlay_trace_route.dart';
part 'page_trace_route.dart';
part 'popup_trace_route.dart';
part 'swipe_trace_route.dart';

/// Defines the presentation style of a route.
///
/// A [TraceRoute] object, or one of its subclasses ([PageTraceRoute],
/// [PopupTraceRoute], [SwipeTraceRoute]), specifies *how* a route is
/// presented on the screen. This includes its transition animation, modality
/// (e.g., fullscreen, popup), barrier color, and other visual properties.
///
/// It can be provided directly to a [Trace] object to override the default
/// presentation style defined in the [BrowserRoute].
sealed class TraceRoute {
  const TraceRoute({
    this.routeTransition,
    this.opaque = false,
    this.maintainState = true,
    this.allowSnapshotting = false,
    this.filter,
    this.traversalEdgeBehavior,
    this.transitionDuration = const Duration(milliseconds: 300),
    this.reverseTransitionDuration = const Duration(milliseconds: 300),
    this.barrierColor = Colors.black54,
    this.barrierLabel = '',
    this.semanticsLabel = '',
    this.barrierDismissible = true,
  });

  /// Creates a [PageTraceRoute] for presenting a route as a standard,
  /// full-screen page.
  factory TraceRoute.page({
    RouteTransition? routeTransition,
    bool opaque = true,
    bool maintainState = true,
    bool allowSnapshotting = true,
    ui.ImageFilter? filter,
    TraversalEdgeBehavior? traversalEdgeBehavior,
    Color barrierColor = Colors.black54,
    Duration reverseTransitionDuration = const Duration(milliseconds: 300),
    Duration transitionDuration = const Duration(milliseconds: 300),
    bool barrierDismissible = false,
    String barrierLabel = '',
    String semanticsLabel = '',
    bool fullscreenDialog = false,
    bool popGestureEnabled = true,
  }) =>
      PageTraceRoute(
        routeTransition: routeTransition,
        opaque: opaque,
        maintainState: maintainState,
        allowSnapshotting: allowSnapshotting,
        filter: filter,
        traversalEdgeBehavior: traversalEdgeBehavior,
        barrierColor: barrierColor,
        reverseTransitionDuration: reverseTransitionDuration,
        transitionDuration: transitionDuration,
        barrierDismissible: barrierDismissible,
        barrierLabel: barrierLabel,
        semanticsLabel: semanticsLabel,
        fullScreenDialog: fullscreenDialog,
        popGestureEnabled: popGestureEnabled,
      );

  /// Creates a [PopupTraceRoute] for presenting a route as a modal dialog
  /// or popup.
  factory TraceRoute.popup({
    RouteTransition? routeTransition,
    bool opaque = false,
    bool maintainState = true,
    bool allowSnapshotting = false,
    ui.ImageFilter? filter,
    TraversalEdgeBehavior? traversalEdgeBehavior,
    Color barrierColor = Colors.black54,
    Duration reverseTransitionDuration = const Duration(milliseconds: 300),
    Duration transitionDuration = const Duration(milliseconds: 300),
    bool barrierDismissible = true,
    String barrierLabel = '',
    String semanticsLabel = '',
  }) =>
      PopupTraceRoute(
        routeTransition: routeTransition,
        opaque: opaque,
        maintainState: maintainState,
        allowSnapshotting: allowSnapshotting,
        filter: filter,
        traversalEdgeBehavior: traversalEdgeBehavior,
        barrierColor: barrierColor,
        reverseTransitionDuration: reverseTransitionDuration,
        transitionDuration: transitionDuration,
        barrierDismissible: barrierDismissible,
        barrierLabel: barrierLabel,
        semanticsLabel: semanticsLabel,
      );

  /// Creates a [SwipeTraceRoute] for presenting a route as a swipeable
  /// bottom sheet.
  factory TraceRoute.swipe({
    RouteTransition? routeTransition,
    bool opaque = false,
    bool maintainState = true,
    bool allowSnapshotting = false,
    ui.ImageFilter? filter,
    TraversalEdgeBehavior? traversalEdgeBehavior,
    Color barrierColor = Colors.black54,
    Duration reverseTransitionDuration = const Duration(milliseconds: 300),
    Duration transitionDuration = const Duration(milliseconds: 300),
    bool barrierDismissible = true,
    String barrierLabel = '',
    String semanticsLabel = '',
    bool useSafeArea = false,
    AxisDirection animationDirection = AxisDirection.up,
    bool enableDrag = true,
    double screenMaximumPercentage = 1,
    Offset? anchorPoint,
  }) =>
      SwipeTraceRoute(
        routeTransition: routeTransition,
        opaque: opaque,
        maintainState: maintainState,
        allowSnapshotting: allowSnapshotting,
        filter: filter,
        traversalEdgeBehavior: traversalEdgeBehavior,
        barrierColor: barrierColor,
        reverseTransitionDuration: reverseTransitionDuration,
        transitionDuration: transitionDuration,
        barrierDismissible: barrierDismissible,
        barrierLabel: barrierLabel,
        semanticsLabel: semanticsLabel,
        useSafeArea: useSafeArea,
        animationDirection: animationDirection,
        enableDrag: enableDrag,
        screenMaximumPercentage: screenMaximumPercentage,
        anchorPoint: anchorPoint,
      );

  /// The transition animation to use when the route is pushed or popped.
  /// If null, the default transition from [BrowserRoute] is used.
  final RouteTransition? routeTransition;

  /// {@template flutter.widgets.ModalRoute.opaque}
  /// Whether this route obscures the route beneath it.
  ///
  /// If this is true, the route below is not built, to save resources.
  /// {@endtemplate}
  final bool opaque;

  /// {@template flutter.widgets.Route.maintainState}
  /// Whether the state of this route should be maintained when it is not visible.
  ///
  /// If this is true, the route is kept in memory, and its state is preserved.
  /// If this is false, the route might be disposed of when it is not visible.
  /// {@endtemplate}
  final bool maintainState;

  /// {@template flutter.widgets.Route.allowSnapshotting}
  /// Whether this route can be snapshotted.
  ///
  /// If this is true, the route can be captured as an image, for example
  /// by the app switcher.
  /// {@endtemplate}
  final bool allowSnapshotting;

  /// {@template flutter.widgets.ModalRoute.barrierDismissible}
  /// Whether the modal barrier can be dismissed by tapping on it.
  /// {@endtemplate}
  final bool barrierDismissible;

  /// {@template flutter.widgets.ModalRoute.filter}
  /// An image filter to apply to the routes below this one.
  /// {@endtemplate}
  final ui.ImageFilter? filter;

  /// {@template flutter.widgets.FocusScope.traversalEdgeBehavior}
  /// The behavior of the traversal policy for nodes in the subtree of this route.
  /// {@endtemplate}
  final TraversalEdgeBehavior? traversalEdgeBehavior;

  /// The duration of the transition animation.
  final Duration transitionDuration;

  /// The duration of the reverse transition animation.
  final Duration reverseTransitionDuration;

  /// Specifies the color of the modal barrier that darkens everything below the
  /// modal.
  ///
  /// Defaults to `Colors.black54`.
  final Color barrierColor;

  /// {@template flutter.widgets.ModalRoute.barrierLabel}
  /// The semantic label for the modal barrier.
  /// {@endtemplate}
  final String barrierLabel;

  /// The semantic label for the route.
  final String semanticsLabel;
}
