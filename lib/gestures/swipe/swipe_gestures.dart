part of 'swipe.dart';

abstract base class SwipeGestures {
  const SwipeGestures({
    required this.obtainChildHeight,
    required this.animationController,
    required this.canDragDone,
    required this.onClosing,
    this.dragStart,
    this.dragEnd,
    this.closePercentage = 0.5,
  });

  final void Function(DragStartDetails)? dragStart;
  final void Function(DragEndDetails)? dragEnd;
  final double Function() obtainChildHeight;
  final AnimationController animationController;
  final bool canDragDone;
  final VoidCallback onClosing;
  final double closePercentage;

  void handleDragStart(DragStartDetails details) {
    dragStart?.call(details);
  }

  void handleDragEnd(DragEndDetails details) {
    if (canDragDone) {
      return;
    }
    var isClosing = false;
    if (details.velocity.pixelsPerSecond.dy > 700.0) {
      final flingVelocity =
          -details.velocity.pixelsPerSecond.dy / (obtainChildHeight());
      if (animationController.value > 0.0) {
        animationController.fling(velocity: flingVelocity);
      }
      if (flingVelocity < 0.0) {
        isClosing = true;
      }
    } else if (animationController.value < closePercentage) {
      if (animationController.value > 0.0) {
        animationController.fling(velocity: -1);
      }
      isClosing = true;
    } else {
      animationController.forward();
    }
    dragEnd?.call(details);
    if (isClosing) {
      onClosing.call();
    }
  }

  void handleDragUpdate(DragUpdateDetails details);
}

final class SwipeDownRightGestures extends SwipeGestures {
  const SwipeDownRightGestures({
    required super.obtainChildHeight,
    required super.animationController,
    required super.canDragDone,
    required super.onClosing,
    super.dragStart,
    super.dragEnd,
    super.closePercentage,
  });

  @override
  void handleDragUpdate(DragUpdateDetails details) {
    final primaryDelta = details.primaryDelta;
    if (canDragDone || primaryDelta == null) {
      return;
    }
    animationController.value -= primaryDelta / (obtainChildHeight());
  }
}

final class SwipeUpLeftGestures extends SwipeGestures {
  const SwipeUpLeftGestures({
    required super.obtainChildHeight,
    required super.animationController,
    required super.canDragDone,
    required super.onClosing,
    super.dragStart,
    super.dragEnd,
    super.closePercentage,
  });

  @override
  void handleDragUpdate(DragUpdateDetails details) {
    final primaryDelta = details.primaryDelta;
    if (canDragDone || primaryDelta == null) {
      return;
    }

    animationController.value += primaryDelta / (obtainChildHeight());
  }
}
