part of 'swipe.dart';

final class SwipeChildLayoutDelegate extends SingleChildLayoutDelegate {
  const new(
    this.progress,
    this.screenPercentage,
    this.direction,
  );

  final double progress;
  final double screenPercentage;
  final AxisDirection direction;

  @override
  BoxConstraints getConstraintsForChild(BoxConstraints constraints) {
    final maxHeight = constraints.maxHeight * screenPercentage;
    return BoxConstraints(
      minWidth: constraints.maxWidth,
      maxWidth: constraints.maxWidth,
      maxHeight: maxHeight,
    );
  }

  @override
  Offset getPositionForChild(Size size, Size childSize) => switch (direction) {
        AxisDirection.up =>
          Offset(0, size.height - childSize.height * progress),
        AxisDirection.down => Offset(
            0,
            size.height - (progress == 0 ? size.height : childSize.height),
          ),
        AxisDirection.right => Offset(
            (childSize.width * progress) - size.width,
            size.height - childSize.height,
          ),
        AxisDirection.left => Offset(
            size.width - childSize.width * progress,
            size.height - childSize.height,
          ),
      };

  @override
  bool shouldRelayout(SwipeChildLayoutDelegate oldDelegate) {
    return progress != oldDelegate.progress ||
        screenPercentage != oldDelegate.screenPercentage ||
        direction != oldDelegate.direction;
  }
}
