import 'package:flutter/foundation.dart';
import 'package:flutter/widgets.dart';

class ModalBaseHeaderParameter {
  ModalBaseHeaderParameter({
    required this.background,
    required this.headerBackground,
    required this.dragBar,
    required this.closeIcon,
    this.closeIconColor,
    this.title,
  });

  final Color background;
  final Color headerBackground;
  final Color dragBar;
  final Color? closeIconColor;
  final Widget? title;
  final Widget closeIcon;
}

abstract class ModalBaseHeader extends SliverPersistentHeaderDelegate {
  ModalBaseHeader({
    required this.parameters,
    required this.shouldCloseOnMinExtent,
    required this.snap,
    required this.border,
  });

  @override
  double get maxExtent => (!kIsWeb && snap)
      ? 57
      : (parameters.title != null)
          ? 57
          : 27;

  @override
  double get minExtent => (!kIsWeb && snap)
      ? 57
      : (parameters.title != null)
          ? 57
          : 27;

  @override
  bool shouldRebuild(covariant SliverPersistentHeaderDelegate oldDelegate) =>
      false;

  final bool shouldCloseOnMinExtent;
  final bool snap;
  final ModalBaseHeaderParameter parameters;
  final BorderRadiusGeometry? border;

  @override
  Widget build(
    BuildContext context,
    double shrinkOffset,
    bool overlapsContent,
  );
}
