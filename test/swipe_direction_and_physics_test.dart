import 'package:browser_router/gestures/swipe/swipe.dart';
import 'package:flutter/widgets.dart';
import 'package:flutter_test/flutter_test.dart';

void main() {
  group('SwipeAnimation All AxisDirections & Notifications', () {
    testWidgets('SwipeAnimation builds with AxisDirection.left and AxisDirection.right', (
      tester,
    ) async {
      final controller = AnimationController(
        vsync: const TestVSync(),
        duration: const Duration(milliseconds: 300),
      );

      // 1. AxisDirection.left
      await tester.pumpWidget(
        Directionality(
          textDirection: TextDirection.ltr,
          child: MediaQuery(
            data: const MediaQueryData(),
            child: SwipeAnimation(
              animation: controller,
              animationController: controller,
              screenMaximumPercentage: 0.8,
              enableDrag: true,
              animationDirection: AxisDirection.left,
              onClosing: () {},
              builder: (context) => const Text('Left Content'),
            ),
          ),
        ),
      );
      await tester.pumpAndSettle();
      expect(find.text('Left Content'), findsOneWidget);

      // 2. AxisDirection.right
      await tester.pumpWidget(
        Directionality(
          textDirection: TextDirection.ltr,
          child: MediaQuery(
            data: const MediaQueryData(),
            child: SwipeAnimation(
              animation: controller,
              animationController: controller,
              screenMaximumPercentage: 0.8,
              enableDrag: true,
              animationDirection: AxisDirection.right,
              onClosing: () {},
              builder: (context) => const Text('Right Content'),
            ),
          ),
        ),
      );
      await tester.pumpAndSettle();
      expect(find.text('Right Content'), findsOneWidget);

      // 3. AxisDirection.down
      await tester.pumpWidget(
        Directionality(
          textDirection: TextDirection.ltr,
          child: MediaQuery(
            data: const MediaQueryData(),
            child: SwipeAnimation(
              animation: controller,
              animationController: controller,
              screenMaximumPercentage: 0.8,
              enableDrag: true,
              animationDirection: AxisDirection.down,
              onClosing: () {},
              builder: (context) => const Text('Down Content'),
            ),
          ),
        ),
      );
      await tester.pumpAndSettle();
      expect(find.text('Down Content'), findsOneWidget);
    });

    testWidgets('SwipeAnimation notification onClosing when minExtent reached', (
      tester,
    ) async {
      final controller = AnimationController(
        vsync: const TestVSync(),
        duration: const Duration(milliseconds: 300),
      );

      var closingFired = false;

      await tester.pumpWidget(
        Directionality(
          textDirection: TextDirection.ltr,
          child: MediaQuery(
            data: const MediaQueryData(),
            child: SwipeAnimation(
              animation: controller,
              animationController: controller,
              screenMaximumPercentage: 1,
              enableDrag: true,
              animationDirection: AxisDirection.up,
              onClosing: () {
                closingFired = true;
              },
              builder: (context) => const Text('Dispatch Target'),
            ),
          ),
        ),
      );
      await tester.pumpAndSettle();

      final childContext = tester.element(find.text('Dispatch Target'));
      DraggableScrollableNotification(
        extent: 0.2,
        minExtent: 0.2,
        maxExtent: 1,
        initialExtent: 0.5,
        context: childContext,
      ).dispatch(childContext);
      await tester.pumpAndSettle();

      expect(closingFired, isTrue);
    });
  });

  group('SwipeGestures Drag Updates and Fling Physics', () {
    test('SwipeDownRightGestures handles start, update with zero size, and end', () {
      final controller = AnimationController(
        vsync: const TestVSync(),
        duration: const Duration(milliseconds: 300),
      );

      var startFired = false;
      var endFired = false;
      var closingFired = false;

      final gestures = SwipeDownRightGestures(
        animationController: controller,
        obtainSize: () => 100,
        canDragDone: () => false,
        onClosing: () {
          closingFired = true;
        },
        dragStart: (d) => startFired = true,
        dragEnd: (d) => endFired = true,
      )..handleDragStart(DragStartDetails());
      expect(startFired, isTrue);

      // 2. handleDragUpdate with normal delta
      controller.value = 0.8;
      gestures.handleDragUpdate(
        DragUpdateDetails(
          globalPosition: Offset.zero,
          delta: const Offset(0, 10),
          primaryDelta: 10,
        ),
      );
      expect(controller.value, lessThan(0.8));

      // 3. handleDragUpdate with zero size
      SwipeDownRightGestures(
        animationController: controller,
        obtainSize: () => 0,
        canDragDone: () => false,
        onClosing: () {},
      ).handleDragUpdate(
        DragUpdateDetails(
          globalPosition: Offset.zero,
          delta: const Offset(0, 5),
          primaryDelta: 5,
        ),
      );

      // 4. handleDragEnd with fast positive velocity (fling right/down)
      gestures.handleDragEnd(
        DragEndDetails(
          velocity: const Velocity(pixelsPerSecond: Offset(0, 200)),
          primaryVelocity: 200,
        ),
      );
      expect(closingFired, isTrue);
      expect(endFired, isTrue);

      // 5. canDragDone true prevents updates
      const canDone = true;
      SwipeDownRightGestures(
        animationController: controller,
        obtainSize: () => 100,
        canDragDone: () => canDone,
        onClosing: () {},
      )
        ..handleDragUpdate(
          DragUpdateDetails(
            globalPosition: Offset.zero,
            delta: const Offset(0, 10),
            primaryDelta: 10,
          ),
        )
        ..handleDragEnd(DragEndDetails());
    });

    test('SwipeUpLeftGestures handles update and slow drag below/above threshold', () {
      final controller = AnimationController(
        vsync: const TestVSync(),
        duration: const Duration(milliseconds: 300),
      );

      var closingFired = false;

      final gestures = SwipeUpLeftGestures(
        animationController: controller,
        obtainSize: () => 100,
        canDragDone: () => false,
        onClosing: () {
          closingFired = true;
        },
        closePercentage: 0.5,
      );

      // 1. handleDragUpdate
      controller.value = 0.2;
      gestures.handleDragUpdate(
        DragUpdateDetails(
          globalPosition: Offset.zero,
          delta: const Offset(0, 10),
          primaryDelta: 10,
        ),
      );
      expect(controller.value, closeTo(0.3, 0.001));

      // 2. handleDragEnd below closePercentage -> pops
      controller.value = 0.4;
      gestures.handleDragEnd(
        DragEndDetails(
          velocity: Velocity.zero,
          primaryVelocity: 0,
        ),
      );
      expect(closingFired, isTrue);

      // 3. handleDragEnd above closePercentage -> forward
      closingFired = false;
      controller.value = 0.8;
      gestures.handleDragEnd(
        DragEndDetails(
          velocity: Velocity.zero,
          primaryVelocity: 0,
        ),
      );
      expect(closingFired, isFalse);
    });
  });
}
