import 'package:browser_example/app_traces.dart';
import 'package:browser_example/deep_screen.dart';
import 'package:browser_example/home_screen.dart';
import 'package:browser_example/intermediate_screen.dart';
import 'package:browser_example/pop_args_screen.dart';
import 'package:browser_example/popup_content_screen.dart';
import 'package:browser_example/push_args_screen.dart';
import 'package:browser_example/to_set_pop_args_screen.dart';
import 'package:browser_router/browser.dart';

final routes = [
  BrowserRoute(
    path: AppPath.home.path,
    page: const HomeScreen(),
    routeTransition: RouteTransition.none,
  ),
  BrowserRoute(
    path: AppPath.pushArgs.path,
    page: const PushArgsScreen(),
    validateArguments: (check, get) {
      // This route can be built from either PushArgs or DeepLinkParam.
      // So, we don't enforce validation here, the screen handles it.
      return true;
    },
  ),
  BrowserRoute(
    path: AppPath.popArgs.path,
    page: const PopArgsScreen(),
  ),
  BrowserRoute(
    path: AppPath.toSetPopArgs.path,
    page: const ToSetPopArgsScreen(),
  ),
  BrowserRoute(
    path: AppPath.popupContent.path,
    page: const PopupContentScreen(),
  ),
  BrowserRoute(
    path: AppPath.intermediate.path,
    page: const IntermediateScreen(),
  ),
  BrowserRoute(
    path: AppPath.deep.path,
    page: const DeepScreen(),
  ),
];
