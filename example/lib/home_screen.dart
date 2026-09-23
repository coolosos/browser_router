import 'package:browser_example/app_traces.dart';
import 'package:browser_example/pop_result_args.dart';
import 'package:browser_example/push_args.dart';
import 'package:browser_router/browser.dart';
import 'package:flutter/widgets.dart';

class HomeScreen extends StatefulWidget {
  const new({super.key});

  @override
  State<HomeScreen> createState() => _HomeScreenState();
}

class _HomeScreenState extends State<HomeScreen> {
  String? _eventMessage;

  @override
  Widget build(BuildContext context) {
    return Browser.watch(
      onAppear: (context, deepLink) {
        if (!mounted) return;

        // First, handle pop arguments, as they are a one-time event.
        final popArgs = context.getArgumentAndClean<PopResultArgs>();
        if (popArgs != null) {
          WidgetsBinding.instance.addPostFrameCallback((_) {
            setState(() {
              _eventMessage = '[From Pop]: ${popArgs.result}';
            });
          });
          return;
        }

        // Second, handle deep link parameter from the callback.
        if (deepLink != null) {
          WidgetsBinding.instance.addPostFrameCallback((_) {
            setState(() {
              _eventMessage = '[From DeepLink]: ${deepLink.params['message']}';
            });
          });
        }
      },
      child: Container(
        color: const Color(0xFF008080),
        padding: const EdgeInsets.all(16),
        child: SafeArea(
          child: Column(
            children: [
              const Text(
                'Browser Examples',
                style: TextStyle(
                  color: Color(0xFFFFFFFF),
                  fontSize: 24,
                  fontWeight: FontWeight.bold,
                ),
                textDirection: TextDirection.ltr,
              ),
              if (_eventMessage != null)
                Padding(
                  padding: const EdgeInsets.only(top: 12),
                  child: Text(
                    'Last Event: "$_eventMessage"',
                    style: const TextStyle(
                      color: Color(0xFFFFFFFF),
                      fontSize: 15,
                    ),
                    textDirection: TextDirection.ltr,
                  ),
                ),
              const SizedBox(height: 16),
              Expanded(
                child: ListView(
                  children: [
                    // --- Material 3 Motion ---
                    const _SectionTitle(title: '✨ Material 3 Motion Transitions'),
                    _ExampleButton(
                      text: 'Fade Through (Top-Level Tabs / Bar)',
                      onTap: () => AppTrace.toPushArgs(
                        message: 'Material 3 Fade Through (scale 0.92->1.0 & fade intervals)',
                        source: 'M3 Fade Through',
                        transition: RouteTransition.fade_through,
                      ).push(context),
                    ),
                    _ExampleButton(
                      text: 'Shared Axis X (Horizontal / Wizards)',
                      onTap: () => AppTrace.toPushArgs(
                        message: 'Material 3 Shared Axis X (directional horizontal slide & fade)',
                        source: 'M3 Shared Axis X',
                        transition: RouteTransition.shared_axis_x,
                      ).push(context),
                    ),
                    _ExampleButton(
                      text: 'Shared Axis Y (Vertical / Expansion)',
                      onTap: () => AppTrace.toPushArgs(
                        message: 'Material 3 Shared Axis Y (directional vertical slide & fade)',
                        source: 'M3 Shared Axis Y',
                        transition: RouteTransition.shared_axis_y,
                      ).push(context),
                    ),
                    _ExampleButton(
                      text: 'Shared Axis Z (Depth / Drill-Down)',
                      onTap: () => AppTrace.toPushArgs(
                        message: 'Material 3 Shared Axis Z (scale 0.8->1.0 / 1.0->1.1 depth)',
                        source: 'M3 Shared Axis Z',
                        transition: RouteTransition.shared_axis_z,
                      ).push(context),
                    ),
                    _ExampleButton(
                      text: 'Scale (Popup / Modal Dialog)',
                      onTap: () => AppTrace.toPushArgs(
                        message: 'Material 3 / Clean Scale & Fade transition',
                        source: 'M3 Scale',
                        transition: RouteTransition.scale,
                      ).push(context),
                    ),
                    const SizedBox(height: 20),

                    // --- Apple Cupertino iOS Motion ---
                    const _SectionTitle(title: '🍎 iOS 16–18 Cupertino Native Motion'),
                    _ExampleButton(
                      text: 'Slide Cupertino (Shadow + 1/3 Parallax)',
                      onTap: () => AppTrace.toPushArgs(
                        message: 'Authentic iOS Cupertino Slide with flat drop-shadow & 1/3 horizontal parallax',
                        source: 'Cupertino Motion',
                        transition: RouteTransition.slide_cupertino,
                      ).push(context),
                    ),
                    const SizedBox(height: 20),

                    // --- Web Micro-Transitions ---
                    const _SectionTitle(title: '🌐 Web Micro-Transitions (SPA)'),
                    _ExampleButton(
                      text: 'Fade Scale (Fast Zoom-Fade 0.95->1.0)',
                      onTap: () => AppTrace.toPushArgs(
                        message: 'Snappy SPA Zoom-Fade (0.95->1.0) with fastEasing',
                        source: 'Web Micro-Transition',
                        transition: RouteTransition.fade_scale,
                      ).push(context),
                    ),
                    const SizedBox(height: 20),

                    // --- Custom Transitions ---
                    const _SectionTitle(title: '🎨 Custom Transition Builders'),
                    _ExampleButton(
                      text: 'CustomBuildTransition (Rotation + Elastic Zoom)',
                      onTap: () => AppTrace.toCustomTransition(
                        name: 'Rotation & EaseOutBack Elastic Scale',
                      ).push(context),
                    ),
                    const SizedBox(height: 20),

                    // --- Adaptive Transitions ---
                    const _SectionTitle(title: '📱 Platform-Adaptive Transition'),
                    _ExampleButton(
                      text: 'Browser.defaultAdaptiveTransition (Platform Auto-Detect)',
                      onTap: () {
                        final adaptive = Browser.defaultAdaptiveTransition(
                          BrowserRoute(
                            path: AppPath.pushArgs.path,
                            page: const SizedBox(),
                          ),
                        );
                        AppTrace.toPushArgs(
                          message: 'Auto-detected adaptive transition: ${adaptive.name}',
                          source: 'Browser.defaultAdaptiveTransition',
                          transition: adaptive,
                        ).push(context);
                      },
                    ),
                    const SizedBox(height: 20),

                    // --- Presentations & Modals ---
                    const _SectionTitle(title: '🪟 Presentation (TraceRoute) Styles'),
                    _ExampleButton(
                      text: 'Present as Popup (Scale Transition)',
                      onTap: () => AppTrace.asPopup(transition: RouteTransition.scale).push(context),
                    ),
                    _ExampleButton(
                      text: 'Present as Popup (Fade Scale Transition)',
                      onTap: () => AppTrace.asPopup(transition: RouteTransition.fade_scale).push(context),
                    ),
                    _ExampleButton(
                      text: 'Present as Swipeable Bottom Sheet',
                      onTap: () => AppTrace.asSheet().push(context),
                    ),
                    const SizedBox(height: 20),

                    // --- Legacy Presets ---
                    const _SectionTitle(title: '📦 Legacy Slide & Fade Presets'),
                    _ExampleButton(
                      text: 'Slide Right',
                      onTap: () => AppTrace.toPushArgs(
                        message: 'Legacy slide_right transition',
                        source: 'Legacy Presets',
                        transition: RouteTransition.slide_right,
                      ).push(context),
                    ),
                    _ExampleButton(
                      text: 'Slide Left',
                      onTap: () => AppTrace.toPushArgs(
                        message: 'Legacy slide_left transition',
                        source: 'Legacy Presets',
                        transition: RouteTransition.slide_left,
                      ).push(context),
                    ),
                    _ExampleButton(
                      text: 'Slide Up',
                      onTap: () => AppTrace.toPushArgs(
                        message: 'Legacy slide_up transition',
                        source: 'Legacy Presets',
                        transition: RouteTransition.slide_up,
                      ).push(context),
                    ),
                    _ExampleButton(
                      text: 'Slide Down',
                      onTap: () => AppTrace.toPushArgs(
                        message: 'Legacy slide_down transition',
                        source: 'Legacy Presets',
                        transition: RouteTransition.slide_down,
                      ).push(context),
                    ),
                    _ExampleButton(
                      text: 'Fade',
                      onTap: () => AppTrace.toPushArgs(
                        message: 'Legacy fade transition',
                        source: 'Legacy Presets',
                        transition: RouteTransition.fade,
                      ).push(context),
                    ),
                    _ExampleButton(
                      text: 'None (Instant)',
                      onTap: () => AppTrace.toPushArgs(
                        message: 'Instant transition without animation',
                        source: 'Legacy Presets',
                        transition: RouteTransition.none,
                      ).push(context),
                    ),
                    const SizedBox(height: 20),

                    // --- Argument Examples ---
                    const _SectionTitle(title: '🔗 Arguments & DeepLink Examples'),
                    _ExampleButton(
                      text: '1. Push with Typed Arguments',
                      onTap: () => AppTrace.toPushArgs(
                        message: 'Hello from pushNamed()',
                        source: 'args',
                      ).push(context),
                    ),
                    _ExampleButton(
                      text: '2. Push with setPushArgument',
                      onTap: () {
                        context
                          ..setPushArgument(
                            const PushArgs(
                              message: 'Hello from setPushArgument()',
                              source: 'setPushArgument',
                            ),
                          )
                          ..pushNamed(AppPath.pushArgs.path);
                      },
                    ),
                    _ExampleButton(
                      text: '3. Receive Arguments from Pop',
                      onTap: () => AppTrace.toPopArgs().push(context),
                    ),
                    _ExampleButton(
                      text: '4. Multi-level Pop with Arguments',
                      onTap: () => AppTrace.toIntermediate().push(context),
                    ),
                    _ExampleButton(
                      text: '5. Deep Link to another screen',
                      onTap: () => context.pushNamed(
                        '${AppPath.pushArgs.path}?message=HelloFromADeepLink&source=URL',
                      ),
                    ),
                    _ExampleButton(
                      text: '6. Deep Link to Home',
                      onTap: () => context.pushNamed(
                        '${AppPath.home.path}?message=Navigated to Home via DeepLink',
                      ),
                    ),
                    _ExampleButton(
                      text: '7. Receive Arguments from dismissed view',
                      onTap: () => AppTrace.toSetPopArgs().push(context),
                    ),
                    const SizedBox(height: 20),

                    // --- Overlay ---
                    const _SectionTitle(title: '📣 Overlay & Banners'),
                    _ExampleButton(
                      text: 'Enqueue Banner (Auto-dismiss 5s)',
                      onTap: () => Browser.enqueueBanner(
                        context,
                        (removableCallback) {
                          return const ColoredBox(
                            color: Color(0xFFF59E0B),
                            child: Padding(
                              padding: EdgeInsets.all(12),
                              child: Text(
                                '🔔 Real-time Notification Banner (Auto-closes in 5s)',
                                style: TextStyle(
                                  color: Color(0xFF1E293B),
                                  fontWeight: FontWeight.bold,
                                ),
                                textDirection: TextDirection.ltr,
                              ),
                            ),
                          );
                        },
                        topPadding: 0,
                      ),
                    ),
                    _ExampleButton(
                      text: 'Enqueue Interactive Banner (Duration 0 + Close Button)',
                      onTap: () => Browser.enqueueBanner(
                        context,
                        (removableCallback) {
                          return Container(
                            margin: const EdgeInsets.symmetric(
                              horizontal: 16,
                              vertical: 8,
                            ),
                            padding: const EdgeInsets.symmetric(
                              horizontal: 16,
                              vertical: 12,
                            ),
                            decoration: BoxDecoration(
                              color: const Color(0xFF1E293B),
                              borderRadius: BorderRadius.circular(12),
                              boxShadow: const [
                                BoxShadow(
                                  color: Color(0x33000000),
                                  blurRadius: 12,
                                  offset: Offset(0, 4),
                                ),
                              ],
                            ),
                            child: Row(
                              children: [
                                Container(
                                  width: 26,
                                  height: 26,
                                  alignment: Alignment.center,
                                  decoration: const BoxDecoration(
                                    color: Color(0xFF38BDF8),
                                    shape: BoxShape.circle,
                                  ),
                                  child: const Text(
                                    'i',
                                    style: TextStyle(
                                      color: Color(0xFF0F172A),
                                      fontWeight: FontWeight.w900,
                                      fontSize: 15,
                                    ),
                                    textDirection: TextDirection.ltr,
                                  ),
                                ),
                                const SizedBox(width: 12),
                                const Expanded(
                                  child: Text(
                                    'Persistent Banner (Scroll & Click work below)',
                                    style: TextStyle(
                                      color: Color(0xFFFFFFFF),
                                      fontWeight: FontWeight.w600,
                                      fontSize: 14,
                                    ),
                                    textDirection: TextDirection.ltr,
                                  ),
                                ),
                                const SizedBox(width: 8),
                                GestureDetector(
                                  behavior: HitTestBehavior.opaque,
                                  onTap: removableCallback,
                                  child: Container(
                                    padding: const EdgeInsets.symmetric(
                                      horizontal: 14,
                                      vertical: 8,
                                    ),
                                    decoration: BoxDecoration(
                                      color: const Color(0xFF38BDF8),
                                      borderRadius: BorderRadius.circular(6),
                                    ),
                                    child: const Text(
                                      'Close ✕',
                                      style: TextStyle(
                                        color: Color(0xFF0F172A),
                                        fontWeight: FontWeight.bold,
                                        fontSize: 13,
                                      ),
                                      textDirection: TextDirection.ltr,
                                    ),
                                  ),
                                ),
                              ],
                            ),
                          );
                        },
                        topPadding: 0,
                        duration: Duration.zero,
                      ),
                    ),
                  ],
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}

class _SectionTitle extends StatelessWidget {
  const new({required this.title});
  final String title;

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 8, top: 12),
      child: Text(
        title,
        style: const TextStyle(
          color: Color(0xFFFFFFFF),
          fontSize: 18,
          fontWeight: FontWeight.bold,
        ),
        textDirection: TextDirection.ltr,
      ),
    );
  }
}

class _ExampleButton extends StatelessWidget {
  const new({required this.text, required this.onTap});

  final String text;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 4),
      child: GestureDetector(
        onTap: onTap,
        child: Container(
          width: double.infinity,
          decoration: BoxDecoration(
            color: const Color(0xFFFFFFFF),
            borderRadius: BorderRadius.circular(8),
          ),
          padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 12),
          child: Text(
            text,
            textAlign: TextAlign.center,
            style: const TextStyle(
              color: Color(0xFF000000),
              fontSize: 15,
              fontWeight: FontWeight.w500,
            ),
            textDirection: TextDirection.ltr,
          ),
        ),
      ),
    );
  }
}
