import 'package:flutter/widgets.dart';

/// Authentic iOS-style Cupertino full-page slide transition.
///
/// Features a native right-to-left slide with a vertical gradient shadow on the
/// leading edge, and 1/3 horizontal parallax on the exiting route.
class SlideCupertino extends StatelessWidget {
  new({
    required this.animation,
    required this.secondaryAnimation,
    required this.child,
    this.hasShadow = true,
    super.key,
  })  : _primaryPosition = Tween<Offset>(
          begin: const Offset(1, 0),
          end: Offset.zero,
        ).animate(
          CurvedAnimation(
            parent: animation,
            curve: Curves.fastEaseInToSlowEaseOut,
            reverseCurve: Curves.fastEaseInToSlowEaseOut.flipped,
          ),
        ),
        _secondaryPosition = Tween<Offset>(
          begin: Offset.zero,
          end: const Offset(-1 / 3, 0),
        ).animate(
          CurvedAnimation(
            parent: secondaryAnimation,
            curve: Curves.linearToEaseOut,
            reverseCurve: Curves.easeInToLinear,
          ),
        );

  final Animation<double> animation;
  final Animation<double> secondaryAnimation;
  final Widget child;
  final bool hasShadow;

  final Animation<Offset> _primaryPosition;
  final Animation<Offset> _secondaryPosition;

  @override
  Widget build(BuildContext context) {
    final textDirection = Directionality.of(context);

    var content = child;
    if (hasShadow) {
      content = DecoratedBox(
        position: DecorationPosition.background,
        decoration: const BoxDecoration(
          boxShadow: <BoxShadow>[
            BoxShadow(
              color: Color(0x26000000),
              blurRadius: 16,
              spreadRadius: 2,
              offset: Offset(-4, 0),
            ),
          ],
        ),
        child: content,
      );
    }

    return SlideTransition(
      position: _secondaryPosition,
      textDirection: textDirection,
      transformHitTests: false,
      child: SlideTransition(
        position: _primaryPosition,
        textDirection: textDirection,
        child: content,
      ),
    );
  }
}
