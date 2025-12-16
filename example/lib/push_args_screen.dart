import 'package:browser/browser.dart';
import 'package:flutter/widgets.dart';

import 'push_args.dart';

class PushArgsScreen extends StatelessWidget {
  const PushArgsScreen({super.key});

  @override
  Widget build(BuildContext context) {
    // Try to get the strongly-typed arguments first.
    var args = context.getArgument<PushArgs>();

    // If they are null, check for deep link parameters.
    if (args == null) {
      final deepLink = context.getArgument<DeepLinkParam>();
      if (deepLink != null) {
        // If deep link params exist, create the PushArgs from them.
        args = PushArgs(
          message: deepLink.params['message'] ?? 'N/A',
          source: deepLink.params['source'] ?? 'N/A',
        );
      }
    }

    return ColoredBox(
      color: const Color(0xFF800080),
      child: Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            const Text(
              'Push Args Screen',
              style: TextStyle(color: Color(0xFFFFFFFF), fontSize: 24),
              textDirection: TextDirection.ltr,
            ),
            const SizedBox(height: 20),
            if (args != null)
              Padding(
                padding: const EdgeInsets.all(8),
                child: Text(
                  'Message: "${args.message}"\n(From: ${args.source})',
                  textAlign: TextAlign.center,
                  style:
                      const TextStyle(color: Color(0xFFFFFFFF), fontSize: 18),
                  textDirection: TextDirection.ltr,
                ),
              ),
            const SizedBox(height: 20),
            GestureDetector(
              onTap: () => context.pop(),
              child: Container(
                color: const Color(0xFFFFFFFF),
                padding: const EdgeInsets.all(12),
                child: const Text(
                  'Go Back',
                  style: TextStyle(color: Color(0xFF000000), fontSize: 16),
                  textDirection: TextDirection.ltr,
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
