import 'package:browser_example/app_traces.dart';
import 'package:browser_example/pop_result_args.dart';
import 'package:browser_example/push_args.dart';
import 'package:browser_router/browser.dart';
import 'package:flutter/material.dart';

class HomeScreen extends StatefulWidget {
  const HomeScreen({super.key});

  @override
  State<HomeScreen> createState() => _HomeScreenState();
}

class _HomeScreenState extends State<HomeScreen> {
  String? _eventMessage;

  @override
  Widget build(BuildContext context) {
    return Browser.watch(
      onAppear: (context, deepLink) {
        // Defer the state update until after the build phase is complete.

        if (!mounted) return; // Ensure the widget is still in the tree.

        // First, handle pop arguments, as they are a one-time event.
        final popArgs = context.getArgumentAndClean<PopResultArgs>();
        if (popArgs != null) {
          WidgetsBinding.instance.addPostFrameCallback((_) {
            setState(() {
              _eventMessage = '[From Pop]: ${popArgs.result}';
            });
          });
          return; // Process one event at a time
        }

        // Second, handle the deep link parameter from the callback.
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
                style: TextStyle(color: Color(0xFFFFFFFF), fontSize: 24),
                textDirection: TextDirection.ltr,
              ),
              if (_eventMessage != null)
                Padding(
                  padding: const EdgeInsets.only(top: 16),
                  child: Text(
                    'Last Event: "$_eventMessage"',
                    style:
                        const TextStyle(color: Color(0xFFFFFFFF), fontSize: 16),
                    textDirection: TextDirection.ltr,
                  ),
                ),
              const SizedBox(height: 16),
              Expanded(
                child: ListView(
                  children: [
                    // --- Argument Examples ---
                    const _SectionTitle(title: 'Argument & DeepLink Examples'),
                    _ExampleButton(
                      text: '1. Push with Arguments',
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
                            PushArgs(
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
                    const SizedBox(height: 24),

                    // --- Semantic Navigation (Trace) Example ---
                    const _SectionTitle(
                      title: 'Semantic Navigation (Trace) Example',
                    ),
                    _ExampleButton(
                      text: 'Push with a Trace Object',
                      onTap: () => AppTrace.toPushArgs(
                        message: 'Hello from a Trace object!',
                        source: 'AppTrace',
                      ).push(context),
                    ),
                    const SizedBox(height: 24),

                    // --- Presentation (TraceRoute) Examples ---
                    const _SectionTitle(
                      title: 'Presentation (TraceRoute) Examples',
                    ),
                    _ExampleButton(
                      text: 'Present as a Popup',
                      onTap: () => AppTrace.asPopup().push(context),
                    ),
                    _ExampleButton(
                      text: 'Present as a sliding Sheet',
                      onTap: () => AppTrace.asSheet().push(context),
                    ),
                    const SizedBox(height: 24),

                    // --- Transition Examples ---
                    const _SectionTitle(title: 'Transition Examples (as Page)'),
                    ...RouteTransition.values.map((transition) {
                      return _ExampleButton(
                        text: 'Push with ${transition.name}',
                        onTap: () => AppTrace.toPushArgs(
                          message: 'Pushed with ${transition.name}',
                          source: 'Transition Example',
                          transition: transition,
                        ).push(context),
                      );
                    }),
                    const SizedBox(height: 24),
                    // --- overlay ---
                    const _SectionTitle(
                      title: 'Overlay',
                    ),
                    _ExampleButton(
                      text: 'EnqueueBanner',
                      onTap: () => Browser.enqueueBanner(
                        context,
                        (removableCallback) {
                          return const ColoredBox(
                            color: Colors.amber,
                            child: Row(
                              children: [
                                _SectionTitle(
                                  title: 'Overlay',
                                ),
                              ],
                            ),
                          );
                        },
                        topPadding: 0,
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
  const _SectionTitle({required this.title});
  final String title;

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 8, top: 8),
      child: Text(
        title,
        style: const TextStyle(
          color: Color(0xFFFFFFFF),
          fontSize: 20,
          fontWeight: FontWeight.bold,
        ),
        textDirection: TextDirection.ltr,
      ),
    );
  }
}

class _ExampleButton extends StatelessWidget {
  const _ExampleButton({required this.text, required this.onTap});

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
          color: const Color(0xFFFFFFFF),
          padding: const EdgeInsets.all(12),
          child: Text(
            text,
            textAlign: TextAlign.center,
            style: const TextStyle(color: Color(0xFF000000), fontSize: 16),
            textDirection: TextDirection.ltr,
          ),
        ),
      ),
    );
  }
}
