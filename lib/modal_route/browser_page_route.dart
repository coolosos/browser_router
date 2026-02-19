import 'package:browser_router/gestures/swipe/swipe.dart';
import 'package:flutter/cupertino.dart' show CupertinoRouteTransitionMixin;
import 'package:flutter/foundation.dart'; // Import for debugPrint
import 'package:flutter/material.dart' show MaterialRouteTransitionMixin;
import 'package:flutter/widgets.dart';

import '../browser.dart';
import 'shared_modal_barrier.dart';

export 'params/trace_route.dart' show PageTraceRoute;

class BrowserPageRoute<T> extends PageRoute<T>
    with BrowserModalBarrierMixin<T> {
  BrowserPageRoute({
    required this.appRoute,
    required this.traceRoute,
    super.settings,
  })  : transitionDuration = appRoute.routeTransition == RouteTransition.none
            ? const Duration(milliseconds: 0)
            : traceRoute.transitionDuration,
        reverseTransitionDuration =
            appRoute.routeTransition == RouteTransition.none
                ? const Duration(milliseconds: 0)
                : traceRoute.reverseTransitionDuration,
        barrierLabel = traceRoute.barrierLabel,
        maintainState = traceRoute.maintainState,
        opaque = traceRoute.opaque,
        barrierDismissible = traceRoute.barrierDismissible,
        barrierColor = traceRoute.barrierColor,
        super(
          allowSnapshotting: traceRoute.allowSnapshotting,
          fullscreenDialog: traceRoute.fullScreenDialog,
        ) {
    debugPrint('BrowserPageRoute: Constructor called for ${settings.name}');
  }

  final BrowserRoute appRoute;
  final PageTraceRoute traceRoute;

  @override
  final bool maintainState;

  @override
  String get debugLabel => '${super.debugLabel}(${settings.name})';

  @override
  final String? barrierLabel;

  @override
  final Color? barrierColor;

  @override
  final Duration transitionDuration;

  @override
  final Duration reverseTransitionDuration;

  @override
  bool opaque;

  @override
  bool barrierDismissible;

  @override
  bool canTransitionTo(TransitionRoute<dynamic> nextRoute) {
    // Don't perform outgoing animation if the next route is a fullscreen dialog.
    return (nextRoute is MaterialRouteTransitionMixin &&
            !nextRoute.fullscreenDialog) ||
        (nextRoute is CupertinoRouteTransitionMixin &&
            !nextRoute.fullscreenDialog) ||
        (nextRoute is BrowserPageRoute && !nextRoute.fullscreenDialog);
  }

  @override
  Widget buildPage(
    BuildContext context,
    Animation<double> animation,
    Animation<double> secondaryAnimation,
  ) {
    appRoute.builderTrigger?.call(context);

    return Semantics(
      scopesRoute: true,
      namesRoute: true,
      explicitChildNodes: true,
      label: traceRoute.semanticsLabel,
      child: appRoute.page,
    );
  }

  @override
  Widget buildTransitions(
    BuildContext context,
    Animation<double> animation,
    Animation<double> secondaryAnimation,
    Widget child,
  ) {
    if (defaultTargetPlatform == TargetPlatform.iOS &&
        appRoute.routeTransition == RouteTransition.slide_right &&
        traceRoute.popGestureEnabled) {
      final swipeGestures = SwipeDownRightGestures(
        animationController: controller!,
        obtainSize: () => context.size?.width ?? 0,
        canDragDone: () => controller?.status == AnimationStatus.reverse,
        onClosing: () {
          if (context.navigate.canPop()) {
            context.pop();
          }
        },
        closePercentage: 0.8,
      );

      return Swipe(
        direction: AxisDirection.left,
        animation: animation,
        screenMaximumPercentage: 1,
        hasEnableGestures: true,
        gestures: swipeGestures,
        disableAnimations: MediaQuery.disableAnimationsOf(context),
        animateChild: false,
        child: appRoute.routeTransition.build(
          animation: animation,
          secondaryAnimation: secondaryAnimation,
          child: child,
        ),
      );
    }

    return appRoute.routeTransition.build(
      animation: animation,
      secondaryAnimation: secondaryAnimation,
      child: child,
    );
  }
}
