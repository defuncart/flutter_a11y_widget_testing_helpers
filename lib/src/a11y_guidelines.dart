import 'package:flutter/rendering.dart';
import 'package:flutter/widgets.dart';
import 'package:flutter_test/flutter_test.dart';

import 'a11y_test_config.dart';
import 'screen_size_helper.dart';

/// Returns the semantic labels expected on screen.
typedef LabelsBuilder = List<Pattern> Function(BuildContext context);

extension AccessibilityTester on WidgetTester {
  /// Pumps [widget] at [screen] and checks it against all built-in guidelines.
  ///
  /// [pumpApp] optionally overrides [A11yTestConfig.pumpApp] for this call,
  /// useful when a screen needs its own dependencies.
  ///
  /// [expectedLabels] is an optional callback to test if semantic labels are present.
  ///
  /// ```dart
  /// await tester.expectMeetsAccessibilityGuidelines(
  ///   const LoginScreen(),
  ///   screen: ScreenSize.mobile,
  ///   expectedLabels: (context) {
  ///     final l10n = AppLocalizations.of(context);
  ///     return [l10n.emailLabel, l10n.passwordLabel, l10n.signIn];
  ///   },
  /// );
  /// ```
  Future<void> expectMeetsAccessibilityGuidelines(
    Widget widget, {
    PumpApp? pumpApp,
    ScreenSize screen = ScreenSize.mobile,
    LabelsBuilder? expectedLabels,
  }) async {
    final SemanticsHandle handle = ensureSemantics();

    try {
      setViewSize(screen.size);
      await (pumpApp ?? A11yTestConfig.pumpApp)(this, widget);

      // on web test 24px, mobile/tablet iOS 44px, Android 48px
      if ([ScreenSize.mobile, ScreenSize.tablet].contains(screen)) {
        await expectLater(this, meetsGuideline(androidTapTargetGuideline));
        await expectLater(this, meetsGuideline(iOSTapTargetGuideline));
      } else {
        await expectLater(this, meetsGuideline(_wcagTapTargetGuideline));
      }
      await expectLater(this, meetsGuideline(labeledTapTargetGuideline));
      await expectLater(this, meetsGuideline(textContrastGuideline));

      if (expectedLabels != null) {
        final context = element(find.byWidget(widget));
        for (final Pattern label in expectedLabels(context)) {
          expect(
            find.bySemanticsLabel(label),
            findsOneWidget,
            reason: 'No element with semantics label "$label" on ${screen.name}',
          );
        }
      }
    } finally {
      handle.dispose();
    }
  }
}

/// Registers one accessibility test per screen size.
/// [builder] is called per test so each gets a fresh widget instance.
///
/// [pumpApp] optionally overrides [A11yTestConfig.pumpApp] for these tests,
/// useful when a screen needs its own dependencies.
///
/// [screens] defaults to [A11yTestConfig.screens].
///
/// [expectedLabels] is an optional callback to test if semantic labels are present.
///
/// ```dart
/// testAccessibility(
///   'LoginScreen',
///   () => const LoginScreen(),
///   expectedLabels: (context) {
///     final l10n = AppLocalizations.of(context);
///     return [l10n.emailLabel, l10n.passwordLabel, l10n.signIn];
///   },
/// );
/// ```
void testAccessibility(
  String description,
  Widget Function() builder, {
  PumpApp? pumpApp,
  List<ScreenSize>? screens,
  LabelsBuilder? expectedLabels,
}) {
  for (final screen in screens ?? A11yTestConfig.screens) {
    testWidgets('$description meets accessibility guidelines on ${screen.name}', (tester) async {
      await tester.expectMeetsAccessibilityGuidelines(
        builder(),
        pumpApp: pumpApp,
        screen: screen,
        expectedLabels: expectedLabels,
      );
    });
  }
}

const AccessibilityGuideline _wcagTapTargetGuideline = MinimumTapTargetGuideline(
  size: Size(24, 24),
  link: 'https://www.w3.org/WAI/WCAG22/Understanding/target-size-minimum.html',
);
