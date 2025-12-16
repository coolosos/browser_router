part of 'browser.dart';

/// An abstract base class for creating strongly-typed route arguments.
///
/// Extend this class to create a custom arguments object for a route.
/// You can override the [validate] method to add custom validation logic.
///
/// Example:
/// ```dart
/// class ProfileScreenArgs extends RouteParams {
///   const ProfileScreenArgs({required this.userId});
///   final String userId;
///
///   @override
///   bool validate() => userId.isNotEmpty;
/// }
/// ```
abstract base class RouteParams {
  const RouteParams();

  /// Validates the arguments. Returns `true` if the arguments are valid.
  ///
  /// This method is called by the `validateArguments` callback in [BrowserRoute].
  /// By default, it always returns `true`. Override it to implement custom
  /// validation logic.
  bool validate() => true;
}

final class DataParam<T> extends RouteParams {
  const DataParam(
    this.data,
  );

  final T? data;
}

/// A special [RouteParams] class that holds URL query parameters.
///
/// When a route is accessed via a URL with query parameters (e.g., `/home?foo=bar`),
/// an instance of [DeepLinkParam] containing `{'foo': 'bar'}` is automatically
/// added to the route's arguments.
final class DeepLinkParam extends RouteParams {
  const DeepLinkParam(
    this.params,
  );

  final Map<String, String> params;
}

final class _PopParam extends RouteParams {
  const _PopParam(
    this.popParams,
  );

  final RouteParams popParams;
}

final class _PushParam extends RouteParams {
  const _PushParam(
    this.pushParams,
  );

  final RouteParams pushParams;
}
