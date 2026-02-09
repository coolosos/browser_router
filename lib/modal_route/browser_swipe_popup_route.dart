import 'package:flutter/widgets.dart';

import '../browser.dart';
import '../gestures/swipe/swipe.dart';
import 'browser_popup_route.dart';

export 'params/trace_route.dart' show SwipeTraceRoute;

class BrowserSwipePopupRoute<T> extends BrowserPopupRoute<T, SwipeTraceRoute> {
  /// A modal bottom sheet route.
  BrowserSwipePopupRoute({
    required super.traceRoute,
    required super.appRoute,
    super.settings,
  });

  @override
  Widget buildPage(
    BuildContext context,
    Animation<double> animation,
    Animation<double> secondaryAnimation,
  ) {
    appRoute.builderTrigger?.call(context);

    Widget content = DisplayFeatureSubScreen(
      anchorPoint: traceRoute.anchorPoint,
      child: SwipeAnimation(
        animationDirection: traceRoute.animationDirection,
        builder: (context) => appRoute.page,
        screenMaximumPercentage: traceRoute.screenMaximumPercentage,
        enableDrag: traceRoute.enableDrag,
        animation: animation,
        animationController: controller,
        onClosing: () {
          if (isCurrent) {
            context.pop(settings: settings);
          }
        },
      ),
    );

    content = Semantics(
      scopesRoute: true,
      namesRoute: true,
      label: traceRoute.semanticsLabel,
      explicitChildNodes: true,
      child: content,
    );

    // If useSafeArea is true, a SafeArea is inserted.
    // If useSafeArea is false, the bottom sheet is aligned to the bottom of the page
    // and isn't exposed to the top padding of the MediaQuery.
    final bottomSheet = traceRoute.useSafeArea
        ? SafeArea(child: content)
        : MediaQuery.removePadding(
            context: context,
            removeTop: true,
            child: content,
          );

    return bottomSheet;
  }

  @override
  Widget buildModalBarrier() {
    Widget barrier;
    if (barrierColor != null && barrierColor?.a != 0.0 && !offstage) {
      assert(
        barrierColor != barrierColor?.withValues(alpha: 0),
        'changedInternalState is called if barrierColor or offstage updates',
      );
      final color = animation!.drive(
        ColorTween(
          begin: barrierColor?.withValues(alpha: 0),
          end: barrierColor,
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
}
