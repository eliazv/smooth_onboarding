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
- Small, reusable API surface for app integration or wrapper gating.

## Installation

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

## Example behavior

The package is designed around these defaults:

- White background in light mode.
- Dark gray background in dark mode.
- Blue progress bar and blue primary button.
- Bottom floating action button that changes label on the last page.
- Small back arrow on the progress row, hidden on the first page.
- Animated transitions when page content changes.

## Publishing checklist

- Add a real GitHub repository URL before publishing.
- Add a GIF or screenshot in the README for pub.dev score.
- Run `dart format .` and `flutter analyze` before publishing.
- Verify with `dart pub publish --dry-run`.

## License

MIT
