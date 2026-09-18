import 'package:browser_router/browser.dart';
import 'package:browser_router/gestures/back_gesture/cupertino_back_gesture_detector.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter/widgets.dart';
import 'package:flutter_test/flutter_test.dart';

class _MockNavigatorObserver extends NavigatorObserver {
  int startUserGestureCount = 0;
  int stopUserGestureCount = 0;

  @override
  void didStartUserGesture(
    Route<dynamic> route,
    Route<dynamic>? previousRoute,
  ) {
    startUserGestureCount++;
  }

  @override
  void didStopUserGesture() {
    stopUserGestureCount++;
  }
}

class _TestPageRoute<T> extends PageRoute<T> {
  _TestPageRoute({
    required this.builder,
    this.backGestureWidth,
    this.closePercentage = 0.35,
    this.enabled = true,
  });

  final WidgetBuilder builder;
  final double? backGestureWidth;
  final double closePercentage;
  final bool enabled;

  @override
  Color? get barrierColor => null;
  @override
  String? get barrierLabel => null;
  @override
  bool get maintainState => true;
  @override
  Duration get transitionDuration => const Duration(milliseconds: 300);

  @override
  Widget buildPage(
    BuildContext context,
    Animation<double> animation,
    Animation<double> secondaryAnimation,
  ) {
    return builder(context);
  }

  @override
  Widget buildTransitions(
    BuildContext context,
    Animation<double> animation,
    Animation<double> secondaryAnimation,
    Widget child,
  ) {
    return CupertinoBackGestureDetector(
      navigator: navigator!,
      controller: controller!,
      backGestureWidth: backGestureWidth,
      closePercentage: closePercentage,
      enabled: enabled,
      child: child,
    );
  }
}

void main() {
  group('CupertinoBackGestureDetector Tests', () {
    testWidgets(
        'Full-screen swipe gesture starts drag and pops route when threshold is met',
        (tester) async {
      final observer = _MockNavigatorObserver();

      await tester.pumpWidget(
        WidgetsApp(
          color: const Color(0xFFFFFFFF),
          navigatorObservers: [observer],
          onGenerateRoute: (settings) {
            if (settings.name == '/second') {
              return _TestPageRoute<void>(
                backGestureWidth: null, // Full screen
                builder: (context) => const Text('Second Page'),
              );
            }
            return _TestPageRoute<void>(
              builder: (context) => const Text('First Page'),
            );
          },
        ),
      );

      expect(find.text('First Page'), findsOneWidget);

      // Push second page
      tester.state<NavigatorState>(find.byType(Navigator)).pushNamed('/second');
      await tester.pumpAndSettle();

      expect(find.text('Second Page'), findsOneWidget);

      // Start dragging from center of screen (dx = 400 on 800-wide screen)
      final gesture = await tester.startGesture(const Offset(400, 300));
      await tester.pump();

      expect(observer.startUserGestureCount, equals(1));

      // Drag 300px to the right (past 35% threshold)
      await gesture.moveBy(const Offset(300, 0));
      await tester.pump();

      // Release gesture
      await gesture.up();
      await tester.pumpAndSettle();

      expect(observer.stopUserGestureCount, equals(1));
      expect(find.text('Second Page'), findsNothing);
      expect(find.text('First Page'), findsOneWidget);
    });

    testWidgets('Edge-only swipe ignores drag starting beyond backGestureWidth',
        (tester) async {
      final observer = _MockNavigatorObserver();

      await tester.pumpWidget(
        WidgetsApp(
          color: const Color(0xFFFFFFFF),
          navigatorObservers: [observer],
          onGenerateRoute: (settings) {
            if (settings.name == '/second') {
              return _TestPageRoute<void>(
                backGestureWidth: 20, // Only 20px from edge
                builder: (context) => const Text('Second Page'),
              );
            }
            return _TestPageRoute<void>(
              builder: (context) => const Text('First Page'),
            );
          },
        ),
      );

      tester.state<NavigatorState>(find.byType(Navigator)).pushNamed('/second');
      await tester.pumpAndSettle();

      expect(find.text('Second Page'), findsOneWidget);

      // Drag starting at dx = 100 (outside 20px edge)
      final gesture = await tester.startGesture(const Offset(100, 300));
      await gesture.moveBy(const Offset(400, 0));
      await tester.pump();
      await gesture.up();
      await tester.pumpAndSettle();

      // Should NOT have started a user gesture
      expect(observer.startUserGestureCount, equals(0));
      expect(find.text('Second Page'), findsOneWidget);

      // Now drag starting at dx = 10 (inside 20px edge)
      final edgeGesture = await tester.startGesture(const Offset(10, 300));
      await tester.pump();

      expect(observer.startUserGestureCount, equals(1));

      await edgeGesture.moveBy(const Offset(400, 0));
      await tester.pump();
      await edgeGesture.up();
      await tester.pumpAndSettle();

      expect(observer.stopUserGestureCount, equals(1));
      expect(find.text('Second Page'), findsNothing);
      expect(find.text('First Page'), findsOneWidget);
    });

    testWidgets('Drag canceled snaps back to 1.0 without popping',
        (tester) async {
      final observer = _MockNavigatorObserver();

      await tester.pumpWidget(
        WidgetsApp(
          color: const Color(0xFFFFFFFF),
          navigatorObservers: [observer],
          onGenerateRoute: (settings) {
            if (settings.name == '/second') {
              return _TestPageRoute<void>(
                backGestureWidth: null,
                closePercentage: 0.5,
                builder: (context) => const Text('Second Page'),
              );
            }
            return _TestPageRoute<void>(
              builder: (context) => const Text('First Page'),
            );
          },
        ),
      );

      tester.state<NavigatorState>(find.byType(Navigator)).pushNamed('/second');
      await tester.pumpAndSettle();

      // Drag small distance (only 20px, not meeting 50% closePercentage)
      final gesture = await tester.startGesture(const Offset(200, 300));
      await gesture.moveBy(const Offset(20, 0));
      await tester.pump();

      expect(observer.startUserGestureCount, equals(1));

      await gesture.up();
      await tester.pumpAndSettle();

      expect(observer.stopUserGestureCount, equals(1));
      // Second page should still be on screen
      expect(find.text('Second Page'), findsOneWidget);
    });

    testWidgets('CupertinoBackGestureDetector disabled returns child untouched',
        (tester) async {
      await tester.pumpWidget(
        WidgetsApp(
          color: const Color(0xFFFFFFFF),
          onGenerateRoute: (settings) => _TestPageRoute<void>(
            enabled: false,
            builder: (context) => const Text('Disabled Test'),
          ),
        ),
      );

      expect(find.text('Disabled Test'), findsOneWidget);
    });
  });

  group('BrowserPageRoute with CupertinoBackGestureDetector', () {
    testWidgets('Integrates with Browser navigation system', (tester) async {
      debugDefaultTargetPlatformOverride = TargetPlatform.iOS;

      final routes = [
        const BrowserRoute(
          path: '/home',
          page: Text('Home View'),
        ),
        const BrowserRoute(
          path: '/detail',
          page: Text('Detail View'),
          routeTransition: RouteTransition.slide_right,
        ),
      ];

      await tester.pumpWidget(
        Browser(
          routes: routes,
          defaultRoute: routes.first,
          builder: (context, routeObserver, generate) {
            return WidgetsApp(
              color: const Color(0xFFFFFFFF),
              navigatorObservers: [routeObserver],
              onGenerateRoute: generate,
              initialRoute: '/home',
            );
          },
        ),
      );

      expect(find.text('Home View'), findsOneWidget);

      tester.state<NavigatorState>(find.byType(Navigator)).pushNamed(
        '/detail',
        arguments: <dynamic, dynamic>{
          TraceRoute: TraceRoute.page(
            routeTransition: RouteTransition.slide_right,
            backGestureWidth: 50,
          ),
        },
      );
      await tester.pumpAndSettle();

      expect(find.text('Detail View'), findsOneWidget);

      // Perform back swipe within 50px
      final gesture = await tester.startGesture(const Offset(25, 300));
      await gesture.moveBy(const Offset(400, 0));
      await tester.pump();
      await gesture.up();
      await tester.pumpAndSettle();

      expect(find.text('Detail View'), findsNothing);
      expect(find.text('Home View'), findsOneWidget);

      debugDefaultTargetPlatformOverride = null;
    });
  });
}
