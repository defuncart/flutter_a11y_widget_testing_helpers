import 'package:a11y_test/a11y_test.dart';
import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';

void main() {
  tearDown(A11yTestConfig.reset);

  group('screens', () {
    testWidgets('default to A11yTestConfig.screens', (tester) async {
      A11yTestConfig.screens = [ScreenSize.tablet];
      final sizes = <Size>[];
      Widget builder() => Builder(
        builder: (context) {
          sizes.add(MediaQuery.sizeOf(context));
          return const Text('hello');
        },
      );

      for (final screen in A11yTestConfig.screens) {
        await tester.expectMeetsAccessibilityGuidelines(builder(), screen: screen);
      }

      expect(sizes.toSet(), {ScreenSize.tablet.size});
    });
  });
}
