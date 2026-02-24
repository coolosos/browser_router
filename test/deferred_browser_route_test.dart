import 'dart:async';

import 'package:browser_router/browser.dart';
import 'package:browser_router/deferred_browser_route.dart';
import 'package:flutter/widgets.dart'; // Changed from material to widgets
import 'package:flutter_test/flutter_test.dart';

class _TestPageRoute extends PageRoute<void> {
  _TestPageRoute({required this.child, required RouteSettings settings})
      : super(settings: settings);

  final Widget child;

  @override
  Color? get barrierColor => null;

  @override
  String? get barrierLabel => null;

  @override
  bool get maintainState => true;

  @override
  Duration get transitionDuration => Duration.zero;

  @override
  Widget buildPage(
    BuildContext context,
    Animation<double> animation,
    Animation<double> secondaryAnimation,
  ) {
    return child;
  }
}

void main() {
  group('DeferredBrowserRoute', () {
    DeferredBrowserRoute createDeferredRoute({
      required Future<void> Function() loadPageLibrary,
      required Widget page,
      Future<void> Function()? initializeServiceLocator,
      Widget? onLoading,
      Widget? Function(Object? error)? onError,
    }) {
      return DeferredBrowserRoute(
        path: '/deferred',
        loadPageLibrary: loadPageLibrary,
        page: page,
        initializeServiceLocator: initializeServiceLocator,
        onLoading: onLoading,
        onError: onError,
      );
    }

    testWidgets(
        'shows loading widget then page when future completes successfully',
        (WidgetTester tester) async {
      var libraryLoaded = false;
      final completer = Completer<void>();

      final route = createDeferredRoute(
        loadPageLibrary: () async {
          await completer.future;
          libraryLoaded = true;
        },
        page: const Text(
          'Deferred Page Content',
          textDirection: TextDirection.ltr,
        ),
        onLoading: const Text('Loading...', textDirection: TextDirection.ltr),
      );

      await tester.pumpWidget(
        WidgetsApp(
          home: Navigator(
            onGenerateRoute: (settings) {
              if (settings.name == route.path) {
                return _TestPageRoute(child: route.page, settings: settings);
              }
              return _TestPageRoute(
                child: const Text(
                  'Initial Page',
                  textDirection: TextDirection.ltr,
                ),
                settings: settings,
              );
            },
            initialRoute: route.path,
          ),
          pageRouteBuilder:
              <T>(RouteSettings settings, WidgetBuilder builder) =>
                  PageRouteBuilder<T>(
            settings: settings,
            pageBuilder: (
              BuildContext context,
              Animation<double> animation,
              Animation<double> secondaryAnimation,
            ) =>
                builder(context),
          ),
          color: const Color(0xFFFFFFFF),
        ),
      );

      expect(find.text('Loading...'), findsOneWidget);
      expect(find.text('Deferred Page Content'), findsNothing);
      expect(libraryLoaded, isFalse);

      completer.complete();
      await tester.pumpAndSettle();

      expect(find.text('Loading...'), findsNothing);
      expect(find.text('Deferred Page Content'), findsOneWidget);
      expect(libraryLoaded, isTrue);
    });

    testWidgets('shows error widget when future completes with an error',
        (WidgetTester tester) async {
      final completer = Completer<void>();
      final testError = Exception('Failed to load library');

      final route = createDeferredRoute(
        loadPageLibrary: () async {
          await completer.future;
          throw testError;
        },
        page: const Text(
          'Deferred Page Content',
          textDirection: TextDirection.ltr,
        ),
        onLoading: const Text('Loading...', textDirection: TextDirection.ltr),
        onError: (error) =>
            Text('Error: $error', textDirection: TextDirection.ltr),
      );

      await tester.pumpWidget(
        WidgetsApp(
          home: Navigator(
            onGenerateRoute: (settings) {
              if (settings.name == route.path) {
                return _TestPageRoute(child: route.page, settings: settings);
              }
              return _TestPageRoute(
                child: const Text(
                  'Initial Page',
                  textDirection: TextDirection.ltr,
                ),
                settings: settings,
              );
            },
            initialRoute: route.path,
          ),
          pageRouteBuilder:
              <T>(RouteSettings settings, WidgetBuilder builder) =>
                  PageRouteBuilder<T>(
            settings: settings,
            pageBuilder: (
              BuildContext context,
              Animation<double> animation,
              Animation<double> secondaryAnimation,
            ) =>
                builder(context),
          ),
          color: const Color(0xFFFFFFFF),
        ),
      );

      expect(find.text('Loading...'), findsOneWidget);
      expect(find.text('Deferred Page Content'), findsNothing);
      expect(
        find.textContaining('Error: Exception: Failed to load library'),
        findsNothing,
      );

      completer.completeError(testError);
      await tester.pumpAndSettle();

      expect(find.text('Loading...'), findsNothing);
      expect(find.text('Deferred Page Content'), findsNothing);
      expect(
        find.textContaining('Error: Exception: Failed to load library'),
        findsOneWidget,
      );
    });

    test(
        'toCompletedBrowserRoute loads content and returns synchronous BrowserRoute',
        () async {
      var libraryLoaded = false;
      var serviceLocatorInitialized = false;

      final deferredRoute = DeferredBrowserRoute(
        path: '/deferred_sync',
        loadPageLibrary: () async {
          await Future.delayed(
            const Duration(milliseconds: 10),
          );
          libraryLoaded = true;
        },
        page: const Text(
          'Synchronous Page Content',
          textDirection: TextDirection.ltr,
        ),
        initializeServiceLocator: () async {
          await Future.delayed(
            const Duration(milliseconds: 5),
          );
          serviceLocatorInitialized = true;
        },
      );

      final completedRoute = await deferredRoute.toCompletedBrowserRoute();

      expect(libraryLoaded, isTrue);
      expect(serviceLocatorInitialized, isTrue);

      expect(completedRoute, isA<BrowserRoute>());
      expect(completedRoute.path, '/deferred_sync');

      expect(
        completedRoute.page,
        isA<Text>(),
      );
      final textWidget = completedRoute.page as Text;
      expect(textWidget.data, 'Synchronous Page Content');
    });
  });
}
