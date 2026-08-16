import 'package:flutter/widgets.dart';
import 'package:flutter_test/flutter_test.dart';

import 'a11y_test_config.dart';

/// Representative screen sizes in logical pixels (iPhone 15/16, iPad Air 11", 13" MacBook Air).
///
/// Override them with [A11yTestConfig.screenSizes].
enum ScreenSize {
  mobile(Size(393, 852)),
  tablet(Size(820, 1180)),
  desktop(Size(1440, 900))
  ;

  const ScreenSize(this._defaultSize);
  final Size _defaultSize;

  Size get size => A11yTestConfig.screenSizes[this] ?? _defaultSize;
}

extension ScreenSizeTester on WidgetTester {
  void setScreenSize(ScreenSize screen) => setViewSize(screen.size);

  void setViewSize(Size size) {
    view.physicalSize = size;
    view.devicePixelRatio = 1.0;
    addTearDown(view.resetPhysicalSize);
    addTearDown(view.resetDevicePixelRatio);
  }
}
