import 'package:flutter/widgets.dart';

enum SharedAxisDirection {
  horizontal,
  vertical,
  scaled,
}

/// Material 3 Shared Axis Transition.
///
/// Implements directional motion along the X (horizontal), Y (vertical), or Z (scaled) axis.
class SharedAxis extends StatelessWidget {
  new({
    required this.animation,
    required this.secondaryAnimation,
    required this.child,
    this.direction = SharedAxisDirection.horizontal,
    super.key,
  })  : _primaryOpacity = CurvedAnimation(
          parent: animation,
          curve: const Interval(0.1, 1, curve: Curves.fastEaseInToSlowEaseOut),
        ),
        _secondaryOpacity = Tween<double>(begin: 1, end: 0).animate(
          CurvedAnimation(
            parent: secondaryAnimation,
            curve: const Interval(0, 0.4, curve: Curves.fastEaseInToSlowEaseOut),
          ),
        );

  final Animation<double> animation;
  final Animation<double> secondaryAnimation;
  final Widget child;
  final SharedAxisDirection direction;

  final Animation<double> _primaryOpacity;
  final Animation<double> _secondaryOpacity;

  @override
  Widget build(BuildContext context) {
    return switch (direction) {
      SharedAxisDirection.horizontal => _buildHorizontal(context),
      SharedAxisDirection.vertical => _buildVertical(context),
      SharedAxisDirection.scaled => _buildScaled(context),
    };
  }

  Widget _buildHorizontal(BuildContext context) {
    final textDirection = Directionality.of(context);
    final isRtl = textDirection == TextDirection.rtl;

    final primaryOffset = Tween<Offset>(
      begin: Offset(isRtl ? -0.3 : 0.3, 0),
      end: Offset.zero,
    ).animate(
      CurvedAnimation(
        parent: animation,
        curve: Curves.fastEaseInToSlowEaseOut,
        reverseCurve: Curves.fastEaseInToSlowEaseOut.flipped,
      ),
    );

    final secondaryOffset = Tween<Offset>(
      begin: Offset.zero,
      end: Offset(isRtl ? 0.3 : -0.3, 0),
    ).animate(
      CurvedAnimation(
        parent: secondaryAnimation,
        curve: Curves.fastEaseInToSlowEaseOut,
        reverseCurve: Curves.fastEaseInToSlowEaseOut.flipped,
      ),
    );

    return SlideTransition(
      position: secondaryOffset,
      child: FadeTransition(
        opacity: _secondaryOpacity,
        child: SlideTransition(
          position: primaryOffset,
          child: FadeTransition(
            opacity: _primaryOpacity,
            child: child,
          ),
        ),
      ),
    );
  }

  Widget _buildVertical(BuildContext context) {
    final primaryOffset = Tween<Offset>(
      begin: const Offset(0, 0.3),
      end: Offset.zero,
    ).animate(
      CurvedAnimation(
        parent: animation,
        curve: Curves.fastEaseInToSlowEaseOut,
        reverseCurve: Curves.fastEaseInToSlowEaseOut.flipped,
      ),
    );

    final secondaryOffset = Tween<Offset>(
      begin: Offset.zero,
      end: const Offset(0, -0.3),
    ).animate(
      CurvedAnimation(
        parent: secondaryAnimation,
        curve: Curves.fastEaseInToSlowEaseOut,
        reverseCurve: Curves.fastEaseInToSlowEaseOut.flipped,
      ),
    );

    return SlideTransition(
      position: secondaryOffset,
      child: FadeTransition(
        opacity: _secondaryOpacity,
        child: SlideTransition(
          position: primaryOffset,
          child: FadeTransition(
            opacity: _primaryOpacity,
            child: child,
          ),
        ),
      ),
    );
  }

  Widget _buildScaled(BuildContext context) {
    final primaryScale = Tween<double>(begin: 0.8, end: 1).animate(
      CurvedAnimation(
        parent: animation,
        curve: Curves.fastEaseInToSlowEaseOut,
        reverseCurve: Curves.fastEaseInToSlowEaseOut.flipped,
      ),
    );

    final secondaryScale = Tween<double>(begin: 1, end: 1.1).animate(
      CurvedAnimation(
        parent: secondaryAnimation,
        curve: Curves.fastEaseInToSlowEaseOut,
        reverseCurve: Curves.fastEaseInToSlowEaseOut.flipped,
      ),
    );

    return ScaleTransition(
      scale: secondaryScale,
      child: FadeTransition(
        opacity: _secondaryOpacity,
        child: ScaleTransition(
          scale: primaryScale,
          child: FadeTransition(
            opacity: _primaryOpacity,
            child: child,
          ),
        ),
      ),
    );
  }
}
