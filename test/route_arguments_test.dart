import 'dart:async';

import 'package:browser_router/browser.dart';
import 'package:flutter/widgets.dart';
import 'package:flutter_test/flutter_test.dart';

// Class hierarchy for polymorphic testing
abstract base class BaseUserArgs extends RouteParams {
  const BaseUserArgs({required this.id});
  final String id;
}

final class AdminUserArgs extends BaseUserArgs {
  const AdminUserArgs({required super.id, required this.role});
  final String role;
}

final class SessionArgs extends RouteParams {
  const SessionArgs(this.token);
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
  });
}
