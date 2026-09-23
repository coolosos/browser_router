import 'dart:async';

import 'package:browser_router/browser.dart';
import 'package:browser_router/overlay/overlay_manager.dart';
import 'package:flutter/widgets.dart';
import 'package:flutter_test/flutter_test.dart';

final class ValidatedArgs extends RouteParams {
  const new(this.code);
  final String code;

  @override
  bool validate() => code == 'VALID';
}

void main() {
  group('Browser & BrowserRoute Tests', () {
    testWidgets('Browser calls onNavigation callback upon route generation', (
      tester,
    ) async {
      final visitedSettings = <RouteSettings>[];

      final routes = [
        const BrowserRoute(
          path: '/home',
          page: Text('Home Screen', textDirection: TextDirection.ltr),
        ),
        const BrowserRoute(
          path: '/detail',
          page: Text('Detail Screen', textDirection: TextDirection.ltr),
        ),
      ];

      await tester.pumpWidget(
        Browser(
          routes: routes,
          defaultRoute: routes.first,
          onNavigation: visitedSettings.add,
          builder: (context, routeObserver, generate) => WidgetsApp(
            color: const Color(0xFFFFFFFF),
            navigatorObservers: [routeObserver],
            onGenerateRoute: generate,
            onGenerateInitialRoutes: (path) => [
              generate(
                RouteSettings(name: path, arguments: const <dynamic, dynamic>{}),
              ),
            ],
          ),
        ),
      );
      await tester.pumpAndSettle();

      expect(visitedSettings.length, equals(1));
      expect(visitedSettings.first.name, equals('/'));

      final homeContext = tester.element(find.text('Home Screen'));
      unawaited(homeContext.pushNamed('/detail'));
      await tester.pumpAndSettle();

      expect(visitedSettings.length, equals(2));
      expect(visitedSettings.last.name, equals('/detail'));
    });

    testWidgets('adaptiveTransition overrides route transition globally', (
      tester,
    ) async {
      RouteTransition? capturedTransition;

      final routes = [
        const BrowserRoute(
          path: '/home',
          page: Text('Home Screen', textDirection: TextDirection.ltr),
          routeTransition: RouteTransition.slide_right,
        ),
      ];

      await tester.pumpWidget(
        Browser(
          routes: routes,
          defaultRoute: routes.first,
          adaptiveTransition: (route) {
            capturedTransition = RouteTransition.fade;
            return RouteTransition.fade;
          },
          builder: (context, routeObserver, generate) => WidgetsApp(
            color: const Color(0xFFFFFFFF),
            navigatorObservers: [routeObserver],
            onGenerateRoute: generate,
            onGenerateInitialRoutes: (path) => [
              generate(
                RouteSettings(name: path, arguments: const <dynamic, dynamic>{}),
              ),
            ],
          ),
        ),
      );
      await tester.pumpAndSettle();

      expect(capturedTransition, equals(RouteTransition.fade));
    });

    testWidgets('adaptiveTrace determines presentation style based on route name', (
      tester,
    ) async {
      final routes = [
        const BrowserRoute(
          path: '/home',
          page: Text('Home Screen', textDirection: TextDirection.ltr),
        ),
        const BrowserRoute(
          path: '/popup_modal',
          page: Text('Modal Content', textDirection: TextDirection.ltr),
        ),
      ];

      await tester.pumpWidget(
        Browser(
          routes: routes,
          defaultRoute: routes.first,
          adaptiveTrace: (name) {
            if (name == '/popup_modal') {
              return const PopupTraceRoute(
                routeTransition: RouteTransition.fade,
              );
            }
            return null;
          },
          builder: (context, routeObserver, generate) => WidgetsApp(
            color: const Color(0xFFFFFFFF),
            navigatorObservers: [routeObserver],
            onGenerateRoute: generate,
            onGenerateInitialRoutes: (path) => [
              generate(
                RouteSettings(name: path, arguments: const <dynamic, dynamic>{}),
              ),
            ],
          ),
        ),
      );
      await tester.pumpAndSettle();

      final homeContext = tester.element(find.text('Home Screen'));
      unawaited(homeContext.pushNamed('/popup_modal'));
      await tester.pumpAndSettle();

      expect(find.text('Modal Content'), findsOneWidget);
    });

    testWidgets('validateArguments redirects to defaultRoute when validation fails', (
      tester,
    ) async {
      final routes = [
        const BrowserRoute(
          path: '/home',
          page: Text('Home Screen', textDirection: TextDirection.ltr),
        ),
        BrowserRoute(
          path: '/protected',
          page: const Text('Protected Screen', textDirection: TextDirection.ltr),
          validateArguments: (check, get) => check<ValidatedArgs>(),
        ),
      ];

      await tester.pumpWidget(
        Browser(
          routes: routes,
          defaultRoute: routes.first,
          builder: (context, routeObserver, generate) => WidgetsApp(
            color: const Color(0xFFFFFFFF),
            navigatorObservers: [routeObserver],
            onGenerateRoute: generate,
            onGenerateInitialRoutes: (path) => [
              generate(
                RouteSettings(name: path, arguments: const <dynamic, dynamic>{}),
              ),
            ],
          ),
        ),
      );
      await tester.pumpAndSettle();

      final homeContext = tester.element(find.text('Home Screen'));

      // 1. Invalid argument -> redirected to defaultRoute (/home)
      unawaited(
        homeContext.pushNamed(
          '/protected',
          args: [const ValidatedArgs('INVALID_CODE')],
        ),
      );
      await tester.pumpAndSettle();
      expect(find.text('Protected Screen'), findsNothing);
      expect(find.text('Home Screen'), findsOneWidget);

      // 2. Valid argument -> loads protected screen
      final homeContext2 = tester.element(find.text('Home Screen'));
      unawaited(
        homeContext2.pushNamed(
          '/protected',
          args: [const ValidatedArgs('VALID')],
        ),
      );
      await tester.pumpAndSettle();
      expect(find.text('Protected Screen'), findsOneWidget);
    });

    testWidgets('DeepLinkParam extracts query parameters automatically', (
      tester,
    ) async {
      final routes = [
        const BrowserRoute(
          path: '/search',
          page: Text('Search Screen', textDirection: TextDirection.ltr),
        ),
      ];

      await tester.pumpWidget(
        Browser(
          routes: routes,
          defaultRoute: routes.first,
          builder: (context, routeObserver, generate) => WidgetsApp(
            color: const Color(0xFFFFFFFF),
            navigatorObservers: [routeObserver],
            onGenerateRoute: generate,
            onGenerateInitialRoutes: (path) => [
              generate(
                const RouteSettings(
                  name: '/search?query=dart&page=3',
                  arguments: <dynamic, dynamic>{},
                ),
              ),
            ],
          ),
        ),
      );
      await tester.pumpAndSettle();

      final searchContext = tester.element(find.text('Search Screen'));
      final deepLink = searchContext.getArgument<DeepLinkParam>();
      expect(deepLink?.params['query'], equals('dart'));
      expect(deepLink?.params['page'], equals('3'));
    });

    testWidgets('builderTrigger is executed before building the route widget', (
      tester,
    ) async {
      var triggerFired = false;

      final routes = [
        BrowserRoute(
          path: '/home',
          page: const Text('Home Screen', textDirection: TextDirection.ltr),
          builderTrigger: (context) {
            triggerFired = true;
          },
        ),
      ];

      await tester.pumpWidget(
        Browser(
          routes: routes,
          defaultRoute: routes.first,
          builder: (context, routeObserver, generate) => WidgetsApp(
            color: const Color(0xFFFFFFFF),
            navigatorObservers: [routeObserver],
            onGenerateRoute: generate,
            onGenerateInitialRoutes: (path) => [
              generate(
                RouteSettings(name: path, arguments: const <dynamic, dynamic>{}),
              ),
            ],
          ),
        ),
      );
      await tester.pumpAndSettle();

      expect(triggerFired, isTrue);
    });

    testWidgets('BrowserRoute copyWith and props equality work properly', (
      tester,
    ) async {
      const page1 = Text('Page 1');
      const page2 = Text('Page 2');

      const route1 = BrowserRoute(
        path: '/test',
        page: page1,
        routeTransition: RouteTransition.fade,
      );

      final route2 = route1.copyWith(
        page: page2,
        routeTransition: RouteTransition.fade,
      );

      expect(route2.path, equals('/test'));
      expect(route2.page, equals(page2));
      expect(route2.routeTransition, equals(RouteTransition.fade));

      // Equatable props equality based on path
      const route3 = BrowserRoute(path: '/test', page: page2);
      expect(route1, equals(route3));
    });

    testWidgets('BrowserConfig InheritedWidget of and error throwing', (
      tester,
    ) async {
      final routes = [
        const BrowserRoute(
          path: '/home',
          page: Text('Home Screen', textDirection: TextDirection.ltr),
        ),
      ];

      await tester.pumpWidget(
        Browser(
          routes: routes,
          defaultRoute: routes.first,
          builder: (context, routeObserver, generate) => WidgetsApp(
            color: const Color(0xFFFFFFFF),
            navigatorObservers: [routeObserver],
            onGenerateRoute: generate,
            onGenerateInitialRoutes: (path) => [
              generate(
                RouteSettings(name: path, arguments: const <dynamic, dynamic>{}),
              ),
            ],
          ),
        ),
      );
      await tester.pumpAndSettle();

      final context = tester.element(find.text('Home Screen'));
      final config1 = BrowserConfig.of(context, build: false);
      final config2 = BrowserConfig.of(context, build: true);

      expect(config1.routes, equals(routes));
      expect(config2.defaultRoute, equals(routes.first));

      // updateShouldNotify
      final configNew = BrowserConfig(
        defaultRoute: routes.first,
        routes: routes,
        openUrl: null,
        child: const SizedBox.shrink(),
      );
      expect(config1.updateShouldNotify(configNew), isFalse);

      // Outside Browser context throws FlutterError
      await tester.pumpWidget(
        Builder(
          builder: (standaloneContext) {
            expect(
              () => BrowserConfig.of(standaloneContext),
              throwsA(isA<FlutterError>()),
            );
            return const SizedBox.shrink();
          },
        ),
      );
    });

    testWidgets('Browser overlay helpers showModalBottomSheet, showOverlay, dismissOverlay, enqueueBanner', (
      tester,
    ) async {
      final routes = [
        const BrowserRoute(
          path: '/home',
          page: Text('Home Screen', textDirection: TextDirection.ltr),
        ),
      ];

      await tester.pumpWidget(
        Browser(
          routes: routes,
          defaultRoute: routes.first,
          builder: (context, routeObserver, generate) => WidgetsApp(
            color: const Color(0xFFFFFFFF),
            navigatorObservers: [routeObserver],
            onGenerateRoute: generate,
            onGenerateInitialRoutes: (path) => [
              generate(
                RouteSettings(name: path, arguments: const <dynamic, dynamic>{}),
              ),
            ],
          ),
        ),
      );
      await tester.pumpAndSettle();

      final context = tester.element(find.text('Home Screen'));

      // 1. showOverlay & dismissOverlay
      Browser.showOverlay(
        context,
        backgroundColor: const Color(0x80000000),
        isDismissible: true,
        builder: (dismiss) => const Text('Custom Overlay Text', textDirection: TextDirection.ltr),
      );
      await tester.pumpAndSettle();
      expect(find.text('Custom Overlay Text'), findsOneWidget);

      Browser.dismissOverlay(context);
      await tester.pumpAndSettle();
      expect(find.text('Custom Overlay Text'), findsNothing);

      // 2. enqueueBanner
      Browser.enqueueBanner(
        context,
        (dismiss) => const Text('Enqueued Banner Text', textDirection: TextDirection.ltr),
      );
      await tester.pump();
      await tester.pump(const Duration(milliseconds: 350));
      expect(find.text('Enqueued Banner Text'), findsOneWidget);

      // Dismiss banner
      OverlayManager.of(context)?.removeActual();
      await tester.pumpAndSettle();
      expect(find.text('Enqueued Banner Text'), findsNothing);

      // 3. showModalBottomSheet
      unawaited(
        Browser.showModalBottomSheet<void>(
          context: context,
          backgroundColor: const Color(0xFFFFFFFF),
          builder: (ctx) => const Text('Bottom Sheet Content', textDirection: TextDirection.ltr),
        ),
      );
      await tester.pumpAndSettle();
      expect(find.text('Bottom Sheet Content'), findsOneWidget);

      // Pop bottom sheet
      final sheetContext = tester.element(find.text('Bottom Sheet Content'));
      unawaited(sheetContext.pop());
      await tester.pumpAndSettle();
      expect(find.text('Bottom Sheet Content'), findsNothing);
    });
  });
}
