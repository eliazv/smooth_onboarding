import 'package:flutter/widgets.dart';

/// Describes a single page displayed by the onboarding flow.
@immutable
class OnboardingPage {
  /// Creates a new onboarding page.
  const OnboardingPage({
    required this.title,
    required this.body,
    this.buttonLabel,
    this.onPrimaryPressed,
    this.advanceOnPrimaryAction = true,
    this.secondaryButtonLabel,
    this.onSecondaryPressed,
  });

  /// The page title.
  final String title;

  /// The widget displayed as the page body.
  final Widget body;

  /// Optional label for the primary button on this page.
  final String? buttonLabel;

  /// Optional custom action executed when the primary button is pressed.
  ///
  /// If null, the flow advances to the next page (or completes on last page).
  final Future<void> Function()? onPrimaryPressed;

  /// Whether the flow should auto-advance after [onPrimaryPressed].
  ///
  /// Ignored when [onPrimaryPressed] is null because default behavior
  /// already advances/completes.
  final bool advanceOnPrimaryAction;

  /// Optional label for a lightweight secondary action shown under the
  /// primary button (for example "Skip").
  final String? secondaryButtonLabel;

  /// Optional callback for the secondary action.
  ///
  /// If null and [secondaryButtonLabel] is set, tapping the secondary button
  /// advances to next page or completes when on the last page.
  final Future<void> Function()? onSecondaryPressed;
}
