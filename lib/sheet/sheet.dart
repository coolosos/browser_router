library;

import 'package:flutter/widgets.dart';

import '../browser.dart';

export 'modal_base_header.dart';
export 'modal_base_params.dart';

part 'sheet_base.dart';
part 'modal_base.dart';

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

  static Future<void> show(
    BuildContext context,
    Widget child,
  ) async {
    await Trace(
      path: sheetPath,
      traceRoute: TraceRoute.popup(),
      args: SheetRouteParams(child: child),
    ).push(context);
  }
}

final class SheetRouteParams extends RouteParams {
  new({
    required this.child,
  });

  final Widget child;
}
