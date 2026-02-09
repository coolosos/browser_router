part of 'sheet.dart';

typedef ScrollableBuilder = Widget Function(
  BuildContext context,
  ScrollController? scrollController,
);

abstract class SheetBase<T extends ModalBaseParams> extends StatelessWidget {
  const SheetBase({
    required this.modal,
    super.key,
  });

  final ModalBase<T> modal;

  void adjustSize({
    required double? extentTotal,
    required double? extentInside,
    required ScrollController? customScrollViewController,
    required DraggableScrollableController? draggableController,
  });

  Widget sheetCase({
    required BuildContext context,
    required ScrollableBuilder build,
    required DraggableScrollableController draggableController,
  });

  PrimaryScrollController scrollController({
    required BuildContext context,
    required Widget child,
  }) =>
      PrimaryScrollController.none(child: child);

  Widget sheetArea({
    required BuildContext context,
    required Widget child,
  }) {
    final keyboard = MediaQuery.viewInsetsOf(context).bottom;

    return Padding(
      padding: EdgeInsets.only(
        bottom: keyboard,
      ),
      child: child,
    );
  }

  BorderRadiusGeometry? get borderRadius;

  EdgeInsets get bodyPadding => const EdgeInsets.only(
        left: 16,
        right: 16,
      );

  EdgeInsets get buttonBarPadding =>
      const EdgeInsets.only(left: 16, right: 16, bottom: 16);

  Clip get clipBehavior => Clip.hardEdge;

  @override
  Widget build(BuildContext context) {
    final draggableController = DraggableScrollableController();

    final buttonBar = modal.bottomBar(context);
    final parameters = modal.contextParameters(context: context);

    final topBarDelegate = modal.topBar(parameters, borderRadius);
    final scrollPhysics = modal.scrollPhysics(context);

    return scrollController(
      context: context,
      child: sheetArea(
        context: context,
        child: sheetCase(
          context: context,
          draggableController: draggableController,
          build: (context, scrollController) {
            final body = modal.body(
              context: context,
              changeDrawerSize: (isExpanded) {
                adjustSize(
                  extentInside: scrollController?.position.extentInside,
                  extentTotal: scrollController?.position.extentTotal,
                  customScrollViewController: scrollController,
                  draggableController: draggableController,
                );
              },
            );

            return _sheetBase(
              backgroundColor: parameters.background,
              context: context,
              topBarDelegate: topBarDelegate,
              body: body,
              buttonBar: buttonBar,
              controller: scrollController,
              scrollPhysics: scrollPhysics,
            );
          },
        ),
      ),
    );
  }

  Widget _sheetBase({
    required Widget body,
    required BuildContext context,
    required SliverPersistentHeaderDelegate topBarDelegate,
    required Color backgroundColor,
    Widget? buttonBar,
    ScrollController? controller,
    ScrollPhysics? scrollPhysics,
  }) {
    final modalSafeArea = modal.safeArea;
    final externalSafeArea = modalSafeArea.external;
    final internalSafeArea = modalSafeArea.internal;

    return externalSafeArea.safeArea(
      child: DecoratedBox(
        decoration: BoxDecoration(
          borderRadius: borderRadius,
          color: backgroundColor,
        ),
        child: ClipRRect(
          borderRadius: borderRadius ?? BorderRadius.zero,
          child: internalSafeArea.safeArea(
            child: Column(
              children: [
                Expanded(
                  child: ScrollConfiguration(
                    behavior: ScrollConfiguration.of(context),
                    // .copyWith(scrollbars: false),
                    child: CustomScrollView(
                      clipBehavior: clipBehavior,
                      // primary: controller == null,
                      controller: controller,
                      physics: scrollPhysics,
                      slivers: [
                        SliverPersistentHeader(
                          delegate: topBarDelegate,
                          pinned: true,
                          floating: true,
                        ),
                        SliverPadding(
                          padding: bodyPadding,
                          sliver: SliverFillRemaining(
                            hasScrollBody: false,
                            fillOverscroll: false,
                            child: body,
                          ),
                        ),
                      ],
                    ),
                  ),
                ),
                if (buttonBar != null)
                  Padding(
                    padding: buttonBarPadding,
                    child: Column(
                      mainAxisSize: MainAxisSize.min,
                      children: [buttonBar],
                    ),
                  ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}
