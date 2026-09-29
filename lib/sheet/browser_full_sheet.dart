part of 'sheet.dart';

/// Collision-safe alias for [BrowserFullSheet].
typedef ModalFullSheet = BrowserFullSheet;

/// Full-screen modal sheet presenting a scrollable view spanning the entire viewport.
final class BrowserFullSheet
    extends SheetBase<ModalDraggableScrollableSheetParams> {
  const new({required super.modal, this.bodyPaddingOverride, super.key});

  /// Optional override for the body padding.
  final EdgeInsets? bodyPaddingOverride;

  /// Convenience helper to push this full-screen sheet to the navigator stack.
  static Future<T?> show<T>(
    BuildContext context,
    ModalBase<ModalDraggableScrollableSheetParams> modal, {
    TraceRoute? traceRoute,
  }) {
    return Trace(
      path: Sheet.sheetPath,
      traceRoute: traceRoute ?? TraceRoute.popup(),
      args: SheetRouteParams(child: BrowserFullSheet(modal: modal)),
    ).push(context).then((value) => value as T?);
  }

  @override
  EdgeInsets get bodyPadding => bodyPaddingOverride ?? super.bodyPadding;

  @override
  void adjustSize({
    required double? extentTotal,
    required double? extentInside,
    required ScrollController? customScrollViewController,
    required DraggableScrollableController? draggableController,
  }) {}

  @override
  Widget sheetCase({
    required BuildContext context,
    required ScrollableBuilder build,
    required DraggableScrollableController draggableController,
  }) {
    return build(context, null);
  }

  @override
  BorderRadiusGeometry? get borderRadius => null;
}
