## 0.2.0

*   **Feat**: Added `CupertinoBackGestureDetector` with full-screen and configurable edge gesture support (`backGestureWidth`), supporting both full-screen and edge-swipe pop with full `NavigatorState.didStartUserGesture()` and `didStopUserGesture()` synchronization.
*   **Feat**: Added `RouteTransition.zoom` implementing Material 3 style zoom and fade transitions in pure `widgets.dart`.
*   **Feat**: Added `RouteTransition.adaptive` to adaptively resolve native-feeling transitions across platforms (iOS/macOS Slide, Android Zoom, Web/Desktop Fade).
*   **Refactor**: Modernized `Slide` transition by removing unwanted `BorderRadius` card deformation and adding leading edge shadow and secondary route scrim darkening.
*   **Feat**: Added `backGestureWidth` and `popClosePercentage` parameters to `PageTraceRoute` and `TraceRoute.page`.
*   **Test**: Added comprehensive test suites (`test/cupertino_back_gesture_test.dart` and `test/transitions_test.dart`).

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
