import 'package:flutter/widgets.dart';

import 'browser.dart';

class DeferredBrowserRoute extends BrowserRoute {
  DeferredBrowserRoute({
    required super.path,
    required Future Function() loadPageLibrary,
    required Widget page,
    Future<void> Function()? initializeServiceLocator,
    Widget? onLoading,
    Widget? Function(Object? error)? onError,
    super.builderTrigger,
    super.validateArguments,
    super.routeTransition,
  })  : _initializeServiceLocator = initializeServiceLocator,
        _loadPageLibrary = loadPageLibrary,
        _page = page,
        super(
          page: _DeferredPageLoader(
            loadDeferredContent: _loadDeferred(
              loadPageLibrary: loadPageLibrary,
              initializeServiceLocator: initializeServiceLocator,
            ),
            onLoading: onLoading,
            onError: onError,
            page: page,
          ),
        );

  final Future Function() _loadPageLibrary;
  final Future Function()? _initializeServiceLocator;
  final Widget _page;

  static Future _loadDeferred({
    required Future Function() loadPageLibrary,
    Future Function()? initializeServiceLocator,
  }) async {
    await loadPageLibrary();

    if (initializeServiceLocator case final initSL?) {
      await initSL();
    }
  }

  /// Converts this DeferredBrowserRoute into a BrowserRoute with its deferred
  /// content already loaded.
  ///
  /// This method performs the asynchronous loading operations (`_loadPageLibrary`
  /// and `_initializeServiceLocator`) and then returns a new [BrowserRoute]
  /// instance that directly displays the final widget, bypassing the loading
  /// state. This is useful when the deferred content has been preloaded
  /// or loaded by another mechanism.
  Future<BrowserRoute> toCompletedBrowserRoute() async {
    await _loadDeferred(
      loadPageLibrary: _loadPageLibrary,
      initializeServiceLocator: _initializeServiceLocator,
    );

    return BrowserRoute(
      path: path,
      page: _page,
      builderTrigger: builderTrigger,
      validateArguments: validateArguments,
      routeTransition: routeTransition,
    );
  }
}

class _DeferredPageLoader extends StatefulWidget {
  const _DeferredPageLoader({
    required this.loadDeferredContent,
    required this.page,
    this.onLoading,
    this.onError,
  });

  final Future<dynamic> loadDeferredContent;
  final Widget page;
  final Widget? onLoading;
  final Widget? Function(Object? error)? onError;

  @override
  _DeferredPageLoaderState createState() => _DeferredPageLoaderState();
}

class _DeferredPageLoaderState extends State<_DeferredPageLoader> {
  late Future _initializationFuture;

  @override
  void initState() {
    super.initState();
    _initializationFuture = widget.loadDeferredContent;
  }

  @override
  Widget build(BuildContext context) {
    return FutureBuilder<void>(
      future: _initializationFuture,
      builder: (context, snapshot) {
        if (snapshot.connectionState == ConnectionState.done) {
          if (snapshot.hasError) {
            return widget.onError?.call(snapshot.error) ??
                const SizedBox.shrink();
          }
          return widget.page;
        }
        return widget.onLoading ?? const SizedBox.shrink();
      },
    );
  }
}
