import 'package:flutter/material.dart';
import 'package:flutter_a11y_widget_testing_helpers/flutter_a11y_widget_testing_helpers.dart';
import 'package:flutter_test/flutter_test.dart';

void main() {
  tearDown(A11yTestConfig.reset);

  testWidgets('default pumpApp wraps the widget in a MaterialApp and Scaffold', (tester) async {
    const widget = Text('hello');

    await A11yTestConfig.pumpApp(tester, widget);

    expect(find.byType(MaterialApp), findsOneWidget);
    expect(
      find.descendant(of: find.byType(Scaffold), matching: find.byWidget(widget)),
      findsOneWidget,
    );
  });

  testWidgets('pumpApp can be replaced', (tester) async {
    Widget? pumped;
    A11yTestConfig.pumpApp = (tester, widget) {
      pumped = widget;
      return tester.pumpWidget(
        Directionality(
          textDirection: TextDirection.ltr,
          child: widget,
        ),
      );
    };
    const widget = Text('hello');

    await A11yTestConfig.pumpApp(tester, widget);

    expect(pumped, widget);
    expect(find.byType(MaterialApp), findsNothing);
  });

  testWidgets('reset restores the default pumpApp', (tester) async {
    A11yTestConfig.pumpApp = (tester, widget) => tester.pumpWidget(
      Directionality(
        textDirection: TextDirection.ltr,
        child: widget,
      ),
    );

    A11yTestConfig.reset();
    await A11yTestConfig.pumpApp(tester, const Text('hello'));

    expect(find.byType(MaterialApp), findsOneWidget);
  });

  test('screenSizes overrides only the listed sizes and reset restores them', () {
    const defaultMobile = Size(393, 852);
    const defaultTablet = Size(820, 1180);
    expect(ScreenSize.mobile.size, defaultMobile);

    A11yTestConfig.screenSizes = {ScreenSize.mobile: const Size(412, 915)};

    expect(ScreenSize.mobile.size, const Size(412, 915));
    expect(ScreenSize.tablet.size, defaultTablet);

    A11yTestConfig.reset();

    expect(ScreenSize.mobile.size, defaultMobile);
  });

  test('screens defaults to all screen sizes and reset restores them', () {
    expect(A11yTestConfig.screens, ScreenSize.values);

    A11yTestConfig.screens = [ScreenSize.mobile];
    expect(A11yTestConfig.screens, [ScreenSize.mobile]);

    A11yTestConfig.reset();

    expect(A11yTestConfig.screens, ScreenSize.values);
  });
}
