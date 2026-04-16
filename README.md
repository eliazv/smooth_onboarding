# smooth_onboarding

`smooth_onboarding` is a reusable Flutter onboarding package designed for pub.dev.
It focuses on a clean first-run experience, animated progress, dark mode adaptation,
and an API that stays easy to integrate in real apps.

## Features

- Animated progress bar with page-based progress.
- Optional back button that appears from the second page onward.
- Floating primary button that changes from `Avanti` to `Inizia` on the last page.
- First-launch persistence via `SharedPreferences`.
- Dark mode aware default styling.
- Fully customizable page content with any widget.
- Customizable labels (`next`, `done`, `back` tooltip).
- External reload trigger for programmatic onboarding reset.

## Installation

### From pub.dev (recommended after publish)

```yaml
dependencies:
  smooth_onboarding: ^0.1.0
```

### Local path dependency (current repository)

```yaml
dependencies:
  smooth_onboarding:
    path: ../smooth_onboarding
```

Replace the path dependency with the pub.dev version when you publish.

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
            title: 'Benvenuto',
            body: Text('Scopri l\'app in pochi passaggi.'),
          ),
          OnboardingPage(
            title: 'Personalizza',
            body: Icon(Icons.palette_outlined, size: 72),
            buttonLabel: 'Avanti',
          ),
          OnboardingPage(
            title: 'Pronto',
            body: Text('Hai finito il setup iniziale.'),
            buttonLabel: 'Inizia',
          ),
        ],
        child: const Scaffold(
          body: Center(child: Text('Contenuto principale dell\'app')),
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
  nextButtonLabel: 'Next',
  doneButtonLabel: 'Start',
  backButtonTooltip: 'Back',
  theme: const OnboardingTheme(
    backgroundColor: Colors.white,
    progressColor: Colors.blue,
    buttonColor: Colors.blue,
    progressHeight: 8,
  ),
  child: const HomePage(),
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
- Bottom floating action button that changes label on the last page.
- Small back arrow on the progress row, hidden on the first page.
- Animated transitions when page content changes.

## Verify locally

Run these commands from the package root:

```bash
flutter pub get
flutter analyze
flutter test
dart pub publish --dry-run
```

## View it graphically

To run the demo app and inspect the onboarding flow visually:

```bash
cd example
flutter create .
flutter run -d windows
```

If you want to test dark mode quickly, switch your system theme to dark and
restart the app. The onboarding background will switch to dark gray.

## Publish to pub.dev

1. Verify links in `pubspec.yaml` (`homepage`, `repository`, `issue_tracker`).
2. Add at least one screenshot or GIF in this README (recommended for pub points).
3. Ensure a clean git state (`git status` should be clean).
4. Run a final check:

```bash
dart pub publish --dry-run
```

5. Publish:

```bash
dart pub publish
```

## Publishing checklist

- Verify repository URLs in `pubspec.yaml`.
- Add a GIF or screenshot in the README for pub.dev score.
- Run `dart format .` and `flutter analyze` before publishing.
- Verify with `dart pub publish --dry-run`.

## License

MIT
