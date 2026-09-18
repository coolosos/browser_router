import 'package:browser_router/browser.dart';
import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';

final class _TestModalParams extends ModalBaseParams {}

class _TestHeader extends ModalBaseHeader {
  _TestHeader({
    required super.parameters,
    required super.shouldCloseOnMinExtent,
    required super.snap,
    required super.border,
  });

  @override
  Widget build(
    BuildContext context,
    double shrinkOffset,
    bool overlapsContent,
  ) {
    return ColoredBox(
      key: const ValueKey('test_header'),
      color: parameters.headerBackground,
      child: parameters.title,
    );
  }
}

class _TestModal extends ModalBase<_TestModalParams> {
  const _TestModal({
    required super.params,
    this.onBodyBuilt,
  });

  final void Function(ChangeDrawerSize? changeDrawerSize)? onBodyBuilt;

  @override
  ModalBaseHeaderParameter contextParameters({
    required BuildContext context,
  }) {
    return ModalBaseHeaderParameter(
      background: Colors.white,
      headerBackground: Colors.blue,
      dragBar: Colors.grey,
      closeIcon: const Icon(Icons.close),
      title: const Text('Test Title'),
    );
  }

  @override
  Widget body({
    required BuildContext context,
    ChangeDrawerSize? changeDrawerSize,
  }) {
    onBodyBuilt?.call(changeDrawerSize);
    return Column(
      children: [
        const Text('Modal Body Content'),
        ElevatedButton(
          onPressed: () {
            changeDrawerSize?.call(isExpanded: true);
          },
          child: const Text('Expand Drawer'),
        ),
      ],
    );
  }

  @override
  Widget? bottomBar(BuildContext context) {
    return const Text('Bottom Bar Content');
  }

  @override
  ScrollPhysics? scrollPhysics(BuildContext context) => null;

  @override
  ModalBaseHeader topBar(
    ModalBaseHeaderParameter headerParameter,
    BorderRadiusGeometry? border,
  ) {
    return _TestHeader(
      parameters: headerParameter,
      shouldCloseOnMinExtent: false,
      snap: false,
      border: border,
    );
  }
}

class _TestSheet extends SheetBase<_TestModalParams> {
  const _TestSheet({
    required super.modal,
    this.onAdjustSizeCalled,
  });

  final VoidCallback? onAdjustSizeCalled;

  @override
  BorderRadiusGeometry? get borderRadius => BorderRadius.circular(16);

  @override
  void adjustSize({
    required double? extentTotal,
    required double? extentInside,
    required ScrollController? customScrollViewController,
    required DraggableScrollableController? draggableController,
  }) {
    onAdjustSizeCalled?.call();
  }

  @override
  Widget sheetCase({
    required BuildContext context,
    required ScrollableBuilder build,
    required DraggableScrollableController draggableController,
  }) {
    return build(context, ScrollController());
  }
}

void main() {
  group('ModalBase & SheetBase with ChangeDrawerSize', () {
    testWidgets('renders modal structure and passes ChangeDrawerSize callback',
        (tester) async {
      var adjustSizeCalled = false;
      ChangeDrawerSize? receivedCallback;

      final modal = _TestModal(
        params: _TestModalParams(),
        onBodyBuilt: (callback) {
          receivedCallback = callback;
        },
      );

      final sheet = _TestSheet(
        modal: modal,
        onAdjustSizeCalled: () {
          adjustSizeCalled = true;
        },
      );

      await tester.pumpWidget(
        MaterialApp(
          home: Scaffold(
            body: sheet,
          ),
        ),
      );

      expect(find.text('Test Title'), findsOneWidget);
      expect(find.text('Modal Body Content'), findsOneWidget);
      expect(find.text('Bottom Bar Content'), findsOneWidget);
      expect(find.text('Expand Drawer'), findsOneWidget);
      expect(receivedCallback, isNotNull);

      // Tap button to invoke changeDrawerSize({required bool isExpanded})
      await tester.tap(find.text('Expand Drawer'));
      await tester.pump();

      expect(adjustSizeCalled, isTrue);
    });

    test('SafeAreaManager creates proper instances and widgets', () {
      const manager = SafeAreaManager(
        top: true,
        right: false,
        bottom: true,
        left: false,
      );

      expect(manager.top, isTrue);
      expect(manager.right, isFalse);
      expect(manager.bottom, isTrue);
      expect(manager.left, isFalse);

      const allManager = SafeAreaManager.all();
      expect(allManager.top, isTrue);
      expect(allManager.right, isTrue);
      expect(allManager.bottom, isTrue);
      expect(allManager.left, isTrue);

      const fromLTRBManager = SafeAreaManager.fromLTRB(false, true, false, true);
      expect(fromLTRBManager.left, isFalse);
      expect(fromLTRBManager.top, isTrue);
      expect(fromLTRBManager.right, isFalse);
      expect(fromLTRBManager.bottom, isTrue);
    });

    test('ModalBaseSafeArea initializes cleanTopSafeArea correctly', () {
      const safeArea = ModalBaseSafeArea.cleanTopSafeArea();
      expect(safeArea.external.top, isTrue);
      expect(safeArea.external.bottom, isFalse);
      expect(safeArea.internal.top, isTrue);
      expect(safeArea.internal.bottom, isTrue);
    });
  });
}
