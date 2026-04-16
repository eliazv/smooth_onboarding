import 'dart:async';

import 'package:flutter/material.dart';

import 'onboarding_controller.dart';
import 'onboarding_page.dart';
import 'onboarding_storage.dart';
import 'onboarding_theme.dart';

/// Main onboarding widget with animated progress, navigation and persistence.
class SmoothOnboarding extends StatefulWidget {
  /// Creates the onboarding experience.
  const SmoothOnboarding({
    super.key,
    required this.pages,
    this.controller,
    this.theme,
    this.storageKey = OnboardingStorage.defaultStorageKey,
    this.persistCompletion = true,
    this.nextButtonLabel = 'Avanti',
    this.doneButtonLabel = 'Inizia',
    this.backButtonTooltip = 'Indietro',
    this.onComplete,
  }) : assert(pages.length > 0, 'At least one onboarding page is required.');

  /// The pages shown by the onboarding flow.
  final List<OnboardingPage> pages;

  /// Optional controller used to navigate the flow.
  final OnboardingController? controller;

  /// Optional theme overrides.
  final OnboardingTheme? theme;

  /// Key used by [OnboardingStorage].
  final String storageKey;

  /// Whether the completion flag should be persisted automatically.
  final bool persistCompletion;

  /// Default label used for intermediate pages.
  final String nextButtonLabel;

  /// Default label used for the last page.
  final String doneButtonLabel;

  /// Tooltip used by the back button.
  final String backButtonTooltip;

  /// Called after the user reaches the last page and completes onboarding.
  final FutureOr<void> Function()? onComplete;

  @override
  State<SmoothOnboarding> createState() => _SmoothOnboardingState();
}

class _SmoothOnboardingState extends State<SmoothOnboarding> {
  late OnboardingController _controller;
  bool _ownsController = false;
  bool _isCompleting = false;

  @override
  void initState() {
    super.initState();
    _initializeController();
  }

  @override
  void didUpdateWidget(covariant SmoothOnboarding oldWidget) {
    super.didUpdateWidget(oldWidget);

    if (oldWidget.controller != widget.controller) {
      if (_ownsController) {
        _controller.removeListener(_onControllerChanged);
        _controller.dispose();
      } else {
        _controller.removeListener(_onControllerChanged);
      }

      _initializeController();
      return;
    }

    if (oldWidget.pages.length != widget.pages.length) {
      _controller.attach(widget.pages.length);
    }
  }

  @override
  void dispose() {
    _controller.removeListener(_onControllerChanged);
    if (_ownsController) {
      _controller.dispose();
    }

    super.dispose();
  }

  void _initializeController() {
    final OnboardingController controller =
        widget.controller ?? OnboardingController();
    _ownsController = widget.controller == null;
    _controller = controller;
    _controller.attach(widget.pages.length);
    _controller.addListener(_onControllerChanged);
  }

  void _onControllerChanged() {
    if (mounted) {
      setState(() {});
    }
  }

  Future<void> _complete() async {
    if (_isCompleting) {
      return;
    }

    setState(() {
      _isCompleting = true;
    });

    try {
      if (widget.persistCompletion) {
        await OnboardingStorage.markCompleted(storageKey: widget.storageKey);
      }

      final FutureOr<void> Function()? callback = widget.onComplete;
      if (callback != null) {
        final FutureOr<void> result = callback();
        if (result is Future<void>) {
          await result;
        }
      }
    } finally {
      if (mounted) {
        setState(() {
          _isCompleting = false;
        });
      }
    }
  }

  void _handlePrimaryAction() {
    if (_controller.isLastPage) {
      unawaited(_complete());
      return;
    }

    _controller.next();
  }

  void _handleBack() {
    _controller.previous();
  }

  @override
  Widget build(BuildContext context) {
    final OnboardingTheme resolvedTheme =
        (widget.theme ?? const OnboardingTheme())
            .merge(OnboardingTheme.fallback(context));

    return AnimatedBuilder(
      animation: _controller,
      builder: (BuildContext context, Widget? child) {
        final OnboardingPage activePage = widget.pages[_controller.currentPage];
        final String actionLabel = activePage.buttonLabel ??
            (_controller.isLastPage
                ? widget.doneButtonLabel
                : widget.nextButtonLabel);

        return Material(
          color: resolvedTheme.backgroundColor,
          child: SafeArea(
            child: Padding(
              padding: resolvedTheme.pagePadding,
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.stretch,
                children: <Widget>[
                  Row(
                    children: <Widget>[
                      AnimatedSize(
                        duration: const Duration(milliseconds: 220),
                        curve: Curves.easeOutCubic,
                        child: SizedBox(
                          width: _controller.isFirstPage ? 0 : 40,
                          child: _controller.isFirstPage
                              ? const SizedBox.shrink()
                              : IconButton(
                                  onPressed: _handleBack,
                                  splashRadius: 18,
                                  padding: EdgeInsets.zero,
                                  constraints: const BoxConstraints.tightFor(
                                      width: 40, height: 40),
                                  icon: Icon(
                                    Icons.arrow_back_rounded,
                                    size: 20,
                                    color: resolvedTheme.progressColor,
                                  ),
                                  tooltip: widget.backButtonTooltip,
                                ),
                        ),
                      ),
                      Expanded(
                        child: Semantics(
                          label: 'Avanzamento onboarding',
                          child: ClipRRect(
                            borderRadius: BorderRadius.circular(999),
                            child: Container(
                              height: resolvedTheme.progressHeight,
                              color: resolvedTheme.progressTrackColor,
                              child: TweenAnimationBuilder<double>(
                                tween: Tween<double>(
                                    begin: 0, end: _controller.progress),
                                duration: const Duration(milliseconds: 320),
                                curve: Curves.easeOutCubic,
                                builder: (BuildContext context, double value,
                                    Widget? child) {
                                  return Align(
                                    alignment: Alignment.centerLeft,
                                    child: FractionallySizedBox(
                                      widthFactor: value.clamp(0.0, 1.0),
                                      child: Container(
                                        decoration: BoxDecoration(
                                          color: resolvedTheme.progressColor,
                                          borderRadius:
                                              BorderRadius.circular(999),
                                        ),
                                      ),
                                    ),
                                  );
                                },
                              ),
                            ),
                          ),
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: 28),
                  Expanded(
                    child: AnimatedSwitcher(
                      duration: const Duration(milliseconds: 280),
                      switchInCurve: Curves.easeOutCubic,
                      switchOutCurve: Curves.easeInCubic,
                      transitionBuilder:
                          (Widget child, Animation<double> animation) {
                        final Animation<Offset> slide = Tween<Offset>(
                          begin: const Offset(0.03, 0.02),
                          end: Offset.zero,
                        ).animate(animation);

                        return FadeTransition(
                          opacity: animation,
                          child: SlideTransition(position: slide, child: child),
                        );
                      },
                      child: _OnboardingPageView(
                        key: ValueKey<int>(_controller.currentPage),
                        page: activePage,
                        titleStyle: resolvedTheme.titleStyle,
                        bodyStyle: resolvedTheme.bodyStyle,
                        titleColor: resolvedTheme.titleColor,
                        bodyColor: resolvedTheme.bodyColor,
                      ),
                    ),
                  ),
                  const SizedBox(height: 24),
                  Align(
                    alignment: Alignment.center,
                    child: ConstrainedBox(
                      constraints: BoxConstraints(
                          maxWidth: resolvedTheme.buttonMaxWidth),
                      child: SizedBox(
                        height: resolvedTheme.buttonHeight,
                        width: double.infinity,
                        child: ElevatedButton(
                          onPressed:
                              _isCompleting ? null : _handlePrimaryAction,
                          style: ElevatedButton.styleFrom(
                            backgroundColor: resolvedTheme.buttonColor,
                            foregroundColor: resolvedTheme.buttonTextColor,
                            shape: RoundedRectangleBorder(
                              borderRadius: resolvedTheme.buttonBorderRadius,
                            ),
                            elevation: 0,
                            textStyle: resolvedTheme.buttonStyle,
                          ),
                          child: AnimatedSwitcher(
                            duration: const Duration(milliseconds: 220),
                            transitionBuilder:
                                (Widget child, Animation<double> animation) {
                              final Animation<Offset> slide = Tween<Offset>(
                                begin: const Offset(0, 0.18),
                                end: Offset.zero,
                              ).animate(animation);

                              return FadeTransition(
                                opacity: animation,
                                child: SlideTransition(
                                    position: slide, child: child),
                              );
                            },
                            child: Text(
                              actionLabel,
                              key: ValueKey<String>(actionLabel),
                            ),
                          ),
                        ),
                      ),
                    ),
                  ),
                ],
              ),
            ),
          ),
        );
      },
    );
  }
}

class _OnboardingPageView extends StatelessWidget {
  const _OnboardingPageView({
    super.key,
    required this.page,
    required this.titleStyle,
    required this.bodyStyle,
    required this.titleColor,
    required this.bodyColor,
  });

  final OnboardingPage page;
  final TextStyle? titleStyle;
  final TextStyle? bodyStyle;
  final Color? titleColor;
  final Color? bodyColor;

  @override
  Widget build(BuildContext context) {
    return LayoutBuilder(
      builder: (BuildContext context, BoxConstraints constraints) {
        return SingleChildScrollView(
          physics: const BouncingScrollPhysics(),
          child: ConstrainedBox(
            constraints: BoxConstraints(minHeight: constraints.maxHeight),
            child: Padding(
              padding: const EdgeInsets.only(top: 24, bottom: 12),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                mainAxisAlignment: MainAxisAlignment.center,
                children: <Widget>[
                  Text(
                    page.title,
                    style: titleStyle?.copyWith(color: titleColor) ??
                        Theme.of(context).textTheme.headlineMedium?.copyWith(
                              fontWeight: FontWeight.w700,
                              color: titleColor,
                            ),
                  ),
                  const SizedBox(height: 20),
                  DefaultTextStyle.merge(
                    style: bodyStyle?.copyWith(color: bodyColor) ??
                        Theme.of(context).textTheme.bodyLarge?.copyWith(
                              height: 1.45,
                              color: bodyColor,
                            ) ??
                        TextStyle(color: bodyColor),
                    child: page.body,
                  ),
                ],
              ),
            ),
          ),
        );
      },
    );
  }
}
