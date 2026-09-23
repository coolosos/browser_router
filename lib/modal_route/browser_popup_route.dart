import 'package:flutter/widgets.dart';

import '../browser.dart';
import 'shared_modal_barrier.dart';

export 'params/trace_route.dart' show PopupTraceRoute;

class BrowserPopupRoute<T, P extends PopupTraceRoute> extends PopupRoute<T>
    with BrowserModalBarrierMixin<T> {
  /// A modal popup route.
  new({
    required this.traceRoute,
    required this.appRoute,
    super.settings,
  })  : transitionDuration =
            (traceRoute.routeTransition ?? appRoute.routeTransition) ==
                    RouteTransition.none
                ? Duration.zero
                : traceRoute.transitionDuration,
        reverseTransitionDuration =
            (traceRoute.routeTransition ?? appRoute.routeTransition) ==
                    RouteTransition.none
                ? Duration.zero
                : traceRoute.reverseTransitionDuration,
        barrierLabel = traceRoute.barrierLabel,
        maintainState = traceRoute.maintainState,
        opaque = traceRoute.opaque,
        barrierDismissible = traceRoute.barrierDismissible,
        barrierColor = traceRoute.barrierColor,
        allowSnapshotting = traceRoute.allowSnapshotting,
        super(
          filter: traceRoute.filter,
          traversalEdgeBehavior: traceRoute.traversalEdgeBehavior,
        );

  final BrowserRoute appRoute;
  final P traceRoute;

  @override
  bool barrierDismissible;

  @override
  final String? barrierLabel;

  @override
  final Color? barrierColor;

  @override
  String get debugLabel => '${super.debugLabel}(${settings.name})';

  @override
  final Duration transitionDuration;

  @override
  final Duration reverseTransitionDuration;

  @override
  bool opaque;

  @override
  bool maintainState;

  @override
  bool allowSnapshotting;

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
    if (MediaQuery.disableAnimationsOf(context) ||
        MediaQuery.accessibleNavigationOf(context)) {
      return child;
    }

    final isolatedChild = RepaintBoundary(child: child);
    final buildTransition = traceRoute.customTransition ??
        appRoute.customTransition ??
        (traceRoute.routeTransition ?? appRoute.routeTransition).build;

    return buildTransition(
      animation: animation,
      secondaryAnimation: secondaryAnimation,
      child: isolatedChild,
    );
  }
}
