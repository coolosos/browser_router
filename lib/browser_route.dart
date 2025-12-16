part of 'browser.dart';

typedef Check = bool Function<T extends RouteParams>();
typedef GetArguments = T? Function<T extends RouteParams>();

/// Defines a single route in the application's navigation map.
///
/// Each [BrowserRoute] associates a [path] (like '/home' or '/profile/:id')
/// with a [page] widget that should be displayed. It also allows for defining
/// a default [routeTransition] and argument validation logic.
class BrowserRoute extends Equatable {
  const BrowserRoute({
    required this.path,
    required this.page,
    this.builderTrigger,
    this.validateArguments,
    this.routeTransition = RouteTransition.slide_right,
  });

  /// The unique path for this route (e.g., '/profile').
  final String path;

  /// The widget to be displayed when this route is active.
  final Widget page;

  /// The default transition animation for this route.
  /// This can be overridden by a [TraceRoute] during navigation.
  final RouteTransition routeTransition;

  /// An optional function that is executed just before the [page] widget is
  /// built.
  ///
  /// This is useful for triggering logic that depends on the route's context,
  /// such as dependency injection or analytics events.
  final Function(BuildContext context)? builderTrigger;

  /// An optional function to validate arguments before navigating to this route.
  ///
  /// It receives two functions:
  /// - `checkArgument`: A function to check if an argument of a certain type
  ///   exists and is valid (by calling its `validate()` method).
  /// - `getArgument`: A function to retrieve an argument of a certain type.
  ///
  /// If this function returns `false`, the navigation is aborted, and the
  /// `defaultRoute` from [Browser] is used instead.
  ///
  /// Example:
  /// ```dart
  /// validateArguments: (check, get) => check<ProfileArgs>(),
  /// ```
  final bool Function(Check checkArgument, GetArguments getArgument)?
      validateArguments;

  @override
  List<Object?> get props => [
        path,
      ];

  BrowserRoute copyWith({
    String? path,
    Widget? page,
    RouteTransition? routeTransition,
    Function(BuildContext context)? builderTrigger,
    bool Function(Check checkArgument, GetArguments getArgument)?
        validateArguments,
  }) {
    return BrowserRoute(
      page: page ?? this.page,
      path: path ?? this.path,
      routeTransition: routeTransition ?? this.routeTransition,
      builderTrigger: builderTrigger ?? this.builderTrigger,
      validateArguments: validateArguments ?? this.validateArguments,
    );
  }
}
