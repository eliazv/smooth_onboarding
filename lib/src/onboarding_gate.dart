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

    return SmoothOnboarding(
      pages: widget.pages,
      theme: widget.theme,
      storageKey: widget.storageKey,
      persistCompletion: widget.persistCompletion,
      onComplete: _handleComplete,
    );
  }
}
