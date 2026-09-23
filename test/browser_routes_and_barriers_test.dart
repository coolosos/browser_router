import 'dart:async';

import 'package:browser_router/browser.dart';
import 'package:browser_router/modal_route/browser_page_route.dart';
import 'package:browser_router/modal_route/browser_popup_route.dart';
import 'package:browser_router/modal_route/browser_swipe_popup_route.dart';
import 'package:browser_router/overlay/overlay_manager.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter/widgets.dart' hide Banner;
import 'package:flutter_test/flutter_test.dart';

void main() {
  group('BrowserPageRoute & BrowserPopupRoute Tests', () {
    testWidgets('BrowserPageRoute has zero duration for RouteTransition.none', (
      tester,
    ) async {
      const appRoute = BrowserRoute(
        path: '/none',
        page: Text('None Route', textDirection: TextDirection.ltr),
        routeTransition: RouteTransition.none,
      );
      const traceRoute = PageTraceRoute();
      final pageRoute = BrowserPageRoute<void>(
        appRoute: appRoute,
        traceRoute: traceRoute,
        settings: const RouteSettings(name: '/none'),
      );

      expect(pageRoute.transitionDuration, equals(Duration.zero));
      expect(pageRoute.reverseTransitionDuration, equals(Duration.zero));
      expect(pageRoute.debugLabel, contains('/none'));
    });

    testWidgets('BrowserPageRoute canTransitionTo respects fullScreenDialog', (
      tester,
    ) async {
      const appRoute = BrowserRoute(
        path: '/page',
        page: Text('Page', textDirection: TextDirection.ltr),
      );
      final pageRoute = BrowserPageRoute<void>(
        appRoute: appRoute,
        traceRoute: const PageTraceRoute(),
      );

      final standardRoute = BrowserPageRoute<void>(
        appRoute: appRoute,
        traceRoute: const PageTraceRoute(fullScreenDialog: false),
      );
      expect(pageRoute.canTransitionTo(standardRoute), isTrue);

      final dialogRoute = BrowserPageRoute<void>(
        appRoute: appRoute,
        traceRoute: const PageTraceRoute(fullScreenDialog: true),
      );
      expect(pageRoute.canTransitionTo(dialogRoute), isFalse);
    });

    testWidgets('BrowserPageRoute renders iOS swipe transition when enabled', (
      tester,
    ) async {
      debugDefaultTargetPlatformOverride = TargetPlatform.iOS;

      try {
        const routes = [
          BrowserRoute(
            path: '/home',
            page: Text('Home Screen', textDirection: TextDirection.ltr),
          ),
          BrowserRoute(
            path: '/swipeable',
            page: Text('Swipeable Screen', textDirection: TextDirection.ltr),
            routeTransition: RouteTransition.slide_right,
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
        unawaited(
          homeContext.pushNamed(
            '/swipeable',
            traceRoute: const PageTraceRoute(popGestureEnabled: true),
          ),
        );
        await tester.pumpAndSettle();

        expect(find.text('Swipeable Screen'), findsOneWidget);
      } finally {
        debugDefaultTargetPlatformOverride = null;
      }
    });

    testWidgets('BrowserPopupRoute properties and debugLabel', (
      tester,
    ) async {
      const appRoute = BrowserRoute(
        path: '/popup',
        page: Text('Popup Content', textDirection: TextDirection.ltr),
      );
      const traceRoute = PopupTraceRoute(
        barrierDismissible: true,
        barrierColor: Color(0x80000000),
        barrierLabel: 'Popup Barrier Label',
      );

      final popupRoute = BrowserPopupRoute<void, PopupTraceRoute>(
        appRoute: appRoute,
        traceRoute: traceRoute,
        settings: const RouteSettings(name: '/popup'),
      );

      expect(popupRoute.barrierDismissible, isTrue);
      expect(popupRoute.barrierColor, equals(const Color(0x80000000)));
      expect(popupRoute.barrierLabel, equals('Popup Barrier Label'));
      expect(popupRoute.debugLabel, contains('/popup'));
    });

    testWidgets('BrowserSwipePopupRoute buildPage with useSafeArea true and false', (
      tester,
    ) async {
      const routes = [
        BrowserRoute(
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

      // 1. Swipe route with useSafeArea: true
      final swipeRouteSafe = BrowserSwipePopupRoute<void>(
        traceRoute: const SwipeTraceRoute(useSafeArea: true),
        appRoute: const BrowserRoute(
          path: '/sheet_safe',
          page: Text('Safe Sheet', textDirection: TextDirection.ltr),
        ),
        settings: const RouteSettings(name: '/sheet_safe'),
      );
      Navigator.of(context).push(swipeRouteSafe);
      await tester.pumpAndSettle();
      expect(find.text('Safe Sheet'), findsOneWidget);

      final safeContext = tester.element(find.text('Safe Sheet'));
      await safeContext.pop();
      await tester.pumpAndSettle();

      // 2. Swipe route with useSafeArea: false
      final swipeRouteUnsafe = BrowserSwipePopupRoute<void>(
        traceRoute: const SwipeTraceRoute(useSafeArea: false),
        appRoute: const BrowserRoute(
          path: '/sheet_unsafe',
          page: Text('Unsafe Sheet', textDirection: TextDirection.ltr),
        ),
        settings: const RouteSettings(name: '/sheet_unsafe'),
      );
      final currentContext = tester.element(find.text('Home Screen'));
      Navigator.of(currentContext).push(swipeRouteUnsafe);
      await tester.pumpAndSettle();
      expect(find.text('Unsafe Sheet'), findsOneWidget);
    });
  });

  group('BrowserModalBarrierMixin & Modal/Banner Tests', () {
    testWidgets('Modal barrier renders and handles tap dismiss', (
      tester,
    ) async {
      const routes = [
        BrowserRoute(
          path: '/home',
          page: Text('Home Screen', textDirection: TextDirection.ltr),
        ),
        BrowserRoute(
          path: '/popup',
          page: Center(child: Text('Popup Content', textDirection: TextDirection.ltr)),
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
      unawaited(
        homeContext.pushNamed(
          '/popup',
          traceRoute: const PopupTraceRoute(
            barrierDismissible: true,
            barrierColor: Color(0x80000000),
          ),
        ),
      );
      await tester.pumpAndSettle();
      expect(find.text('Popup Content'), findsOneWidget);

      // Verify and trigger modal barrier dismiss
      final barrierFinder = find.byType(AnimatedModalBarrier).last;
      final modalBarrier = tester.widget<AnimatedModalBarrier>(barrierFinder);
      expect(modalBarrier.dismissible, isTrue);
      modalBarrier.onDismiss?.call();
      await tester.pumpAndSettle();

      expect(find.text('Popup Content'), findsNothing);
      expect(find.text('Home Screen'), findsOneWidget);
    });

    testWidgets('Modal alignment fix and properties', (
      tester,
    ) async {
      const routes = [
        BrowserRoute(
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

      final homeContext = tester.element(find.text('Home Screen'));

      // Show Modal with custom alignment and useSafeArea = true
      Browser.showOverlay(
        homeContext,
        backgroundColor: const Color(0x80000000),
        isDismissible: true,
        useSafeArea: true,
        builderAlignment: Alignment.bottomCenter,
        builder: (dismiss) => const Text('Aligned Modal', textDirection: TextDirection.ltr),
      );
      await tester.pumpAndSettle();

      expect(find.text('Aligned Modal'), findsOneWidget);

      // Verify Align widget has Alignment.bottomCenter
      final alignFinder = find.ancestor(
        of: find.text('Aligned Modal'),
        matching: find.byType(Align),
      );
      expect(alignFinder, findsWidgets);
      final alignWidget = tester.widget<Align>(alignFinder.first);
      expect(alignWidget.alignment, equals(Alignment.bottomCenter));

      // Tap background to dismiss
      await tester.tap(find.byType(GestureDetector).last);
      await tester.pumpAndSettle();
      expect(find.text('Aligned Modal'), findsNothing);
    });

    testWidgets('Banner.fromContext and swipe dismiss up', (
      tester,
    ) async {
      const routes = [
        BrowserRoute(
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

      final homeContext = tester.element(find.text('Home Screen'));
      unawaited(
        Banner.fromContext(
          context: homeContext,
          content: (dismiss) => const Text('Swipe Up Banner', textDirection: TextDirection.ltr),
          transition: const OverlayTraceRoute(),
        ).insert(),
      );
      await tester.pumpAndSettle();
      expect(find.text('Swipe Up Banner'), findsOneWidget);

      // Dismiss by swiping up
      await tester.fling(find.text('Swipe Up Banner'), const Offset(0, -300), 1000);
      await tester.pumpAndSettle();

      expect(find.text('Swipe Up Banner'), findsNothing);
    });

    testWidgets('Sheet widget and ModalDraggableScrollableSheetParams', (
      tester,
    ) async {
      // 1. Sheet route & static show
      final sheetRoute = Sheet.route;
      expect(sheetRoute.path, equals(Sheet.sheetPath));

      final routes = [
        const BrowserRoute(
          path: '/home',
          page: Text('Home Screen', textDirection: TextDirection.ltr),
        ),
        Sheet.route,
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
      unawaited(
        Sheet.show(
          homeContext,
          const Text('Sheet Dynamic Child', textDirection: TextDirection.ltr),
        ),
      );
      await tester.pumpAndSettle();

      expect(find.text('Sheet Dynamic Child'), findsOneWidget);

      final sheetContext = tester.element(find.text('Sheet Dynamic Child'));
      unawaited(sheetContext.pop());
      await tester.pumpAndSettle();
      expect(find.text('Sheet Dynamic Child'), findsNothing);

      // 2. ModalDraggableScrollableSheetParams variants
      const smallParams = ModalDraggableScrollableSheetParams.small();
      expect(smallParams.initialHeightChildSize, equals(0.35));
      expect(smallParams.minHeightChildSize, equals(0.35));
      expect(smallParams.maxHeightChildSize, equals(0.75));

      const mediumParams = ModalDraggableScrollableSheetParams.medium();
      expect(mediumParams.initialHeightChildSize, equals(0.4));
      expect(mediumParams.maxHeightChildSize, equals(0.6));

      const largeParams = ModalDraggableScrollableSheetParams.large();
      expect(largeParams.initialHeightChildSize, equals(0.45));
      expect(largeParams.minHeightChildSize, equals(0.3));
      expect(largeParams.maxHeightChildSize, equals(0.86));
    });
  });
}
