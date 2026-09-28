part of 'sheet.dart';

/// Collision-safe alias for [BrowserCenterSheet].
typedef ModalCenterSheet = BrowserCenterSheet;

/// Centered modal dialog sheet tailored for desktop, web, and tablet form factors.
///
/// Wraps content in a constrained box, absorbs vertical drag gestures to prevent
/// interfering with dialog scrolling, and applies fully rounded corners.
final class BrowserCenterSheet extends SheetBase<ModalCenterParams> {
  const new({
    required super.modal,
    this.bodyPaddingOverride,
    this.borderRadiusOverride,
    super.key,
  });

  /// Optional override for the body padding.
  final EdgeInsets? bodyPaddingOverride;

  /// Optional override for the border radius. Defaults to 16 circular radius.
  final BorderRadiusGeometry? borderRadiusOverride;

  /// Convenience helper to push this centered sheet to the navigator stack.
  static Future<T?> show<T>(
    BuildContext context,
    ModalBase<ModalCenterParams> modal, {
    TraceRoute? traceRoute,
  }) {
    return Trace(
      path: Sheet.sheetPath,
      traceRoute: traceRoute ?? TraceRoute.popup(),
      args: SheetRouteParams(child: BrowserCenterSheet(modal: modal)),
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
    final sheet = Center(
      child: ConstrainedBox(
        constraints: modal.params.constraints,
        child: DraggableScrollableSheet(
          controller: draggableController,
          expand: false,
          snap: modal.params.snap,
          shouldCloseOnMinExtent: modal.params.shouldCloseOnMinExtent,
          snapAnimationDuration: modal.params.snapAnimationDuration,
          snapSizes: modal.params.snapSizes,
          builder: (context, customScrollViewController) {
            WidgetsBinding.instance.addPostFrameCallback((_) {
              adjustSize(
                extentInside: customScrollViewController.position.extentInside,
                extentTotal: customScrollViewController.position.extentTotal,
                customScrollViewController: customScrollViewController,
                draggableController: draggableController,
              );
            });
            return build(context, customScrollViewController);
          },
        ),
      ),
    );

    return GestureDetector(
      onVerticalDragDown: (details) {},
      dragStartBehavior: DragStartBehavior.down,
      child: sheet,
    );
  }

  @override
  BorderRadiusGeometry? get borderRadius =>
      borderRadiusOverride ?? const BorderRadius.all(Radius.circular(16));
}
