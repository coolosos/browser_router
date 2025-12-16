# Browser - Advanced Navigation for Flutter

[![pub version](https://img.shields.io/pub/v/browser.svg)](https://pub.dev/packages/browser)

An advanced navigation system for Flutter that enables typed routes, custom transitions, and robust overlay management (Banners, Modals, Sheets).

## Features

- **Centralized Route Management**: Define all your app routes in one place.
- **Typed Route Arguments**: Pass strongly-typed arguments to your routes safely, with validation.
- **Custom Transitions**: Easily implement custom page transitions (slide, fade, etc.) with a smart priority system.
- **Versatile Presentations**: Display any route as a full page, a modal popup, or a swipeable bottom sheet using `TraceRoute`.
- **Semantic Navigation API**: Create a reusable, semantic, and centralized navigation API for your app using `Trace` objects.
- **Deep Linking**: Automatically parses URL query parameters and delivers them to new or existing screens.
- **Advanced Overlays & Popups**: Show sequential banners, complex modals, and multi-level popups.

---

## Installation

...

---

## Advanced Navigation

`browser` provides powerful, unified methods for navigation.

### Deep Linking

If you navigate to a path that contains URL query parameters (e.g. `/profile?id=123`), `browser` automatically parses them into a `DeepLinkParam` object.

There are two ways to receive these parameters:

**1. On a new screen**

If the deep link pushes a new screen, that screen can get the parameters directly in its `build` method.

```dart
// In ProfileScreen's build method
final deepLinkParams = context.getArgument<DeepLinkParam>();
if (deepLinkParams != null) {
  final userId = deepLinkParams.params['id']; // "123"
}
```

**2. On an existing screen (with `Browser.watch`)**

If the deep link navigates to a screen that is already in the stack (like the `HomeScreen`), you can receive the parameters in the `onAppear` callback of `Browser.watch`.

```dart
// In HomeScreen's State
Widget build(BuildContext context) {
  return Browser.watch(
    onAppear: (context, deepLink) {
      // The `deepLink` parameter will be populated here
      if (deepLink != null) {
        final message = deepLink.params['message'];
        // ... update state with the message
      }
    },
    child: ...
  );
}
```

### Presentation with `TraceRoute`

A `TraceRoute` is an object that defines **HOW** a route is presented. The type of `TraceRoute` you provide determines the presentation style.

- `PageTraceRoute`: The default. Presents the route as a standard, full-screen page.
- `PopupTraceRoute`: Presents the route as a modal dialog.
- `SwipeTraceRoute`: Presents the route as a swipeable bottom sheet.

### Typed Arguments (`args`)

This is the recommended way to pass data between screens.

**1. Create an arguments class**

```dart
class ProfileArgs extends RouteParams { ... }
```

**2. Add validation to your route**

```dart
BrowserRoute(
  path: '/profile',
  page: ProfileScreen(),
  validateArguments: (check, get) => check<ProfileArgs>(),
),
```

**3. Push with arguments**

```dart
context.pushNamed(
  '/profile',
  args: [ProfileArgs(userId: '123')],
);
```

**4. Retrieve the arguments**

```dart
final args = context.getArgument<ProfileArgs>();
```

### Receiving Arguments from `pop`

To receive a "result" from a screen that was popped, you must wrap the receiving widget with `Browser.watch` and check for your result arguments inside the `onAppear` callback.

```dart
// In the receiving screen (e.g., HomeScreen)
return Browser.watch(
  onAppear: (context, deepLink) {
    // Use getArgumentAndClean for one-time pop results
    final popArgs = context.getArgumentAndClean<PopResultArgs>();
    if (popArgs != null) {
      // ... update state with popArgs.result
    }
  },
  child: ...
);
```

### `getArgument` vs. `getArgumentAndClean`

- **`getArgument<T>()`**: **Reads** an argument without removing it. Use for data needed to build a screen (e.g., a product ID).
- **`getArgumentAndClean<T>()`**: **Reads** an argument and then **removes it**. Use for one-time events, like results from a `pop`, to avoid processing the same event multiple times.

---

## Advanced Pattern: Semantic Navigation API with `Trace`

For large applications, you can use the `Trace` class to create a centralized, reusable, and semantic API for all your navigation events.

**1. Centralize Paths**

```dart
enum AppPath {
  profile('/profile');
  const AppPath(this.path);
  final String path;
}
```

**2. Create a `Trace` Wrapper**

```dart
class AppTrace extends Trace {
  const AppTrace._({required super.path, super.args, super.traceRoute});

  factory AppTrace.toProfile({ required String userId }) {
    return AppTrace._(
      path: AppPath.profile.path,
      args: ProfileArgs(userId: userId),
    );
  }
}
```

**3. Use the Semantic API**

```dart
AppTrace.toProfile(userId: '123').push(context);
```
---
## A Note on Flutter Web Routing Strategies

This package works directly with Flutter's default web routing strategy, which uses a "hash" (or fragment) in the URL.

### Default Strategy (Hash-based)

By default, your Flutter web app's URLs will look like this:

```
https://yourapp.com/#/home
https://yourapp.com/#/profile/123?mode=edit
```

With this strategy, route arguments and parameters are managed on the client-side and work without any special configuration on your web server.

### Path-based Strategy

If you prefer cleaner, more SEO-friendly URLs without the `#`:

```
https://yourapp.com/home
https://yourapp.com/profile/123?mode=edit
```

You can enable the "path-based" routing strategy. To do so, follow these two steps:

1.  **Enable the Strategy in Flutter:** Call `usePathUrlStrategy()` at the beginning of your `main()` function in `main.dart`.

    ```dart
    // main.dart
    import 'package:flutter/material.dart';
    import 'package:flutter_web_plugins/url_strategy.dart';

    void main() {
      // Call this function before runApp()
      usePathUrlStrategy();
      runApp(const MyApp());
    }
    ```

2.  **Configure Your Web Server:** This is a **critical** step. You must configure your production server (Nginx, Apache, Firebase Hosting, etc.) to redirect all requests to your `index.html` file. Without this, users who directly access an internal URL of your app will get a 404 error.

    For more details on how to configure your server, see the [official Flutter documentation](https://docs.flutter.dev/ui/navigation/url-strategies).

By following these steps, `browser` will work perfectly with the routing strategy you choose.

---

## Maintainers & Contributors ✨

Big thanks go to these wonderful people who have contributed to the project:

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

 