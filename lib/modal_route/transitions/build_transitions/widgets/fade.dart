import 'package:flutter/widgets.dart';

class Fade extends StatelessWidget {
  const Fade({
    required this.animation,
    required this.child,
    super.key,
  });

  final Animation<double> animation;
  final Widget child;

  @override
  Widget build(BuildContext context) {
    final curvedAnimation = CurvedAnimation(
      parent: animation,
      curve: Curves.easeIn,
      reverseCurve: Curves.easeIn,
    );
    return FadeTransition(
      opacity: curvedAnimation,
      child: child,
    );
  }
}
