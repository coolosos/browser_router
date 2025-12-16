part of 'sheet.dart';

abstract class ModalBase<T extends ModalBaseParams> {
  const ModalBase({required this.params});

  final T params;

  ModalBaseHeaderParameter contextParameters({
    required BuildContext context,
  });

  Widget body({
    required BuildContext context,
    // ignore: avoid_positional_boolean_parameters todo
    void Function(bool)? changeDrawerSize,
  });

  Widget? bottomBar(BuildContext context);
  ScrollPhysics? scrollPhysics(BuildContext context);

  ModalBaseSafeArea get safeArea => const ModalBaseSafeArea.cleanTopSafeArea();

  ModalBaseHeader topBar(
    ModalBaseHeaderParameter headerParameter,
    BorderRadiusGeometry? border,
  );
}

final class ModalBaseSafeArea {
  const ModalBaseSafeArea({
    required this.external,
    required this.internal,
  });

  const ModalBaseSafeArea.cleanTopSafeArea()
      : external = const SafeAreaManager.fromLTRB(true, true, true, false),
        internal = const SafeAreaManager.all();

  final SafeAreaManager external;
  final SafeAreaManager internal;
}

final class SafeAreaManager {
  const SafeAreaManager({
    required this.top,
    required this.right,
    required this.bottom,
    required this.left,
  });

  const SafeAreaManager.fromLTRB(
    // ignore: avoid_positional_boolean_parameters this is standard on .fromLTRB
    this.left,
    this.top,
    this.right,
    this.bottom,
  );

  const SafeAreaManager.all()
      : top = true,
        bottom = true,
        left = true,
        right = true;

  final bool top;
  final bool bottom;
  final bool left;
  final bool right;

  SafeArea safeArea({required Widget child}) => SafeArea(
        bottom: bottom,
        left: left,
        top: top,
        right: right,
        child: child,
      );
}
