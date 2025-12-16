import 'package:browser/browser.dart';
import 'package:flutter/widgets.dart';

import 'pop_result_args.dart';

class DeepScreen extends StatelessWidget {
  const DeepScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return ColoredBox(
      color: const Color(0xFF3E2723),
      child: Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            const Text(
              'Deep Screen (Lvl 3)',
              style: TextStyle(color: Color(0xFFFFFFFF), fontSize: 24),
              textDirection: TextDirection.ltr,
            ),
            const SizedBox(height: 20),
            GestureDetector(
              onTap: () {
                // This will pop all screens until the first one,
                // and pass arguments to it.
                context.popToFirst(
                  args: [PopResultArgs(result: 'Result from Level 3')],
                );
              },
              child: Container(
                color: const Color(0xFFFFFFFF),
                padding: const EdgeInsets.all(12),
                child: const Text(
                  'Pop to First with Arguments',
                  textAlign: TextAlign.center,
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
