import 'package:flutter/widgets.dart';

class PopupContentScreen extends StatelessWidget {
  const PopupContentScreen({super.key});

  @override
  Widget build(BuildContext context) {
    // This widget is designed to look like a dialog.
    return Center(
      child: Container(
        height: 250,
        width: 300,
        decoration: BoxDecoration(
          color: const Color(0xFF800080),
          borderRadius: BorderRadius.circular(12),
          boxShadow: const [
            BoxShadow(
              color: Color(0x44000000),
              blurRadius: 10,
              spreadRadius: 5,
            ),
          ],
        ),
        child: const Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Text(
              'I am a Popup!',
              style: TextStyle(color: Color(0xFFFFFFFF), fontSize: 24),
              textDirection: TextDirection.ltr,
            ),
            SizedBox(height: 20),
            Text(
              "My content doesn't fill the screen.",
              textAlign: TextAlign.center,
              style: TextStyle(color: Color(0xFFFFFFFF), fontSize: 16),
              textDirection: TextDirection.ltr,
            ),
          ],
        ),
      ),
    );
  }
}
