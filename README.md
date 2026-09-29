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
  browser_router: ^0.4.0
```

Then run:

```bash
flutter pub get
```

---

## Getting Started

### 1. Define Routes

Create a list of `BrowserRoute` instances. If you plan to use `Sheet.bottom`, `Sheet.center`, or `Sheet.responsive`, include `Sheet.route`:

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
  Sheet.route, // Enables Sheet.bottom, Sheet.center, Sheet.responsive
];
```

### 2. Wrap Your App with `Browser` and `OverlayManager`

Place `Browser` at the root and wrap `WidgetsApp` (or `MaterialApp`) with `OverlayManager` to enable top-level banners and loading overlays:

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
        return OverlayManager(
          child: WidgetsApp(
            color: const Color(0xFFFFFFFF),
            navigatorObservers: [routeObserver],
            onGenerateRoute: generate,
            onGenerateInitialRoutes: (routePath) => [
              generate(
                RouteSettings(name: routePath, arguments: const <dynamic, dynamic>{}),
              ),
            ],
          ),
        );
      },
    );
  }
}
```

> [!TIP]
> Wrapping your app with `OverlayManager` enables non-blocking sequential notification banners (`Browser.enqueueBanner`) and blocking loading spinners (`Browser.showLoading`) anywhere across your application without extra boilerplate.

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

### Available Transitions (`RouteTransition`)

`browser_router` includes modern Material 3, iOS Cupertino, Web, and legacy presets:

| Preset | Platform / Style | Motion Behavior |
| :--- | :--- | :--- |
| `RouteTransition.fade_through` | **Material 3 & Web** | Outgoing fades out & scales (1.0 -> 0.96), incoming fades in & scales (0.92 -> 1.0). Ideal for bottom nav bars and top-level destinations. |
| `RouteTransition.fade_scale` | **Modern Web & M3** | Snappy zoom-fade (0.95 -> 1.0) with fast easing. Perfect for web SPAs, search overlays, and dialogs. |
| `RouteTransition.shared_axis_x` | **Material 3** | Horizontal directional slide with subtle fade. Ideal for wizards and linear multi-step flows. |
| `RouteTransition.shared_axis_y` | **Material 3** | Vertical directional slide with subtle fade. Ideal for form expansions and vertical progressions. |
| `RouteTransition.shared_axis_z` | **Material 3** | Depth zoom (0.8 -> 1.0 / 1.0 -> 1.1) with fade. Ideal for drill-down hierarchies. |
| `RouteTransition.slide_cupertino`| **Authentic iOS** | iOS native push with left-edge gradient drop shadow and 1/3 parallax on the exiting route. |
| `RouteTransition.scale` | **Popup / Dialog** | Clean scale and fade animation for alerts and confirmation modals. |
| `RouteTransition.slide_right` | **Legacy Slide** | Standard horizontal right slide. |
| `RouteTransition.slide_left` | **Legacy Slide** | Standard horizontal left slide. |
| `RouteTransition.slide_up` | **Legacy Slide** | Standard vertical upward slide. |
| `RouteTransition.slide_down` | **Legacy Slide** | Standard vertical downward slide. |
| `RouteTransition.fade` | **Legacy Fade** | Simple fade in / fade out. |
| `RouteTransition.none` | **Instant** | Zero-duration transition without animation. |

---

### Custom Transitions (`CustomBuildTransition`)

You can define custom transition builders at the route level or per navigation request:

```dart
// At BrowserRoute level
BrowserRoute(
  path: '/custom',
  page: const CustomScreen(),
  customTransition: CustomBuildTransition(
    ({required animation, required secondaryAnimation, required child}) {
      return RotationTransition(
        turns: animation,
        child: child,
      );
    },
  ),
);

// Or per navigation request via TraceRoute
context.pushNamed(
  '/custom',
  traceRoute: PageTraceRoute(
    customTransition: CustomBuildTransition(
      ({required animation, required secondaryAnimation, required child}) {
        return FadeTransition(opacity: animation, child: child);
      },
    ),
  ),
);
```

---

### Accessibility & Reduced Motion (WCAG Compliance)

All `BrowserPageRoute` and `BrowserPopupRoute` transitions automatically detect system accessibility settings:
- `MediaQuery.disableAnimationsOf(context)`
- `MediaQuery.accessibleNavigationOf(context)`

When motion reduction is requested by the user, transitions bypass animations instantly with zero motion discomfort, requiring zero extra configuration.

---

### Adaptive Transitions and Traces

Configure global platform-adaptive transition rules using built-in `Browser.defaultAdaptiveTransition`:

```dart
Browser(
  routes: routes,
  defaultRoute: routes.first,
  adaptiveTransition: Browser.defaultAdaptiveTransition, // iOS/macOS: slide_cupertino, Android/Fuchsia: shared_axis_x, Web/Desktop: only_hero
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

`browser_router` includes a complete suite of pure Flutter (`package:flutter/widgets.dart`) presentation primitives:

### 1. Sequential Banners Queue

Display notification banners one after another in FIFO order with responsive width constraints on desktop/web:

```dart
Browser.enqueueBanner(
  context,
  (dismiss) => Container(
    padding: const EdgeInsets.all(16),
    color: const Color(0xFF008080),
    child: Row(
      mainAxisAlignment: MainAxisAlignment.spaceBetween,
      children: [
        const Text('Update available!'),
        GestureDetector(
          onTap: dismiss,
          child: const Text('Dismiss', style: TextStyle(fontWeight: FontWeight.bold)),
        ),
      ],
    ),
  ),
  maxWidth: 500, // Clamped on wide screens
  margin: const EdgeInsets.symmetric(horizontal: 16),
  duration: const Duration(seconds: 4),
);
```

### 2. Loading Overlays & Custom Modals

Show non-dismissible loading overlays or custom modals decoupled from the route stack:

```dart
// Show blocking loading overlay
Browser.showLoading(
  context,
  child: const LoadingSpinnerWidget(),
  backgroundColor: const Color(0x80000000),
);

// Dismiss loading overlay
Browser.dismissLoading(context);

// Or show custom dismissible overlay modal
Browser.showOverlay(
  context,
  backgroundColor: const Color(0x80000000),
  isDismissible: true,
  builder: (dismiss) => Center(
    child: Container(
      width: 300,
      height: 200,
      color: const Color(0xFFFFFFFF),
      child: Center(
        child: GestureDetector(
          onTap: dismiss,
          child: const Text('Close Overlay'),
        ),
      ),
    ),
  ),
);
```

### 3. Concrete Sheets, Dialogs & Responsive Adapters (`Sheet`)

`browser_router` provides a complete, collision-safe, pure-widget modal architecture built on `ModalBase<T>`:

| Widget | Alias | Facade Method | Description |
| :--- | :--- | :--- | :--- |
| `BrowserBottomSheet` | `ModalBottomSheet` | `Sheet.bottom(...)` | Draggable bottom sheet with automatic size adjustment (`adjustSize`) and native swipe-to-dismiss. |
| `BrowserCenterSheet` | `ModalCenterSheet` | `Sheet.center(...)` | Centered modal dialog with `BoxConstraints` and vertical drag absorption. |
| `BrowserFullSheet` | `ModalFullSheet` | `Sheet.full(...)` | Full-viewport modal sheet for immersive workflows. |
| `BrowserResponsiveSheet` | `ModalResponsiveSheet` | `Sheet.responsive(...)` | Adapts dynamically: renders `BrowserBottomSheet` on compact screens (`< breakpoint`) and `BrowserCenterSheet` on wide/desktop screens (`>= breakpoint`). |

#### Step 1: Register `Sheet.route`

Include `Sheet.route` in your `Browser` route list:

```dart
final routes = [
  BrowserRoute(path: '/', page: const HomeScreen()),
  Sheet.route, // Enables Sheet.bottom, Sheet.center, Sheet.full, Sheet.responsive
];
```

#### Step 2: Define your Modal with `ModalBase`

```dart
import 'package:browser_router/browser.dart';
import 'package:flutter/widgets.dart';

class ProfileModal extends ModalBase<ModalCenterParams> {
  const ProfileModal({super.params = const ModalCenterParams.medium()});

  @override
  ModalBaseHeaderParameter contextParameters({required BuildContext context}) {
    return const ModalBaseHeaderParameter(
      background: Color(0xFFFFFFFF),
      headerBackground: Color(0xFFF8FAFC),
      dragBar: Color(0xFFCBD5E1),
      closeIcon: Text('✕', style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold)),
      title: Text('User Profile', style: TextStyle(fontWeight: FontWeight.bold)),
    );
  }

  @override
  Widget body({required BuildContext context, ChangeDrawerSize? changeDrawerSize}) {
    return Padding(
      padding: const EdgeInsets.all(16),
      child: Column(
        children: [
          const Text('Profile details content...'),
          const SizedBox(height: 12),
          // Programmatically expand/collapse the sheet if supported
          GestureDetector(
            onTap: () => changeDrawerSize?.call(isExpanded: true),
            child: const Text('Expand Details'),
          ),
        ],
      ),
    );
  }

  @override
  Widget? bottomBar(BuildContext context) => null;

  @override
  ScrollPhysics? scrollPhysics(BuildContext context) => const BouncingScrollPhysics();

  @override
  ModalBaseSafeArea get safeArea => ModalBaseSafeArea.adaptive();

  @override
  ModalBaseHeader topBar(ModalBaseHeaderParameter headerParameter, BorderRadiusGeometry? border) {
    return ModalHeader(
      parameters: headerParameter,
      shouldCloseOnMinExtent: true,
      snap: false,
      border: border,
    );
  }
}
```

#### Step 3: Open Modal with Semantic Helpers

```dart
// 1. Draggable Bottom Sheet
await Sheet.bottom(context, const ProfileModal());

// 2. Centered Modal Dialog
await Sheet.center(context, const ProfileModal());

// 3. Full-Screen Viewport Modal
await Sheet.full(context, const ProfileModal());

// 4. Responsive (Phone: BottomSheet, Desktop/Tablet >= 600px: CenterDialog)
await Sheet.responsive(context, const ProfileModal(), breakpoint: 600);
```

#### Header Customization (`ModalHeader` & `EmptyHeader`)

- **`ModalHeader`**: Includes a rounded drag pill handle, centered title, dismiss close icon (`Navigator.maybePop`), and auto-elevating bottom shadow on scroll.
- **`EmptyHeader`**: Delegate with zero extent (`minExtent = 0`, `maxExtent = 0`) for headerless modals.

#### Size & Constraint Parameters

- **`ModalCenterParams`**: Presets (`.small()`, `.medium()`, `.large()`) or custom `BoxConstraints(maxWidth: ..., maxHeight: ...)`.
- **`ModalDraggableScrollableSheetParams`**: Controls `initialHeightChildSize`, `minHeightChildSize`, `maxHeightChildSize`, `snap`, and `snapSizes`.
- **`ModalBaseSafeArea`**: Configures screen insets (`.none()`, `.all()`, `.cleanTopSafeArea()`, or `.adaptive()`).

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