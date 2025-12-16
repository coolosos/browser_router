part of 'overlay_manager.dart';

/// Call a remove callback or use OverlayManager.of(context).removeActual can be the same if de actual is this
typedef ContentBuilder = Widget Function(
  FutureOr<void> Function() removableCallback,
);

abstract class OverlayModal {
  OverlayModal({
    required this.duration,
    required ContentBuilder content,
    required this.transition,
    required OverlayState overlayState,
  })  : _content = content,
        _overlayState = overlayState,
        _animationController = AnimationController(
          vsync: overlayState,
          duration: transition.transitionDuration,
          reverseDuration: transition.reverseTransitionDuration,
        );

  //constructor fields
  final OverlayState _overlayState;
  final Duration? duration;
  final ContentBuilder _content;
  final OverlayTraceRoute transition;
  final AnimationController _animationController;

  // fields needed for job
  OverlayEntry? _overlayEntry;
  Timer? timer;
  Completer? completer;

  /// the child widget is a content wrapped with transition animation
  OverlayEntry _createModal(Widget child);
  Animation<double> _createAnimation() => _animationController.view;
  Animation<double> _createSecondaryAnimation() => _animationController.view;

  /// create animation and overlayEntry an insert to overlayState
  Future insert() async {
    _overlayEntry = _createModal(
      (transition.routeTransition ?? RouteTransition.slide_down).build(
        child: _content(remove),
        animation: _createAnimation(),
        secondaryAnimation: _createSecondaryAnimation(),
      ),
    );
    //show
    _overlayState.insert(_overlayEntry!);
    await _animationController.forward();
    //wait, if the duration is null, de content have a responsibility to cause
    completer = Completer();

    if (duration is Duration) {
      timer = Timer(
        duration!,
        remove,
      );
    }

    return completer!.future;
  }

  /// remove overlayEntry
  Future<void> remove() async {
    timer?.cancel();

    await _animationController.reverse();

    _overlayEntry?.remove();
    _overlayEntry = null;
    if (!(completer?.isCompleted ?? true)) {
      completer?.complete();
    }
  }
}
