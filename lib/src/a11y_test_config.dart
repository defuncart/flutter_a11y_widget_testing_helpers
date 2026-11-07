import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';

import 'screen_size_helper.dart';

/// Pumps [widget] with a custom test setup.
typedef PumpApp = Future<void> Function(WidgetTester tester, Widget widget);

/// Package-wide configuration, typically set once in `test/flutter_test_config.dart`:
///
/// ```dart
/// Future<void> testExecutable(FutureOr<void> Function() testMain) async {
///   A11yTestConfig.pumpApp = (tester, widget) => tester.pumpWidget(MaterialApp(home: widget));
///   A11yTestConfig.screens = [ScreenSize.mobile, ScreenSize.desktop]; // optional
///   A11yTestConfig.screenSizes = {ScreenSize.mobile: Size(412, 915)}; // optional
///   await testMain();
/// }
/// ```
abstract final class A11yTestConfig {
  /// Custom wrapper around [widget], useful to setup localization delegates, dependency injection etc.
  static PumpApp pumpApp = _defaultPumpApp;

  /// List of screens run by default. Defaults to [ScreenSize.mobile] and [ScreenSize.tablet].
  /// Add [ScreenSize.desktop] to also test desktop and web layouts.
  static List<ScreenSize> screens = _defaultScreens;

  /// Optional overrides the size of individual [ScreenSize]s. Sizes not listed keep their defaults.
  static Map<ScreenSize, Size> screenSizes = {};

  static void reset() {
    pumpApp = _defaultPumpApp;
    screens = _defaultScreens;
    screenSizes = {};
  }
}

const List<ScreenSize> _defaultScreens = [ScreenSize.mobile, ScreenSize.tablet];

Future<void> _defaultPumpApp(WidgetTester tester, Widget widget) {
  return tester.pumpWidget(
    MaterialApp(
      debugShowCheckedModeBanner: false,
      home: Scaffold(body: widget),
    ),
  );
}
