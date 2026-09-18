import 'package:flutter/widgets.dart';

/// Positions
///
/// ![](https://koenig-media.raywenderlich.com/uploads/2021/05/proportional-co-ordinate-system-322x320.jpg)
enum Positions {
  // Offset from offscreen below to fully on screen.

  left(
    primaryOffset: Offset(-1, 0),
    secondaryOffset: Offset(1 / 3, 0),
  ),
  right(
    primaryOffset: Offset(1, 0),
    secondaryOffset: Offset(-1 / 3, 0),
  ),
  //Esto esta seteado a 0, 0 para que las navegaciones no se rompan en las pantallas que se navega sobre ellas.
  //Estaría bien setear en la navegación el secondary del navegador anterior
  // Offset(0, -1 / 3),
  up(
    primaryOffset: Offset(0, 1),
    secondaryOffset: Offset.zero,
  ),
  down(
    primaryOffset: Offset(0, -1),
    secondaryOffset: Offset(0, 1 / 3),
  ),
  ;

  const Positions({
    required this.primaryOffset,
    required this.secondaryOffset,
  });
  final Offset primaryOffset;
  final Offset secondaryOffset;
}

final class Slide extends StatelessWidget {
  Slide({
    required this.primaryRouteAnimation,
    required Animation<double> secondaryRouteAnimation,
    required Positions drive,
    required this.child,
    super.key,
  })  : _drive = drive,
        _primaryPositionAnimation = CurvedAnimation(
          parent: primaryRouteAnimation,
          curve: Curves.fastEaseInToSlowEaseOut,
          reverseCurve: Curves.fastEaseInToSlowEaseOut.flipped,
        ).drive(
          Tween<Offset>(
            begin: drive.primaryOffset,
            end: Offset.zero,
          ),
        ),
        _secondaryPositionAnimation = CurvedAnimation(
          parent: secondaryRouteAnimation,
          curve: Curves.linearToEaseOut,
          reverseCurve: Curves.easeInToLinear,
        ).drive(
          Tween<Offset>(
            begin: Offset.zero,
            end: drive.secondaryOffset,
          ),
        ),
        _scrimAnimation = CurvedAnimation(
          parent: secondaryRouteAnimation,
          curve: Curves.linearToEaseOut,
          reverseCurve: Curves.easeInToLinear,
        ),
        decorationTween = DecorationTween(
          begin: drive == Positions.right
              ? const BoxDecoration(
                  boxShadow: <BoxShadow>[
                    BoxShadow(
                      color: Color(0x33000000),
                      blurRadius: 16,
                      offset: Offset(-4, 0),
                    ),
                  ],
                )
              : drive == Positions.left
                  ? const BoxDecoration(
                      boxShadow: <BoxShadow>[
                        BoxShadow(
                          color: Color(0x33000000),
                          blurRadius: 16,
                          offset: Offset(4, 0),
                        ),
                      ],
                    )
                  : const BoxDecoration(),
          end: const BoxDecoration(),
        );

  final Positions _drive;
  final Animation<double> primaryRouteAnimation;

  // When this page is coming in to cover another page.
  final Animation<Offset> _primaryPositionAnimation;
  // When this page is becoming covered by another page.
  final Animation<Offset> _secondaryPositionAnimation;
  // Dimming scrim when covered by another page.
  final Animation<double> _scrimAnimation;

  final Widget child;
  final DecorationTween decorationTween;

  @override
  Widget build(BuildContext context) {
    final textDirection = Directionality.of(context);
    final isHorizontal =
        _drive == Positions.right || _drive == Positions.left;

    return SlideTransition(
      position: _secondaryPositionAnimation,
      textDirection: textDirection,
      transformHitTests: false,
      child: Stack(
        fit: StackFit.passthrough,
        children: [
          SlideTransition(
            position: _primaryPositionAnimation,
            textDirection: textDirection,
            child: DecoratedBoxTransition(
              decoration: decorationTween.animate(primaryRouteAnimation),
              child: child,
            ),
          ),
          if (isHorizontal)
            AnimatedBuilder(
              animation: _scrimAnimation,
              builder: (context, child) {
                if (_scrimAnimation.value <= 0) {
                  return const SizedBox.shrink();
                }
                return Positioned.fill(
                  child: IgnorePointer(
                    child: ColoredBox(
                      color: Color.fromRGBO(
                        0,
                        0,
                        0,
                        _scrimAnimation.value * 0.25,
                      ),
                    ),
                  ),
                );
              },
            ),
        ],
      ),
    );
  }
}
