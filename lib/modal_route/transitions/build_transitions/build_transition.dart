import 'package:flutter/widgets.dart';

abstract interface class BuildTransition {
  Widget call({
    required Animation<double> animation,
    required Animation<double> secondaryAnimation,
    required Widget child,
  });
}
