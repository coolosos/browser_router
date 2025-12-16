import 'package:flutter/widgets.dart';

import '../browser.dart';

export 'params/trace_route.dart' show PopupTraceRoute;

class BrowserPopupRoute<T, P extends PopupTraceRoute> extends PopupRoute<T> {
  /// A modal bottom sheet route.
  BrowserPopupRoute({
    required this.traceRoute,
    required this.appRoute,
    super.settings,
  })  : transitionDuration = traceRoute.transitionDuration,
        reverseTransitionDuration = traceRoute.reverseTransitionDuration,
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
  final Color barrierColor;

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
  Widget buildModalBarrier() {
    Widget barrier;
    if (barrierColor.alpha != 0 && !offstage) {
      // changedInternalState is called if barrierColor or offstage updates
      assert(barrierColor != barrierColor.withOpacity(0));
      final color = animation!.drive(
        ColorTween(
          begin: barrierColor.withOpacity(0),
          end:
              barrierColor, // changedInternalState is called if barrierColor updates
        ).chain(
          CurveTween(
            curve: barrierCurve,
          ),
        ), // changedInternalState is called if barrierCurve updates
      );
      barrier = Builder(
        builder: (context) {
          return AnimatedModalBarrier(
            color: color,
            dismissible:
                barrierDismissible, // changedInternalState is called if barrierDismissible updates
            semanticsLabel:
                barrierLabel, // changedInternalState is called if barrierLabel updates
            barrierSemanticsDismissible: semanticsDismissible,
            onDismiss: () {
              if (isCurrent) {
                context.pop(settings: settings);
              }
            },
          );
        },
      );
    } else {
      barrier = Builder(
        builder: (context) {
          return ModalBarrier(
            dismissible:
                barrierDismissible, // changedInternalState is called if barrierDismissible updates
            semanticsLabel:
                barrierLabel, // changedInternalState is called if barrierLabel updates
            barrierSemanticsDismissible: semanticsDismissible,
            onDismiss: () {
              if (isCurrent) {
                context.pop(settings: settings);
              }
            },
          );
        },
      );
    }

    return barrier;
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
      label: traceRoute.semanticsLabel,
      explicitChildNodes: true,
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
    final transitions =
        traceRoute.routeTransition ?? appRoute.routeTransition;
    return transitions.build(
      animation: animation,
      secondaryAnimation: secondaryAnimation,
      child: child,
    );
  }
}
