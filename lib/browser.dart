library;

import 'dart:async';
import 'package:flutter/foundation.dart'; // Import for debugPrint

import 'package:collection/collection.dart';
import 'package:equatable/equatable.dart';
import 'package:flutter/material.dart' show Colors;
import 'package:flutter/widgets.dart';
import 'package:nested/nested.dart';

import 'modal_route/browser_page_route.dart';
import 'modal_route/browser_popup_route.dart';
import 'modal_route/browser_swipe_popup_route.dart';
import 'modal_route/params/trace_route.dart';
import 'modal_route/transitions/route_transition.dart';
import 'overlay/overlay_manager.dart';

export 'modal_route/params/trace_route.dart';
export 'modal_route/transitions/route_transition.dart';
export 'sheet/sheet.dart';

part 'browser_config.dart';
part 'browser_route.dart';
part 'navigator_extension.dart';
part 'route_arguments.dart';
part 'route_observer.dart';
part 'trace.dart';

/// A function that builds the main widget of the application,
/// providing access to the [RouteObserver] and the route generation function.
typedef BrowserBuilder = Widget Function(
  BuildContext context,
  RouteObserver<ModalRoute<void>> routeObserver,
  Route<dynamic> Function(RouteSettings settings) generate,
);

/// A callback that is triggered whenever a navigation event occurs.
typedef OnNavigation = void Function(RouteSettings settings);

/// The main widget for the Browser navigation system.
///
/// It acts as a wrapper around a root application widget (like `WidgetsApp`,
/// `MaterialApp`, or `CupertinoApp`) and provides the necessary logic for
/// route generation, observation, and management.
///
/// This widget should be placed at the root of your application. It provides
/// the `onGenerateRoute` function and the `RouteObserver` to be used by your
/// app widget.
///
/// Example:
/// ```dart
/// void main() {
///   runApp(
///     Browser(
///       routes: [...],
///       defaultRoute: ...,
///       builder: (context, routeObserver, generate) {
///         // Use the provided parameters with your app widget
///         return WidgetsApp(
///           color: const Color(0xFFFFFFFF),
///           onGenerateRoute: generate,
///           navigatorObservers: [routeObserver],
///           // ... other properties
///         );
///       },
///     ),
///   );
/// }
/// ```
class Browser extends StatelessWidget {
  /// Creates a [Browser] widget.
  ///
  /// The [builder] is used to construct the main app widget.
  /// The [routes] list defines all possible navigation paths.
  /// The [defaultRoute] is used as a fallback when a route is not found or invalid.
  const Browser({
    required this.builder,
    required this.routes,
    required this.defaultRoute,
    this.onNavigation,
    this.adaptiveTransition,
    this.adaptiveTrace,
    this.openUrl,
    super.key,
  });

  /// A builder for the main application widget.
  ///
  /// This builder is responsible for creating the root app widget
  /// (e.g., `WidgetsApp`, `MaterialApp`) and providing it with the
  /// `routeObserver` and `generate` function supplied by `Browser`.
  final BrowserBuilder builder;

  /// A list of all [BrowserRoute]s available in the application.
  /// This list acts as the "route map" for the app.
  final List<BrowserRoute> routes;

  /// The default [BrowserRoute] to navigate to when a specified route
  /// is not found or its arguments fail validation.
  final BrowserRoute defaultRoute;

  /// An optional callback that is invoked on every navigation event.
  /// Useful for logging, analytics, or other side effects.
  final OnNavigation? onNavigation;

  /// A function to determine the [RouteTransition] adaptively.
  ///
  /// This allows for global transition logic, e.g., using platform-specific
  /// transitions based on the target platform.
  final RouteTransition Function(BrowserRoute route)? adaptiveTransition;

  /// A function to determine the [TraceRoute] adaptively based on the route name.
  ///
  /// This can be used to enforce a specific presentation style (e.g., all
  /// routes starting with '/modal' should be popups) globally.
  final TraceRoute? Function(String? name)? adaptiveTrace;

  /// An optional function to handle external URL opening.
  ///
  /// If provided, this function will be called when `context.openUrl` or
  /// `launchAction` is used with an external URL (e.g., 'https://...').
  final Future<void> Function(Uri uri)? openUrl;

  /// The central [RouteObserver] for the browser navigation stack.
  ///
  /// This observer is used internally by `Browser.watch` to listen for route
  /// changes (push, pop, etc.).
  ///
  /// It **must** be passed to the `navigatorObservers` property of your
  /// `MaterialApp`, `CupertinoApp`, or `WidgetsApp`.
  ///
  /// See the example in the [Browser] class documentation.
  static final RouteObserver<ModalRoute<void>> routeObserver =
      RouteObserver<ModalRoute<void>>();

  /// The core route generation logic for the browser.
  ///
  /// This function is intended to be used as the `onGenerateRoute` for your
  /// root app widget (e.g., `MaterialApp`).
  ///
  /// It parses route settings, extracts path and arguments, validates them
  /// against the `routes` list, and creates the appropriate [PageRoute]
  /// (e.g., [BrowserPageRoute], [BrowserPopupRoute]) based on the
  /// provided [TraceRoute].
  Route<dynamic> generate(RouteSettings settings) {
    debugPrint('Browser.generate: Called with settings: ${settings.name}');
    onNavigation?.call(settings);

    final uri = Uri.tryParse(settings.name ?? '');

    final name = uri?.path;
    final deepLinkParameter = uri?.queryParameters;
    final traceParameter = settings.arguments as Map?;

    final traceRoute = adaptiveTrace?.call(name) ??
        traceParameter?.getAndClean<TraceRoute>() ??
        PageTraceRoute();
    debugPrint('Browser.generate: traceRoute: $traceRoute');

    final arguments = Map.from({
      if (traceParameter != null) ...traceParameter,
      if (deepLinkParameter != null)
        DeepLinkParam: DeepLinkParam(deepLinkParameter),
    });
    debugPrint('Browser.generate: arguments: $arguments');

    final appRoute = _obtainMainRoute(name, arguments);
    debugPrint('Browser.generate: appRoute: ${appRoute.path}');

    final browserRouteWithCustomTransition =
        _browserRouteTransition(traceRoute, appRoute);
    debugPrint('Browser.generate: browserRouteWithCustomTransition: ${browserRouteWithCustomTransition.path}');

    final newSettings = RouteSettings(
      name: name,
      arguments: arguments,
    );

    final route = switch (traceRoute) {
      PageTraceRoute() => BrowserPageRoute(
          traceRoute: traceRoute,
          appRoute: browserRouteWithCustomTransition,
          settings: newSettings,
        ),
      SwipeTraceRoute() => BrowserSwipePopupRoute(
          traceRoute: traceRoute,
          appRoute: browserRouteWithCustomTransition,
          settings: newSettings,
        ),
      PopupTraceRoute() => BrowserPopupRoute(
          traceRoute: traceRoute,
          appRoute: browserRouteWithCustomTransition,
          settings: newSettings,
        ),
      OverlayTraceRoute() => BrowserPageRoute(
          appRoute: browserRouteWithCustomTransition,
          traceRoute: PageTraceRoute(),
          settings: newSettings,
        ),
    };
    debugPrint('Browser.generate: Returning route: $route');
    return route;
  }

  ///Obtain main route after check execute the validate arguments function:
  ///
  /// * When validate is correct route obtain by the name will be return.
  /// * When validate is incorrect default route will be return.
  ///
  /// In case of path is not found then will be use the default route.
  BrowserRoute _obtainMainRoute(
    String? name,
    Map<dynamic, dynamic> arguments,
  ) {
    debugPrint('Browser._obtainMainRoute: Called with name: $name, arguments: $arguments');
    final appRoute =
        routes.firstWhereOrNull((appRoute) => appRoute.path == name);
    debugPrint('Browser._obtainMainRoute: Found appRoute: ${appRoute?.path}');

    final isValid = appRoute?.validateArguments?.call(
      ///Check
      <T extends RouteParams>() =>
          arguments.getArgument<T>()?.validate() ?? false,

      ///GetArguments
      <T extends RouteParams>() => arguments.getArgument<T>(),
    );
    debugPrint('Browser._obtainMainRoute: isValid: $isValid');

    if (isValid case final bool validArguments when !validArguments) {
      debugPrint('Browser._obtainMainRoute: Returning defaultRoute due to invalid arguments.');
      return defaultRoute;
    }

    debugPrint('Browser._obtainMainRoute: Returning appRoute or defaultRoute.');
    return appRoute ?? defaultRoute;
  }

  ///Return the BrowserRoute with the transition of the view depending if is given by the trace, the app, or the adaptive
  BrowserRoute _browserRouteTransition(
    TraceRoute traceRoute,
    BrowserRoute appRoute,
  ) {
    debugPrint('Browser._browserRouteTransition: Called with traceRoute: $traceRoute, appRoute: ${appRoute.path}');
    final internalTransition =
        traceRoute.routeTransition ?? appRoute.routeTransition;
    debugPrint('Browser._browserRouteTransition: internalTransition: $internalTransition');

    final route = appRoute.copyWith(routeTransition: internalTransition);
    final transition = adaptiveTransition?.call(route) ?? internalTransition;
    debugPrint('Browser._browserRouteTransition: final transition: $transition');

    return route.copyWith(routeTransition: transition);
  }

  /// Shows a customizable modal bottom sheet.
  ///
  /// This is a helper method that wraps `Navigator.of(context).push` with a
  /// pre-configured [BrowserSwipePopupRoute] for common bottom sheet behavior.
  static Future<T?> showModalBottomSheet<T>({
    required BuildContext context,
    required WidgetBuilder builder,
    required Color backgroundColor,
    double heightFactor = 0.5,
    EdgeInsetsGeometry padding = const EdgeInsets.only(top: 19),
    AxisDirection animationDirection = AxisDirection.up,
    RouteSettings? routeSettings,
    bool isDismissible = true,
    Color? modalBarrierColor,
    bool enableDrag = true,
    bool useSafeAre = false,
    List<BoxShadow>? boxShadow,
  }) =>
      Navigator.of(context).push<T>(
        BrowserSwipePopupRoute<T>(
          settings: routeSettings,
          traceRoute: SwipeTraceRoute(
            useSafeArea: useSafeAre,
            enableDrag: enableDrag,
            barrierColor: modalBarrierColor ?? Colors.black54,
            barrierDismissible: isDismissible,
            screenMaximumPercentage: heightFactor,
            animationDirection: animationDirection,
          ),
          appRoute: BrowserRoute(
            path: '',
            page: Container(
              padding: padding,
              decoration: BoxDecoration(
                color: backgroundColor,
                boxShadow: boxShadow,
              ),
              child: Builder(
                builder: (context) {
                  return builder.call(context);
                },
              ),
            ),
            routeTransition: RouteTransition.none,
          ),
        ),
      );

  /// Provides a widget that can listen to page appearance and disappearance events.
  ///
  /// This is a convenience method that wraps your widget with a [PageObserverProvider],
  /// allowing it to react when a route becomes visible or invisible.
  ///
  /// The `onAppear` callback is triggered in two scenarios:
  /// 1. When the route is first pushed onto the navigation stack.
  /// 2. When a route on top of it is popped, making this route visible again.
  ///
  /// `onAppear` is the ideal place to handle arguments passed from a previous
  /// route via `context.pop(args: ...)` or deep link parameters from the URL.
  /// Use `context.getArgumentAndClean()` within this callback to consume
  /// one-time events.
  ///
  /// The `onDisappear` callback is triggered when this route is no longer
  /// visible, either because a new route was pushed on top of it or because
  /// it was popped.
  static SingleChildStatelessWidget watch({
    Key? key,
    void Function(BuildContext context)? onDisappear,
    void Function(
      BuildContext context,
      DeepLinkParam? deepLinkParam,
    )? onAppear,
    Widget? child,
  }) {
    return PageObserverProvider(
      key: key,
      onAppear: onAppear,
      onDisappear: onDisappear,
      routeObserver: routeObserver,
      child: child,
    );
  }

  /// Enqueues a banner to be displayed by the [OverlayManager].
  ///
  /// Banners are shown one by one in the order they are enqueued.
  static void enqueueBanner(
    BuildContext context,
    ContentBuilder content, {
    double? topPadding,
  }) =>
      OverlayManager.enqueueBanner(
        context,
        content: content,
        topPadding: topPadding,
      );

  /// Dismisses the currently visible overlay modal.
  static void dismissOverlay(BuildContext context) =>
      OverlayManager.of(context)?.dismissModal();

  /// Shows a custom overlay modal.
  ///
  /// The [builder] provides a `dismiss` function to close the overlay from within.
  static void showOverlay(
    BuildContext context, {
    required Widget Function(void Function() dismiss) builder,
    required Color backgroundColor,
    required bool isDismissible,
    bool useSafeArea = false,
    Alignment builderAlignment = Alignment.center,
    OverlayTraceRoute? transitionParams,
  }) {
    OverlayManager.of(context)?.showModal(
      Modal(
        content: builder,
        isDismissible: isDismissible,
        useSafeArea: useSafeArea,
        alignment: builderAlignment,
        duration: null,
        transition: transitionParams ??
            OverlayTraceRoute(
              routeTransition: RouteTransition.fade,
              transitionDuration: const Duration(
                milliseconds: 300,
              ),
              reverseTransitionDuration: const Duration(
                milliseconds: 300,
              ),
            ),
        overlayState: Overlay.of(context),
        backgroundColor: backgroundColor,
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return BrowserConfig(
      defaultRoute: defaultRoute,
      routes: routes,
      openUrl: openUrl,
      child: OverlayManager(
        child: Builder(
          builder: (context) {
            return builder(
              context,
              routeObserver,
              generate,
            );
          },
        ),
      ),
    );
  }
}
