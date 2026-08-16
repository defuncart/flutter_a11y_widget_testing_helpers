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
    ScreenSize screen = ScreenSize.mobile,
    LabelsBuilder? expectedLabels,
  }) async {
    final SemanticsHandle handle = ensureSemantics();

    try {
      setViewSize(screen.size);
      await A11yTestConfig.pumpApp(this, widget);

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
  List<ScreenSize>? screens,
  LabelsBuilder? expectedLabels,
}) {
  for (final screen in screens ?? A11yTestConfig.screens) {
    testWidgets('$description meets accessibility guidelines on ${screen.name}', (tester) async {
      await tester.expectMeetsAccessibilityGuidelines(
        builder(),
        screen: screen,
        expectedLabels: expectedLabels,
      );
    });
  }
}

/// Convenience like [testWidgets], with the semantics tree enabled for the whole test.
void testSemantics(String description, Future<void> Function(WidgetTester tester) body) {
  testWidgets(description, (WidgetTester tester) async {
    final SemanticsHandle handle = tester.ensureSemantics();
    try {
      await body(tester);
    } finally {
      handle.dispose();
    }
  });
}

extension SemanticsExpectations on WidgetTester {
  /// Expects exactly [count] semantics nodes whose label matches [label].
  void expectSemanticsLabel(Pattern label, {int count = 1}) {
    expect(
      find.bySemanticsLabel(label),
      count == 0 ? findsNothing : findsNWidgets(count),
      reason: 'Expected $count semantics node(s) labelled "$label"',
    );
  }

  /// The semantics node whose label matches [label].
  SemanticsNode semanticsNode(Pattern label) => getSemantics(find.bySemanticsLabel(label));
}

const AccessibilityGuideline _wcagTapTargetGuideline = MinimumTapTargetGuideline(
  size: Size(24, 24),
  link: 'https://www.w3.org/WAI/WCAG22/Understanding/target-size-minimum.html',
);
