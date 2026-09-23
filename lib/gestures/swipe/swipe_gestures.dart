part of 'swipe.dart';

abstract base class SwipeGestures {
  new({
    required this.obtainSize,
    required this.animationController,
    required this.canDragDone,
    required this.onClosing,
    this.dragStart,
    this.dragEnd,
    this.closePercentage = 0.5,
  });

  final void Function(DragStartDetails)? dragStart;
  final void Function(DragEndDetails)? dragEnd;
  final double Function() obtainSize;
  final AnimationController animationController;
  final bool Function() canDragDone;
  final VoidCallback onClosing;
  final double closePercentage;

  // final ValueNotifier<bool> isDragging = ValueNotifier<bool>(false);

  void handleDragStart(DragStartDetails details) {
    // isDragging.value = true;
    dragStart?.call(details);
  }

  void handleDragEnd(DragEndDetails details) {
    // isDragging.value = false;
    if (canDragDone()) {
      return;
    }

    final velocity = details.primaryVelocity;
    final bool willPop;
    if (velocity != null && velocity.abs() >= _kMinFlingVelocity) {
      willPop = velocity < 0; //Negative for pop Left
    } else {
      willPop = animationController.value <= closePercentage;
    }

    if (willPop) {
      if (animationController.value < 1.0) {
        animationController.fling(velocity: -1);
      }
      onClosing.call();
    } else {
      animationController.forward();
    }
    dragEnd?.call(details);
  }

  void handleDragUpdate(DragUpdateDetails details);
}

const double _kMinFlingVelocity = 1;

final class SwipeDownRightGestures extends SwipeGestures {
  new({
    required super.obtainSize,
    required super.animationController,
    required super.canDragDone,
    required super.onClosing,
    super.dragStart,
    super.dragEnd,
    super.closePercentage,
  });

  @override
  void handleDragUpdate(DragUpdateDetails details) {
    if (canDragDone()) {
      return;
    }

    final delta = details.primaryDelta;
    if (delta == null) {
      return;
    }
    final size = obtainSize();
    if (size <= 0) {
      return;
    }

    if (delta > 0 || animationController.value > 0) {
      animationController.value =
          (animationController.value - delta / size).clamp(0.0, 1.0);
    }
  }

  @override
  void handleDragEnd(DragEndDetails details) {
    // isDragging.value = false;
    if (canDragDone()) {
      return;
    }

    final velocity = details.primaryVelocity;
    final bool willPop;
    if (velocity != null && velocity.abs() >= _kMinFlingVelocity) {
      willPop = velocity > 0; // Positive for pop right
    } else {
      willPop = animationController.value <= closePercentage;
    }

    if (willPop) {
      if (animationController.value < 1.0) {
        animationController.fling(velocity: -1);
      }
      onClosing.call();
    } else {
      animationController.forward();
    }
    dragEnd?.call(details);
  }
}

final class SwipeUpLeftGestures extends SwipeGestures {
  new({
    required super.obtainSize,
    required super.animationController,
    required super.canDragDone,
    required super.onClosing,
    super.dragStart,
    super.dragEnd,
    super.closePercentage,
  });

  @override
  void handleDragUpdate(DragUpdateDetails details) {
    if (canDragDone()) {
      return;
    }

    final delta = details.primaryDelta;
    if (delta == null) {
      return;
    }
    final size = obtainSize();
    if (size <= 0) {
      return;
    }

    if (delta > 0 || animationController.value > 0) {
      animationController.value =
          (animationController.value + delta / size).clamp(0.0, 1.0);
    }
  }
}
