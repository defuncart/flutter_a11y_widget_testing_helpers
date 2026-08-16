import 'package:example/l10n/generated/app_localizations.dart';
import 'package:example/main.dart';
import 'package:flutter_a11y_widget_testing_helpers/flutter_a11y_widget_testing_helpers.dart';

void main() {
  testAccessibility(
    'LoginScreen',
    () => const LoginScreen(),
    expectedLabels: (context) {
      final l10n = AppLocalizations.of(context);
      return [l10n.emailLabel, l10n.passwordLabel, l10n.signIn];
    },
  );
}
