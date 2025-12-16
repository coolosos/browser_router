part of 'overlay_manager.dart';

const double kAppbarHeight = 40;

class Banner extends OverlayModal {
  Banner({
    required super.content,
    required super.duration,
    required super.transition,
    required super.overlayState,
    this.topPadding = kAppbarHeight,
  });

  factory Banner.fromContext({
    required BuildContext context,
    required ContentBuilder content,
    required OverlayTraceRoute transition,
    Duration? duration,
    double? topPadding,
  }) {
    return Banner(
      content: content,
      duration: duration,
      transition: transition,
      overlayState: Overlay.of(context),
      topPadding: topPadding ?? kAppbarHeight,
    );
  }

  final double topPadding;

  @override
  OverlayEntry _createModal(Widget child) {
    return OverlayEntry(
      builder: (BuildContext context) {
        return SafeArea(
          child: Padding(
            padding: EdgeInsets.only(top: topPadding),
            child: Align(
              alignment: Alignment.topCenter,
              child: Dismissible(
                onDismissed: (direction) {
                  // animationController?.reverse();
                  remove();
                },
                key: UniqueKey(),
                direction: DismissDirection.up,
                child: child,
              ),
            ),
          ),
        );
      },
    );
  }
}
