import 'package:flutter/material.dart';

/// Styling options used by the onboarding widget.
@immutable
class OnboardingTheme {
  /// Creates a theme configuration for the onboarding UI.
  const OnboardingTheme({
    this.progressColor,
    this.progressTrackColor,
    this.backgroundColor,
    this.buttonColor,
    this.buttonTextColor,
    this.titleColor,
    this.bodyColor,
    this.titleStyle,
    this.bodyStyle,
    this.buttonStyle,
    this.pagePadding = const EdgeInsets.fromLTRB(24, 20, 24, 28),
    this.progressHeight = 8,
    this.buttonHeight = 56,
    this.buttonMaxWidth = 420,
    this.buttonBorderRadius = const BorderRadius.all(Radius.circular(18)),
  });

  /// Blue accent used by the progress bar and button.
  final Color? progressColor;

  /// Background of the progress track.
  final Color? progressTrackColor;

  /// Page background color.
  final Color? backgroundColor;

  /// Primary button background color.
  final Color? buttonColor;

  /// Primary button foreground color.
  final Color? buttonTextColor;

  /// Title color.
  final Color? titleColor;

  /// Body color.
  final Color? bodyColor;

  /// Optional title text style.
  final TextStyle? titleStyle;

  /// Optional body text style.
  final TextStyle? bodyStyle;

  /// Optional primary button text style.
  final TextStyle? buttonStyle;

  /// Padding applied to the onboarding layout.
  final EdgeInsetsGeometry pagePadding;

  /// Height of the top progress bar.
  final double progressHeight;

  /// Height of the primary button.
  final double buttonHeight;

  /// Maximum width of the floating button.
  final double buttonMaxWidth;

  /// Border radius of the primary button.
  final BorderRadius buttonBorderRadius;

  /// Returns a copy of this theme with the provided values replaced.
  OnboardingTheme copyWith({
    Color? progressColor,
    Color? progressTrackColor,
    Color? backgroundColor,
    Color? buttonColor,
    Color? buttonTextColor,
    Color? titleColor,
    Color? bodyColor,
    TextStyle? titleStyle,
    TextStyle? bodyStyle,
    TextStyle? buttonStyle,
    EdgeInsetsGeometry? pagePadding,
    double? progressHeight,
    double? buttonHeight,
    double? buttonMaxWidth,
    BorderRadius? buttonBorderRadius,
  }) {
    return OnboardingTheme(
      progressColor: progressColor ?? this.progressColor,
      progressTrackColor: progressTrackColor ?? this.progressTrackColor,
      backgroundColor: backgroundColor ?? this.backgroundColor,
      buttonColor: buttonColor ?? this.buttonColor,
      buttonTextColor: buttonTextColor ?? this.buttonTextColor,
      titleColor: titleColor ?? this.titleColor,
      bodyColor: bodyColor ?? this.bodyColor,
      titleStyle: titleStyle ?? this.titleStyle,
      bodyStyle: bodyStyle ?? this.bodyStyle,
      buttonStyle: buttonStyle ?? this.buttonStyle,
      pagePadding: pagePadding ?? this.pagePadding,
      progressHeight: progressHeight ?? this.progressHeight,
      buttonHeight: buttonHeight ?? this.buttonHeight,
      buttonMaxWidth: buttonMaxWidth ?? this.buttonMaxWidth,
      buttonBorderRadius: buttonBorderRadius ?? this.buttonBorderRadius,
    );
  }

  /// Merges this theme over the given [fallback].
  OnboardingTheme merge(OnboardingTheme fallback) {
    return fallback.copyWith(
      progressColor: progressColor,
      progressTrackColor: progressTrackColor,
      backgroundColor: backgroundColor,
      buttonColor: buttonColor,
      buttonTextColor: buttonTextColor,
      titleColor: titleColor,
      bodyColor: bodyColor,
      titleStyle: titleStyle,
      bodyStyle: bodyStyle,
      buttonStyle: buttonStyle,
      pagePadding: pagePadding,
      progressHeight: progressHeight,
      buttonHeight: buttonHeight,
      buttonMaxWidth: buttonMaxWidth,
      buttonBorderRadius: buttonBorderRadius,
    );
  }

  /// Creates the default theme from the current app theme.
  factory OnboardingTheme.fallback(BuildContext context) {
    final ThemeData theme = Theme.of(context);
    final bool isDark = theme.brightness == Brightness.dark;
    const Color accent = Colors.blue;

    return OnboardingTheme(
      progressColor: accent,
      progressTrackColor: accent.withValues(alpha: 0.16),
      backgroundColor: isDark ? const Color(0xFF1F1F1F) : Colors.white,
      buttonColor: accent,
      buttonTextColor: Colors.white,
      titleColor: theme.colorScheme.onSurface,
      bodyColor: theme.colorScheme.onSurfaceVariant,
      titleStyle: theme.textTheme.headlineMedium?.copyWith(
        fontWeight: FontWeight.w700,
        color: theme.colorScheme.onSurface,
      ),
      bodyStyle: theme.textTheme.bodyLarge?.copyWith(
        height: 1.45,
        color: theme.colorScheme.onSurfaceVariant,
      ),
      buttonStyle: theme.textTheme.titleMedium?.copyWith(
        fontWeight: FontWeight.w700,
        color: Colors.white,
      ),
    );
  }
}
