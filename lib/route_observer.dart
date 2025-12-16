part of 'browser.dart';

class PageObserverProvider extends SingleChildStatelessWidget {
  const PageObserverProvider({
    required this.routeObserver,
    this.onAppear,
    this.onDisappear,
    super.key,
    super.child,
  });

  final void Function(
    BuildContext context,
    DeepLinkParam? deepLinkParam,
  )? onAppear;

  final void Function(
    BuildContext context,
  )? onDisappear;

  final RouteObserver<ModalRoute<void>> routeObserver;

  @override
  Widget buildWithChild(BuildContext context, Widget? child) {
    return RouteObserverProvider(
      routeObserver: routeObserver,
      didPopNextWithArguments: onAppear,
      didPush: onAppear,
      didPop: onDisappear,
      didPushNext: onDisappear,
      child: child,
    );
  }
}

class RouteObserverProvider extends SingleChildStatefulWidget {
  const RouteObserverProvider({
    required this.routeObserver,
    this.didPopNext,
    this.didPopNextWithArguments,
    this.didPush,
    this.didPop,
    this.didPushNext,
    super.child,
    super.key,
  });

  final RouteObserver<ModalRoute<void>> routeObserver;

  /// Called when the top route has been popped off, and the current route
  /// shows up.
  /// !appears
  final void Function(
    BuildContext context,
  )? didPopNext;

  /// Called when the top route has been popped off, and the current route
  /// shows up with arguments.
  /// !appears
  final void Function(
    BuildContext context,
    DeepLinkParam? deepLinkParam,
  )? didPopNextWithArguments;

  /// Called when the current route has been pushed.
  /// !appears
  final void Function(
    BuildContext context,
    DeepLinkParam? deepLinkParam,
  )? didPush;

  /// Called when the current route has been popped off.
  /// !disappear
  final void Function(
    BuildContext context,
  )? didPop;

  /// Called when a new route has been pushed, and the current route is no
  /// longer visible.
  /// !disappear
  final void Function(
    BuildContext context,
  )? didPushNext;

  @override
  State<RouteObserverProvider> createState() => _RouteObserverProviderState();
}

class _RouteObserverProviderState
    extends SingleChildState<RouteObserverProvider> with RouteAware {
  @override
  void didChangeDependencies() {
    super.didChangeDependencies();

    final ModalRoute? modalRoute = ModalRoute.of(context);
    if (modalRoute is ModalRoute) {
      widget.routeObserver.subscribe(this, modalRoute);
    }
  }

  @override
  void dispose() {
    widget.routeObserver.unsubscribe(this);
    super.dispose();
  }

  @override
  void didPopNext() {
    if (mounted) {
      widget.didPopNext?.call(context);
      if (widget.didPopNextWithArguments != null) {
        WidgetsBinding.instance.addPostFrameCallback((_) {
          final deepLink = context.getArgument<DeepLinkParam>();

          if (mounted) {
            widget.didPopNextWithArguments?.call(context, deepLink);
          }
        });
      }
    }
    super.didPopNext();
  }

  @override
  void didPush() {
    if (mounted) {
      final deepLink = context.getArgument<DeepLinkParam>();
      widget.didPush?.call(context, deepLink);
    }
    super.didPush();
  }

  @override
  void didPop() {
    if (mounted) {
      widget.didPop?.call(context);
    }
    super.didPop();
  }

  @override
  void didPushNext() {
    if (mounted) {
      widget.didPushNext?.call(context);
    }
    super.didPushNext();
  }

  @override
  Widget buildWithChild(BuildContext context, Widget? child) {
    return child ?? const SizedBox.shrink();
  }
}
