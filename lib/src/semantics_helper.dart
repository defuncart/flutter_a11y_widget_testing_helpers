import 'package:flutter/rendering.dart';
import 'package:flutter_test/flutter_test.dart';

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
