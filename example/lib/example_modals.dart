import 'package:browser_router/browser.dart';
import 'package:flutter/widgets.dart';

/// Example of a draggable bottom sheet modal with [ModalHeader].
final class ExampleBottomModal
    extends ModalBase<ModalDraggableScrollableSheetParams> {
  const new({
    super.params = const ModalDraggableScrollableSheetParams(
      initialHeightChildSize: 0.5,
      minHeightChildSize: 0.25,
      maxHeightChildSize: 0.85,
    ),
  });

  @override
  ModalBaseHeaderParameter contextParameters({required BuildContext context}) {
    return const ModalBaseHeaderParameter(
      background: Color(0xFF1E293B),
      headerBackground: Color(0xFF334155),
      dragBar: Color(0xFF94A3B8),
      closeIcon: Text(
        '✕',
        style: TextStyle(
          color: Color(0xFFFFFFFF),
          fontSize: 16,
          fontWeight: FontWeight.bold,
        ),
        textDirection: TextDirection.ltr,
      ),
      title: Text(
        'Draggable Sheet',
        style: TextStyle(
          color: Color(0xFFFFFFFF),
          fontSize: 16,
          fontWeight: FontWeight.bold,
        ),
        textDirection: TextDirection.ltr,
      ),
    );
  }

  @override
  Widget body({
    required BuildContext context,
    ChangeDrawerSize? changeDrawerSize,
  }) {
    return Container(
      color: const Color(0xFF1E293B),
      padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 12),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const Text(
            'This modal extends ModalBase and is rendered via BrowserBottomSheet.\n\n'
            'It supports dynamic scrolling, drag-to-dismiss gestures, and smooth size adjustment.',
            style: TextStyle(color: Color(0xFFE2E8F0), fontSize: 14),
            textDirection: TextDirection.ltr,
          ),
          const SizedBox(height: 16),
          for (var i = 1; i <= 8; i++)
            Container(
              margin: const EdgeInsets.only(bottom: 8),
              padding: const EdgeInsets.all(12),
              decoration: BoxDecoration(
                color: const Color(0xFF334155),
                borderRadius: BorderRadius.circular(8),
              ),
              child: Row(
                children: [
                  const Text(
                    '📌 ',
                    style: TextStyle(fontSize: 16),
                    textDirection: TextDirection.ltr,
                  ),
                  Text(
                    'Interactive Item $i',
                    style: const TextStyle(
                      color: Color(0xFFFFFFFF),
                      fontWeight: FontWeight.w600,
                    ),
                    textDirection: TextDirection.ltr,
                  ),
                ],
              ),
            ),
        ],
      ),
    );
  }

  @override
  Widget? bottomBar(BuildContext context) => null;

  @override
  ScrollPhysics? scrollPhysics(BuildContext context) =>
      const BouncingScrollPhysics();

  @override
  ModalBaseHeader topBar(
    ModalBaseHeaderParameter headerParameter,
    BorderRadiusGeometry? border,
  ) {
    return ModalHeader(
      parameters: headerParameter,
      shouldCloseOnMinExtent: true,
      snap: true,
      border: border,
    );
  }
}

/// Example of a centered dialog modal with [ModalCenterParams].
final class ExampleCenterModal extends ModalBase<ModalCenterParams> {
  const new({super.params = const ModalCenterParams.small()});

  @override
  ModalBaseHeaderParameter contextParameters({required BuildContext context}) {
    return const ModalBaseHeaderParameter(
      background: Color(0xFF1E293B),
      headerBackground: Color(0xFF334155),
      dragBar: Color(0xFF94A3B8),
      closeIcon: Text(
        '✕',
        style: TextStyle(
          color: Color(0xFFFFFFFF),
          fontSize: 16,
          fontWeight: FontWeight.bold,
        ),
        textDirection: TextDirection.ltr,
      ),
      title: Text(
        'Center Dialog Modal',
        style: TextStyle(
          color: Color(0xFFFFFFFF),
          fontSize: 16,
          fontWeight: FontWeight.bold,
        ),
        textDirection: TextDirection.ltr,
      ),
    );
  }

  @override
  Widget body({
    required BuildContext context,
    ChangeDrawerSize? changeDrawerSize,
  }) {
    return Container(
      color: const Color(0xFF1E293B),
      padding: const EdgeInsets.all(24),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const Text(
            'Centered Dialog Sheet (BrowserCenterSheet)',
            style: TextStyle(
              color: Color(0xFF38BDF8),
              fontSize: 16,
              fontWeight: FontWeight.bold,
            ),
            textDirection: TextDirection.ltr,
          ),
          const SizedBox(height: 12),
          const Text(
            'Rendered with box constraints (ModalCenterParams) and clamped inside the viewport. Perfect for desktop dialogs or tablet popups.',
            style: TextStyle(color: Color(0xFFE2E8F0), fontSize: 14),
            textDirection: TextDirection.ltr,
          ),
          const SizedBox(height: 20),
          GestureDetector(
            behavior: HitTestBehavior.opaque,
            onTap: () => Navigator.of(context).pop(),
            child: Container(
              width: double.infinity,
              padding: const EdgeInsets.symmetric(vertical: 12),
              alignment: Alignment.center,
              decoration: BoxDecoration(
                color: const Color(0xFF38BDF8),
                borderRadius: BorderRadius.circular(8),
              ),
              child: const Text(
                'Understood',
                style: TextStyle(
                  color: Color(0xFF0F172A),
                  fontWeight: FontWeight.bold,
                  fontSize: 14,
                ),
                textDirection: TextDirection.ltr,
              ),
            ),
          ),
        ],
      ),
    );
  }

  @override
  Widget? bottomBar(BuildContext context) => null;

  @override
  ScrollPhysics? scrollPhysics(BuildContext context) => null;

  @override
  ModalBaseHeader topBar(
    ModalBaseHeaderParameter headerParameter,
    BorderRadiusGeometry? border,
  ) {
    return ModalHeader(
      parameters: headerParameter,
      shouldCloseOnMinExtent: true,
      snap: false,
      border: border,
    );
  }
}
