library;

import 'dart:async';
import 'dart:developer';

import 'package:flutter/widgets.dart';
import 'package:pool/pool.dart';

import '../modal_route/params/trace_route.dart';
import '../modal_route/transitions/route_transition.dart';

part 'banner.dart';
part 'modal.dart';
part 'overlay_modal.dart';

class OverlayManager extends StatefulWidget {
  const OverlayManager({
    required this.child,
    super.key,
  });

  final Widget child;

  static OverlayManagerState? of(
    BuildContext context, {
    bool rootManager = false,
  }) {
    OverlayManagerState? manager;
    if (context is StatefulElement && context.state is OverlayManagerState) {
      manager = context.state as OverlayManagerState;
    }
    if (rootManager) {
      manager =
          context.findRootAncestorStateOfType<OverlayManagerState>() ?? manager;
    } else {
      manager =
          manager ?? context.findAncestorStateOfType<OverlayManagerState>();
    }

    return manager;
  }

  static void enqueueBanner(
    BuildContext context, {
    required ContentBuilder content,
    double? topPadding,
  }) {
    of(context)?.enqueue(
      Banner.fromContext(
        context: context,
        duration: const Duration(seconds: 5),
        transition: OverlayTraceRoute(
          routeTransition: RouteTransition.slide_down,
          reverseTransitionDuration: const Duration(milliseconds: 300),
          transitionDuration: const Duration(milliseconds: 300),
        ),
        content: content,
        topPadding: topPadding,
      ),
    );
  }

  @override
  State<OverlayManager> createState() => OverlayManagerState();
}

class OverlayManagerState extends State<OverlayManager> {
  //! no se debe poner un timeout, debido a que pueden existir overlay sin limite
  final Pool pool = Pool(1);
  OverlayModal? poolCurrentOverlayModal;

  OverlayModal? modal;

  ///Show a [OverlayModal] in foreground
  ///
  ///Only one modal can be display at the same time if you want to insert multiple OverlayModal show [enqueue] function.
  Future<void> showModal(
    OverlayModal overlayModal,
  ) async {
    if (mounted) {
      await dismissModal();
      modal = overlayModal;
      await overlayModal.insert();
    }
  }

  ///Dismiss the current [OverlayModal] in foreground
  Future<void> dismissModal() async {
    await modal?.remove();
    modal = null;
  }

  void enqueue(OverlayModal overlayModal) {
    if (!pool.isClosed) {
      pool.withResource(() => _work(overlayModal));
    } else {
      _work(overlayModal);
    }
  }

  void removeActual() {
    if (poolCurrentOverlayModal is OverlayModal) {
      poolCurrentOverlayModal?.remove();
      poolCurrentOverlayModal = null;
    }
  }

  Future<void> _work(
    OverlayModal overlayModal,
  ) async {
    try {
      if (mounted) {
        poolCurrentOverlayModal = overlayModal;
        await overlayModal.insert();
      }
    } catch (e, s) {
      log(
        'Timeout of pool or error on overlay',
        error: e,
        stackTrace: s,
        name: 'OverlayManagerState.enqueue',
      );
    }
  }

  @override
  Widget build(BuildContext context) => widget.child;
}
