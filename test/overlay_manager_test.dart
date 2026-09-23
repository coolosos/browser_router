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
  });
}
