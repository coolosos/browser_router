part of 'swipe.dart';

class SwipeAnimation extends StatefulWidget {
  const SwipeAnimation({
    required this.animation,
    required this.builder,
    required this.screenMaximumPercentage,
    required this.animationController,
    required this.enableDrag,
    required this.onClosing,
    required this.animationDirection,
    super.key,
  }) : assert(
          enableDrag && animationController != null,
          "'BottomSheet.animationController' can not be null when 'BottomSheet.enableDrag' is true. "
          "Use 'BottomSheet.createAnimationController' to create one, or provide another AnimationController.",
        );
  final Animation<double> animation;
  final WidgetBuilder builder;
  final double screenMaximumPercentage;
  final AnimationController? animationController;
  final bool enableDrag;
  final VoidCallback onClosing;

  final AxisDirection animationDirection;

  @override
  State<SwipeAnimation> createState() => _SwipeAnimationState();
}

class _SwipeAnimationState extends State<SwipeAnimation> {
  final GlobalKey _childKey = GlobalKey(debugLabel: 'BottomSheet child');

  double get _childHeight {
    final keyContext = _childKey.currentContext;
    if (keyContext == null) {
      assert(
        keyContext != null,
        'Function call before child was show in screen',
      );
      return 0;
    }
    final keyRender = keyContext.findRenderObject();
    if (keyRender == null) {
      assert(
        keyRender != null,
        'Function in time with render object missing',
      );

      return 0;
    }
    return (keyRender as RenderBox).size.height;
  }

  SwipeGestures _generateSwipeGestures({required AxisDirection direction}) {
    switch (direction) {
      case AxisDirection.up:
        return SwipeDownRightGestures(
          animationController: widget.animationController!,
          obtainChildHeight: () => _childHeight,
          canDragDone:
              widget.animationController?.status == AnimationStatus.reverse,
          onClosing: widget.onClosing,
        );
      case AxisDirection.left:
        return SwipeDownRightGestures(
          animationController: widget.animationController!,
          obtainChildHeight: () => _childHeight,
          canDragDone:
              widget.animationController?.status == AnimationStatus.reverse,
          onClosing: widget.onClosing,
          closePercentage: 0.8,
        );
      case AxisDirection.down:
        return SwipeUpLeftGestures(
          animationController: widget.animationController!,
          obtainChildHeight: () => _childHeight,
          canDragDone:
              widget.animationController?.status == AnimationStatus.reverse,
          onClosing: widget.onClosing,
        );

      case AxisDirection.right:
        return SwipeUpLeftGestures(
          animationController: widget.animationController!,
          obtainChildHeight: () => _childHeight,
          canDragDone:
              widget.animationController?.status == AnimationStatus.reverse,
          onClosing: widget.onClosing,
          closePercentage: 0.8,
        );
    }
  }

  @override
  Widget build(BuildContext context) {
    assert(
      debugCheckHasMediaQuery(context),
      'Need inherited mediaQuery on context',
    );
    return Swipe(
      animation: widget.animation,
      screenMaximumPercentage: widget.screenMaximumPercentage,
      hasEnableGestures: widget.enableDrag,
      direction: widget.animationDirection,
      gestures: _generateSwipeGestures(
        direction: widget.animationDirection,
      ),
      onNotification: (DraggableScrollableNotification notification) {
        if (notification.extent == notification.minExtent) {
          widget.onClosing();
        }
        return false;
      },
      disableAnimations: MediaQuery.of(context).disableAnimations,
      child: KeyedSubtree(
        key: _childKey,
        child: widget.builder(context),
      ),
    );
  }
}
