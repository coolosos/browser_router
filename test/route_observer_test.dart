import 'dart:async';

import 'package:browser_router/browser.dart';
import 'package:flutter/widgets.dart';
import 'package:flutter_test/flutter_test.dart';

final class TestArgs extends RouteParams {
  const new(this.value);
  final String value;
}

void main() {
  group('RouteObserverProvider and Browser.watch Tests', () {
    testWidgets('triggers onAppear and onDisappear on push and pop',
        (tester) async {
      var homeAppearCount = 0;
      var homeDisappearCount = 0;
      var detailAppearCount = 0;
      late BuildContext savedHomeContext;

      final routes = [
        BrowserRoute(
          path: '/',
          page: Browser.watch(
            onAppear: (context, deepLink) {
              homeAppearCount++;
            },
            onDisappear: (context) {
              homeDisappearCount++;
            },
            child: Builder(
              builder: (context) {
                savedHomeContext = context;
                return const Text(
                  'Home Screen',
                  textDirection: TextDirection.ltr,
                );
              },
            ),
          ),
        ),
        BrowserRoute(
          path: '/detail',
          page: Browser.watch(
            onAppear: (context, deepLink) {
              detailAppearCount++;
            },
            child: const Text(
              'Detail Screen',
              textDirection: TextDirection.ltr,
            ),
          ),
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
              initialRoute: '/',
            );
          },
        ),
      );

      await tester.pumpAndSettle();
      expect(find.text('Home Screen'), findsOneWidget);
      expect(homeAppearCount, 1);
      expect(homeDisappearCount, 0);

      // Navigate to /detail
      unawaited(savedHomeContext.pushNamed('/detail'));
      await tester.pumpAndSettle();

      expect(find.text('Detail Screen'), findsOneWidget);
      expect(detailAppearCount, 1);
      expect(homeDisappearCount, 1);

      // Pop /detail back to /home
      savedHomeContext.navigate.pop();
      await tester.pumpAndSettle();

      expect(find.text('Home Screen'), findsOneWidget);
      expect(homeAppearCount, 2);
    });

    testWidgets('Trace navigation helper methods push and pop properly',
        (tester) async {
      late BuildContext savedContext;
      TestArgs? receivedArgs;

      final routes = [
        BrowserRoute(
          path: '/start',
          page: Builder(
            builder: (context) {
              savedContext = context;
              return const Text('Start', textDirection: TextDirection.ltr);
            },
          ),
        ),
        BrowserRoute(
          path: '/step1',
          page: Builder(
            builder: (context) {
              receivedArgs = context.getArgument<TestArgs>();
              return const Text('Step 1', textDirection: TextDirection.ltr);
            },
          ),
        ),
        const BrowserRoute(
          path: '/step2',
          page: Text('Step 2', textDirection: TextDirection.ltr),
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
              initialRoute: '/start',
            );
          },
        ),
      );

      await tester.pumpAndSettle();
      expect(find.text('Start'), findsOneWidget);

      // Trace.push
      const trace1 = Trace<PageTraceRoute>(
        path: '/step1',
        args: TestArgs('arg1'),
      );
      unawaited(trace1.push(savedContext));
      await tester.pumpAndSettle();
      expect(find.text('Step 1'), findsOneWidget);
      expect(receivedArgs?.value, 'arg1');

      // Trace.pushAndReplacement
      const trace2 = Trace<PageTraceRoute>(
        path: '/step2',
      );
      unawaited(trace2.pushAndReplacement(savedContext));
      await tester.pumpAndSettle();
      expect(find.text('Step 2'), findsOneWidget);
    });
  });
}
