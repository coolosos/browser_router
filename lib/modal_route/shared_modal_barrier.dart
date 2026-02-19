import 'package:browser_router/browser.dart';
import 'package:flutter/widgets.dart';

mixin BrowserModalBarrierMixin<T> on ModalRoute<T> {
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
        ),
      );
      barrier = Builder(
        builder: (context) {
          return AnimatedModalBarrier(
            color: color,
            dismissible: barrierDismissible,
            semanticsLabel: barrierLabel,
            barrierSemanticsDismissible: semanticsDismissible,
            onDismiss: () {
              if (isCurrent && context.navigate.canPop()) {
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
            dismissible: barrierDismissible,
            semanticsLabel: barrierLabel,
            barrierSemanticsDismissible: semanticsDismissible,
            onDismiss: () {
              if (isCurrent && context.navigate.canPop()) {
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
