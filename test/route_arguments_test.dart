import 'dart:async';

import 'package:browser_router/browser.dart';
import 'package:flutter/widgets.dart';
import 'package:flutter_test/flutter_test.dart';

// Class hierarchy for polymorphic testing
abstract base class BaseUserArgs extends RouteParams {
  const new({required this.id});
  final String id;
}

final class AdminUserArgs extends BaseUserArgs {
  const new({required super.id, required this.role});
  final String role;
}

final class SessionArgs extends RouteParams {
  const new(this.token);
  final String token;
}

void main() {
  group('Route Arguments & Polymorphism Tests', () {
    testWidgets('Exact type and polymorphic base class argument retrieval',
        (tester) async {
      BaseUserArgs? retrievedAsBase;
      AdminUserArgs? retrievedAsExact;
      SessionArgs? retrievedSession;
      late BuildContext savedContext;

      final routes = [
        BrowserRoute(
          path: '/home',
          page: Builder(
            builder: (context) {
              savedContext = context;
              return const Text(
                'Home',
                textDirection: TextDirection.ltr,
              );
            },
          ),
        ),
        BrowserRoute(
          path: '/detail',
          page: Builder(
            builder: (context) {
              retrievedAsBase = context.getArgument<BaseUserArgs>();
              retrievedAsExact = context.getArgument<AdminUserArgs>();
              retrievedSession = context.getArgument<SessionArgs>();
              return Text(
                'Detail: ${retrievedAsExact?.role}',
                textDirection: TextDirection.ltr,
              );
            },
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
              initialRoute: '/home',
            );
          },
        ),
      );

      await tester.pumpAndSettle();
      expect(find.text('Home'), findsOneWidget);

      // Navigate passing AdminUserArgs (subclass) and SessionArgs
      unawaited(
        savedContext.pushNamed(
          '/detail',
          args: [
            const AdminUserArgs(id: 'admin_1', role: 'superadmin'),
            const SessionArgs('tok_xyz123'),
          ],
        ),
      );
      await tester.pumpAndSettle();

      expect(find.text('Detail: superadmin'), findsOneWidget);

      // Verify exact type retrieval
      expect(retrievedAsExact, isNotNull);
      expect(retrievedAsExact?.id, 'admin_1');
      expect(retrievedAsExact?.role, 'superadmin');

      // Verify polymorphic base class retrieval
      expect(retrievedAsBase, isNotNull);
      expect(retrievedAsBase?.id, 'admin_1');
      expect(retrievedAsBase, isA<AdminUserArgs>());

      // Verify second distinct argument type
      expect(retrievedSession, isNotNull);
      expect(retrievedSession?.token, 'tok_xyz123');
    });

    testWidgets('getArgumentAndClean consumes argument on read',
        (tester) async {
      SessionArgs? firstRead;
      SessionArgs? secondRead;
      late BuildContext savedContext;

      final routes = [
        BrowserRoute(
          path: '/home',
          page: Builder(
            builder: (context) {
              savedContext = context;
              return const Text('Home', textDirection: TextDirection.ltr);
            },
          ),
        ),
        BrowserRoute(
          path: '/detail',
          page: Builder(
            builder: (context) {
              firstRead = context.getArgumentAndClean<SessionArgs>();
              secondRead = context.getArgument<SessionArgs>();
              return const Text('Detail', textDirection: TextDirection.ltr);
            },
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
              initialRoute: '/home',
            );
          },
        ),
      );

      await tester.pumpAndSettle();

      unawaited(
        savedContext.pushNamed(
          '/detail',
          args: [const SessionArgs('one_time_token')],
        ),
      );
      await tester.pumpAndSettle();

      expect(firstRead, isNotNull);
      expect(firstRead?.token, 'one_time_token');
      expect(secondRead, isNull);
    });

    testWidgets(
        'getArgumentAndClean works polymorphically with base class',
        (tester) async {
      BaseUserArgs? firstReadBase;
      AdminUserArgs? secondReadExact;
      late BuildContext savedContext;

      final routes = [
        BrowserRoute(
          path: '/home',
          page: Builder(
            builder: (context) {
              savedContext = context;
              return const Text('Home', textDirection: TextDirection.ltr);
            },
          ),
        ),
        BrowserRoute(
          path: '/detail',
          page: Builder(
            builder: (context) {
              firstReadBase = context.getArgumentAndClean<BaseUserArgs>();
              secondReadExact = context.getArgument<AdminUserArgs>();
              return const Text('Detail', textDirection: TextDirection.ltr);
            },
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
              initialRoute: '/home',
            );
          },
        ),
      );

      await tester.pumpAndSettle();

      unawaited(
        savedContext.pushNamed(
          '/detail',
          args: [const AdminUserArgs(id: 'adm_99', role: 'root')],
        ),
      );
      await tester.pumpAndSettle();

      expect(firstReadBase, isNotNull);
      expect(firstReadBase?.id, 'adm_99');
      expect(firstReadBase, isA<AdminUserArgs>());
      // After getAndClean on the base type, it should be removed
      expect(secondReadExact, isNull);
    });

    testWidgets('Missing argument returns null without throwing',
        (tester) async {
      SessionArgs? retrieved;

      final routes = [
        BrowserRoute(
          path: '/home',
          page: Builder(
            builder: (context) {
              retrieved = context.getArgument<SessionArgs>();
              return const Text('Home', textDirection: TextDirection.ltr);
            },
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
              initialRoute: '/home',
            );
          },
        ),
      );

      await tester.pumpAndSettle();
      expect(retrieved, isNull);
    });

    testWidgets('DeepLinkParam is retrieved correctly from URL query parameters',
        (tester) async {
      DeepLinkParam? deepLink;

      final routes = [
        BrowserRoute(
          path: '/home',
          page: Builder(
            builder: (context) {
              deepLink = context.getArgument<DeepLinkParam>();
              return Text(
                'DeepLink: ${deepLink?.params['code']}',
                textDirection: TextDirection.ltr,
              );
            },
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
              initialRoute: '/home?code=12345&source=email',
            );
          },
        ),
      );

      await tester.pumpAndSettle();
      expect(find.text('DeepLink: 12345'), findsOneWidget);
      expect(deepLink, isNotNull);
      expect(deepLink?.params['code'], '12345');
      expect(deepLink?.params['source'], 'email');
    });

    test(
        'generate handles unmodifiable map with TraceRoute without throwing UnsupportedError',
        () {
      final routes = [
        const BrowserRoute(
          path: '/home',
          page: SizedBox(),
        ),
        const BrowserRoute(
          path: '/detail',
          page: SizedBox(),
        ),
      ];

      final browser = Browser(
        routes: routes,
        defaultRoute: routes.first,
        builder: (context, routeObserver, generate) => const SizedBox(),
      );

      final unmodifiableArgs = Map<dynamic, dynamic>.unmodifiable({
        PageTraceRoute: TraceRoute.page(),
        AdminUserArgs: const AdminUserArgs(id: 'adm_1', role: 'admin'),
      });

      expect(
        () => browser.generate(
          RouteSettings(
            name: '/detail',
            arguments: unmodifiableArgs,
          ),
        ),
        returnsNormally,
      );

      final route = browser.generate(
        RouteSettings(
          name: '/detail',
          arguments: unmodifiableArgs,
        ),
      );

      expect(route, isA<PageRoute<dynamic>>());
      final generatedArgs = route.settings.arguments as Map?;
      expect(generatedArgs?[AdminUserArgs], isA<AdminUserArgs>());
      expect(generatedArgs?.containsKey(PageTraceRoute), isFalse);
    });

    test(
        'generate handles const map without throwing and cleans TraceRoute keys/values',
        () {
      final routes = [
        const BrowserRoute(
          path: '/home',
          page: SizedBox(),
        ),
        const BrowserRoute(
          path: '/modal',
          page: SizedBox(),
        ),
      ];

      final browser = Browser(
        routes: routes,
        defaultRoute: routes.first,
        builder: (context, routeObserver, generate) => const SizedBox(),
      );

      const constArgs = <dynamic, dynamic>{
        AdminUserArgs: AdminUserArgs(id: 'adm_const', role: 'viewer'),
      };

      final route = browser.generate(
        const RouteSettings(
          name: '/modal',
          arguments: constArgs,
        ),
      );

      expect(route, isA<PageRoute<dynamic>>());
      final generatedArgs = route.settings.arguments as Map?;
      expect(generatedArgs?[AdminUserArgs], isA<AdminUserArgs>());
      expect((generatedArgs?[AdminUserArgs] as AdminUserArgs?)?.id, 'adm_const');
    });

    test(
        'generate handles unmodifiable map with polymorphic TraceRoute and selects PopupRoute',
        () {
      final routes = [
        const BrowserRoute(
          path: '/home',
          page: SizedBox(),
        ),
        const BrowserRoute(
          path: '/modal',
          page: SizedBox(),
        ),
      ];

      final browser = Browser(
        routes: routes,
        defaultRoute: routes.first,
        builder: (context, routeObserver, generate) => const SizedBox(),
      );

      final unmodifiableArgs = Map<dynamic, dynamic>.unmodifiable({
        SwipeTraceRoute: TraceRoute.swipe(),
      });

      final route = browser.generate(
        RouteSettings(
          name: '/modal',
          arguments: unmodifiableArgs,
        ),
      );

      expect(route, isA<PopupRoute<dynamic>>());
      final generatedArgs = route.settings.arguments as Map?;
      expect(generatedArgs?.containsKey(SwipeTraceRoute), isFalse);
    });

    testWidgets(
        'Navigation with unmodifiable arguments Map retrieves arguments and does not throw',
        (tester) async {
      AdminUserArgs? retrievedAdmin;
      late BuildContext savedContext;

      final routes = [
        BrowserRoute(
          path: '/home',
          page: Builder(
            builder: (context) {
              savedContext = context;
              return const Text('Home', textDirection: TextDirection.ltr);
            },
          ),
        ),
        BrowserRoute(
          path: '/detail',
          page: Builder(
            builder: (context) {
              retrievedAdmin = context.getArgument<AdminUserArgs>();
              return Text(
                'Detail: ${retrievedAdmin?.role}',
                textDirection: TextDirection.ltr,
              );
            },
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
              initialRoute: '/home',
            );
          },
        ),
      );

      await tester.pumpAndSettle();
      expect(find.text('Home'), findsOneWidget);

      final unmodifiableArgs = Map<dynamic, dynamic>.unmodifiable({
        PageTraceRoute: TraceRoute.page(),
        AdminUserArgs: const AdminUserArgs(id: 'adm_unmodifiable', role: 'editor'),
      });

      savedContext.navigate.pushNamed(
        '/detail',
        arguments: unmodifiableArgs,
      );
      await tester.pumpAndSettle();

      expect(find.text('Detail: editor'), findsOneWidget);
      expect(retrievedAdmin, isNotNull);
      expect(retrievedAdmin?.id, 'adm_unmodifiable');
      expect(retrievedAdmin?.role, 'editor');
    });

    testWidgets(
        'getArgumentAndClean on missing polymorphic argument in unmodifiable map does not throw',
        (tester) async {
      final routes = [
        const BrowserRoute(
          path: '/home',
          page: SizedBox(),
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

      await tester.pumpAndSettle();

      final unmodifiableArgs = Map<dynamic, dynamic>.unmodifiable({
        const AdminUserArgs(id: 'adm_1', role: 'admin').runtimeType:
            const AdminUserArgs(id: 'adm_1', role: 'admin'),
      });

      final settings = RouteSettings(name: '/home', arguments: unmodifiableArgs);
      final element = tester.element(find.byType(SizedBox));

      expect(
        () => element.getArgumentAndClean<SessionArgs>(settings: settings),
        returnsNormally,
      );
      expect(
        element.getArgumentAndClean<SessionArgs>(settings: settings),
        isNull,
      );
    });
  });
}
