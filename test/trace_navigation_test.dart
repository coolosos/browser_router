import 'dart:async';

import 'package:browser_router/browser.dart';
import 'package:flutter/widgets.dart';
import 'package:flutter_test/flutter_test.dart';

final class TraceSampleArgs extends RouteParams {
  const new(this.message);
  final String message;
}

Widget createTraceApp() {
  const routes = [
    BrowserRoute(
      path: '/home',
      page: Text('Home Screen', textDirection: TextDirection.ltr),
    ),
    BrowserRoute(
      path: '/screen1',
      page: Text('Screen 1', textDirection: TextDirection.ltr),
    ),
    BrowserRoute(
      path: '/screen2',
      page: Text('Screen 2', textDirection: TextDirection.ltr),
    ),
    BrowserRoute(
      path: '/target',
      page: Text('Target Screen', textDirection: TextDirection.ltr),
    ),
  ];

  return Browser(
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
  );
}

void main() {
  group('Trace & TraceRoute Tests', () {
    testWidgets('Trace.push navigates with arguments and traceRoute', (
      tester,
    ) async {
      await tester.pumpWidget(createTraceApp());
      await tester.pumpAndSettle();

      final homeContext = tester.element(find.text('Home Screen'));
      const trace = Trace(
        path: '/target',
        args: TraceSampleArgs('trace_arg'),
        traceRoute: PageTraceRoute(),
      );

      unawaited(trace.push(homeContext));
      await tester.pumpAndSettle();

      expect(find.text('Target Screen'), findsOneWidget);
      final targetContext = tester.element(find.text('Target Screen'));
      expect(
        targetContext.getArgument<TraceSampleArgs>()?.message,
        equals('trace_arg'),
      );
    });

    testWidgets('Trace.pushAndReplacement replaces current screen', (
      tester,
    ) async {
      await tester.pumpWidget(createTraceApp());
      await tester.pumpAndSettle();

      final homeContext = tester.element(find.text('Home Screen'));
      const trace1 = Trace(path: '/screen1');
      unawaited(trace1.push(homeContext));
      await tester.pumpAndSettle();
      expect(find.text('Screen 1'), findsOneWidget);

      final screen1Context = tester.element(find.text('Screen 1'));
      const trace2 = Trace(path: '/screen2');
      unawaited(trace2.pushAndReplacement(screen1Context));
      await tester.pumpAndSettle();

      expect(find.text('Screen 2'), findsOneWidget);
      expect(find.text('Screen 1'), findsNothing);
    });

    testWidgets('Trace.popToFirstAndPush pops to first and pushes target', (
      tester,
    ) async {
      await tester.pumpWidget(createTraceApp());
      await tester.pumpAndSettle();

      final homeContext = tester.element(find.text('Home Screen'));
      unawaited(const Trace(path: '/screen1').push(homeContext));
      await tester.pumpAndSettle();

      final screen1Context = tester.element(find.text('Screen 1'));
      unawaited(const Trace(path: '/screen2').push(screen1Context));
      await tester.pumpAndSettle();

      final screen2Context = tester.element(find.text('Screen 2'));
      unawaited(const Trace(path: '/target').popToFirstAndPush(screen2Context));
      await tester.pumpAndSettle();

      expect(find.text('Target Screen'), findsOneWidget);
      expect(find.text('Screen 1'), findsNothing);
      expect(find.text('Screen 2'), findsNothing);
    });

    testWidgets('Trace.cleanAndPush pops to first and replaces first route', (
      tester,
    ) async {
      await tester.pumpWidget(createTraceApp());
      await tester.pumpAndSettle();

      final homeContext = tester.element(find.text('Home Screen'));
      unawaited(const Trace(path: '/screen1').push(homeContext));
      await tester.pumpAndSettle();

      final screen1Context = tester.element(find.text('Screen 1'));
      unawaited(const Trace(path: '/target').cleanAndPush(screen1Context));
      await tester.pumpAndSettle();

      expect(find.text('Target Screen'), findsOneWidget);
      expect(find.text('Screen 1'), findsNothing);
      expect(find.text('Home Screen'), findsNothing);
    });

    testWidgets('Trace.findMeOrPush finds existing route in stack or pushes', (
      tester,
    ) async {
      await tester.pumpWidget(createTraceApp());
      await tester.pumpAndSettle();

      final homeContext = tester.element(find.text('Home Screen'));
      unawaited(const Trace(path: '/screen1').push(homeContext));
      await tester.pumpAndSettle();

      final screen1Context = tester.element(find.text('Screen 1'));
      unawaited(const Trace(path: '/screen2').push(screen1Context));
      await tester.pumpAndSettle();

      // Existing route in stack: pops back to /screen1
      final screen2Context = tester.element(find.text('Screen 2'));
      unawaited(const Trace(path: '/screen1').findMeOrPush(screen2Context));
      await tester.pumpAndSettle();

      expect(find.text('Screen 1'), findsOneWidget);
      expect(find.text('Screen 2'), findsNothing);
    });

    test('TraceRoute factory constructors instantiate subclasses with all properties', () {
      // 1. TraceRoute.page
      final pageTrace = TraceRoute.page(
        routeTransition: RouteTransition.fade,
        opaque: true,
        maintainState: true,
        allowSnapshotting: true,
        barrierColor: const Color(0xFF000000),
        barrierDismissible: true,
        barrierLabel: 'PageBarrier',
        semanticsLabel: 'PageSemantics',
        fullscreenDialog: true,
        popGestureEnabled: true,
      ) as PageTraceRoute;
      expect(pageTrace, isA<PageTraceRoute>());
      expect(pageTrace.routeTransition, equals(RouteTransition.fade));
      expect(pageTrace.fullScreenDialog, isTrue);
      expect(pageTrace.popGestureEnabled, isTrue);

      // 2. TraceRoute.popup
      final popupTrace = TraceRoute.popup(
        routeTransition: RouteTransition.fade,
        opaque: false,
        barrierDismissible: true,
        barrierLabel: 'PopupBarrier',
        semanticsLabel: 'PopupSemantics',
      ) as PopupTraceRoute;
      expect(popupTrace, isA<PopupTraceRoute>());
      expect(popupTrace.routeTransition, equals(RouteTransition.fade));
      expect(popupTrace.barrierDismissible, isTrue);

      // 3. TraceRoute.swipe
      final swipeTrace = TraceRoute.swipe(
        routeTransition: RouteTransition.none,
        useSafeArea: true,
        animationDirection: AxisDirection.down,
        enableDrag: false,
        screenMaximumPercentage: 0.75,
        anchorPoint: const Offset(10, 20),
      ) as SwipeTraceRoute;
      expect(swipeTrace, isA<SwipeTraceRoute>());
      expect(swipeTrace.useSafeArea, isTrue);
      expect(swipeTrace.animationDirection, equals(AxisDirection.down));
      expect(swipeTrace.enableDrag, isFalse);
      expect(swipeTrace.screenMaximumPercentage, equals(0.75));
      expect(swipeTrace.anchorPoint, equals(const Offset(10, 20)));

      // 4. OverlayTraceRoute
      const overlayTrace = OverlayTraceRoute(
        routeTransition: RouteTransition.fade,
      );
      expect(overlayTrace.routeTransition, equals(RouteTransition.fade));
    });
  });
}
