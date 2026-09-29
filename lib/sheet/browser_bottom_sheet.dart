part of 'sheet.dart';

/// Collision-safe alias for [BrowserBottomSheet].
typedef ModalBottomSheet = BrowserBottomSheet;

/// Concrete bottom sheet implementation with automatic content size adjustment
/// and native swipe-to-dismiss behavior.
final class BrowserBottomSheet
    extends SheetBase<ModalDraggableScrollableSheetParams> {
  const new({required super.modal, this.borderRadiusOverride, super.key});

  /// Optional override for the top border radius.
  /// Defaults to `BorderRadius.vertical(top: Radius.circular(24))`.
  final BorderRadiusGeometry? borderRadiusOverride;

  /// Convenience helper to push this bottom sheet to the navigator stack.
  static Future<T?> show<T>(
    BuildContext context,
    ModalBase<ModalDraggableScrollableSheetParams> modal, {
    TraceRoute? traceRoute,
  }) {
    return Trace(
      path: Sheet.sheetPath,
      traceRoute: traceRoute ?? TraceRoute.swipe(),
      args: SheetRouteParams(child: BrowserBottomSheet(modal: modal)),
    ).push(context).then((value) => value as T?);
  }

  @override
  void adjustSize({
    required double? extentTotal,
    required double? extentInside,
    required ScrollController? customScrollViewController,
    required DraggableScrollableController? draggableController,
  }) {
    if (draggableController == null || !draggableController.isAttached) {
      return;
    }
    if (customScrollViewController == null ||
        !customScrollViewController.hasClients) {
      return;
    }
    if (extentInside == null || extentInside <= 0) {
      return;
    }
    if (extentTotal == null || extentTotal <= 0) {
      return;
    }

    final currentSize = draggableController.size;
    final targetSize = currentSize * extentTotal / extentInside;
    if (targetSize.isNaN || targetSize.isInfinite) {
      return;
    }

    final min = modal.params.minHeightChildSize;
    final max = modal.params.maxHeightChildSize;
    final newSize = targetSize.clamp(min, max);

    if ((newSize - currentSize).abs() > 0.005 &&
        (customScrollViewController.position.extentAfter != 0 ||
            customScrollViewController.position.extentBefore != 0)) {
      draggableController.animateTo(
        newSize,
        curve: Curves.linear,
        duration:
            modal.params.snapAnimationDuration ??
            const Duration(milliseconds: 300),
      );
    }
  }

  @override
  Widget sheetCase({
    required BuildContext context,
    required ScrollableBuilder build,
    required DraggableScrollableController draggableController,
  }) {
    return DraggableScrollableSheet(
      controller: draggableController,
      initialChildSize: modal.params.initialHeightChildSize,
      minChildSize: modal.params.minHeightChildSize,
      maxChildSize: modal.params.maxHeightChildSize,
      expand: modal.params.expand,
      snap: modal.params.snap,
      shouldCloseOnMinExtent: modal.params.shouldCloseOnMinExtent,
      snapAnimationDuration: modal.params.snapAnimationDuration,
      snapSizes: modal.params.snapSizes,
      builder: (context, customScrollViewController) {
        if (customScrollViewController.hasClients) {
          WidgetsBinding.instance.addPostFrameCallback((_) {
            adjustSize(
              extentInside: customScrollViewController.position.extentInside,
              extentTotal: customScrollViewController.position.extentTotal,
              customScrollViewController: customScrollViewController,
              draggableController: draggableController,
            );
          });
        }
        return build(context, customScrollViewController);
      },
    );
  }

  @override
  BorderRadiusGeometry? get borderRadius =>
      borderRadiusOverride ??
      const BorderRadius.vertical(top: Radius.circular(24));
}
