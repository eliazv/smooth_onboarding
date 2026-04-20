# smooth_onboarding

[![pub package](https://img.shields.io/pub/v/smooth_onboarding.svg)](https://pub.dev/packages/smooth_onboarding)
[![likes](https://img.shields.io/pub/likes/smooth_onboarding)](https://pub.dev/packages/smooth_onboarding)
[![Buy Me a Coffee](https://img.shields.io/badge/Buy%20me%20a%20coffee-support-FFDD00?logo=buymeacoffee&logoColor=000)](https://buymeacoffee.com/elizavatta)

A smooth, production-ready onboarding UI for Flutter apps.

✨ Smooth animations • 🎯 Simple API • 📱 Production-ready

Build beautiful onboarding flows in minutes, with smooth animations and zero boilerplate.

![Onboarding Preview](https://raw.githubusercontent.com/eliazv/smooth_onboarding/master/assets/readme/video_example.gif)

## Demo

See it in action: the example app uses built-in shapes and icons to stay lightweight while providing a sleek, smooth onboarding experience.

---

## Why smooth_onboarding?

Most onboarding packages are either too basic or too rigid.

`smooth_onboarding` focuses on:

- **Clean, modern UI** out of the box
- **Smooth, production-level animations**
- **Simple API** that integrates easily in real apps

## Features

- Animated progress bar with page-based progress.
- Optional back button that appears from the second page onward.
- Floating primary button that changes from `Next` to `Get started` on the last page.
- Built-in haptic feedback on primary and secondary actions.
- Per-page primary action callback for login/paywall/micro-setup flows.
- Per-page text-only secondary action (for skippable steps like `Salta`).
- First-launch persistence via `SharedPreferences`.
- Dark mode aware default styling.
- Fully customizable page content with any widget.
- Customizable labels (`next`, `done`, `back` tooltip).
- Optional back button toggle (`showBackButton`).
- Configurable animation durations and progress semantics label.
- Configurable page transition style: horizontal slide (default), shared-axis, or fade.
- Modern completion animation that slides the whole screen upward.
- External reload trigger for programmatic onboarding reset.

## Installation

```yaml
dependencies:
  smooth_onboarding: ^0.2.2
```

## Usage

```dart
import 'package:flutter/material.dart';
import 'package:smooth_onboarding/smooth_onboarding.dart';

class AppRoot extends StatelessWidget {
  const AppRoot({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      home: OnboardingGate(
        storageKey: OnboardingStorage.defaultStorageKey,
        pages: const [
          OnboardingPage(
            title: 'Welcome',
            body: Text('Discover the app in a few steps.'),
          ),
          OnboardingPage(
            title: 'Customize',
            body: Icon(Icons.palette_outlined, size: 72),
          ),
          OnboardingPage(
            title: 'Ready',
            body: Text('Initial setup is complete.'),
          ),
        ],
        child: const Scaffold(
          body: Center(child: Text('Main app content')),
        ),
      ),
    );
  }
}
```

If you want to control the first-launch check yourself, use `OnboardingStorage`:

```dart
final showOnboarding = await OnboardingStorage.shouldShowOnboarding();
if (showOnboarding) {
  // Show onboarding.
}
```

## Customization

You can customize texts, colors and layout through page data, labels and theme:

```dart
OnboardingGate(
  pages: pages,
  showBackButton: true,
  nextButtonLabel: 'Next',
  doneButtonLabel: 'Get started',
  backButtonTooltip: 'Back',
  progressSemanticsLabel: 'Onboarding progress',
  progressAnimationDuration: const Duration(milliseconds: 360),
  contentAnimationDuration: const Duration(milliseconds: 300),
  contentAnimationCurve: Curves.easeOutCubic,
  pageTransitionType: OnboardingPageTransitionType.slideHorizontal,
  buttonLabelAnimationDuration: const Duration(milliseconds: 240),
  closeAnimationDuration: const Duration(milliseconds: 420),
  closeAnimationCurve: Curves.easeInCubic,
  theme: const OnboardingTheme(
    backgroundColor: Colors.white,
    progressColor: Colors.blue,
    buttonColor: Colors.blue,
    progressHeight: 8,
  ),
  child: const HomePage(),
)
```

Per-page custom CTA example (login with skip):

```dart
OnboardingPage(
  title: 'Salva tutto in sicurezza',
  body: const Text('Accedi per sincronizzare su tutti i dispositivi.'),
  buttonLabel: 'Continua con Google',
  secondaryButtonLabel: 'Salta',
  onPrimaryPressed: () async {
    // Trigger your Google sign-in flow.
  },
)
```

Reset + force gate re-check:

```dart
await OnboardingStorage.reset();
setState(() {
  reloadToken++;
});
```

Then pass `reloadTrigger: reloadToken` to `OnboardingGate`.

## Example behavior

The package is designed around these defaults:

- White background in light mode.
- Dark gray background in dark mode.
- Blue progress bar and blue primary button.
- Horizontal slide transitions between pages (no fade).
- Full-screen close animation that moves the onboarding upward.
- Small back arrow with a compact hit area.

## Used in production

This package is used in real Flutter applications.

## Development

For local checks, run the usual Flutter commands from the package root:

```bash
flutter analyze
flutter test
```

---

## 👨‍💻 Author

Created by Elia Zavatta

I build production-ready Flutter apps and reusable UI components.

👉 Need help integrating this package or building your app?
Feel free to reach out:

- GitHub: https://github.com/eliazv
- LinkedIn: https://www.linkedin.com/in/eliazavatta/
- Email: info@eliazavatta.it

---

## ⭐ Support

If you find this package useful:

- ⭐ Star the repo on GitHub
- 👍 Like it on pub.dev
- 🐛 Open issues or suggest improvements

---

## Related smooth packages

- [smooth_bottom_sheet](https://pub.dev/packages/smooth_bottom_sheet)
- [smooth_paywall](https://pub.dev/packages/smooth_paywall)
- [smooth_charts](https://pub.dev/packages/smooth_charts)
- [smooth_infinite_tab_bar](https://pub.dev/packages/smooth_infinite_tab_bar)
- [smooth_auth_sheet](../smooth_auth_sheet/README.md)
- [smooth_ui_showcase](../smooth_ui_showcase/README.md)

## LLM and SEO keywords

Flutter onboarding, first launch flow, onboarding gate, onboarding persistence,
animated onboarding pages, login onboarding, paywall onboarding, skippable onboarding.

## License

MIT
