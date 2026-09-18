part of 'browser.dart';

extension _Args on Map<Object?, Object?> {
  T? getArgument<T>() {
    if (containsKey(T)) {
      return this[T] as T?;
    } else {
      // Fallback for polymorphic arguments.
      // This handles cases where the requested type `T` is a superclass
      // of the actual argument instance. e.g., if `getArgument<BaseClass>()`
      // is called when the stored argument is an instance of `SubClass`.
      return values.firstWhereOrNull((element) => element is T) as T?;
    }
  }

  T? getAndClean<T>() {
    if (containsKey(T)) {
      return remove(T) as T?;
    } else {
      // Fallback for polymorphic arguments.
      // This handles cases where the requested type `T` is a superclass
      // of the actual argument instance. e.g., if `getArgument<BaseClass>()`
      // is called when the stored argument is an instance of `SubClass`.
      final arg = values.firstWhereOrNull((value) => value is T) as T?;
      if (arg != null) {
        removeWhere((key, value) => value is T);
      }
      return arg;
    }
  }
}

extension NavigatorX on BuildContext {
  Map<Object, Object?> _createArguments(List<Object?>? args) {
    final arguments = <Object, Object?>{
      for (final argument in (args ?? <Object?>[]))
        if (argument != null) argument.runtimeType: argument,
    };
    return arguments;
  }

  /// Reads an argument of type [T] from the current route's settings.
  ///
  /// This method retrieves an argument without removing it from the arguments map.
  /// It is suitable for data that is required to build the screen and may be
  /// accessed multiple times (e.g., a product ID).
  ///
  /// See also:
  ///
  ///  * [getArgumentAndClean], for reading an argument and consuming it immediately.
  T? getArgument<T extends RouteParams?>() {
    final arguments = ModalRoute.of(this)?.settings.arguments;
    if (arguments is Map<Object?, Object?>) {
      return arguments.getArgument<T>();
    }
    return null;
  }

  /// Reads an argument of type [T] and immediately removes it from the
  /// current route's settings.
  ///
  /// This method is designed for consuming one-time events, such as the result
  /// from a screen that was popped (`context.pop(args: ...)`). By removing the
  /// argument after reading, it prevents the same event from being processed
  /// again if the widget rebuilds.
  ///
  /// It is best used within the `onAppear` callback of [Browser.watch].
  ///
  /// See also:
  ///
  ///  * [getArgument], for reading an argument without consuming it.
  T? getArgumentAndClean<T extends RouteParams?>({
    RouteSettings? settings,
  }) {
    final arguments =
        settings?.arguments ?? ModalRoute.of(this)?.settings.arguments;

    if (arguments is! Map<Object?, Object?>) return null;

    return arguments.getAndClean<T>();
  }

  void cleanArguments({
    RouteSettings? settings,
  }) {
    final arguments =
        settings?.arguments ?? ModalRoute.of(this)?.settings.arguments;

    if (arguments is! Map<Object?, Object?>) return;
    arguments.clear();
  }

  NavigatorState get navigate => Navigator.of(
        this,
        // rootNavigator: true
      );

  /// Navigates to a new route by its `path`.
  ///
  /// - [path]: The route path to navigate to.
  /// - [args]: A list of [RouteParams] to pass to the new route.
  /// - [traceRoute]: An optional [TraceRoute] to override the default
  ///   presentation style (e.g., to present as a popup).
  Future<T?> pushNamed<T extends Object?>(
    String path, {
    List<RouteParams?> args = const [],
    TraceRoute? traceRoute,
    RouteSettings? settings,
    NavigatorState? navigator,
  }) {
    final pushParams = getArgumentAndClean<_PushParam>(
      settings: settings,
    )?.pushParams;

    final argsMap = _createArguments([
      ...args,
      pushParams,
      if (traceRoute != null) traceRoute,
    ]);
    return (navigator ?? navigate).pushNamed<T>(path, arguments: argsMap);
  }

  Future<T?> pushReplacementNamed<T extends Object?, TO extends Object?>(
    String path, {
    List<RouteParams?> args = const [],
    TraceRoute? traceRoute,
    RouteSettings? settings,
    NavigatorState? navigator,
    TO? result,
  }) {
    final pushParams = getArgumentAndClean<_PushParam>(
      settings: settings,
    )?.pushParams;
    final argsMap = _createArguments([
      ...args,
      pushParams,
      if (traceRoute != null) traceRoute,
    ]);
    return (navigator ?? navigate).pushReplacementNamed<T, TO>(
      path,
      arguments: argsMap,
      result: result,
    );
  }

  /// Pops the current route off the navigator.
  ///
  /// - [args]: An optional [RouteParams] object to pass to the route
  ///   that will become visible after this one is popped. The receiving
  ///   route can get this argument via `context.getArgumentAndClean()` in its
  ///   `onAppear` callback.
  Future<void> pop({
    RouteParams? args,
    RouteSettings? settings,
  }) async {
    final popParams = getArgumentAndClean<_PopParam>(
      settings: settings,
    )?.popParams;
    final navigator = navigate;

    if (navigator.canPop()) {
      final name = settings?.name ?? ModalRoute.of(this)?.settings.name;
      navigator.popUntil((route) {
        if (route.settings.name == name) {
          return false;
        }
        if (route.settings.arguments is Map<Object?, Object?>) {
          _createArguments([args, popParams]).forEach(
            (key, value) {
              ((route.settings.arguments as Map<Object?, Object?>?) ?? {}).update(
                key,
                (value) => value,
                ifAbsent: () => value,
              );
            },
          );
        }
        return true;
      });
    } else {
      await pushNamed<void>(
        BrowserConfig.of(this).defaultRoute.path,
        args: [args, popParams],
        navigator: navigator,
      );
    }
  }

  Future<void> popToFirstAndPushNamed(
    String path, {
    List<RouteParams?> args = const [],
  }) async {
    final popParams = getArgumentAndClean<_PopParam>()?.popParams;

    final navigator = navigate
      ..popUntil((route) {
        return route.isFirst;
      });

    await pushNamed<void>(path, args: [...args, popParams], navigator: navigator);
  }

  Future<void> popToSelectOrFirstAndPushNamed(
    String path, {
    List<RouteParams?> args = const [],
  }) async {
    final popParams = getArgumentAndClean<_PopParam>()?.popParams;

    final navigator = navigate;

    var returnAsExpected = false;

    navigator.popUntil((route) {
      if (route.settings.name == path) {
        return returnAsExpected = true;
      }
      return route.isFirst;
    });
    if (!returnAsExpected) {
      await pushNamed<void>(path, args: [...args, popParams], navigator: navigator);
    }
  }

  Future<void> popToFirstAndPushReplacementNamed(
    String path, {
    List<RouteParams?> args = const [],
  }) async {
    final popParams = getArgumentAndClean<_PopParam>()?.popParams;
    final navigator = navigate
      ..popUntil((route) {
        return route.isFirst;
      });

    await pushReplacementNamed<void, void>(
      path,
      args: [...args, popParams],
      navigator: navigator,
    );
  }

  Future<void> popToFirst({
    List<RouteParams?> args = const [],
    RouteSettings? settings,
  }) async {
    final popParams = getArgumentAndClean<_PopParam>(
      settings: settings,
    )?.popParams;

    if (!navigate.canPop()) {
      await pushNamed<void>(
        BrowserConfig.of(this).defaultRoute.path,
        args: [
          ...args,
          if (popParams != null) popParams,
        ],
      );
      return;
    }

    return navigate.popUntil((route) {
      if (route.isFirst) {
        if (route.settings.arguments is Map<Object?, Object?>) {
          _createArguments([...args, popParams]).forEach(
            (key, value) {
              (route.settings.arguments! as Map<Object?, Object?>).update(
                key,
                (value) => value,
                ifAbsent: () => value,
              );
            },
          );
        }
        return true;
      } else {
        return false;
      }
    });
  }

  void setPopArgument(RouteParams routeParams) {
    final arguments = ModalRoute.of(this)?.settings.arguments;

    if (arguments is! Map<Object?, Object?>) return;

    final argument = _PopParam(routeParams);

    arguments.update(
      _PopParam,
      (value) => argument,
      ifAbsent: () => argument,
    );
  }

  void setPushArgument(RouteParams routeParams) {
    final arguments = ModalRoute.of(this)?.settings.arguments;

    if (arguments is! Map<Object?, Object?>) return;

    final argument = _PushParam(routeParams);

    arguments.update(
      _PushParam,
      (value) => argument,
      ifAbsent: () => argument,
    );
  }

  bool canNavigate(String path) {
    return BrowserConfig.of(this).routes.any((element) => element.path == path);
  }

  void openUrl(Uri uri) {
    final conf = BrowserConfig.of(this);
    conf.openUrl?.call(uri);
  }

  /// Launches a navigation or URL action based on the given [action] string.
  /// Supports various navigation types via the `navigateType` query parameter.
  ///
  /// Support navigateType:
  ///  * pop: /?navigateType=pop will be pop the current view
  ///  * popFirstAndPush: profile?navigateType=popFirstAndPush pop to the first view and then push
  ///  * pushReplacement: profile?navigateType=pushReplacement push and replacement
  ///  * null || other: push
  ///
  /// If the URI has a scheme (e.g., "https"), it opens the external URL.
  /// Otherwise, it attempts to navigate within the app using named routes.
  void launchAction(String action, {List<RouteParams>? args}) {
    // Try to parse the action as a URI. If invalid, exit early.
    final uri = Uri.tryParse(action);

    if (uri == null) {
      return;
    }

    // If the URI contains a scheme (e.g., "https", "mailto"), treat it as an external link.
    if (uri.scheme.isNotEmpty) {
      openUrl(uri);
      return;
    }

    final navigationType = uri.queryParameters['navigateType']?.toLowerCase();

    // Perform a pop operation
    if (navigationType == 'pop') {
      pop(args: (args ?? <RouteParams>[]).firstOrNull);
    }

    if (uri.path.isEmpty || !canNavigate(uri.path)) {
      return;
    }

    // Handle different navigation strategies based on `navigateType`.
    switch (navigationType) {
      case 'popfirstandpush':
        popToFirstAndPushNamed(uri.toString(), args: args ?? <RouteParams>[]);
        return;
      case 'pushreplacement':
        pushReplacementNamed<void, void>(
          uri.toString(),
          args: args ?? <RouteParams>[],
        );
        return;
      default:
        pushNamed<void>(uri.toString(), args: args ?? <RouteParams>[]);
        return;
    }
  }
}
