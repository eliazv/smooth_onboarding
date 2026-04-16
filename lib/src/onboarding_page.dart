import 'package:flutter/widgets.dart';

/// Describes a single page displayed by the onboarding flow.
@immutable
class OnboardingPage {
  /// Creates a new onboarding page.
  const OnboardingPage({
    required this.title,
    required this.body,
    this.buttonLabel,
  });

  /// The page title.
  final String title;

  /// The widget displayed as the page body.
  final Widget body;

  /// Optional label for the primary button on this page.
  final String? buttonLabel;
}
