# Changelog

## 0.3.0

- **UI Overhaul**: Replaced the default primary button with `ChicletAnimatedButton` from the `chiclet` package for a satisfying 3D press animation.
- **Text Reveal Animation**: Added a new staggered top-down text reveal animation when pages load.
- **Scaffold Base**: `SmoothOnboarding` now uses a `Scaffold` instead of `Material` as its base widget. This prevents `ScaffoldMessenger` errors when attempting to show SnackBars during onboarding.
- **Button Tweaks**: Changed the back button icon to a minimal `<` (`arrow_back_ios_new_rounded`).
- **Secondary Buttons**: Secondary "Skip" buttons now use `Colors.blue` by default and apply a 150ms delay on press to allow the tap animation to finish visually before navigating.

## 0.2.3

- Fixed preview GIF visibility on pub.dev by using absolute raw GitHub URLs.
- Updated documentation installation snippets to reflect current version.
- Documented per-page notification CTA callbacks in the README and example.
- Refined related package links to keep only published packages.

## 0.2.2

- Fixed preview GIF visibility on pub.dev by using absolute raw GitHub URLs.
- Updated documentation installation snippets to reflect current version.
## 0.2.1

- Improved documentation visibility by adding a preview GIF at the top of the `README.md`.
- Moved preview assets to `assets/readme/` for better project organization.

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
