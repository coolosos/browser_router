import 'package:browser_router/browser.dart';

final class DetailArgs extends RouteParams {
  new({
    required this.message,
  });

  final String message;

  @override
  bool validate() {
    return message.isNotEmpty;
  }
}
