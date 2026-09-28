part of 'sheet.dart';

/// Collision-safe alias for [BrowserResponsiveSheet].
typedef ModalResponsiveSheet = BrowserResponsiveSheet;

/// Adaptive sheet that automatically renders [BrowserBottomSheet] on compact
/// screens (width < [breakpoint]) and [BrowserCenterSheet] on wide/desktop screens.
final class BrowserResponsiveSheet extends StatelessWidget {
  const new({
    required this.modal,
    this.breakpoint = 600,
    this.bodyPaddingOverride,
    this.borderRadiusOverride,
    super.key,
  });

  /// The modal definition providing content, headers, and parameters.
  final ModalBase<ModalCenterParams> modal;

  /// The width threshold separating bottom sheet presentation from center dialog.
  /// Defaults to `600`.
  final double breakpoint;

  /// Optional override for the body padding.
  final EdgeInsets? bodyPaddingOverride;

  /// Optional override for the border radius.
  final BorderRadiusGeometry? borderRadiusOverride;

  /// Convenience helper to push this responsive sheet to the navigator stack.
  static Future<T?> show<T>(
    BuildContext context,
    ModalBase<ModalCenterParams> modal, {
    double breakpoint = 600,
    EdgeInsets? bodyPaddingOverride,
    BorderRadiusGeometry? borderRadiusOverride,
    TraceRoute? traceRoute,
  }) {
    return Trace(
      path: Sheet.sheetPath,
      traceRoute: traceRoute ?? TraceRoute.swipe(),
      args: SheetRouteParams(
        child: BrowserResponsiveSheet(
          modal: modal,
          breakpoint: breakpoint,
          bodyPaddingOverride: bodyPaddingOverride,
          borderRadiusOverride: borderRadiusOverride,
        ),
      ),
    ).push(context).then((value) => value as T?);
  }

  @override
  Widget build(BuildContext context) {
    return LayoutBuilder(
      builder: (context, constraints) {
        if (constraints.maxWidth < breakpoint) {
          return BrowserBottomSheet(
            modal: modal,
            borderRadiusOverride: borderRadiusOverride,
          );
        }
        return BrowserCenterSheet(
          modal: modal,
          bodyPaddingOverride: bodyPaddingOverride,
          borderRadiusOverride: borderRadiusOverride,
        );
      },
    );
  }
}
