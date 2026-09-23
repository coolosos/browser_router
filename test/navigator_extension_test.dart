import 'dart:async';

import 'package:browser_router/browser.dart';
import 'package:flutter/widgets.dart';
import 'package:flutter_test/flutter_test.dart';

final class TestUserArgs extends RouteParams {
  const new(this.id);
  final String id;
}

final class TestResultArgs extends RouteParams {
  const new(this.value);
  final String value;
}

Widget createNavigationApp({
  List<BrowserRoute>? routes,
  BrowserRoute? defaultRoute,
  Future<void> Function(Uri)? openUrl,
}) {
  final effectiveRoutes = routes ??
      [
        const BrowserRoute(
          path: '/home',
          page: Text('Home Screen', textDirection: TextDirection.ltr),
        ),
        const BrowserRoute(
          path: '/detail',
          page: Text('Detail Screen', textDirection: TextDirection.ltr),
        ),
        const BrowserRoute(
          path: '/step1',
          page: Text('Step 1 Screen', textDirection: TextDirection.ltr),
        ),
        const BrowserRoute(
          path: '/step2',
          page: Text('Step 2 Screen', textDirection: TextDirection.ltr),
        ),
        const BrowserRoute(
          path: '/target',
          page: Text('Target Screen', textDirection: TextDirection.ltr),
        ),
      ];

  return Browser(
    routes: effectiveRoutes,
    defaultRoute: defaultRoute ?? effectiveRoutes.first,
    openUrl: openUrl,
    builder: (context, routeObserver, generate) => WidgetsApp(
      color: const Color(0xFFFFFFFF),
      navigatorObservers: [routeObserver],
      onGenerateRoute: generate,
      onGenerateInitialRoutes: (initialRoute) => [
        generate(
          RouteSettings(
            name: initialRoute,
            arguments: const <dynamic, dynamic>{},
          ),
        ),
      ],
    ),
  );
}

void main() {
  group('NavigatorX Extension Tests', () {
    testWidgets('pushNamed navigates and delivers strongly-typed arguments', (
      tester,
    ) async {
      await tester.pumpWidget(createNavigationApp());
      await tester.pumpAndSettle();

      final context = tester.element(find.text('Home Screen'));
      unawaited(
        context.pushNamed(
          '/detail',
          args: [const TestUserArgs('user_42')],
        ),
      );

      await tester.pumpAndSettle();
      expect(find.text('Detail Screen'), findsOneWidget);

      final detailContext = tester.element(find.text('Detail Screen'));
      final args = detailContext.getArgument<TestUserArgs>();
      expect(args?.id, equals('user_42'));
    });

    testWidgets('pushReplacementNamed replaces the current route on stack', (
      tester,
    ) async {
      await tester.pumpWidget(createNavigationApp());
      await tester.pumpAndSettle();

      final context = tester.element(find.text('Home Screen'));
      unawaited(context.pushNamed('/step1'));
      await tester.pumpAndSettle();
      expect(find.text('Step 1 Screen'), findsOneWidget);

      final step1Context = tester.element(find.text('Step 1 Screen'));
      unawaited(
        step1Context.pushReplacementNamed(
          '/step2',
          args: [const TestUserArgs('step2_arg')],
        ),
      );
      await tester.pumpAndSettle();

      expect(find.text('Step 2 Screen'), findsOneWidget);
      expect(find.text('Step 1 Screen'), findsNothing);

      final step2Context = tester.element(find.text('Step 2 Screen'));
      expect(step2Context.getArgument<TestUserArgs>()?.id, equals('step2_arg'));
    });

    testWidgets('setPushArgument stages arguments for subsequent push', (
      tester,
    ) async {
      await tester.pumpWidget(createNavigationApp());
      await tester.pumpAndSettle();

      final homeContext = tester.element(find.text('Home Screen'))
        ..setPushArgument(const TestUserArgs('staged_push'));
      unawaited(homeContext.pushNamed('/target'));
      await tester.pumpAndSettle();

      expect(find.text('Target Screen'), findsOneWidget);
      final targetContext = tester.element(find.text('Target Screen'));
      expect(targetContext.getArgument<TestUserArgs>()?.id, equals('staged_push'));
    });

    testWidgets('pop sends return arguments and updates previous route settings', (
      tester,
    ) async {
      await tester.pumpWidget(createNavigationApp());
      await tester.pumpAndSettle();

      final homeContext = tester.element(find.text('Home Screen'));
      unawaited(homeContext.pushNamed('/detail'));
      await tester.pumpAndSettle();

      final detailContext = tester.element(find.text('Detail Screen'));
      await detailContext.pop(args: const TestResultArgs('success_result'));
      await tester.pumpAndSettle();

      expect(find.text('Home Screen'), findsOneWidget);
      final currentHomeContext = tester.element(find.text('Home Screen'));
      final result = currentHomeContext.getArgument<TestResultArgs>();
      expect(result?.value, equals('success_result'));
    });

    testWidgets('pop falls back to defaultRoute when canPop is false', (
      tester,
    ) async {
      await tester.pumpWidget(createNavigationApp());
      await tester.pumpAndSettle();

      final homeContext = tester.element(find.text('Home Screen'));
      expect(homeContext.navigate.canPop(), isFalse);

      unawaited(homeContext.pop(args: const TestResultArgs('fallback_pop')));
      await tester.pumpAndSettle();

      expect(find.text('Home Screen'), findsOneWidget);
      final updatedContext = tester.element(find.text('Home Screen'));
      expect(
        updatedContext.getArgument<TestResultArgs>()?.value,
        equals('fallback_pop'),
      );
    });

    testWidgets('setPopArgument stages return arguments before pop', (
      tester,
    ) async {
      await tester.pumpWidget(createNavigationApp());
      await tester.pumpAndSettle();

      final homeContext = tester.element(find.text('Home Screen'));
      unawaited(homeContext.pushNamed('/detail'));
      await tester.pumpAndSettle();

      final detailContext = tester.element(find.text('Detail Screen'))
        ..setPopArgument(const TestResultArgs('staged_pop_result'));
      await detailContext.pop();
      await tester.pumpAndSettle();

      final currentHome = tester.element(find.text('Home Screen'));
      expect(
        currentHome.getArgument<TestResultArgs>()?.value,
        equals('staged_pop_result'),
      );
    });

    testWidgets('popToFirst pops multiple routes and passes return arguments', (
      tester,
    ) async {
      await tester.pumpWidget(createNavigationApp());
      await tester.pumpAndSettle();

      final homeContext = tester.element(find.text('Home Screen'));
      unawaited(homeContext.pushNamed('/step1'));
      await tester.pumpAndSettle();

      final step1Context = tester.element(find.text('Step 1 Screen'));
      unawaited(step1Context.pushNamed('/step2'));
      await tester.pumpAndSettle();

      final step2Context = tester.element(find.text('Step 2 Screen'));
      await step2Context.popToFirst(
        args: [const TestResultArgs('from_lvl2')],
      );
      await tester.pumpAndSettle();

      expect(find.text('Home Screen'), findsOneWidget);
      expect(find.text('Step 1 Screen'), findsNothing);
      expect(find.text('Step 2 Screen'), findsNothing);

      final currentHome = tester.element(find.text('Home Screen'));
      expect(
        currentHome.getArgument<TestResultArgs>()?.value,
        equals('from_lvl2'),
      );
    });

    testWidgets('popToFirst falls back to defaultRoute when canPop is false', (
      tester,
    ) async {
      await tester.pumpWidget(createNavigationApp());
      await tester.pumpAndSettle();

      final homeContext = tester.element(find.text('Home Screen'));
      unawaited(
        homeContext.popToFirst(
          args: [const TestResultArgs('root_pop_first')],
        ),
      );
      await tester.pumpAndSettle();

      expect(find.text('Home Screen'), findsOneWidget);
      final currentHome = tester.element(find.text('Home Screen'));
      expect(
        currentHome.getArgument<TestResultArgs>()?.value,
        equals('root_pop_first'),
      );
    });

    testWidgets('popToFirstAndPushNamed pops to first and pushes target route', (
      tester,
    ) async {
      await tester.pumpWidget(createNavigationApp());
      await tester.pumpAndSettle();

      final homeContext = tester.element(find.text('Home Screen'));
      unawaited(homeContext.pushNamed('/step1'));
      await tester.pumpAndSettle();

      final step1Context = tester.element(find.text('Step 1 Screen'));
      unawaited(step1Context.pushNamed('/step2'));
      await tester.pumpAndSettle();

      final step2Context = tester.element(find.text('Step 2 Screen'));
      unawaited(
        step2Context.popToFirstAndPushNamed(
          '/target',
          args: [const TestUserArgs('direct_target')],
        ),
      );
      await tester.pumpAndSettle();

      expect(find.text('Target Screen'), findsOneWidget);
      expect(find.text('Step 1 Screen'), findsNothing);
      expect(find.text('Step 2 Screen'), findsNothing);

      final targetContext = tester.element(find.text('Target Screen'));
      expect(
        targetContext.getArgument<TestUserArgs>()?.id,
        equals('direct_target'),
      );
    });

    testWidgets('popToFirstAndPushReplacementNamed replaces the first route', (
      tester,
    ) async {
      await tester.pumpWidget(createNavigationApp());
      await tester.pumpAndSettle();

      final homeContext = tester.element(find.text('Home Screen'));
      unawaited(homeContext.pushNamed('/step1'));
      await tester.pumpAndSettle();

      final step1Context = tester.element(find.text('Step 1 Screen'));
      unawaited(
        step1Context.popToFirstAndPushReplacementNamed(
          '/target',
          args: [const TestUserArgs('replacement_target')],
        ),
      );
      await tester.pumpAndSettle();

      expect(find.text('Target Screen'), findsOneWidget);
      expect(find.text('Step 1 Screen'), findsNothing);
      expect(find.text('Home Screen'), findsNothing);
    });

    testWidgets(
      'popToSelectOrFirstAndPushNamed returns to existing route if present in stack',
      (tester) async {
        await tester.pumpWidget(createNavigationApp());
        await tester.pumpAndSettle();

        final homeContext = tester.element(find.text('Home Screen'));
        unawaited(homeContext.pushNamed('/step1'));
        await tester.pumpAndSettle();

        final step1Context = tester.element(find.text('Step 1 Screen'));
        unawaited(step1Context.pushNamed('/step2'));
        await tester.pumpAndSettle();

        final step2Context = tester.element(find.text('Step 2 Screen'));
        unawaited(step2Context.popToSelectOrFirstAndPushNamed('/step1'));
        await tester.pumpAndSettle();

        expect(find.text('Step 1 Screen'), findsOneWidget);
        expect(find.text('Step 2 Screen'), findsNothing);
      },
    );

    testWidgets(
      'popToSelectOrFirstAndPushNamed pushes route if not present in stack',
      (tester) async {
        await tester.pumpWidget(createNavigationApp());
        await tester.pumpAndSettle();

        final homeContext = tester.element(find.text('Home Screen'));
        unawaited(homeContext.pushNamed('/step1'));
        await tester.pumpAndSettle();

        final step1Context = tester.element(find.text('Step 1 Screen'));
        unawaited(step1Context.popToSelectOrFirstAndPushNamed('/target'));
        await tester.pumpAndSettle();

        expect(find.text('Target Screen'), findsOneWidget);
      },
    );

    testWidgets('cleanArguments removes all arguments from route settings', (
      tester,
    ) async {
      await tester.pumpWidget(createNavigationApp());
      await tester.pumpAndSettle();

      final homeContext = tester.element(find.text('Home Screen'));
      unawaited(
        homeContext.pushNamed(
          '/detail',
          args: [const TestUserArgs('to_clean')],
        ),
      );
      await tester.pumpAndSettle();

      final detailContext = tester.element(find.text('Detail Screen'));
      expect(detailContext.getArgument<TestUserArgs>(), isNotNull);

      detailContext.cleanArguments();
      expect(detailContext.getArgument<TestUserArgs>(), isNull);
    });

    testWidgets('canNavigate returns true for registered paths and false otherwise', (
      tester,
    ) async {
      await tester.pumpWidget(createNavigationApp());
      await tester.pumpAndSettle();

      final context = tester.element(find.text('Home Screen'));
      expect(context.canNavigate('/home'), isTrue);
      expect(context.canNavigate('/detail'), isTrue);
      expect(context.canNavigate('/unknown_route'), isFalse);
    });

    testWidgets('openUrl invokes configured callback in BrowserConfig', (
      tester,
    ) async {
      Uri? openedUri;
      await tester.pumpWidget(
        createNavigationApp(
          openUrl: (uri) async {
            openedUri = uri;
          },
        ),
      );
      await tester.pumpAndSettle();

      tester.element(find.text('Home Screen')).openUrl(Uri.parse('https://flutter.dev'));
      expect(openedUri, equals(Uri.parse('https://flutter.dev')));
    });

    testWidgets('launchAction handles external links, internal routes and navigateType', (
      tester,
    ) async {
      Uri? openedUri;
      await tester.pumpWidget(
        createNavigationApp(
          openUrl: (uri) async {
            openedUri = uri;
          },
        ),
      );
      await tester.pumpAndSettle();

      // 1. External URL
      tester.element(find.text('Home Screen')).launchAction('https://dart.dev');
      expect(openedUri, equals(Uri.parse('https://dart.dev')));

      // 2. Default push
      tester.element(find.text('Home Screen')).launchAction('/detail');
      await tester.pumpAndSettle();
      expect(find.text('Detail Screen'), findsOneWidget);

      // 3. navigateType=pop
      tester.element(find.text('Detail Screen')).launchAction('/?navigateType=pop');
      await tester.pumpAndSettle();
      expect(find.text('Home Screen'), findsOneWidget);

      // 4. navigateType=pushreplacement
      tester.element(find.text('Home Screen')).launchAction('/step1?navigateType=pushreplacement');
      await tester.pumpAndSettle();
      expect(find.text('Step 1 Screen'), findsOneWidget);
      expect(find.text('Home Screen'), findsNothing);

      // 5. navigateType=popfirstandpush
      tester.element(find.text('Step 1 Screen')).launchAction('/step2?navigateType=popfirstandpush');
      await tester.pumpAndSettle();
      expect(find.text('Step 2 Screen'), findsOneWidget);

      // 6. Invalid or non-navigable action
      tester.element(find.text('Step 2 Screen'))
        ..launchAction(':::invalid_uri')
        ..launchAction('/non_existent_route');
      await tester.pumpAndSettle();
      expect(find.text('Step 2 Screen'), findsOneWidget);
    });
  });
}
