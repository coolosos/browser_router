import 'package:browser_example/pop_result_args.dart';
import 'package:browser_router/browser.dart';
import 'package:flutter/widgets.dart';

class ToSetPopArgsScreen extends StatefulWidget {
  const ToSetPopArgsScreen({super.key});

  @override
  State<ToSetPopArgsScreen> createState() => _ToSetPopArgsScreenState();
}

class _ToSetPopArgsScreenState extends State<ToSetPopArgsScreen> {
  @override
  void initState() {
    WidgetsBinding.instance.addPostFrameCallback((_) {
      if (mounted) {
        context.setPopArgument(
          PopResultArgs(result: 'Result from ToSetPopArgsScreen()'),
        );
      }
    });

    super.initState();
  }

  @override
  Widget build(BuildContext context) {
    return const ColoredBox(
      color: Color(0xFF008000),
      child: Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Text(
              'Dismiss view',
              style: TextStyle(color: Color(0xFFFFFFFF), fontSize: 24),
              textDirection: TextDirection.ltr,
            ),
          ],
        ),
      ),
    );
  }
}
