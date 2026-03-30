import 'package:flutter_test/flutter_test.dart';
import 'package:new_project/models/template_parameter.dart';
import 'package:new_project/widgets/depends_on_explanation.dart';

void main() {
  group('dependsOnExplanation', () {
    test('set → Requires label to be set', () {
      const condition = DependsOnCondition(key: 'foo', op: DependsOnOp.set);
      expect(
        dependsOnExplanation(condition, 'My Field'),
        "Requires 'My Field' to be set.",
      );
    });

    test('unset → Requires label to not be set', () {
      const condition = DependsOnCondition(key: 'foo', op: DependsOnOp.unset);
      expect(
        dependsOnExplanation(condition, 'My Field'),
        "Requires 'My Field' to not be set.",
      );
    });

    test('eq → Requires label to be value', () {
      const condition = DependsOnCondition(
        key: 'foo',
        op: DependsOnOp.eq,
        value: 'bar',
      );
      expect(
        dependsOnExplanation(condition, 'My Field'),
        "Requires 'My Field' to be 'bar'.",
      );
    });

    test('neq → Not available when label is value', () {
      const condition = DependsOnCondition(
        key: 'foo',
        op: DependsOnOp.neq,
        value: 'bar',
      );
      expect(
        dependsOnExplanation(condition, 'My Field'),
        "Not available when 'My Field' is 'bar'.",
      );
    });
  });
}
