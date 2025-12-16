part of 'browser.dart';

@immutable
class BrowserConfig extends InheritedWidget {
  const BrowserConfig({
    required this.defaultRoute,
    required this.routes,
    required this.openUrl,
    required super.child,
    super.key,
  });

  final BrowserRoute defaultRoute;
  final List<BrowserRoute> routes;
  final Future<void> Function(Uri uri)? openUrl;

  static BrowserConfig of(
    BuildContext context, {
    bool build = false,
  }) {
    final conf = build
        ? context.dependOnInheritedWidgetOfExactType<BrowserConfig>()
        : context.findAncestorWidgetOfExactType<BrowserConfig>();

    if (conf == null) {
      throw FlutterError(
        '''
        BrowserConfig.of() called with a context that does not contain a config.
        
        The widget used was: ${context.widget.runtimeType}.
        ''',
      );
    }

    return conf;
  }

  @override
  bool updateShouldNotify(BrowserConfig oldWidget) {
    return oldWidget.defaultRoute != defaultRoute ||
        oldWidget.routes != routes ||
        oldWidget.openUrl != openUrl;
  }
}
