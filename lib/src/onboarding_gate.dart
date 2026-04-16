import 'package:flutter/material.dart';

import 'onboarding_page.dart';
import 'onboarding_storage.dart';
import 'onboarding_theme.dart';
import 'onboarding_widget.dart';

/// Wraps an app section and shows onboarding only on first launch.
class OnboardingGate extends StatefulWidget {
  /// Creates a gate that switches between onboarding and the provided child.
  const OnboardingGate({
    super.key,
    required this.child,
    required this.pages,
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
    this.buttonLabelAnimationDuration = const Duration(milliseconds: 220),
    this.contentAnimationCurve = Curves.easeOutCubic,
    this.pageTransitionType = OnboardingPageTransitionType.sharedAxis,
    this.closeAnimationDuration = const Duration(milliseconds: 420),
    this.closeAnimationCurve = Curves.easeInOutCubic,
    this.reloadTrigger,
    this.loadingChild,
  });

  /// The widget shown after onboarding is completed.
  final Widget child;

  /// The pages displayed during onboarding.
  final List<OnboardingPage> pages;

  /// Optional theme overrides.
  final OnboardingTheme? theme;

  /// Storage key used to remember that onboarding has been completed.
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

  /// Duration of the primary button label transition.
  final Duration buttonLabelAnimationDuration;

  /// Curve used for onboarding page content transitions.
  final Curve contentAnimationCurve;

  /// Transition style used when switching between pages.
  final OnboardingPageTransitionType pageTransitionType;

  /// Duration of the full-screen close animation on completion.
  final Duration closeAnimationDuration;

  /// Curve used by the close animation on completion.
  final Curve closeAnimationCurve;

  /// Optional external trigger used to force a new first-launch check.
  ///
  /// Change this value when you reset onboarding from outside the gate.
  final Object? reloadTrigger;

  /// Optional placeholder while the first-launch check is running.
  final Widget? loadingChild;

  @override
  State<OnboardingGate> createState() => _OnboardingGateState();
}

class _OnboardingGateState extends State<OnboardingGate> {
  bool _isLoading = true;
  bool _showOnboarding = false;

  @override
  void initState() {
    super.initState();
    _loadGateState();
  }

  @override
  void didUpdateWidget(covariant OnboardingGate oldWidget) {
    super.didUpdateWidget(oldWidget);

    if (oldWidget.storageKey != widget.storageKey ||
        oldWidget.reloadTrigger != widget.reloadTrigger) {
      setState(() {
        _isLoading = true;
      });
      _loadGateState();
    }
  }

  Future<void> _loadGateState() async {
    final bool shouldShow =
        await OnboardingStorage.isFirstLaunch(storageKey: widget.storageKey);
    if (!mounted) {
      return;
    }

    setState(() {
      _showOnboarding = shouldShow;
      _isLoading = false;
    });
  }

  Future<void> _handleComplete() async {
    if (!mounted) {
      return;
    }

    setState(() {
      _showOnboarding = false;
    });
  }

  @override
  Widget build(BuildContext context) {
    if (_isLoading) {
      return widget.loadingChild ?? const SizedBox.shrink();
    }

    if (!_showOnboarding) {
      return widget.child;
    }

    return Stack(
      children: <Widget>[
        Positioned.fill(child: widget.child),
        SmoothOnboarding(
          pages: widget.pages,
          theme: widget.theme,
          storageKey: widget.storageKey,
          persistCompletion: widget.persistCompletion,
          nextButtonLabel: widget.nextButtonLabel,
          doneButtonLabel: widget.doneButtonLabel,
          backButtonTooltip: widget.backButtonTooltip,
          progressSemanticsLabel: widget.progressSemanticsLabel,
          showBackButton: widget.showBackButton,
          progressAnimationDuration: widget.progressAnimationDuration,
          contentAnimationDuration: widget.contentAnimationDuration,
          buttonLabelAnimationDuration: widget.buttonLabelAnimationDuration,
          contentAnimationCurve: widget.contentAnimationCurve,
          pageTransitionType: widget.pageTransitionType,
          closeAnimationDuration: widget.closeAnimationDuration,
          closeAnimationCurve: widget.closeAnimationCurve,
          onComplete: _handleComplete,
        ),
      ],
    );
  }
}
