import 'build_transitions/build_transition.dart';
import 'build_transitions/fade_build_transition.dart';
import 'build_transitions/fade_scale_build_transition.dart';
import 'build_transitions/fade_through_build_transition.dart';
import 'build_transitions/no_build_transition.dart';
import 'build_transitions/scale_build_transition.dart';
import 'build_transitions/shared_axis_build_transition.dart';
import 'build_transitions/slide_build_transition.dart';
import 'build_transitions/slide_cupertino_build_transition.dart';
import 'build_transitions/widgets/slide.dart';

export 'build_transitions/build_transition.dart';
export 'build_transitions/custom_build_transition.dart';
export 'build_transitions/fade_build_transition.dart';
export 'build_transitions/fade_scale_build_transition.dart';
export 'build_transitions/fade_through_build_transition.dart';
export 'build_transitions/no_build_transition.dart';
export 'build_transitions/scale_build_transition.dart';
export 'build_transitions/shared_axis_build_transition.dart';
export 'build_transitions/slide_build_transition.dart';
export 'build_transitions/slide_cupertino_build_transition.dart';

enum RouteTransition {
  fade(
    build: FadeBuildTransition(),
  ),
  fade_through(
    build: FadeThroughBuildTransition(),
  ),
  fade_scale(
    build: FadeScaleBuildTransition(),
  ),
  shared_axis_x(
    build: SharedAxisBuildTransition(direction: SharedAxisDirection.horizontal),
  ),
  shared_axis_y(
    build: SharedAxisBuildTransition(direction: SharedAxisDirection.vertical),
  ),
  shared_axis_z(
    build: SharedAxisBuildTransition(direction: SharedAxisDirection.scaled),
  ),
  scale(
    build: ScaleBuildTransition(),
  ),
  slide_cupertino(
    build: SlideCupertinoBuildTransition(),
  ),
  slide_right(
    build: SlideBuildTransition(
      position: Positions.right,
    ),
  ),
  slide_up(
    build: SlideBuildTransition(
      position: Positions.up,
    ),
  ),
  slide_left(
    build: SlideBuildTransition(
      position: Positions.left,
    ),
  ),
  slide_down(
    build: SlideBuildTransition(
      position: Positions.down,
    ),
  ),
  only_hero(
    build: NoBuildTransition(),
  ),
  none(
    build: NoBuildTransition(),
  ),
  ;

  new({required this.build});

  final BuildTransition build;
}
