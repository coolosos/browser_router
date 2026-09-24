import 'package:browser_router/browser.dart';
import 'package:browser_router/modal_route/browser_page_route.dart';
import 'package:browser_router/modal_route/browser_popup_route.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter/widgets.dart';
import 'package:flutter_test/flutter_test.dart';

void main() {
  group('Browser.defaultAdaptiveTransition Tests', () {
    test('returns platform-appropriate transitions', () {
      const sampleRoute = BrowserRoute(
        path: '/test',
        page: SizedBox(),
      );

      debugDefaultTargetPlatformOverride = TargetPlatform.iOS;
      expect(
        Browser.defaultAdaptiveTransition(sampleRoute),
        equals(RouteTransition.slide_cupertino),
      );

      debugDefaultTargetPlatformOverride = TargetPlatform.macOS;
      expect(
        Browser.defaultAdaptiveTransition(sampleRoute),
        equals(RouteTransition.slide_cupertino),
      );

      debugDefaultTargetPlatformOverride = TargetPlatform.android;
      expect(
        Browser.defaultAdaptiveTransition(sampleRoute),
        equals(RouteTransition.shared_axis_x),
      );

      debugDefaultTargetPlatformOverride = TargetPlatform.fuchsia;
      expect(
        Browser.defaultAdaptiveTransition(sampleRoute),
        equals(RouteTransition.shared_axis_x),
      );

      debugDefaultTargetPlatformOverride = TargetPlatform.windows;
      expect(
        Browser.defaultAdaptiveTransition(sampleRoute),
        equals(RouteTransition.fade_scale),
      );

      debugDefaultTargetPlatformOverride = TargetPlatform.linux;
      expect(
        Browser.defaultAdaptiveTransition(sampleRoute),
        equals(RouteTransition.fade_scale),
      );

      debugDefaultTargetPlatformOverride = null;
    });
  });

  group('Modern Transitions Integration in BrowserPageRoute', () {
    final modernTransitions = [
      RouteTransition.fade_through,
      RouteTransition.fade_scale,
      RouteTransition.shared_axis_x,
      RouteTransition.shared_axis_y,
      RouteTransition.shared_axis_z,
      RouteTransition.slide_cupertino,
      RouteTransition.scale,
    ];

    for (final transition in modernTransitions) {
      testWidgets('BrowserPageRoute builds transition correctly for ${transition.name}', (
        tester,
      ) async {
        final appRoute = BrowserRoute(
          path: '/${transition.name}',
          page: Text('Page ${transition.name}', textDirection: TextDirection.ltr),
          routeTransition: transition,
        );
        const traceRoute = PageTraceRoute();
        final pageRoute = BrowserPageRoute<void>(
          appRoute: appRoute,
          traceRoute: traceRoute,
          settings: RouteSettings(name: '/${transition.name}'),
        );

        await tester.pumpWidget(
          Directionality(
            textDirection: TextDirection.ltr,
            child: MediaQuery(
              data: const MediaQueryData(),
              child: Builder(
                builder: (context) {
                  return pageRoute.buildTransitions(
                    context,
                    kAlwaysCompleteAnimation,
                    kAlwaysDismissedAnimation,
                    const Text('Child', textDirection: TextDirection.ltr),
                  );
                },
              ),
            ),
          ),
        );

        expect(find.text('Child'), findsOneWidget);
        expect(find.byType(RepaintBoundary), findsWidgets);
      });
    }

    testWidgets('BrowserPageRoute bypasses transitions when disableAnimations is true', (
      tester,
    ) async {
      const appRoute = BrowserRoute(
        path: '/a11y-disable',
        page: Text('Page', textDirection: TextDirection.ltr),
        routeTransition: RouteTransition.fade_through,
      );
      const traceRoute = PageTraceRoute();
      final pageRoute = BrowserPageRoute<void>(
        appRoute: appRoute,
        traceRoute: traceRoute,
      );

      await tester.pumpWidget(
        Directionality(
          textDirection: TextDirection.ltr,
          child: MediaQuery(
            data: const MediaQueryData(disableAnimations: true),
            child: Builder(
              builder: (context) {
                return pageRoute.buildTransitions(
                  context,
                  kAlwaysCompleteAnimation,
                  kAlwaysDismissedAnimation,
                  const Text('Reduced Motion Child', textDirection: TextDirection.ltr),
                );
              },
            ),
          ),
        ),
      );

      expect(find.text('Reduced Motion Child'), findsOneWidget);
    });

    testWidgets('BrowserPageRoute bypasses transitions when accessibleNavigation is true', (
      tester,
    ) async {
      const appRoute = BrowserRoute(
        path: '/a11y-nav',
        page: Text('Page', textDirection: TextDirection.ltr),
        routeTransition: RouteTransition.slide_cupertino,
      );
      const traceRoute = PageTraceRoute();
      final pageRoute = BrowserPageRoute<void>(
        appRoute: appRoute,
        traceRoute: traceRoute,
      );

      await tester.pumpWidget(
        Directionality(
          textDirection: TextDirection.ltr,
          child: MediaQuery(
            data: const MediaQueryData(accessibleNavigation: true),
            child: Builder(
              builder: (context) {
                return pageRoute.buildTransitions(
                  context,
                  kAlwaysCompleteAnimation,
                  kAlwaysDismissedAnimation,
                  const Text('A11y Nav Child', textDirection: TextDirection.ltr),
                );
              },
            ),
          ),
        ),
      );

      expect(find.text('A11y Nav Child'), findsOneWidget);
    });
  });

  group('Modern Transitions Integration in BrowserPopupRoute', () {
    testWidgets('BrowserPopupRoute builds transition and respects reduced motion', (
      tester,
    ) async {
      const appRoute = BrowserRoute(
        path: '/popup-modern',
        page: Text('Popup Page', textDirection: TextDirection.ltr),
        routeTransition: RouteTransition.fade_scale,
      );
      const traceRoute = PopupTraceRoute();
      final popupRoute = BrowserPopupRoute<void, PopupTraceRoute>(
        appRoute: appRoute,
        traceRoute: traceRoute,
      );

      // Normal animation
      await tester.pumpWidget(
        Directionality(
          textDirection: TextDirection.ltr,
          child: MediaQuery(
            data: const MediaQueryData(),
            child: Builder(
              builder: (context) {
                return popupRoute.buildTransitions(
                  context,
                  kAlwaysCompleteAnimation,
                  kAlwaysDismissedAnimation,
                  const Text('Popup Child', textDirection: TextDirection.ltr),
                );
              },
            ),
          ),
        ),
      );

      expect(find.text('Popup Child'), findsOneWidget);
      expect(find.byType(RepaintBoundary), findsWidgets);

      // Reduced motion
      await tester.pumpWidget(
        Directionality(
          textDirection: TextDirection.ltr,
          child: MediaQuery(
            data: const MediaQueryData(disableAnimations: true),
            child: Builder(
              builder: (context) {
                return popupRoute.buildTransitions(
                  context,
                  kAlwaysCompleteAnimation,
                  kAlwaysDismissedAnimation,
                  const Text('Popup Reduced Motion', textDirection: TextDirection.ltr),
                );
              },
            ),
          ),
        ),
      );

      expect(find.text('Popup Reduced Motion'), findsOneWidget);
    });
  });

  group('Custom Transition Tests', () {
    testWidgets('BrowserPageRoute uses customTransition from appRoute', (
      tester,
    ) async {
      var customBuilderCalled = false;
      final appRoute = BrowserRoute(
        path: '/custom-app',
        page: const Text('Custom Page', textDirection: TextDirection.ltr),
        customTransition: CustomBuildTransition(
          ({
            required animation,
            required secondaryAnimation,
            required child,
          }) {
            customBuilderCalled = true;
            return Padding(
              padding: const EdgeInsets.all(8),
              child: child,
            );
          },
        ),
      );
      const traceRoute = PageTraceRoute();
      final pageRoute = BrowserPageRoute<void>(
        appRoute: appRoute,
        traceRoute: traceRoute,
      );

      await tester.pumpWidget(
        Directionality(
          textDirection: TextDirection.ltr,
          child: MediaQuery(
            data: const MediaQueryData(),
            child: Builder(
              builder: (context) {
                return pageRoute.buildTransitions(
                  context,
                  kAlwaysCompleteAnimation,
                  kAlwaysDismissedAnimation,
                  const Text('Custom App Child', textDirection: TextDirection.ltr),
                );
              },
            ),
          ),
        ),
      );

      expect(customBuilderCalled, isTrue);
      expect(find.text('Custom App Child'), findsOneWidget);
      expect(find.byType(Padding), findsOneWidget);
    });

    testWidgets('BrowserPageRoute gives precedence to TraceRoute customTransition', (
      tester,
    ) async {
      var appRouteBuilderCalled = false;
      var traceRouteBuilderCalled = false;

      final appRoute = BrowserRoute(
        path: '/precedence',
        page: const Text('Page', textDirection: TextDirection.ltr),
        customTransition: CustomBuildTransition(
          ({
            required animation,
            required secondaryAnimation,
            required child,
          }) {
            appRouteBuilderCalled = true;
            return child;
          },
        ),
      );
      final traceRoute = PageTraceRoute(
        customTransition: CustomBuildTransition(
          ({
            required animation,
            required secondaryAnimation,
            required child,
          }) {
            traceRouteBuilderCalled = true;
            return DecoratedBox(
              decoration: const BoxDecoration(),
              child: child,
            );
          },
        ),
      );
      final pageRoute = BrowserPageRoute<void>(
        appRoute: appRoute,
        traceRoute: traceRoute,
      );

      await tester.pumpWidget(
        Directionality(
          textDirection: TextDirection.ltr,
          child: MediaQuery(
            data: const MediaQueryData(),
            child: Builder(
              builder: (context) {
                return pageRoute.buildTransitions(
                  context,
                  kAlwaysCompleteAnimation,
                  kAlwaysDismissedAnimation,
                  const Text('Precedence Child', textDirection: TextDirection.ltr),
                );
              },
            ),
          ),
        ),
      );

      expect(traceRouteBuilderCalled, isTrue);
      expect(appRouteBuilderCalled, isFalse);
      expect(find.byType(DecoratedBox), findsOneWidget);
    });

    test('TraceRoute subclasses accept customTransition parameter', () {
      final customBuilder = CustomBuildTransition(
        ({
          required animation,
          required secondaryAnimation,
          required child,
        }) =>
            child,
      );

      final page = PageTraceRoute(customTransition: customBuilder);
      expect(page.customTransition, equals(customBuilder));

      final popup = PopupTraceRoute(customTransition: customBuilder);
      expect(popup.customTransition, equals(customBuilder));

      final swipe = SwipeTraceRoute(customTransition: customBuilder);
      expect(swipe.customTransition, equals(customBuilder));

      final overlay = OverlayTraceRoute(customTransition: customBuilder);
      expect(overlay.customTransition, equals(customBuilder));

      final factoryPage = TraceRoute.page(customTransition: customBuilder);
      expect(factoryPage.customTransition, equals(customBuilder));

      final factoryPopup = TraceRoute.popup(customTransition: customBuilder);
      expect(factoryPopup.customTransition, equals(customBuilder));

      final factorySwipe = TraceRoute.swipe(customTransition: customBuilder);
      expect(factorySwipe.customTransition, equals(customBuilder));
    });

    test('BrowserRoute copyWith preserves or updates customTransition', () {
      final custom1 = CustomBuildTransition(
        ({
          required animation,
          required secondaryAnimation,
          required child,
        }) =>
            child,
      );
      final custom2 = CustomBuildTransition(
        ({
          required animation,
          required secondaryAnimation,
          required child,
        }) =>
            child,
      );

      final route1 = BrowserRoute(
        path: '/r1',
        page: const SizedBox(),
        customTransition: custom1,
      );
      expect(route1.customTransition, equals(custom1));

      final route2 = route1.copyWith(customTransition: custom2);
      expect(route2.customTransition, equals(custom2));

      final route3 = route1.copyWith(path: '/r3');
      expect(route3.customTransition, equals(custom1));
      expect(route3.path, equals('/r3'));
    });
  });
}
