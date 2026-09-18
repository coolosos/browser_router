import 'package:browser_router/gestures/swipe/swipe.dart';
import 'package:flutter/widgets.dart';
import 'package:flutter_test/flutter_test.dart';

void main() {
  group('SwipeAnimation Tests', () {
    testWidgets(
        'renders successfully when enableDrag is false and animationController is null',
        (tester) async {
      await tester.pumpWidget(
        WidgetsApp(
          color: const Color(0xFFFFFFFF),
          home: SwipeAnimation(
            animation: const AlwaysStoppedAnimation(1),
            animationController: null,
            enableDrag: false,
            screenMaximumPercentage: 1,
            animationDirection: AxisDirection.up,
            onClosing: () {},
            builder: (context) => const Text(
              'Content without drag',
              textDirection: TextDirection.ltr,
            ),
          ),
          pageRouteBuilder: <T>(settings, builder) => PageRouteBuilder<T>(
            settings: settings,
            pageBuilder: (context, animation, secondaryAnimation) =>
                builder(context),
          ),
        ),
      );

      expect(find.text('Content without drag'), findsOneWidget);
    });

    testWidgets(
        'renders successfully when enableDrag is true with animationController',
        (tester) async {
      late AnimationController controller;

      await tester.pumpWidget(
        WidgetsApp(
          color: const Color(0xFFFFFFFF),
          home: StatefulBuilder(
            builder: (context, setState) {
              return _TestSwipeWidget(
                onControllerCreated: (c) => controller = c,
              );
            },
          ),
          pageRouteBuilder: <T>(settings, builder) => PageRouteBuilder<T>(
            settings: settings,
            pageBuilder: (context, animation, secondaryAnimation) =>
                builder(context),
          ),
        ),
      );

      expect(find.text('Content with drag'), findsOneWidget);
      expect(controller.value, 1);
    });
  });

  group('SwipeGestures Tests', () {
    testWidgets('SwipeDownRightGestures handles drag updates and edge cases',
        (tester) async {
      var closed = false;
      late AnimationController controller;

      await tester.pumpWidget(
        WidgetsApp(
          color: const Color(0xFFFFFFFF),
          home: _GestureHostWidget(
            onInit: (vsync) {
              controller = AnimationController(
                vsync: vsync,
                value: 1,
              );
            },
            child: const SizedBox(width: 200, height: 200),
          ),
          pageRouteBuilder: <T>(settings, builder) => PageRouteBuilder<T>(
            settings: settings,
            pageBuilder: (context, animation, secondaryAnimation) =>
                builder(context),
          ),
        ),
      );

      final gestures = SwipeDownRightGestures(
        obtainSize: () => 100,
        animationController: controller,
        canDragDone: () => false,
        onClosing: () => closed = true,
      )..handleDragUpdate(
          DragUpdateDetails(
            globalPosition: Offset.zero,
            delta: const Offset(20, 0),
            primaryDelta: 20,
          ),
        );
      expect(controller.value, 0.8); // 1.0 - (20 / 100) = 0.8

      // Zero size guard (should not produce NaN or change value)
      SwipeDownRightGestures(
        obtainSize: () => 0,
        animationController: controller,
        canDragDone: () => false,
        onClosing: () => closed = true,
      )
        ..handleDragUpdate(
          DragUpdateDetails(
            globalPosition: Offset.zero,
            delta: const Offset(20, 0),
            primaryDelta: 20,
          ),
        )
        ..handleDragUpdate(
          DragUpdateDetails(
            globalPosition: Offset.zero,
            primaryDelta: null,
          ),
        );
      expect(controller.value, 0.8);

      // Drag end with fling towards pop (> 0 for SwipeDownRightGestures)
      gestures.handleDragEnd(
        DragEndDetails(
          velocity: const Velocity(pixelsPerSecond: Offset(10, 0)),
          primaryVelocity: 10,
        ),
      );
      expect(closed, isTrue);
      controller.dispose();
    });

    testWidgets('SwipeUpLeftGestures handles drag updates and edge cases',
        (tester) async {
      var closed = false;
      late AnimationController controller;

      await tester.pumpWidget(
        WidgetsApp(
          color: const Color(0xFFFFFFFF),
          home: _GestureHostWidget(
            onInit: (vsync) {
              controller = AnimationController(
                vsync: vsync,
                value: 0,
              );
            },
            child: const SizedBox(width: 200, height: 200),
          ),
          pageRouteBuilder: <T>(settings, builder) => PageRouteBuilder<T>(
            settings: settings,
            pageBuilder: (context, animation, secondaryAnimation) =>
                builder(context),
          ),
        ),
      );

      final gestures = SwipeUpLeftGestures(
        obtainSize: () => 100,
        animationController: controller,
        canDragDone: () => false,
        onClosing: () => closed = true,
      )..handleDragUpdate(
          DragUpdateDetails(
            globalPosition: Offset.zero,
            delta: const Offset(30, 0),
            primaryDelta: 30,
          ),
        );
      expect(controller.value, 0.3); // 0.0 + (30 / 100) = 0.3

      // Drag end below closePercentage forward or fling negative for pop
      gestures.handleDragEnd(
        DragEndDetails(
          velocity: const Velocity(pixelsPerSecond: Offset(-10, 0)),
          primaryVelocity: -10,
        ),
      );
      expect(closed, isTrue);
      controller.dispose();
    });
  });

  group('SwipeChildLayoutDelegate Tests', () {
    test('Calculates constraints and positions for each AxisDirection', () {
      final delegateUp = SwipeChildLayoutDelegate(0.5, 0.8, AxisDirection.up);
      final constraints = delegateUp.getConstraintsForChild(
        const BoxConstraints(maxWidth: 400, maxHeight: 800),
      );
      expect(constraints.maxHeight, 800 * 0.8);
      expect(constraints.maxWidth, 400);

      // Position up
      final posUp = delegateUp.getPositionForChild(
        const Size(400, 800),
        const Size(400, 400),
      );
      expect(posUp, const Offset(0, 800 - 400 * 0.5));

      // Position down
      final delegateDown =
          SwipeChildLayoutDelegate(0.5, 0.8, AxisDirection.down);
      final posDown = delegateDown.getPositionForChild(
        const Size(400, 800),
        const Size(400, 400),
      );
      expect(posDown, const Offset(0, 800 - 400));

      // Position right
      final delegateRight =
          SwipeChildLayoutDelegate(0.5, 0.8, AxisDirection.right);
      final posRight = delegateRight.getPositionForChild(
        const Size(400, 800),
        const Size(400, 400),
      );
      expect(posRight, const Offset(400 * 0.5 - 400, 800 - 400));

      // Position left
      final delegateLeft =
          SwipeChildLayoutDelegate(0.5, 0.8, AxisDirection.left);
      final posLeft = delegateLeft.getPositionForChild(
        const Size(400, 800),
        const Size(400, 400),
      );
      expect(posLeft, const Offset(400 - 400 * 0.5, 800 - 400));

      // shouldRelayout
      final delegateSame =
          SwipeChildLayoutDelegate(0.5, 0.8, AxisDirection.up);
      expect(delegateUp.shouldRelayout(delegateSame), isFalse);

      final delegateDiffProgress =
          SwipeChildLayoutDelegate(0.7, 0.8, AxisDirection.up);
      expect(delegateUp.shouldRelayout(delegateDiffProgress), isTrue);

      final delegateDiffDirection =
          SwipeChildLayoutDelegate(0.5, 0.8, AxisDirection.left);
      expect(delegateUp.shouldRelayout(delegateDiffDirection), isTrue);
    });
  });
}

class _TestSwipeWidget extends StatefulWidget {
  const _TestSwipeWidget({required this.onControllerCreated});

  final void Function(AnimationController controller) onControllerCreated;

  @override
  State<_TestSwipeWidget> createState() => _TestSwipeWidgetState();
}

class _TestSwipeWidgetState extends State<_TestSwipeWidget>
    with SingleTickerProviderStateMixin {
  late final AnimationController _controller;

  @override
  void initState() {
    super.initState();
    _controller = AnimationController(
      vsync: this,
      value: 1,
      duration: const Duration(milliseconds: 300),
    );
    widget.onControllerCreated(_controller);
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return SwipeAnimation(
      animation: _controller.view,
      animationController: _controller,
      enableDrag: true,
      screenMaximumPercentage: 1,
      animationDirection: AxisDirection.up,
      onClosing: () {},
      builder: (context) => const Text(
        'Content with drag',
        textDirection: TextDirection.ltr,
      ),
    );
  }
}

class _GestureHostWidget extends StatefulWidget {
  const _GestureHostWidget({required this.onInit, required this.child});

  final void Function(TickerProvider vsync) onInit;
  final Widget child;

  @override
  State<_GestureHostWidget> createState() => _GestureHostWidgetState();
}

class _GestureHostWidgetState extends State<_GestureHostWidget>
    with SingleTickerProviderStateMixin {
  @override
  void initState() {
    super.initState();
    widget.onInit(this);
  }

  @override
  Widget build(BuildContext context) => widget.child;
}
