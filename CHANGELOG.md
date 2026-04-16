# Changelog

## 0.2.0

- Reworked page transition: true simultaneous horizontal slide via `PageView` — no fade, no overlap.
- Close animation now slides the onboarding screen downward, revealing the app content behind it.
- Added `onClosing` callback to `SmoothOnboarding`, fired when the close animation begins.
- Fixed `OnboardingGate` default transition type to `slideHorizontal`.

## 0.1.0

- Initial public release of `smooth_onboarding`.
- Added `SmoothOnboarding`, `OnboardingGate`, `OnboardingController`, `OnboardingPage`, `OnboardingTheme`, and `OnboardingStorage`.
- Added animated progress, dark mode defaults, and first-launch persistence.
- Horizontal slide page transition (no fade) set as default; shared-axis and fade available as alternatives.
- Modern close animation: screen accelerates upward on completion.
