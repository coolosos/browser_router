# Browser Router - Advanced Navigation for Flutter

[![pub version](https://img.shields.io/pub/v/browser_router.svg)](https://pub.dev/packages/browser_router)
[![License: MIT](https://img.shields.io/badge/license-MIT-blue.svg)](LICENSE)

An advanced, strongly-typed navigation and overlay management system for Flutter, built with zero external UI dependencies on pure `package:flutter/widgets.dart`.

---

## Features

- **Centralized Route Management**: Define all application routes in a single declarative registry.
- **Strongly-Typed Route Arguments**: Pass type-safe arguments using `RouteParams` with built-in validation and polymorphic type resolution.
- **Custom & Adaptive Transitions**: Seamlessly apply transitions (slide, fade, scale, etc.) per route or globally based on platform/path.
- **Versatile Presentation Styles**: Present any screen as a full page, a modal dialog, or a swipeable bottom sheet via `TraceRoute`.
- **Semantic Navigation API**: Create a decoupled, domain-driven navigation layer using `Trace` objects.
- **Reactive Navigation Lifecycle**: Listen to visibility changes (`onAppear`, `onDisappear`) via `Browser.watch`.
- **Atomic Argument Consumption**: Eliminate duplicate event triggers on widget rebuilds with `context.getArgumentAndClean<T>()`.
- **Universal Navigation & Deep Linking**: Automatic URL query parameter extraction to `DeepLinkParam` and versatile URL routing with `context.launchAction()`.
- **Advanced Overlays & Sequential Banners**: Managed banner queues, modal overlays, and bottom sheets decoupled from the navigator stack.
- **Code Splitting & Deferred Loading**: Out-of-the-box support for lazy loading routes with `DeferredBrowserRoute`.
- **Zero UI Framework Dependencies**: 100% decoupled from Material and Cupertino widgets.

---

## Installation

Add `browser_router` to your `pubspec.yaml`:

```yaml
dependencies:
  browser_router: ^0.1.0
```

Then run:

```bash
flutter pub get
```

---

## Getting Started

### 1. Define Routes

Create a list of `BrowserRoute` instances:

```dart
import 'package:browser_router/browser.dart';
import 'package:flutter/widgets.dart';

final routes = [
  BrowserRoute(
    path: '/',
    page: const HomeScreen(),
    routeTransition: RouteTransition.none,
  ),
  BrowserRoute(
    path: '/profile',
    page: const ProfileScreen(),
    routeTransition: RouteTransition.slide_right,
  ),
];
```

### 2. Wrap Your App with `Browser`

Place `Browser` at the root of your application widget hierarchy:

```dart
import 'package:browser_router/browser.dart';
import 'package:flutter/widgets.dart';
import 'routes.dart';

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
      builder: (context, routeObserver, generate) {
        return WidgetsApp(
          color: const Color(0xFFFFFFFF),
          navigatorObservers: [routeObserver],
          onGenerateRoute: generate,
          onGenerateInitialRoutes: (routePath) => [
            generate(
              RouteSettings(name: routePath, arguments: const <dynamic, dynamic>{}),
            ),
          ],
        );
      },
    );
  }
}
```

### 3. Basic Navigation

Navigate using the `BuildContext` extension methods:

```dart
// Push a new route
context.pushNamed('/profile');

// Pop the current route
context.pop();
```

---

## Typed Route Arguments (`RouteParams`)

Pass strongly-typed data between screens safely without casting `dynamic` maps.

### 1. Define an Arguments Class

Subclass `RouteParams` (using `final class` or `base class`):

```dart
import 'package:browser_router/browser.dart';

final class ProfileArgs extends RouteParams {
  const ProfileArgs({required this.userId});

  final String userId;

  @override
  bool validate() => userId.isNotEmpty;
}
```

### 2. Add Route Validation (Optional)

Enforce arguments validation before navigation occurs. If validation fails, `Browser` automatically falls back to `defaultRoute`:

```dart
BrowserRoute(
  path: '/profile',
  page: const ProfileScreen(),
  validateArguments: (check, get) => check<ProfileArgs>(),
)
```

### 3. Push with Arguments

```dart
context.pushNamed(
  '/profile',
  args: [ProfileArgs(userId: 'usr_12345')],
);
```

### 4. Read Arguments in the Target Screen

Use `context.getArgument<T>()` in your `build` method. This read is **idempotent** and safe across multiple widget rebuilds:

```dart
class ProfileScreen extends StatelessWidget {
  const ProfileScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final args = context.getArgument<ProfileArgs>();

    return Center(
      child: Text('User ID: ${args?.userId}'),
    );
  }
}
```

---

## Returning Data & Reactive Lifecycle (`Browser.watch`)

`browser_router` solves the problem of lost return data and unhandled gestures (*swipe-to-dismiss*) by updating the route settings of the underlying screen directly.

### 1. Returning Arguments on Pop

```dart
// Return data directly when popping
context.pop(args: OrderResultArgs(status: 'COMPLETED'));

// Or pop multiple screens to the root and pass arguments
context.popToFirst(args: [OrderResultArgs(status: 'COMPLETED')]);
```

### 2. Staging Arguments for Gesture Dismissals

If a screen can be dismissed via swipe gestures or system back buttons, stage return arguments in `initState` or upon user actions using `setPopArgument`:

```dart
@override
void initState() {
  super.initState();
  WidgetsBinding.instance.addPostFrameCallback((_) {
    context.setPopArgument(DraftSavedArgs(savedAt: DateTime.now()));
  });
}
```

### 3. Consuming Results with `Browser.watch` and `getArgumentAndClean`

Wrap the receiving widget with `Browser.watch`. In `onAppear`, use `context.getArgumentAndClean<T>()` to read and atomically remove the argument:

```dart
class HomeScreen extends StatelessWidget {
  const HomeScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Browser.watch(
      onAppear: (context, deepLink) {
        // Atomic consumption: eliminates repeat execution on rebuilds
        final result = context.getArgumentAndClean<OrderResultArgs>();
        if (result != null) {
          showToast('Order: ${result.status}');
        }
      },
      child: const HomeContent(),
    );
  }
}
```

### `getArgument` vs. `getArgumentAndClean`

| Method | Behavior | Primary Use Case |
| :--- | :--- | :--- |
| `context.getArgument<T>()` | **Reads** the argument without modifying the route map. | Screen construction data (e.g. IDs, configurations). |
| `context.getArgumentAndClean<T>()` | **Reads and removes** the argument from the route map. | One-time events (e.g. pop results, snackbar triggers). |

---

## Semantic Navigation API with `Trace`

Encapsulate routes, arguments, and presentations into reusable domain objects:

```dart
enum AppPath {
  home('/'),
  profile('/profile'),
  productDetail('/product/detail');

  const AppPath(this.path);
  final String path;
}

class AppTrace extends Trace {
  const AppTrace._({
    required super.path,
    super.args,
    super.traceRoute,
  });

  factory AppTrace.toProfile(String userId) {
    return AppTrace._(
      path: AppPath.profile.path,
      args: ProfileArgs(userId: userId),
      traceRoute: const PageTraceRoute(
        routeTransition: RouteTransition.slide_right,
      ),
    );
  }

  factory AppTrace.toProductModal(String productId) {
    return AppTrace._(
      path: AppPath.productDetail.path,
      args: ProductArgs(id: productId),
      traceRoute: const PopupTraceRoute(
        routeTransition: RouteTransition.fade,
      ),
    );
  }
}
```

### Semantic Actions

```dart
// Standard push
AppTrace.toProfile('123').push(context);

// Push and replace current route
AppTrace.toProfile('123').pushAndReplacement(context);

// Pop to first screen and push
AppTrace.toProfile('123').popToFirstAndPush(context);

// Pop to root and replace
AppTrace.toProfile('123').cleanAndPush(context);

// Pop to existing instance in stack or push if not present
AppTrace.toProfile('123').findMeOrPush(context);
```

---

## Presentation Styles (`TraceRoute`) & Transitions

Change how a route is presented without altering its widget implementation:

- **`PageTraceRoute`**: Full-screen page navigation.
- **`PopupTraceRoute`**: Displays the route as a modal dialog.
- **`SwipeTraceRoute`**: Displays the route as an interactive bottom sheet with swipe-to-dismiss gestures.
- **`OverlayTraceRoute`**: Displays the route in the overlay layer.

### Available Transitions

- `RouteTransition.slide_right`
- `RouteTransition.slide_left`
- `RouteTransition.slide_up`
- `RouteTransition.slide_down`
- `RouteTransition.fade`
- `RouteTransition.scale`
- `RouteTransition.none`

### Adaptive Transitions and Traces

Configure global transition or presentation rules in `Browser`:

```dart
Browser(
  routes: routes,
  defaultRoute: routes.first,
  adaptiveTransition: (route) {
    // Apply platform-specific transitions
    return RouteTransition.slide_right;
  },
  adaptiveTrace: (name) {
    // All routes under /modal/ open as popups automatically
    if (name?.startsWith('/modal/') ?? false) {
      return const PopupTraceRoute();
    }
    return null;
  },
  builder: (context, routeObserver, generate) => ...,
)
```

---

## Universal Navigation & Deep Linking (`launchAction`)

`browser_router` automatically captures query parameters into `DeepLinkParam`:

```dart
// Navigating to: /profile?id=456&theme=dark
final deepLink = context.getArgument<DeepLinkParam>();
final id = deepLink?.params['id']; // "456"
```

Use `context.launchAction()` for unified routing of internal routes and external URLs:

```dart
// Pop current view
context.launchAction('/?navigateType=pop');

// Pop to first view and push
context.launchAction('/profile?navigateType=popFirstAndPush');

// Push replacement
context.launchAction('/dashboard?navigateType=pushReplacement');

// External link (triggers openUrl callback)
context.launchAction('https://flutter.dev');
```

---

## Overlays, Sequential Banners & Sheets

Manage UI components that sit above the navigation stack using built-in overlay utilities:

### 1. Sequential Banners Queue

Display notification banners one after another in FIFO order:

```dart
Browser.enqueueBanner(
  context,
  (dismiss) => Container(
    padding: const EdgeInsets.all(16),
    color: const Color(0xFF008080),
    child: Row(
      children: [
        const Text('Update available!'),
        GestureDetector(
          onTap: dismiss,
          child: const Text(' Dismiss'),
        ),
      ],
    ),
  ),
);
```

### 2. Custom Overlay Modals

Show a modal overlay independent of the Navigator route stack:

```dart
Browser.showOverlay(
  context,
  backgroundColor: const Color(0x80000000),
  isDismissible: true,
  builder: (dismiss) => Container(
    width: 300,
    height: 200,
    color: const Color(0xFFFFFFFF),
    child: Center(
      child: GestureDetector(
        onTap: dismiss,
        child: const Text('Close Modal'),
      ),
    ),
  ),
);

// Dismiss programmatically
Browser.dismissOverlay(context);
```

### 3. Modal Bottom Sheet

```dart
Browser.showModalBottomSheet(
  context: context,
  backgroundColor: const Color(0xFFFFFFFF),
  heightFactor: 0.6,
  builder: (context) => const SheetContentView(),
);
```

---

## Code Splitting & Deferred Loading (`DeferredBrowserRoute`)

Optimize initial download bundle sizes on Flutter Web and apps by loading route modules on-demand:

```dart
import 'package:browser_router/deferred_browser_route.dart';
import 'package:my_app/screens/heavy_feature.dart' deferred as heavy_feature;

final routes = [
  DeferredBrowserRoute(
    path: '/heavy_feature',
    loadLibrary: heavy_feature.loadLibrary,
    pageBuilder: () => heavy_feature.HeavyFeatureScreen(),
    loadingWidget: const Center(child: Text('Loading...')),
  ),
];
```

---

## Flutter Web Routing Strategies

`browser_router` supports both Hash-based and Path-based URL routing strategies.

### 1. Default Strategy (Hash-based)
URLs contain `#`: `https://yourapp.com/#/profile?id=123`. Works out-of-the-box without web server configuration.

### 2. Path-based Strategy
Clean URLs: `https://yourapp.com/profile?id=123`.

To enable:
```dart
import 'package:flutter_web_plugins/url_strategy.dart';

void main() {
  usePathUrlStrategy();
  runApp(const MyApp());
}
```

> [!IMPORTANT]
> When using path-based URLs, configure your web server (Nginx, Firebase Hosting, Apache) to rewrite all requests to `index.html` to prevent 404 errors on direct URL access.

---

## License

This project is licensed under the MIT License - see the [LICENSE](LICENSE) file for details.

---

## Maintainers & Contributors ✨

Big thanks to the contributors:

<!-- prettier-ignore-start -->
<!-- markdownlint-disable -->
<table>
  <tbody>
    <tr>
      <td align="center" valign="top" width="14.28%"><a href="https://github.com/3d24rd0"><img src="https://github.com/3d24rd0.png?size=100" width="100px;" alt="Eduardo Martínez Catalá"/><br /><sub><b>Eduardo Martínez Catalá</b></sub></a></td>
      <td align="center" valign="top" width="14.28%"><a href="https://github.com/Mithos5r"><img src="https://github.com/Mithos5r.png?size=100" width="100px;" alt="Cayetano Bañón Rubio"/><br /><sub><b>Cayetano Bañón Rubio</b></sub></a></td>
      <td align="center" valign="top" width="14.28%"><a href="https://github.com/GsusBS"><img src="https://github.com/GsusBS.png?size=100" width="100px;" alt="Jesus Bernabeu"/><br /><sub><b>Jesus Bernabeu</b></sub></a></td>
    </tr>
  </tbody>
</table>
<!-- markdownlint-restore -->
<!-- prettier-ignore-end -->