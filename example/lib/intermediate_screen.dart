import 'package:flutter/widgets.dart';

import 'app_traces.dart';

class IntermediateScreen extends StatelessWidget {
  const IntermediateScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return ColoredBox(
      color: const Color(0xFF004D40),
      child: Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            const Text(
              'Intermediate Screen (Lvl 2)',
              style: TextStyle(color: Color(0xFFFFFFFF), fontSize: 24),
              textDirection: TextDirection.ltr,
            ),
            const SizedBox(height: 20),
            GestureDetector(
              onTap: () => AppTrace.toDeep().push(context),
              child: Container(
                color: const Color(0xFFFFFFFF),
                padding: const EdgeInsets.all(12),
                child: const Text(
                  'Go to Deep Screen (Lvl 3)',
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
