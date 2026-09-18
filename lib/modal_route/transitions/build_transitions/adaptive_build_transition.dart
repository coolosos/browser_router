import 'package:flutter/foundation.dart';
import 'package:flutter/widgets.dart';

import 'build_transition.dart';
import 'fade_build_transition.dart';
import 'slide_build_transition.dart';
import 'widgets/slide.dart';
import 'zoom_build_transition.dart';

/// A platform-adaptive transition builder that selects the most native-feeling
/// transition for the target platform:
/// - iOS & macOS: [SlideBuildTransition] (right-to-left slide with parallax and edge shadow)
/// - Android: [ZoomBuildTransition] (Material 3 zoom & fade)
/// - Web, Windows, Linux: [FadeBuildTransition] (clean fade for desktop & SPA web)
class AdaptiveBuildTransition implements BuildTransition {
  const AdaptiveBuildTransition();

  @override
  Widget call({
    required Animation<double> animation,
    required Widget child,
    required Animation<double> secondaryAnimation,
  }) {
    if (kIsWeb) {
      return const FadeBuildTransition().call(
        animation: animation,
        child: child,
        secondaryAnimation: secondaryAnimation,
      );
    }

    switch (defaultTargetPlatform) {
      case TargetPlatform.iOS:
      case TargetPlatform.macOS:
        return const SlideBuildTransition(position: Positions.right).call(
          animation: animation,
          child: child,
          secondaryAnimation: secondaryAnimation,
        );
      case TargetPlatform.android:
        return const ZoomBuildTransition().call(
          animation: animation,
          child: child,
          secondaryAnimation: secondaryAnimation,
        );
      case TargetPlatform.fuchsia:
      case TargetPlatform.linux:
      case TargetPlatform.windows:
        return const FadeBuildTransition().call(
          animation: animation,
          child: child,
          secondaryAnimation: secondaryAnimation,
        );
    }
  }
}
