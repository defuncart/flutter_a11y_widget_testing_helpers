import 'dart:async';

import 'package:example/l10n/generated/app_localizations.dart';
import 'package:flutter/material.dart';
import 'package:flutter_a11y_widget_testing_helpers/flutter_a11y_widget_testing_helpers.dart';
import 'package:flutter_test/flutter_test.dart';

Future<void> testExecutable(FutureOr<void> Function() testMain) async {
  A11yTestConfig.pumpApp = (WidgetTester tester, Widget widget) {
    return tester.pumpWidget(
      MaterialApp(
        debugShowCheckedModeBanner: false,
        localizationsDelegates: AppLocalizations.localizationsDelegates,
        supportedLocales: AppLocalizations.supportedLocales,
        home: widget,
      ),
    );
  };

  await testMain();
}
