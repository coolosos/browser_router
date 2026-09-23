import 'package:browser_router/browser.dart';
import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';

final class _TestModalParams extends ModalBaseParams;

class _TestHeader extends ModalBaseHeader {
  new({
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
  const new({
    required super.params,
    this.onBodyBuilt,
  });

  final void Function(ChangeDrawerSize? changeDrawerSize)? onBodyBuilt;

  @override
  ModalBaseHeaderParameter contextParameters({
    required BuildContext context,
  }) {
    return const ModalBaseHeaderParameter(
      background: Colors.white,
      headerBackground: Colors.blue,
      dragBar: Colors.grey,
      closeIcon: Icon(Icons.close),
      title: Text('Test Title'),
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
  const new({
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

    test('ModalDraggableScrollableSheetParams constructors and fields', () {
      const standard = ModalDraggableScrollableSheetParams(
        initialHeightChildSize: 0.5,
        minHeightChildSize: 0.2,
        maxHeightChildSize: 0.9,
        withChildSize: 0.7,
        expand: false,
        snap: true,
        snapSizes: [0.5, 0.9],
        snapAnimationDuration: Duration(milliseconds: 250),
        shouldCloseOnMinExtent: false,
      );
      expect(standard.initialHeightChildSize, equals(0.5));
      expect(standard.minHeightChildSize, equals(0.2));
      expect(standard.maxHeightChildSize, equals(0.9));
      expect(standard.withChildSize, equals(0.7));
      expect(standard.expand, isFalse);
      expect(standard.snap, isTrue);
      expect(standard.snapSizes, equals([0.5, 0.9]));
      expect(standard.snapAnimationDuration, equals(const Duration(milliseconds: 250)));
      expect(standard.shouldCloseOnMinExtent, isFalse);

      const small = ModalDraggableScrollableSheetParams.small();
      expect(small.initialHeightChildSize, equals(0.35));
      expect(small.minHeightChildSize, equals(0.35));
      expect(small.maxHeightChildSize, equals(0.75));

      const medium = ModalDraggableScrollableSheetParams.medium();
      expect(medium.initialHeightChildSize, equals(0.4));
      expect(medium.minHeightChildSize, equals(0.4));
      expect(medium.maxHeightChildSize, equals(0.6));

      const large = ModalDraggableScrollableSheetParams.large();
      expect(large.initialHeightChildSize, equals(0.45));
      expect(large.minHeightChildSize, equals(0.3));
      expect(large.maxHeightChildSize, equals(0.86));
    });

    test('ModalBaseHeader extents with and without title/snap', () {
      final headerWithTitle = _TestHeader(
        parameters: const ModalBaseHeaderParameter(
          background: Colors.white,
          headerBackground: Colors.blue,
          dragBar: Colors.grey,
          closeIcon: Icon(Icons.close),
          title: Text('Title'),
        ),
        shouldCloseOnMinExtent: false,
        snap: false,
        border: null,
      );
      expect(headerWithTitle.maxExtent, equals(57));
      expect(headerWithTitle.minExtent, equals(57));
      expect(headerWithTitle.shouldRebuild(headerWithTitle), isFalse);

      final headerWithoutTitle = _TestHeader(
        parameters: const ModalBaseHeaderParameter(
          background: Colors.white,
          headerBackground: Colors.blue,
          dragBar: Colors.grey,
          closeIcon: Icon(Icons.close),
          title: null,
        ),
        shouldCloseOnMinExtent: false,
        snap: false,
        border: null,
      );
      expect(headerWithoutTitle.maxExtent, equals(27));
      expect(headerWithoutTitle.minExtent, equals(27));

      final headerWithSnap = _TestHeader(
        parameters: const ModalBaseHeaderParameter(
          background: Colors.white,
          headerBackground: Colors.blue,
          dragBar: Colors.grey,
          closeIcon: Icon(Icons.close),
          title: null,
        ),
        shouldCloseOnMinExtent: false,
        snap: true,
        border: null,
      );
      expect(headerWithSnap.maxExtent, equals(57));
      expect(headerWithSnap.minExtent, equals(57));
    });

    test('ModalDraggableScrollableSheetParams named constructors instantiate with correct defaults', () {
      const small = ModalDraggableScrollableSheetParams.small(
        snapSizes: [0.5],
        snapAnimationDuration: Duration(milliseconds: 200),
        shouldCloseOnMinExtent: false,
        expand: false,
        snap: true,
        withChildSize: 0.8,
      );
      expect(small.initialHeightChildSize, equals(0.35));
      expect(small.minHeightChildSize, equals(0.35));
      expect(small.maxHeightChildSize, equals(0.75));
      expect(small.snapSizes, equals([0.5]));
      expect(small.snapAnimationDuration, equals(const Duration(milliseconds: 200)));
      expect(small.shouldCloseOnMinExtent, isFalse);
      expect(small.expand, isFalse);
      expect(small.snap, isTrue);
      expect(small.withChildSize, equals(0.8));

      const medium = ModalDraggableScrollableSheetParams.medium(
        snapSizes: [0.5],
        snapAnimationDuration: Duration(milliseconds: 200),
        shouldCloseOnMinExtent: false,
        expand: false,
        snap: true,
        withChildSize: 0.8,
      );
      expect(medium.initialHeightChildSize, equals(0.4));
      expect(medium.minHeightChildSize, equals(0.4));
      expect(medium.maxHeightChildSize, equals(0.6));

      const large = ModalDraggableScrollableSheetParams.large(
        snapSizes: [0.5],
        snapAnimationDuration: Duration(milliseconds: 200),
        shouldCloseOnMinExtent: false,
        expand: false,
        snap: true,
        withChildSize: 0.8,
      );
      expect(large.initialHeightChildSize, equals(0.45));
      expect(large.minHeightChildSize, equals(0.3));
      expect(large.maxHeightChildSize, equals(0.86));
    });
  });
}
