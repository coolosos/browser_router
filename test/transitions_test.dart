import 'package:browser_router/browser.dart';
import 'package:browser_router/modal_route/transitions/build_transitions/adaptive_build_transition.dart';
import 'package:browser_router/modal_route/transitions/build_transitions/widgets/slide.dart';
import 'package:browser_router/modal_route/transitions/build_transitions/widgets/zoom.dart';
import 'package:browser_router/modal_route/transitions/build_transitions/zoom_build_transition.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter/widgets.dart';
import 'package:flutter_test/flutter_test.dart';

void main() {
  group('Transition Widgets Tests', () {
    testWidgets('Zoom widget renders scale and fade transitions correctly',
        (tester) async {
      final primaryController = AnimationController(
        vsync: const TestVSync(),
        duration: const Duration(milliseconds: 300),
      );
      final secondaryController = AnimationController(
        vsync: const TestVSync(),
        duration: const Duration(milliseconds: 300),
      );

      await tester.pumpWidget(
        Directionality(
          textDirection: TextDirection.ltr,
          child: Zoom(
            primaryRouteAnimation: primaryController,
            secondaryRouteAnimation: secondaryController,
            child: const Text('Zoom Content'),
          ),
        ),
      );

      expect(find.text('Zoom Content'), findsOneWidget);

      primaryController.value = 0.5;
      await tester.pump();
      expect(find.text('Zoom Content'), findsOneWidget);

      secondaryController.value = 0.8;
      await tester.pump();
      expect(find.text('Zoom Content'), findsOneWidget);

      primaryController.dispose();
      secondaryController.dispose();
    });

    testWidgets('Slide widget renders with leading edge shadow and scrim',
        (tester) async {
      final primaryController = AnimationController(
        vsync: const TestVSync(),
        duration: const Duration(milliseconds: 300),
      );
      final secondaryController = AnimationController(
        vsync: const TestVSync(),
        duration: const Duration(milliseconds: 300),
      );

      await tester.pumpWidget(
        Directionality(
          textDirection: TextDirection.ltr,
          child: Slide(
            drive: Positions.right,
            primaryRouteAnimation: primaryController,
            secondaryRouteAnimation: secondaryController,
            child: const Text('Slide Content'),
          ),
        ),
      );

      expect(find.text('Slide Content'), findsOneWidget);

      // Verify decoration tween starts with leading edge shadow
      final slideFinder = find.byType(Slide);
      final slideWidget = tester.widget<Slide>(slideFinder);
      final beginDec = slideWidget.decorationTween.begin as BoxDecoration?;
      expect(beginDec?.boxShadow, isNotNull);

      // Animate secondary to trigger scrim
      secondaryController.value = 0.5;
      await tester.pump();
      expect(find.byType(ColoredBox), findsOneWidget);

      primaryController.dispose();
      secondaryController.dispose();
    });
  });

  group('Transition Builders & RouteTransition Enum Tests', () {
    testWidgets('ZoomBuildTransition creates Zoom widget', (tester) async {
      const zoomBuilder = ZoomBuildTransition();
      final anim = AnimationController(vsync: const TestVSync());
      final secAnim = AnimationController(vsync: const TestVSync());

      await tester.pumpWidget(
        Directionality(
          textDirection: TextDirection.ltr,
          child: zoomBuilder.call(
            animation: anim,
            secondaryAnimation: secAnim,
            child: const Text('Zoom Builder Content'),
          ),
        ),
      );

      expect(find.byType(Zoom), findsOneWidget);

      anim.dispose();
      secAnim.dispose();
    });

    testWidgets('AdaptiveBuildTransition adapts to target platforms',
        (tester) async {
      const adaptiveBuilder = AdaptiveBuildTransition();
      final anim = AnimationController(vsync: const TestVSync());
      final secAnim = AnimationController(vsync: const TestVSync());

      // iOS -> Slide
      debugDefaultTargetPlatformOverride = TargetPlatform.iOS;
      await tester.pumpWidget(
        Directionality(
          textDirection: TextDirection.ltr,
          child: adaptiveBuilder.call(
            animation: anim,
            secondaryAnimation: secAnim,
            child: const Text('Adaptive Content iOS'),
          ),
        ),
      );
      expect(find.byType(Slide), findsOneWidget);

      // Android -> Zoom
      debugDefaultTargetPlatformOverride = TargetPlatform.android;
      await tester.pumpWidget(
        Directionality(
          textDirection: TextDirection.ltr,
          child: adaptiveBuilder.call(
            animation: anim,
            secondaryAnimation: secAnim,
            child: const Text('Adaptive Content Android'),
          ),
        ),
      );
      expect(find.byType(Zoom), findsOneWidget);

      // Linux -> Fade
      debugDefaultTargetPlatformOverride = TargetPlatform.linux;
      await tester.pumpWidget(
        Directionality(
          textDirection: TextDirection.ltr,
          child: adaptiveBuilder.call(
            animation: anim,
            secondaryAnimation: secAnim,
            child: const Text('Adaptive Content Linux'),
          ),
        ),
      );
      expect(find.byType(FadeTransition), findsOneWidget);

      debugDefaultTargetPlatformOverride = null;
      anim.dispose();
      secAnim.dispose();
    });

    test('RouteTransition enum contains zoom and adaptive with non-null build',
        () {
      expect(RouteTransition.zoom.build, isA<ZoomBuildTransition>());
      expect(RouteTransition.adaptive.build, isA<AdaptiveBuildTransition>());
    });
  });
}
