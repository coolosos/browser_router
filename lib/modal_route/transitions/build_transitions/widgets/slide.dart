import 'package:flutter/cupertino.dart';

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
    secondaryOffset: Offset(0, 0),
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

class Slide extends StatelessWidget {
  Slide({
    required this.primaryRouteAnimation,
    required Animation<double> secondaryRouteAnimation,
    required Positions drive,
    required this.child,
    super.key,
  })  : _primaryPositionAnimation = CurvedAnimation(
          // The curves below have been rigorously derived from plots of native
          // iOS animation frames. Specifically, a video was taken of a page
          // transition animation and the distance in each frame that the page
          // moved was measured. A best fit bezier curve was the fitted to the
          // point set, which is linearToEaseIn. Conversely, easeInToLinear is the
          // reflection over the origin of linearToEaseIn.
          parent: primaryRouteAnimation,
          // curve: Curves.linearToEaseOut,
          // reverseCurve: Curves.easeInToLinear,
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
        );
  final Animation<double> primaryRouteAnimation;

  // When this page is coming in to cover another page.
  final Animation<Offset> _primaryPositionAnimation;
  // When this page is becoming covered by another page.
  final Animation<Offset> _secondaryPositionAnimation;

  final Widget child;

  final DecorationTween decorationTween = DecorationTween(
    begin: BoxDecoration(
      color: const Color.fromARGB(0, 255, 255, 255),
      border: Border.all(style: BorderStyle.none),
      borderRadius: BorderRadius.circular(60),
      boxShadow: const <BoxShadow>[
        BoxShadow(
          color: Color(0x66666666),
          blurRadius: 10,
          spreadRadius: 3,
          offset: Offset(0, 6),
        ),
      ],
    ),
    end: BoxDecoration(
      color: const Color.fromARGB(0, 255, 255, 255),
      border: Border.all(
        style: BorderStyle.none,
      ),
      borderRadius: BorderRadius.zero,
      // No shadow.
    ),
  );

  @override
  Widget build(BuildContext context) {
    final textDirection = Directionality.of(context);
    return SlideTransition(
      position: _secondaryPositionAnimation,
      textDirection: textDirection,
      transformHitTests: false,
      child: SlideTransition(
        position: _primaryPositionAnimation,
        textDirection: textDirection,
        child: DecoratedBoxTransition(
          decoration: decorationTween.animate(primaryRouteAnimation),
          child: child,
        ),
      ),
    );
  }
}
