part of 'overlay_manager.dart';

const double kAppbarHeight = 40;

class Banner extends OverlayModal {
  new({
    required super.content,
    required super.duration,
    required super.transition,
    required super.overlayState,
    this.topPadding = kAppbarHeight,
    this.maxWidth,
    this.margin,
    this.dismissDirection = DismissDirection.up,
  });

  factory fromContext({
    required BuildContext context,
    required ContentBuilder content,
    required OverlayTraceRoute transition,
    Duration? duration,
    double? topPadding,
    double? maxWidth,
    EdgeInsetsGeometry? margin,
    DismissDirection dismissDirection = DismissDirection.up,
  }) {
    return Banner(
      content: content,
      duration: duration,
      transition: transition,
      overlayState: Overlay.of(context),
      topPadding: topPadding ?? kAppbarHeight,
      maxWidth: maxWidth,
      margin: margin,
      dismissDirection: dismissDirection,
    );
  }

  final double topPadding;
  final double? maxWidth;
  final EdgeInsetsGeometry? margin;
  final DismissDirection dismissDirection;

  @override
  OverlayEntry _createModal(Widget child) {
    return OverlayEntry(
      builder: (context) {
        return SafeArea(
          top: true,
          bottom: false,
          child: Padding(
            padding: EdgeInsets.only(top: topPadding),
            child: Align(
              alignment: Alignment.topCenter,
              child: Dismissible(
                onDismissed: (direction) {
                  remove();
                },
                key: UniqueKey(),
                direction: dismissDirection,
                child: Padding(
                  padding: margin ?? EdgeInsets.zero,
                  child: maxWidth != null
                      ? ConstrainedBox(
                          constraints: BoxConstraints(maxWidth: maxWidth!),
                          child: child,
                        )
                      : child,
                ),
              ),
            ),
          ),
        );
      },
    );
  }
}
