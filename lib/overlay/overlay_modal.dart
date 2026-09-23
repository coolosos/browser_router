part of 'overlay_manager.dart';

/// Call a remove callback or use OverlayManager.of(context).removeActual can be the same if de actual is this
typedef ContentBuilder = Widget Function(
  FutureOr<void> Function() removableCallback,
);

abstract class OverlayModal {
  new({
    required this.duration,
    required this._content,
    required this.transition,
    required OverlayState overlayState,
  })  : _overlayState = overlayState,
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
  Completer<void>? completer;

  /// the child widget is a content wrapped with transition animation
  OverlayEntry _createModal(Widget child);
  Animation<double> _createAnimation() => _animationController.view;
  Animation<double> _createSecondaryAnimation() => kAlwaysDismissedAnimation;

  /// create animation and overlayEntry an insert to overlayState
  Future<void> insert() async {
    if (_isDisposed) return;
    completer = Completer<void>();

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

    if (_isDisposed) return;

    if (duration is Duration && duration != Duration.zero) {
      timer = Timer(
        duration!,
        remove,
      );
    }

    await completer?.future;
  }

  bool _isDisposed = false;

  /// remove overlayEntry
  Future<void> remove() async {
    if (_isDisposed) return;
    _isDisposed = true;

    timer?.cancel();
    timer = null;

    if (_animationController.status != AnimationStatus.dismissed) {
      await _animationController.reverse();
    }

    _overlayEntry?.remove();
    _overlayEntry = null;
    if (!(completer?.isCompleted ?? true)) {
      completer?.complete();
    }
    _animationController.dispose();
  }
}
