import 'package:flutter/widgets.dart';

import '../browser.dart';
import '../gestures/swipe/swipe.dart';
import 'browser_popup_route.dart';
import 'shared_modal_barrier.dart';

export 'params/trace_route.dart' show SwipeTraceRoute;

class BrowserSwipePopupRoute<T> extends BrowserPopupRoute<T, SwipeTraceRoute>
    with BrowserModalBarrierMixin<T> {
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
}
