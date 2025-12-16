import 'package:browser/browser.dart';

final class DetailArgs extends RouteParams {
  DetailArgs({
    required this.message,
  });

  final String message;

  @override
  bool validate() {
    return message.isNotEmpty;
  }
}
