import 'build_transitions/build_transition.dart';
import 'build_transitions/fade_build_transition.dart';
import 'build_transitions/no_build_transition.dart';
import 'build_transitions/slide_build_transition.dart';
import 'build_transitions/widgets/slide.dart';

enum RouteTransition {
  fade(
    build: FadeBuildTransition(),
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

  const RouteTransition({required this.build});

  final BuildTransition build;
}
