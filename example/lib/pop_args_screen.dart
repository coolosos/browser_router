import 'package:browser/browser.dart';
import 'package:flutter/widgets.dart';

import 'pop_result_args.dart';

class PopArgsScreen extends StatelessWidget {
  const PopArgsScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return ColoredBox(
      color: const Color(0xFF008000),
      child: Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            const Text(
              'Pop Args Screen',
              style: TextStyle(color: Color(0xFFFFFFFF), fontSize: 24),
              textDirection: TextDirection.ltr,
            ),
            const SizedBox(height: 20),
            GestureDetector(
              onTap: () {
                // Example 1: Pass arguments directly in pop()
                context.pop(
                  args: PopResultArgs(result: 'Result from pop()'),
                );
              },
              child: Container(
                color: const Color(0xFFFFFFFF),
                padding: const EdgeInsets.all(12),
                child: const Text(
                  'Pop with Arguments',
                  style: TextStyle(color: Color(0xFF000000), fontSize: 16),
                  textDirection: TextDirection.ltr,
                ),
              ),
            ),
            const SizedBox(height: 20),
            GestureDetector(
              onTap: () {
                // Example 2: Stage arguments with setPopArgument() then pop
                context
                  ..setPopArgument(
                    PopResultArgs(result: 'Result from setPopArgument()'),
                  )
                  ..pop();
              },
              child: Container(
                color: const Color(0xFFFFFFFF),
                padding: const EdgeInsets.all(12),
                child: const Text(
                  'Pop using setPopArgument',
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
