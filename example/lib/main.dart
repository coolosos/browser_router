import 'dart:developer';

import 'package:browser_example/routes.dart';
import 'package:browser_router/browser.dart';
import 'package:flutter/widgets.dart';

void main() {
  runApp(const MyApp());
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    return Browser(
      routes: routes,
      defaultRoute: routes.first,
      openUrl: (uri) async {
        log(uri.toString());
      },
      builder: (context, routeObserver, generate) {
        return WidgetsApp(
          color: const Color(0xFFFFFFFF),
          navigatorObservers: [routeObserver],
          onGenerateRoute: generate,
          onGenerateInitialRoutes: (routePath) => [
            generate(
              RouteSettings(name: routePath, arguments: Map.from({})),
            ),
          ],
        );
      },
    );
  }
}
