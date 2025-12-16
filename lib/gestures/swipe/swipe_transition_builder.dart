part of 'swipe.dart';

class SwipeChildLayoutDelegate extends SingleChildLayoutDelegate {
  SwipeChildLayoutDelegate(
    this.progress,
    this.screenPercentaje,
    this.direction,
  );

  final double progress;
  final double screenPercentaje;
  final AxisDirection direction;

  @override
  BoxConstraints getConstraintsForChild(BoxConstraints constraints) {
    final maxHeight = constraints.maxHeight * screenPercentaje;
    return BoxConstraints(
      minWidth: constraints.maxWidth,
      maxWidth: constraints.maxWidth,
      maxHeight: maxHeight,
    );
  }

  @override
  Offset getPositionForChild(Size size, Size childSize) {
    switch (direction) {
      case AxisDirection.up:
        return Offset(0, size.height - childSize.height * progress);
      case AxisDirection.down:
        return Offset(
          0,
          size.height - (progress == 0 ? size.height : childSize.height),
        );
      case AxisDirection.right:
        return Offset(
          (childSize.width * progress) - size.width,
          size.height - childSize.height,
        );
      case AxisDirection.left:
        return Offset(
          size.width - childSize.width * progress,
          size.height - childSize.height,
        );
    }
  }

  @override
  bool shouldRelayout(SwipeChildLayoutDelegate oldDelegate) {
    return progress != oldDelegate.progress;
  }
}
