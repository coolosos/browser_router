import 'package:flutter/gestures.dart';
import 'package:flutter/widgets.dart';

const double _kDefaultMinFlingVelocity = 300;

/// A gesture detector that enables iOS-style back-swipe gestures with full
/// synchronization to [NavigatorState.didStartUserGesture] and [NavigatorState.didStopUserGesture].
///
/// Supports both full-screen swipe (when [backGestureWidth] is `null`) and
/// edge-only swipe (when [backGestureWidth] is specified, e.g. `20.0`).
final class CupertinoBackGestureDetector extends StatefulWidget {
  const CupertinoBackGestureDetector({
    required this.child,
    required this.navigator,
    required this.controller,
    this.backGestureWidth,
    this.closePercentage = 0.35,
    this.enabled = true,
    super.key,
  });

  final Widget child;
  final NavigatorState navigator;
  final AnimationController controller;

  /// The width in logical pixels from the leading edge where the back gesture can start.
  /// If `null`, the gesture can be initiated from anywhere across the screen.
  final double? backGestureWidth;

  /// The fraction of the screen width that must be dragged to trigger a pop when
  /// there is no fling velocity. Defaults to `0.35` (35%).
  final double closePercentage;

  /// Whether the back gesture is enabled.
  final bool enabled;

  @override
  State<CupertinoBackGestureDetector> createState() =>
      _CupertinoBackGestureDetectorState();
}

final class _CupertinoBackGestureDetectorState
    extends State<CupertinoBackGestureDetector> {
  bool _isDragging = false;

  void _handleDragStart(DragStartDetails details) {
    if (!widget.enabled || _isDragging) {
      return;
    }
    _isDragging = true;
    widget.navigator.didStartUserGesture();
  }

  void _handleDragUpdate(DragUpdateDetails details) {
    if (!_isDragging) {
      return;
    }
    final delta = details.primaryDelta;
    if (delta == null) {
      return;
    }

    final size = context.size?.width ?? 0;
    if (size <= 0) {
      return;
    }

    final isLTR = Directionality.of(context) == TextDirection.ltr;
    final normalizedDelta = isLTR ? delta : -delta;

    widget.controller.value =
        (widget.controller.value - normalizedDelta / size).clamp(0.0, 1.0);
  }

  void _handleDragEnd(DragEndDetails details) {
    if (!_isDragging) {
      return;
    }
    _isDragging = false;

    final velocity = details.primaryVelocity;
    final isLTR = Directionality.of(context) == TextDirection.ltr;
    final normalizedVelocity = isLTR ? (velocity ?? 0.0) : -(velocity ?? 0.0);

    final bool willPop;
    if (normalizedVelocity.abs() >= _kDefaultMinFlingVelocity) {
      willPop = normalizedVelocity > 0;
    } else {
      willPop = widget.controller.value <= (1.0 - widget.closePercentage);
    }

    if (willPop) {
      if (widget.controller.value > 0.0) {
        widget.controller.fling(velocity: -1).orCancel.catchError((Object _) {
          // Ignored if animation is cancelled
        }).whenComplete(() {
          if (mounted) {
            widget.navigator.didStopUserGesture();
          }
        });
      } else {
        widget.navigator.didStopUserGesture();
      }
      widget.navigator.pop();
    } else {
      widget.controller.forward().orCancel.catchError((Object _) {
        // Ignored if animation is cancelled
      }).whenComplete(() {
        if (mounted) {
          widget.navigator.didStopUserGesture();
        }
      });
    }
  }

  void _handleDragCancel() {
    if (!_isDragging) {
      return;
    }
    _isDragging = false;
    widget.controller.forward().orCancel.catchError((Object _) {
      // Ignored if animation is cancelled
    }).whenComplete(() {
      if (mounted) {
        widget.navigator.didStopUserGesture();
      }
    });
  }

  @override
  void dispose() {
    if (_isDragging) {
      _isDragging = false;
      widget.navigator.didStopUserGesture();
    }
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    if (!widget.enabled) {
      return widget.child;
    }

    return RawGestureDetector(
      behavior: HitTestBehavior.translucent,
      gestures: <Type, GestureRecognizerFactory>{
        _CupertinoBackGestureRecognizer: GestureRecognizerFactoryWithHandlers<
            _CupertinoBackGestureRecognizer>(
          () => _CupertinoBackGestureRecognizer(
            getBackGestureWidth: () => widget.backGestureWidth,
            getTextDirection: () => Directionality.of(context),
            getWidgetSize: () => context.size,
          ),
          (instance) {
            instance
              ..onStart = _handleDragStart
              ..onUpdate = _handleDragUpdate
              ..onEnd = _handleDragEnd
              ..onCancel = _handleDragCancel;
          },
        ),
      },
      child: widget.child,
    );
  }
}

final class _CupertinoBackGestureRecognizer
    extends HorizontalDragGestureRecognizer {
  _CupertinoBackGestureRecognizer({
    required this.getBackGestureWidth,
    required this.getTextDirection,
    required this.getWidgetSize,
  });

  final double? Function() getBackGestureWidth;
  final TextDirection Function() getTextDirection;
  final Size? Function() getWidgetSize;

  @override
  void addAllowedPointer(PointerDownEvent event) {
    final backGestureWidth = getBackGestureWidth();
    if (backGestureWidth != null) {
      final textDirection = getTextDirection();
      final size = getWidgetSize();
      final isLTR = textDirection == TextDirection.ltr;
      final startX = event.localPosition.dx;

      if (isLTR) {
        if (startX > backGestureWidth) {
          return;
        }
      } else {
        final width = size?.width ?? 0;
        if (width > 0 && startX < width - backGestureWidth) {
          return;
        }
      }
    }
    super.addAllowedPointer(event);
  }
}
