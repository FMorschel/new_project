import 'package:flutter_test/flutter_test.dart';
import 'package:new_project/models/depends_on_condition.dart';

void main() {
  group('DependsOnCondition', () {
    test('parses set operator', () {
      var json = {'key': 'pub', 'op': 'set'};
      var condition = DependsOnCondition.fromJson(json);
      expect(condition.key, 'pub');
      expect(condition.op, DependsOnOp.set);
    });

    test('parses unset operator', () {
      var json = {'key': 'pub', 'op': 'unset'};
      var condition = DependsOnCondition.fromJson(json);
      expect(condition.op, DependsOnOp.unset);
    });

    test('parses eq operator with value', () {
      var json = {'key': 'pub', 'op': 'eq', 'value': 'true'};
      var condition = DependsOnCondition.fromJson(json);
      expect(condition.op, DependsOnOp.eq);
      expect(condition.value, 'true');
    });

    test('parses neq operator with value', () {
      var json = {'key': 'platforms', 'op': 'neq', 'value': 'web'};
      var condition = DependsOnCondition.fromJson(json);
      expect(condition.op, DependsOnOp.neq);
      expect(condition.value, 'web');
    });

    test('value is absent for set operator', () {
      var json = {'key': 'pub', 'op': 'set'};
      var condition = DependsOnCondition.fromJson(json);
      expect(condition.value, isNull);
    });

    test('value is absent for unset operator', () {
      var json = {'key': 'pub', 'op': 'unset'};
      var condition = DependsOnCondition.fromJson(json);
      expect(condition.value, isNull);
    });
  });
}
