import 'package:browser_router/browser.dart';
import 'package:browser_router/modal_route/transitions/build_transitions/widgets/fade_scale.dart';
import 'package:browser_router/modal_route/transitions/build_transitions/widgets/fade_through.dart';
import 'package:browser_router/modal_route/transitions/build_transitions/widgets/scale.dart';
import 'package:browser_router/modal_route/transitions/build_transitions/widgets/shared_axis.dart';
import 'package:browser_router/modal_route/transitions/build_transitions/widgets/slide_cupertino.dart';
import 'package:flutter/widgets.dart';
import 'package:flutter_test/flutter_test.dart';

void main() {
  group('Modern Transitions Widget Tests', () {
    testWidgets('FadeThrough renders with animation and secondaryAnimation', (
      tester,
    ) async {
      late AnimationController primaryController;
      late AnimationController secondaryController;

      await tester.pumpWidget(
        Directionality(
          textDirection: TextDirection.ltr,
          child: StatefulBuilder(
            builder: (context, setState) {
              final vsync = tester;
              primaryController = AnimationController(
                vsync: vsync,
                duration: const Duration(milliseconds: 300),
              );
              secondaryController = AnimationController(
                vsync: vsync,
                duration: const Duration(milliseconds: 300),
              );

              return FadeThrough(
                animation: primaryController,
                secondaryAnimation: secondaryController,
                fillColor: const Color(0xFFFFFFFF),
                child: const Text('FadeThrough Content'),
              );
            },
          ),
        ),
      );

      expect(find.text('FadeThrough Content'), findsOneWidget);

      // Verify at t=0.0
      primaryController.value = 0.0;
      secondaryController.value = 0.0;
      await tester.pump();
      expect(find.text('FadeThrough Content'), findsOneWidget);

      // Verify at t=0.5
      primaryController.value = 0.5;
      await tester.pump();
      expect(find.text('FadeThrough Content'), findsOneWidget);

      // Verify at t=1.0 with secondary animation active
      primaryController.value = 1.0;
      secondaryController.value = 0.5;
      await tester.pump();
      expect(find.text('FadeThrough Content'), findsOneWidget);

      primaryController.dispose();
      secondaryController.dispose();
    });

    testWidgets('FadeScale renders with scale and fade intervals', (
      tester,
    ) async {
      late AnimationController primaryController;
      late AnimationController secondaryController;

      await tester.pumpWidget(
        Directionality(
          textDirection: TextDirection.ltr,
          child: StatefulBuilder(
            builder: (context, setState) {
              final vsync = tester;
              primaryController = AnimationController(
                vsync: vsync,
                duration: const Duration(milliseconds: 200),
              );
              secondaryController = AnimationController(
                vsync: vsync,
                duration: const Duration(milliseconds: 200),
              );

              return FadeScale(
                animation: primaryController,
                secondaryAnimation: secondaryController,
                child: const Text('FadeScale Content'),
              );
            },
          ),
        ),
      );

      expect(find.text('FadeScale Content'), findsOneWidget);

      primaryController.value = 0.0;
      await tester.pump();

      primaryController.value = 1.0;
      secondaryController.value = 0.5;
      await tester.pump();
      expect(find.text('FadeScale Content'), findsOneWidget);

      primaryController.dispose();
      secondaryController.dispose();
    });

    testWidgets('SharedAxis renders horizontal, vertical, and scaled', (
      tester,
    ) async {
      for (final type in SharedAxisDirection.values) {
        for (final direction in [TextDirection.ltr, TextDirection.rtl]) {
          late AnimationController primaryController;
          late AnimationController secondaryController;

          await tester.pumpWidget(
            Directionality(
              textDirection: direction,
              child: StatefulBuilder(
                builder: (context, setState) {
                  final vsync = tester;
                  primaryController = AnimationController(
                    vsync: vsync,
                    duration: const Duration(milliseconds: 300),
                  );
                  secondaryController = AnimationController(
                    vsync: vsync,
                    duration: const Duration(milliseconds: 300),
                  );

                  return SharedAxis(
                    animation: primaryController,
                    secondaryAnimation: secondaryController,
                    direction: type,
                    child: Text('SharedAxis ${type.name} ${direction.name}'),
                  );
                },
              ),
            ),
          );

          expect(find.text('SharedAxis ${type.name} ${direction.name}'), findsOneWidget);

          primaryController.value = 0.0;
          await tester.pump();

          primaryController.value = 0.5;
          await tester.pump();

          primaryController.value = 1.0;
          secondaryController.value = 0.5;
          await tester.pump();

          primaryController.dispose();
          secondaryController.dispose();
        }
      }
    });

    testWidgets('SlideCupertino handles shadow and LTR/RTL text directions', (
      tester,
    ) async {
      for (final hasShadow in [true, false]) {
        for (final direction in [TextDirection.ltr, TextDirection.rtl]) {
          late AnimationController primaryController;
          late AnimationController secondaryController;

          await tester.pumpWidget(
            Directionality(
              textDirection: direction,
              child: StatefulBuilder(
                builder: (context, setState) {
                  final vsync = tester;
                  primaryController = AnimationController(
                    vsync: vsync,
                    duration: const Duration(milliseconds: 300),
                  );
                  secondaryController = AnimationController(
                    vsync: vsync,
                    duration: const Duration(milliseconds: 300),
                  );

                  return SlideCupertino(
                    animation: primaryController,
                    secondaryAnimation: secondaryController,
                    hasShadow: hasShadow,
                    child: Text('SlideCupertino shadow=$hasShadow dir=${direction.name}'),
                  );
                },
              ),
            ),
          );

          expect(
            find.text('SlideCupertino shadow=$hasShadow dir=${direction.name}'),
            findsOneWidget,
          );

          primaryController.value = 0.0;
          await tester.pump();

          primaryController.value = 0.5;
          await tester.pump();

          primaryController.value = 1.0;
          secondaryController.value = 0.5;
          await tester.pump();

          primaryController.dispose();
          secondaryController.dispose();
        }
      }
    });

    testWidgets('Scale renders scale and fade', (
      tester,
    ) async {
      late AnimationController primaryController;
      late AnimationController secondaryController;

      await tester.pumpWidget(
        Directionality(
          textDirection: TextDirection.ltr,
          child: StatefulBuilder(
            builder: (context, setState) {
              final vsync = tester;
              primaryController = AnimationController(
                vsync: vsync,
                duration: const Duration(milliseconds: 250),
              );
              secondaryController = AnimationController(
                vsync: vsync,
                duration: const Duration(milliseconds: 250),
              );

              return Scale(
                animation: primaryController,
                secondaryAnimation: secondaryController,
                initialScale: 0.85,
                child: const Text('Scale Content'),
              );
            },
          ),
        ),
      );

      expect(find.text('Scale Content'), findsOneWidget);

      primaryController.value = 0.0;
      await tester.pump();

      primaryController.value = 1.0;
      secondaryController.value = 0.5;
      await tester.pump();
      expect(find.text('Scale Content'), findsOneWidget);

      primaryController.dispose();
      secondaryController.dispose();
    });
  });

  group('Modern BuildTransition Classes and RouteTransition Enum Tests', () {
    testWidgets('BuildTransition implementations construct valid widgets', (
      tester,
    ) async {
      const dummyAnim = kAlwaysCompleteAnimation;
      const dummySecAnim = kAlwaysDismissedAnimation;
      const child = Text('Inner', textDirection: TextDirection.ltr);

      await tester.pumpWidget(
        Directionality(
          textDirection: TextDirection.ltr,
          child: Builder(
            builder: (context) {
              return Column(
                children: [
                  const FadeThroughBuildTransition().call(
                    animation: dummyAnim,
                    secondaryAnimation: dummySecAnim,
                    child: child,
                  ),
                  const FadeScaleBuildTransition().call(
                    animation: dummyAnim,
                    secondaryAnimation: dummySecAnim,
                    child: child,
                  ),
                  const SharedAxisBuildTransition(
                    direction: SharedAxisDirection.horizontal,
                  ).call(
                    animation: dummyAnim,
                    secondaryAnimation: dummySecAnim,
                    child: child,
                  ),
                  const SharedAxisBuildTransition(
                    direction: SharedAxisDirection.vertical,
                  ).call(
                    animation: dummyAnim,
                    secondaryAnimation: dummySecAnim,
                    child: child,
                  ),
                  const SharedAxisBuildTransition(
                    direction: SharedAxisDirection.scaled,
                  ).call(
                    animation: dummyAnim,
                    secondaryAnimation: dummySecAnim,
                    child: child,
                  ),
                  const SlideCupertinoBuildTransition().call(
                    animation: dummyAnim,
                    secondaryAnimation: dummySecAnim,
                    child: child,
                  ),
                  const SlideCupertinoBuildTransition(hasShadow: false).call(
                    animation: dummyAnim,
                    secondaryAnimation: dummySecAnim,
                    child: child,
                  ),
                  const ScaleBuildTransition().call(
                    animation: dummyAnim,
                    secondaryAnimation: dummySecAnim,
                    child: child,
                  ),
                  CustomBuildTransition(
                    ({
                      required animation,
                      required secondaryAnimation,
                      required child,
                    }) =>
                        Opacity(
                      opacity: 0.5,
                      child: child,
                    ),
                  ).call(
                    animation: dummyAnim,
                    secondaryAnimation: dummySecAnim,
                    child: child,
                  ),
                ],
              );
            },
          ),
        ),
      );

      expect(find.text('Inner'), findsNWidgets(9));
    });

    test('RouteTransition enum contains all modern transitions and correctly maps to BuildTransitions', () {
      expect(RouteTransition.fade_through.build, isA<FadeThroughBuildTransition>());
      expect(RouteTransition.fade_scale.build, isA<FadeScaleBuildTransition>());
      expect(RouteTransition.shared_axis_x.build, isA<SharedAxisBuildTransition>());
      expect(RouteTransition.shared_axis_y.build, isA<SharedAxisBuildTransition>());
      expect(RouteTransition.shared_axis_z.build, isA<SharedAxisBuildTransition>());
      expect(RouteTransition.slide_cupertino.build, isA<SlideCupertinoBuildTransition>());
      expect(RouteTransition.scale.build, isA<ScaleBuildTransition>());

      // Legacy transitions are preserved
      expect(RouteTransition.fade.build, isA<FadeBuildTransition>());
      expect(RouteTransition.slide_right.build, isA<SlideBuildTransition>());
      expect(RouteTransition.slide_up.build, isA<SlideBuildTransition>());
      expect(RouteTransition.slide_left.build, isA<SlideBuildTransition>());
      expect(RouteTransition.slide_down.build, isA<SlideBuildTransition>());
      expect(RouteTransition.none.build, isA<NoBuildTransition>());
      expect(RouteTransition.only_hero.build, isA<NoBuildTransition>());
    });
  });
}
