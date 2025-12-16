part of 'overlay_manager.dart';

class Modal extends OverlayModal {
  Modal({
    required super.content,
    required super.transition,
    required super.overlayState,
    required this.backgroundColor,
    super.duration,
    this.alignment = Alignment.center,
    this.isDismissible = true,
    this.useSafeArea = false,
  });

  final Alignment alignment;
  final Color backgroundColor;
  final bool isDismissible;
  final bool useSafeArea;

  @override
  OverlayEntry _createModal(Widget child) {
    final overlay = ColoredBox(
      color: backgroundColor,
      child: Align(
        alignment: Alignment.center,
        child: child,
      ),
    );

    return OverlayEntry(
      builder: (BuildContext context) {
        return GestureDetector(
          onTap: () {
            if (isDismissible) {
              remove();
            }
          },
          child: useSafeArea ? SafeArea(child: overlay) : overlay,
        );
      },
    );
  }
}
