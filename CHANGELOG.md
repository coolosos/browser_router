## 0.3.0

*   **Feat (Transitions & Motion)**: Implemented modern **Material 3 Transitions** (`fade_through`, `fade_scale`, `shared_axis_x`, `shared_axis_y`, `shared_axis_z`, `scale`) and authentic **Cupertino iOS 16–18** transition (`slide_cupertino` with flat edges, 1/3 horizontal parallax, and left-edge drop shadow).
*   **Feat (Custom Transitions)**: Added `CustomBuildTransition` and `customTransition` parameter to `BrowserRoute`, `TraceRoute`, `PageTraceRoute`, `PopupTraceRoute`, `SwipeTraceRoute`, and `OverlayTraceRoute`.
*   **Feat (Platform Adaptivity)**: Added `Browser.defaultAdaptiveTransition` providing platform-native motion defaults (Cupertino on iOS/macOS, Shared Axis X on Android/Fuchsia, Fade Scale on Web/Windows/Linux).
*   **Feat (Accessibility & WCAG)**: Implemented zero-configuration reduced motion support detecting `MediaQuery.disableAnimationsOf(context)` and `MediaQuery.accessibleNavigationOf(context)` to bypass animations immediately.
*   **Perf**: Added `RepaintBoundary` rendering isolation in route transitions to avoid rebuilding ancestor tree rendering layers.
*   **Fix (Overlay & Banners)**: Fixed secondary animation in `OverlayModal` to return `kAlwaysDismissedAnimation` (preventing visual offset / hit-test misalignment) and eliminated full-screen root opaque gesture detector in `Banner`, enabling seamless pass-through scrolling, clicks, and interactive banner buttons.
*   **Test**: Expanded test coverage to 95.4% (99 passing unit & widget tests) covering modern transitions, accessibility, custom transitions, `Browser`, `BrowserRoute`, `NavigatorX` extensions, `TraceRoute`, modal barriers, swipe physics/gestures, and overlay lifecycle.
*   **Docs & Example**: Enhanced `README.md` with complete transitions catalog, custom transitions guide, accessibility guide, and platform adaptive configuration. Converted `example/` into a 100% pure `package:flutter/widgets.dart` showcase with zero Material or Cupertino dependencies.

## 0.2.0

*   **Feat**: Modernized codebase to Dart 3.13 syntax, leveraging concise constructor declarations (`new(...)`), dot shorthands, and cleaner expression bodies.
*   **Fix**: Fixed alignment property propagation in `Modal` overlay (`lib/overlay/modal.dart`), ensuring custom `builderAlignment` values (e.g., `Alignment.bottomCenter`) are honored.
*   **Test**: Expanded test coverage to 93.6% (74 passing unit & widget tests) covering `Browser`, `BrowserRoute`, `NavigatorX` extensions, `TraceRoute`, modal barriers, swipe physics/gestures, and overlay lifecycle.
*   **Chore**: Added `tool/coverage.sh` for streamlined coverage generation and analysis.
*   **Docs**: Enhanced `README.md` with complete architecture diagrams, usage guides for `Trace`, overlay managers, deep linking, and arguments validation.

## 0.1.0

*   **BREAKING CHANGE**: Defined `ChangeDrawerSize` semantic typedef (`void Function({required bool isExpanded})`) and updated `ModalBase.body` signature to use named boolean parameters, complying with `avoid_positional_boolean_parameters` linter rule.
*   **Refactor**: Completely decoupled core library from `flutter/material.dart` and `flutter/cupertino.dart` across all `lib/` files in favor of pure `package:flutter/widgets.dart` and `package:flutter/foundation.dart`.
*   **Refactor**: Updated `SheetBase` and internal drawer resizing calls to pass named `isExpanded` parameter.
*   **Fix**: Resolved `SwipeAnimation` assertion logic (`!enableDrag || animationController != null`) and gesture passing.
*   **Fix**: Added null safety guards in `SwipeDownRightGestures` and `SwipeUpLeftGestures` for `primaryDelta` and division by zero.
*   **Fix**: Resolved race condition in `OverlayModal.insert()` by initializing `completer` before animation starts and guarding against disposal.
*   **Fix**: Added `dispose()` in `OverlayManagerState` to close the concurrency `Pool` and cleanup active overlay entries.
*   **Fix**: Added `didUpdateWidget` in `_RouteObserverProviderState` to handle `routeObserver` changes.
*   **Fix**: Fixed typos in `screenPercentaje` -> `screenPercentage` and `useSafeAre` -> `useSafeArea`.
*   **Fix**: Refined return types in `Trace` navigation methods to `Future<void>`.
*   **Chore**: Upgraded `coolint` to `^3.0.0-rc.1` and updated codebase for strict analyzer rules (`strict_raw_type`, `avoid_types_on_closure_parameters`, `inference_failure_on_instance_creation`, etc.).
*   **Chore**: Upgraded `equatable` to `^2.1.0` and `pool` to `^1.5.3`.
*   **Test**: Added comprehensive 22-test unit and widget test suite covering `route_arguments` (polymorphism & exact types), `swipe_animation`, `overlay_manager` (lifecycle & race conditions), `route_observer`, `sheet`, and `deferred_browser_route`.

## 0.0.5

*   **Feat**: Changed `DeferredBrowserRoute` to use `pageBuilder` instead of `page` in its constructor, ensuring the page is built only after the deferred library is loaded, preventing potential issues.
*   **Fix**: Updated `DeferredBrowserRoute` test cases to align with the new `pageBuilder` constructor parameter.

## 0.0.4

*   **Feat**: Add `toCompletedBrowserRoute` method to `DeferredBrowserRoute` to allow synchronous route creation after deferred content loading.
*   **Refactor**: Improve `DeferredBrowserRoute` internal logic for future handling and error display.
*   **Test**: Enhance test coverage for `DeferredBrowserRoute` with `WidgetsApp` and custom `PageRoute` to minimize Material Design dependencies.

## 0.0.3

*   **Fix**: Prevent popping when no routes are available in `BrowserPageRoute` swipe gestures.
*   **Fix**: Ensure `DeepLinkParam` argument retrieval is mounted in `_RouteObserverProviderState`.

## 0.0.2

* Update repository, homepage, and issue_tracker fields.

## 0.0.1

* **Initial release** of the `browser` package.
* **Centralized Route Management**: Define all app routes in one place.
* **Typed Route Arguments**: Pass strongly-typed arguments to your routes safely, with validation.
* **Custom Transitions**: Easily implement custom page transitions (slide, fade, etc.).
* **Versatile Presentations**: Display routes as full pages, modal popups, or swipeable bottom sheets using `TraceRoute`.
* **Semantic Navigation API**: Create a reusable, semantic, and centralized navigation API with `Trace` objects.
* **Deep Linking**: Automatically parses URL query parameters.
* **Advanced Overlays & Popups**: Show sequential banners, complex modals, and multi-level popups.
