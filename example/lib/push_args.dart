import 'package:browser_router/browser.dart';

final class PushArgs extends RouteParams {
  new({
    required this.message,
    required this.source,
  });

  final String message;
  final String source;

  @override
  bool validate() {
    return message.isNotEmpty && source.isNotEmpty;
  }
}
