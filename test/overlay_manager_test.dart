import 'dart:async';

import 'package:browser_router/browser.dart';
import 'package:browser_router/overlay/overlay_manager.dart';
import 'package:flutter/material.dart' hide Banner;
import 'package:flutter_test/flutter_test.dart';

void main() {
  group('OverlayManager & OverlayModal Tests', () {
    testWidgets('OverlayManager.of locates ancestor state', (tester) async {
      OverlayManagerState? foundState;
      OverlayManagerState? foundRootState;

      await tester.pumpWidget(
        WidgetsApp(
          color: const Color(0xFFFFFFFF),
          home: OverlayManager(
            child: Builder(
              builder: (context) {
                foundState = OverlayManager.of(context);
                foundRootState = OverlayManager.of(context, rootManager: true);
                return const Text(
                  'Overlay Child',
                  textDirection: TextDirection.ltr,
                );
              },
            ),
          ),
          pageRouteBuilder: <T>(settings, builder) => PageRouteBuilder<T>(
            settings: settings,
            pageBuilder: (context, animation, secondaryAnimation) =>
                builder(context),
          ),
        ),
      );

      expect(foundState, isNotNull);
      expect(foundRootState, isNotNull);
      expect(foundState, equals(foundRootState));
    });

    testWidgets('showModal and dismissModal manage overlay visibility',
        (tester) async {
      late BuildContext savedContext;

      await tester.pumpWidget(
        MaterialApp(
          home: OverlayManager(
            child: Scaffold(
              body: Builder(
                builder: (context) {
                  savedContext = context;
                  return const Text('Home Screen');
                },
              ),
            ),
          ),
        ),
      );

      expect(find.text('Home Screen'), findsOneWidget);
      expect(find.text('Modal Content'), findsNothing);

      // Show overlay modal
      final overlayManager = OverlayManager.of(savedContext);
      expect(overlayManager, isNotNull);

      final modal = Modal(
        content: (remove) => Column(
          children: [
            const Text('Modal Content'),
            ElevatedButton(
              onPressed: remove,
              child: const Text('Close Modal'),
            ),
          ],
        ),
        transition: const OverlayTraceRoute(
          routeTransition: RouteTransition.fade,
          transitionDuration: Duration(milliseconds: 100),
          reverseTransitionDuration: Duration(milliseconds: 100),
        ),
        overlayState: Overlay.of(savedContext),
        backgroundColor: Colors.black54,
      );

      unawaited(overlayManager?.showModal(modal));
      await tester.pump();
      await tester.pump(const Duration(milliseconds: 150));

      expect(find.text('Modal Content'), findsOneWidget);

      // Dismiss modal (unawaited because dismissModal awaits reverse animation ticks)
      unawaited(overlayManager?.dismissModal());
      await tester.pump();
      await tester.pump(const Duration(milliseconds: 150));

      expect(find.text('Modal Content'), findsNothing);
    });

    testWidgets('enqueue process sequential overlays', (tester) async {
      late BuildContext savedContext;

      await tester.pumpWidget(
        MaterialApp(
          home: OverlayManager(
            child: Scaffold(
              body: Builder(
                builder: (context) {
                  savedContext = context;
                  return const Text('Home Screen');
                },
              ),
            ),
          ),
        ),
      );

      final overlayManager = OverlayManager.of(savedContext)!;

      final banner1 = Banner.fromContext(
        context: savedContext,
        duration: const Duration(seconds: 1),
        transition: const OverlayTraceRoute(
          routeTransition: RouteTransition.slide_down,
          transitionDuration: Duration(milliseconds: 50),
          reverseTransitionDuration: Duration(milliseconds: 50),
        ),
        content: (remove) => const Text('Banner 1 Content'),
      );

      overlayManager.enqueue(banner1);
      await tester.pump();
      await tester.pump(const Duration(milliseconds: 100));

      expect(find.text('Banner 1 Content'), findsOneWidget);

      // Remove actual
      overlayManager.removeActual();
      await tester.pump();
      await tester.pump(const Duration(milliseconds: 100));

      expect(find.text('Banner 1 Content'), findsNothing);
    });

    testWidgets('Disposing OverlayManager cleans up without errors',
        (tester) async {
      final showManager = ValueNotifier<bool>(true);

      await tester.pumpWidget(
        MaterialApp(
          home: ValueListenableBuilder<bool>(
            valueListenable: showManager,
            builder: (context, show, child) {
              if (!show) return const SizedBox.shrink();
              return OverlayManager(
                child: Scaffold(
                  body: Builder(
                    builder: (context) {
                      return ElevatedButton(
                        onPressed: () {
                          OverlayManager.of(context)?.showModal(
                            Modal(
                              content: (remove) => const Text('Overlay'),
                              transition: const OverlayTraceRoute(
                                routeTransition: RouteTransition.none,
                                transitionDuration: Duration.zero,
                                reverseTransitionDuration: Duration.zero,
                              ),
                              overlayState: Overlay.of(context),
                              backgroundColor: Colors.transparent,
                            ),
                          );
                        },
                        child: const Text('Show'),
                      );
                    },
                  ),
                ),
              );
            },
          ),
        ),
      );

      // Open modal
      await tester.tap(find.text('Show'));
      await tester.pump();
      await tester.pump(const Duration(milliseconds: 50));
      expect(find.text('Overlay'), findsOneWidget);

      // Unmount OverlayManager to trigger dispose
      showManager.value = false;
      await tester.pump();
      await tester.pump(const Duration(milliseconds: 50));

      expect(find.text('Overlay'), findsNothing);
    });

    testWidgets('enqueueBanner displays banner and allows clicks and interaction on underlying widgets', (
      tester,
    ) async {
      var underlyingButtonClicked = false;

      await tester.pumpWidget(
        MaterialApp(
          home: OverlayManager(
            child: Scaffold(
              body: Builder(
                builder: (context) {
                  return Column(
                    children: [
                      ElevatedButton(
                        onPressed: () {
                          OverlayManager.enqueueBanner(
                            context,
                            content: (remove) => const ColoredBox(
                              color: Colors.amber,
                              child: Text('Top Banner Content'),
                            ),
                          );
                        },
                        child: const Text('Show Banner'),
                      ),
                      const SizedBox(height: 100),
                      ElevatedButton(
                        onPressed: () {
                          underlyingButtonClicked = true;
                        },
                        child: const Text('Underlying Button'),
                      ),
                    ],
                  );
                },
              ),
            ),
          ),
        ),
      );

      // Trigger banner
      await tester.tap(find.text('Show Banner'));
      await tester.pump();
      await tester.pump(const Duration(milliseconds: 350));

      expect(find.text('Top Banner Content'), findsOneWidget);

      // Click underlying button while banner is visible
      await tester.tap(find.text('Underlying Button'));
      await tester.pump();

      expect(underlyingButtonClicked, isTrue);

      // Settle timer
      await tester.pump(const Duration(seconds: 6));
      await tester.pump(const Duration(milliseconds: 350));
    });

    testWidgets('enqueueBanner with standard Flutter buttons works out of the box without special configuration', (
      tester,
    ) async {
      var bannerActionClicked = false;

      await tester.pumpWidget(
        MaterialApp(
          home: OverlayManager(
            child: Scaffold(
              body: Builder(
                builder: (context) {
                  return ElevatedButton(
                    onPressed: () {
                      OverlayManager.enqueueBanner(
                        context,
                        duration: Duration.zero,
                        content: (remove) => Container(
                          color: Colors.blue,
                          padding: const EdgeInsets.all(12),
                          child: Row(
                            children: [
                              const Text('Notification'),
                              ElevatedButton(
                                onPressed: () {
                                  bannerActionClicked = true;
                                  remove();
                                },
                                child: const Text('Action'),
                              ),
                            ],
                          ),
                        ),
                      );
                    },
                    child: const Text('Show Persistent Banner'),
                  );
                },
              ),
            ),
          ),
        ),
      );

      // Open banner
      await tester.tap(find.text('Show Persistent Banner'));
      await tester.pump();
      await tester.pump(const Duration(milliseconds: 350));

      expect(find.text('Notification'), findsOneWidget);
      expect(find.text('Action'), findsOneWidget);

      // Tap standard button in banner
      await tester.tap(find.text('Action'));
      await tester.pump();
      await tester.pump(const Duration(milliseconds: 350));

      expect(bannerActionClicked, isTrue);
      expect(find.text('Notification'), findsNothing);
    });
  });
}
