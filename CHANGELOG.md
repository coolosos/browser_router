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
