import 'dart:async';

import 'package:flutter/material.dart';
import 'package:flutter/services.dart';

import 'onboarding_controller.dart';
import 'onboarding_page.dart';
import 'onboarding_storage.dart';
import 'onboarding_theme.dart';

/// Transition styles available for onboarding page changes.
enum OnboardingPageTransitionType {
  /// New page enters from the side, previous page exits to the opposite side.
  slideHorizontal,

  /// Shared-axis transition with fade, scale and directional motion.
  sharedAxis,

  /// Cross-fade transition between pages.
  fade,
}

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
    this.nextButtonLabel = 'Next',
    this.doneButtonLabel = 'Get started',
    this.backButtonTooltip = 'Back',
    this.progressSemanticsLabel = 'Onboarding progress',
    this.showBackButton = true,
    this.progressAnimationDuration = const Duration(milliseconds: 320),
    this.contentAnimationDuration = const Duration(milliseconds: 280),
    this.contentAnimationCurve = Curves.easeOutCubic,
    this.buttonLabelAnimationDuration = const Duration(milliseconds: 220),
    this.pageTransitionType = OnboardingPageTransitionType.slideHorizontal,
    this.closeAnimationDuration = const Duration(milliseconds: 480),
    this.closeAnimationCurve = Curves.easeInCubic,
    this.onComplete,
    this.onClosing,
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

  /// Accessibility label used by the top progress bar.
  final String progressSemanticsLabel;

  /// Whether the back button should be visible when not on the first page.
  final bool showBackButton;

  /// Duration of the progress fill animation.
  final Duration progressAnimationDuration;

  /// Duration of onboarding page content transitions.
  final Duration contentAnimationDuration;

  /// Curve used for onboarding page content transitions.
  final Curve contentAnimationCurve;

  /// Duration of the primary button label transition.
  final Duration buttonLabelAnimationDuration;

  /// Transition style used when switching between pages.
  final OnboardingPageTransitionType pageTransitionType;

  /// Duration of the full-screen close animation on completion.
  final Duration closeAnimationDuration;

  /// Curve used by the close animation on completion.
  final Curve closeAnimationCurve;

  /// Called after the user reaches the last page and completes onboarding.
  final FutureOr<void> Function()? onComplete;

  /// Called when the close animation begins (before [onComplete]).
  final VoidCallback? onClosing;

  @override
  State<SmoothOnboarding> createState() => _SmoothOnboardingState();
}

class _SmoothOnboardingState extends State<SmoothOnboarding> {
  late OnboardingController _controller;
  late PageController _pageController;

  bool _ownsController = false;
  bool _isCompleting = false;
  bool _isClosing = false;
  int _lastPageIndex = 0;
  int _navigationDirection = 1;

  @override
  void initState() {
    super.initState();
    _pageController = PageController();
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
    _pageController.dispose();
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
    _lastPageIndex = _controller.currentPage;
    _navigationDirection = 1;
    _controller.addListener(_onControllerChanged);
  }

  void _onControllerChanged() {
    final int nextPage = _controller.currentPage;
    _navigationDirection = nextPage >= _lastPageIndex ? 1 : -1;
    _lastPageIndex = nextPage;

    if (!mounted) return;

    if (widget.pageTransitionType ==
            OnboardingPageTransitionType.slideHorizontal &&
        _pageController.hasClients) {
      _pageController.animateToPage(
        nextPage,
        duration: widget.contentAnimationDuration,
        curve: widget.contentAnimationCurve,
      );
    }

    setState(() {});
  }

  Future<void> _complete() async {
    if (_isCompleting) {
      return;
    }

    setState(() {
      _isCompleting = true;
      _isClosing = true;
    });

    widget.onClosing?.call();

    try {
      await Future<void>.delayed(widget.closeAnimationDuration);

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
          _isClosing = false;
        });
      }
    }
  }

  Future<void> _handlePrimaryAction() async {
    if (_isCompleting) {
      return;
    }

    final OnboardingPage activePage = widget.pages[_controller.currentPage];

    unawaited(_safeHaptic(HapticFeedback.lightImpact));

    if (activePage.onPrimaryPressed != null) {
      await activePage.onPrimaryPressed!.call();
      if (!mounted) {
        return;
      }

      if (!activePage.advanceOnPrimaryAction) {
        return;
      }
    }

    if (_controller.isLastPage) {
      unawaited(_complete());
      return;
    }

    _controller.next();
  }

  Future<void> _handleSecondaryAction(OnboardingPage activePage) async {
    if (_isCompleting) {
      return;
    }

    unawaited(_safeHaptic(HapticFeedback.selectionClick));

    if (activePage.onSecondaryPressed != null) {
      await activePage.onSecondaryPressed!.call();
      if (!mounted) {
        return;
      }
      return;
    }

    if (_controller.isLastPage) {
      unawaited(_complete());
      return;
    }

    _controller.next();
  }

  Future<void> _safeHaptic(Future<void> Function() callback) async {
    try {
      await callback();
    } on MissingPluginException {
      // Haptic channel might be unavailable in tests or unsupported platforms.
    }
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
        final bool canGoBack =
            widget.showBackButton && !_controller.isFirstPage;

        return AnimatedSlide(
          duration: widget.closeAnimationDuration,
          curve: widget.closeAnimationCurve,
          offset: _isClosing ? const Offset(0, 1) : Offset.zero,
          child: Material(
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
                          duration: const Duration(milliseconds: 180),
                          curve: Curves.easeOutCubic,
                          child: SizedBox(
                            width: canGoBack ? 32 : 0,
                            height: 32,
                            child: canGoBack
                                ? IconButton(
                                    onPressed: _handleBack,
                                    splashRadius: 16,
                                    padding: EdgeInsets.zero,
                                    visualDensity: VisualDensity.compact,
                                    constraints: const BoxConstraints.tightFor(
                                      width: 32,
                                      height: 32,
                                    ),
                                    iconSize: 18,
                                    icon: Icon(
                                      Icons.arrow_back_rounded,
                                      color: resolvedTheme.progressColor,
                                    ),
                                    tooltip: widget.backButtonTooltip,
                                  )
                                : const SizedBox.shrink(),
                          ),
                        ),
                        Expanded(
                          child: Semantics(
                            label: widget.progressSemanticsLabel,
                            child: ClipRRect(
                              borderRadius: BorderRadius.circular(999),
                              child: Container(
                                height: resolvedTheme.progressHeight,
                                color: resolvedTheme.progressTrackColor,
                                child: TweenAnimationBuilder<double>(
                                  tween: Tween<double>(
                                      begin: 0, end: _controller.progress),
                                  duration: widget.progressAnimationDuration,
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
                      child: widget.pageTransitionType ==
                              OnboardingPageTransitionType.slideHorizontal
                          ? PageView(
                              controller: _pageController,
                              physics: const NeverScrollableScrollPhysics(),
                              children: widget.pages
                                  .map(
                                    (OnboardingPage p) => _OnboardingPageView(
                                      page: p,
                                      titleStyle: resolvedTheme.titleStyle,
                                      bodyStyle: resolvedTheme.bodyStyle,
                                      titleColor: resolvedTheme.titleColor,
                                      bodyColor: resolvedTheme.bodyColor,
                                    ),
                                  )
                                  .toList(),
                            )
                          : AnimatedSwitcher(
                              duration: widget.contentAnimationDuration,
                              switchInCurve: widget.contentAnimationCurve,
                              switchOutCurve: widget.contentAnimationCurve,
                              layoutBuilder: (
                                Widget? currentChild,
                                List<Widget> previousChildren,
                              ) {
                                return Stack(
                                  fit: StackFit.expand,
                                  clipBehavior: Clip.hardEdge,
                                  children: <Widget>[
                                    ...previousChildren,
                                    if (currentChild != null) currentChild,
                                  ],
                                );
                              },
                              transitionBuilder:
                                  (Widget child, Animation<double> animation) {
                                if (widget.pageTransitionType ==
                                    OnboardingPageTransitionType.fade) {
                                  return FadeTransition(
                                    opacity: animation,
                                    child: child,
                                  );
                                }

                                final bool isIncoming = child.key ==
                                    ValueKey<int>(_controller.currentPage);
                                final double direction =
                                    _navigationDirection.toDouble();
                                final Animation<double> motionAnimation =
                                    isIncoming
                                        ? animation
                                        : ReverseAnimation(animation);
                                final Animation<double> curvedMotion =
                                    CurvedAnimation(
                                  parent: motionAnimation,
                                  curve: widget.contentAnimationCurve,
                                );

                                final Animation<Offset> slide = Tween<Offset>(
                                  begin: isIncoming
                                      ? Offset(direction * 0.08, 0)
                                      : Offset.zero,
                                  end: isIncoming
                                      ? Offset.zero
                                      : Offset(-direction * 0.08, 0),
                                ).animate(curvedMotion);

                                final Animation<double> scale = Tween<double>(
                                  begin: isIncoming ? 0.985 : 1,
                                  end: isIncoming ? 1 : 0.985,
                                ).animate(CurvedAnimation(
                                  parent: motionAnimation,
                                  curve: Curves.easeOutCubic,
                                ));

                                return FadeTransition(
                                  opacity: animation,
                                  child: SlideTransition(
                                    position: slide,
                                    child: ScaleTransition(
                                      scale: scale,
                                      child: child,
                                    ),
                                  ),
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
                              duration: widget.buttonLabelAnimationDuration,
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
                    if (activePage.secondaryButtonLabel != null) ...<Widget>[
                      const SizedBox(height: 8),
                      Center(
                        child: TextButton(
                          onPressed: _isCompleting
                              ? null
                              : () => _handleSecondaryAction(activePage),
                          style: TextButton.styleFrom(
                            foregroundColor: resolvedTheme.bodyColor ??
                                Theme.of(context).colorScheme.onSurfaceVariant,
                            textStyle: Theme.of(context)
                                .textTheme
                                .labelLarge
                                ?.copyWith(fontWeight: FontWeight.w600),
                          ),
                          child: Text(activePage.secondaryButtonLabel!),
                        ),
                      ),
                    ],
                  ],
                ),
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
