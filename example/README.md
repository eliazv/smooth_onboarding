# smooth_onboarding example

This folder contains the demo app for the `smooth_onboarding` package.

## Run

From this directory:

```bash
flutter pub get
flutter create .
flutter run -d windows
```

The app shows:

- onboarding only on first launch;
- animated top progress bar;
- `Next`/`Get started` button behavior;
- back arrow visibility from the second page;
- dark mode adaptation.

Use the top-right reset action in the demo app to clear the onboarding flag and
replay the full flow.
