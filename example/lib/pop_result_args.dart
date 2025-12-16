import 'package:browser/browser.dart';

final class PopResultArgs extends RouteParams {
  PopResultArgs({
    required this.result,
  });

  final String result;

  @override
  bool validate() {
    return result.isNotEmpty;
  }
}
