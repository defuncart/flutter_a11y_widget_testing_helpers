# a11y_test

Accessibility testing helpers for Flutter widget and integration tests.

## Features

Every generated test checks that:

- Tap targets are big enough (48px Android and 44px iOS on mobile and tablet, 24px WCAG on desktop)
- Tappable widgets have a semantic label
- Text has enough contrast

The tap target, label and contrast checks build on Flutter's [`meetsGuideline`](https://api.flutter.dev/flutter/flutter_test/meetsGuideline.html) matchers. They run against the semantics tree in `flutter_test`, so they catch regressions early, but do not replace testing with TalkBack, VoiceOver or real users.

## Getting Started

Add the package as a dev dependency:

```yaml
dev_dependencies:
  a11y_test:
    git:
      url: https://github.com/defuncart/a11y_test
```

With no setup, screens are pumped inside a plain `MaterialApp` and `Scaffold`. If your screens need localization, theming or dependency injection, set `pumpApp` once in `test/flutter_test_config.dart`:

```dart
import 'dart:async';

import 'package:a11y_test/a11y_test.dart';
import 'package:flutter/material.dart';

Future<void> testExecutable(FutureOr<void> Function() testMain) async {
  A11yTestConfig.pumpApp = (tester, widget) => tester.pumpWidget(
        MaterialApp(
          localizationsDelegates: AppLocalizations.localizationsDelegates,
          supportedLocales: AppLocalizations.supportedLocales,
          home: widget,
        ),
      );

  await testMain();
}
```

## Usage

```dart
testAccessibility(
  'LoginScreen',
  () => const LoginScreen(),
  expectedLabels: (context) {
    final l10n = AppLocalizations.of(context);
    return [l10n.emailLabel, l10n.passwordLabel, l10n.signIn];
  },
);
```

## Contributing

Issues and PRs are welcome on [GitHub](https://github.com/defuncart/a11y_test/issues).
