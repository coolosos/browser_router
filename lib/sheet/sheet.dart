library;

import 'package:flutter/foundation.dart';
import 'package:flutter/gestures.dart';
import 'package:flutter/widgets.dart';

import '../browser.dart';

export 'modal_base_header.dart';
export 'modal_base_params.dart';

part 'sheet_base.dart';
part 'modal_base.dart';
part 'browser_bottom_sheet.dart';
part 'browser_center_sheet.dart';
part 'browser_full_sheet.dart';
part 'browser_responsive_sheet.dart';

class Sheet extends StatelessWidget {
  const new({super.key});

  static const sheetPath = 'sheet';

  @override
  Widget build(BuildContext context) {
    final params = context.getArgument<SheetRouteParams>();
    if (params != null) {
      return params.child;
    }
    return const SizedBox.shrink();
  }

  static BrowserRoute get route => const BrowserRoute(
    path: sheetPath,
    page: Sheet(),
    routeTransition: RouteTransition.none,
  );

  /// Opens a platform-adaptive draggable bottom sheet ([BrowserBottomSheet]).
  static Future<T?> bottom<T>(
    BuildContext context,
    ModalBase<ModalDraggableScrollableSheetParams> modal, {
    TraceRoute? traceRoute,
  }) => BrowserBottomSheet.show<T>(context, modal, traceRoute: traceRoute);

  /// Opens a centered modal dialog sheet ([BrowserCenterSheet]).
  static Future<T?> center<T>(
    BuildContext context,
    ModalBase<ModalCenterParams> modal, {
    TraceRoute? traceRoute,
  }) => BrowserCenterSheet.show<T>(context, modal, traceRoute: traceRoute);

  /// Opens a full-screen modal viewport ([BrowserFullSheet]).
  static Future<T?> full<T>(
    BuildContext context,
    ModalBase<ModalDraggableScrollableSheetParams> modal, {
    TraceRoute? traceRoute,
  }) => BrowserFullSheet.show<T>(context, modal, traceRoute: traceRoute);

  /// Opens a responsive sheet ([BrowserResponsiveSheet]) switching between
  /// bottom sheet and center dialog based on available width.
  static Future<T?> responsive<T>(
    BuildContext context,
    ModalBase<ModalCenterParams> modal, {
    double breakpoint = 600,
    EdgeInsets? bodyPaddingOverride,
    BorderRadiusGeometry? borderRadiusOverride,
    TraceRoute? traceRoute,
  }) => BrowserResponsiveSheet.show<T>(
    context,
    modal,
    breakpoint: breakpoint,
    bodyPaddingOverride: bodyPaddingOverride,
    borderRadiusOverride: borderRadiusOverride,
    traceRoute: traceRoute,
  );

  /// Generic helper to display any custom widget inside a popup sheet route.
  static Future<void> show(BuildContext context, Widget child) async {
    await Trace(
      path: sheetPath,
      traceRoute: TraceRoute.popup(),
      args: SheetRouteParams(child: child),
    ).push(context);
  }
}

final class SheetRouteParams extends RouteParams {
  new({required this.child});

  final Widget child;
}
