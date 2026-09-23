import 'package:browser_router/browser.dart';

final class PopResultArgs extends RouteParams {
  new({
    required this.result,
  });

  final String result;

  @override
  bool validate() {
    return result.isNotEmpty;
  }
}
