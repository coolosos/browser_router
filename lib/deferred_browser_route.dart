import 'package:browser/browser.dart';
import 'package:flutter/widgets.dart';

class DeferredBrowserRoute extends BrowserRoute {
  DeferredBrowserRoute({
    required super.path,
    required Future<void> Function() loadPageLibrary,
    required Widget Function() pageBuilder,
    Future<void> Function()? initializeServiceLocator,
    Widget? loadingWidget,
  }) : super(
          page: FutureBuilder<void>(
            future: () async {
              await loadPageLibrary();
              if (initializeServiceLocator != null) {
                await initializeServiceLocator();
              }
            }(),
            builder: (context, snapshot) {
              if (snapshot.connectionState == ConnectionState.done) {
                return pageBuilder();
              }

              return loadingWidget ?? const SizedBox.shrink();
            },
          ),
        );
}
