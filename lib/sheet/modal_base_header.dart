import 'package:flutter/foundation.dart';
import 'package:flutter/widgets.dart';

final class ModalBaseHeaderParameter {
  const new({
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
  const new({
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
  Widget build(BuildContext context, double shrinkOffset, bool overlapsContent);
}

/// An empty header delegate with zero extent for modals without headers.
final class EmptyHeader extends ModalBaseHeader {
  const new({
    required super.parameters,
    required super.shouldCloseOnMinExtent,
    required super.snap,
    required super.border,
  });

  @override
  double get maxExtent => 0;

  @override
  double get minExtent => 0;

  @override
  Widget build(
    BuildContext context,
    double shrinkOffset,
    bool overlapsContent,
  ) {
    return const SizedBox.shrink();
  }
}

/// Standard modal header with a drag handle (pill), title, close button, and dynamic scroll shadow.
class ModalHeader extends ModalBaseHeader {
  const new({
    required super.parameters,
    required super.shouldCloseOnMinExtent,
    required super.snap,
    required super.border,
    this.showCloseIcon = true,
    this.showDragBar,
  });

  final bool showCloseIcon;
  final bool? showDragBar;

  bool get _effectiveShowDragBar => showDragBar ?? (!kIsWeb && snap);

  @override
  double get maxExtent => _effectiveShowDragBar
      ? 72
      : (parameters.title != null)
      ? 60
      : 48;

  @override
  double get minExtent => _effectiveShowDragBar
      ? 57
      : (parameters.title != null)
      ? 57
      : 48;

  @override
  bool shouldRebuild(covariant ModalHeader oldDelegate) =>
      oldDelegate.parameters != parameters ||
      oldDelegate.showCloseIcon != showCloseIcon ||
      oldDelegate.showDragBar != showDragBar ||
      oldDelegate.border != border ||
      oldDelegate.snap != snap ||
      oldDelegate.shouldCloseOnMinExtent != shouldCloseOnMinExtent;

  @override
  Widget build(
    BuildContext context,
    double shrinkOffset,
    bool overlapsContent,
  ) {
    final hasShadow = shrinkOffset > 0;
    final topBorderRadius = switch (border) {
      final BorderRadius r => BorderRadius.only(
        topLeft: r.topLeft,
        topRight: r.topRight,
      ),
      _ => const BorderRadius.only(
        topLeft: Radius.circular(16),
        topRight: Radius.circular(16),
      ),
    };

    return DecoratedBox(
      decoration: BoxDecoration(
        borderRadius: topBorderRadius,
        color: parameters.headerBackground,
        border: hasShadow
            ? const Border(
                bottom: BorderSide(color: Color(0xFFE0E0E0), width: 1),
              )
            : null,
        boxShadow: hasShadow
            ? const [
                BoxShadow(
                  color: Color(0x1A000000),
                  blurRadius: 4,
                  offset: Offset(0, 2),
                ),
              ]
            : null,
      ),
      child: Column(
        mainAxisSize: MainAxisSize.max,
        mainAxisAlignment: (parameters.title != null)
            ? MainAxisAlignment.center
            : MainAxisAlignment.end,
        children: [
          if (_effectiveShowDragBar)
            Padding(
              padding: const EdgeInsets.only(top: 8, bottom: 2),
              child: Container(
                width: 44,
                height: 4,
                decoration: ShapeDecoration(
                  color: parameters.dragBar,
                  shape: const RoundedRectangleBorder(
                    borderRadius: BorderRadius.all(Radius.circular(100)),
                  ),
                ),
              ),
            ),
          if (parameters.title != null)
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
              child: Row(
                children: [
                  Expanded(
                    child: Padding(
                      padding: EdgeInsets.only(
                        left: (showCloseIcon && shouldCloseOnMinExtent)
                            ? 36
                            : 0,
                      ),
                      child: Align(
                        alignment: Alignment.center,
                        child: parameters.title,
                      ),
                    ),
                  ),
                  if (shouldCloseOnMinExtent && showCloseIcon)
                    GestureDetector(
                      behavior: HitTestBehavior.opaque,
                      onTap: () => Navigator.of(context).maybePop(),
                      child: Padding(
                        padding: const EdgeInsets.all(6),
                        child: parameters.closeIcon,
                      ),
                    ),
                ],
              ),
            )
          else if (showCloseIcon && shouldCloseOnMinExtent)
            Padding(
              padding: const EdgeInsets.only(right: 8, top: 4, bottom: 4),
              child: Align(
                alignment: Alignment.centerRight,
                child: GestureDetector(
                  behavior: HitTestBehavior.opaque,
                  onTap: () => Navigator.of(context).maybePop(),
                  child: Padding(
                    padding: const EdgeInsets.all(6),
                    child: parameters.closeIcon,
                  ),
                ),
              ),
            ),
        ],
      ),
    );
  }
}
