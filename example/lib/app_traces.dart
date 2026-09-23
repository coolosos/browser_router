import 'package:browser_router/browser.dart';

import 'push_args.dart';

/// A centralized, type-safe way to manage all application paths.
/// This avoids using raw strings for routes throughout the app.
enum AppPath {
  home('/home'),
  pushArgs('/push_args'),
  popArgs('/pop_args'),
  toSetPopArgs('/toSetPopArgs'),
  popupContent('/popup_content'),
  intermediate('/intermediate'),
  deep('/deep');

  new(this.path);
  final String path;
}

/// A semantic, reusable navigation action that extends [Trace].
///
/// This class creates a pre-configured "shortcut" for a specific navigation
/// event, bundling the path, arguments, and presentation (`TraceRoute`).
class AppTrace extends Trace {
  /// Private constructor to be used by the factory constructors.
  const new _({
    required super.path,
    super.args,
    super.traceRoute,
  });

  /// Navigates to the push arguments screen.
  factory toPushArgs({
    required String message,
    required String source,
    RouteTransition? transition,
  }) {
    return AppTrace._(
      path: AppPath.pushArgs.path,
      args: PushArgs(message: message, source: source),
      traceRoute: PageTraceRoute(
        routeTransition: transition ?? RouteTransition.slide_right,
      ),
    );
  }

  /// Navigates to the screen that demonstrates returning arguments via pop.
  factory toPopArgs() => AppTrace._(path: AppPath.popArgs.path);
  factory toSetPopArgs() =>
      AppTrace._(path: AppPath.toSetPopArgs.path);

  /// Navigates to the intermediate screen for the multi-level pop example.
  factory toIntermediate() =>
      AppTrace._(path: AppPath.intermediate.path);

  /// Navigates to the deepest screen for the multi-level pop example.
  factory toDeep() => AppTrace._(path: AppPath.deep.path);

  /// Presents a specific screen as a modal popup.
  factory asPopup() {
    return AppTrace._(
      path: AppPath.popupContent.path,
      traceRoute: const PopupTraceRoute(routeTransition: RouteTransition.fade),
    );
  }

  /// Presents the push-args screen as a swipeable bottom sheet.
  factory asSheet() {
    return AppTrace._(
      path: AppPath.pushArgs.path,
      args:
          PushArgs(message: 'Presented as a Sheet', source: 'SwipeTraceRoute'),
      traceRoute: const SwipeTraceRoute(
        screenMaximumPercentage: 0.6,
        routeTransition: RouteTransition.none,
      ),
    );
  }
}
