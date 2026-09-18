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

  Future<R?> push<R extends Object?>(BuildContext context) {
    return context.pushNamed<R>(
      path,
      args: [if (args != null) args!],
      traceRoute: traceRoute,
    );
  }

  Future<R?> pushAndReplacement<R extends Object?, TO extends Object?>(
    BuildContext context, {
    TO? result,
  }) {
    return context.pushReplacementNamed<R, TO>(
      path,
      args: [if (args != null) args!],
      traceRoute: traceRoute,
      result: result,
    );
  }

  Future<void> cleanAndPush(BuildContext context) {
    return context.popToFirstAndPushReplacementNamed(
      path,
      args: [if (args != null) args!],
    );
  }

  Future<void> popToFirstAndPush(BuildContext context) {
    return context.popToFirstAndPushNamed(
      path,
      args: [if (args != null) args!],
    );
  }

  Future<void> findMeOrPush(BuildContext context) {
    return context.popToSelectOrFirstAndPushNamed(
      path,
      args: [if (args != null) args!],
    );
  }

  final String path;
  final T? traceRoute;
  final RouteParams? args;
}
