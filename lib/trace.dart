part of 'browser.dart';

/// Represents a semantic navigation event.
///
/// A [Trace] object encapsulates all the information needed for a navigation
/// action: a destination [path], the arguments [args], and the presentation
/// style [traceRoute].
///
/// This class is designed to be extended to create a centralized, type-safe,
/// and semantic navigation API for your application.
///
/// Example:
/// ```dart
/// class AppTraces extends Trace {
///   AppTraces._({required super.path, super.args, super.traceRoute});
///
///   factory AppTraces.toProfile(String userId) {
///     return AppTraces._(
///       path: '/profile',
///       args: ProfileArgs(userId: userId),
///     );
///   }
/// }
///
/// // Usage:
/// AppTraces.toProfile('123').push(context);
/// ```
class Trace<T extends TraceRoute> {
  const Trace({
    required this.path,
    this.traceRoute,
    this.args,
  });

  Future<dynamic> push(BuildContext context) {
    return context.pushNamed(
      path,
      args: [args],
      traceRoute: traceRoute,
    );
  }

  Future<dynamic> pushAndReplacement(BuildContext context) {
    return context.pushReplacementNamed(
      path,
      args: [args],
      traceRoute: traceRoute,
    );
  }

  Future<dynamic> cleanAndPush(BuildContext context) {
    return context.popToFirstAndPushReplacementNamed(
      path,
      args: [args],
    );
  }

  Future<dynamic> popToFirstAndPush(BuildContext context) {
    return context.popToFirstAndPushNamed(
      path,
      args: [args],
    );
  }

  Future<dynamic> findMeOrPush(BuildContext context) {
    return context.popToSelectOrFirstAndPushNamed(
      path,
      args: [args],
    );
  }

  final String path;
  final T? traceRoute;
  final RouteParams? args;
}
