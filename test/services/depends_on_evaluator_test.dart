import 'package:flutter_test/flutter_test.dart';
import 'package:new_project/models/template_parameter.dart';
import 'package:new_project/services/depends_on_evaluator.dart';

void main() {
  group('DependsOnEvaluator', () {
    TemplateParameter buildParam(DependsOnCondition condition) =>
        TemplateParameter(
          key: 'test_param',
          label: 'Test Param',
          type: ParameterType.string,
          required: false,
          passing: const PassingConfig(style: PassingStyle.positional),
          dependsOn: [condition],
        );

    test('set — true when referenced param has any non-empty value', () {
      var param = buildParam(
        const DependsOnCondition(key: 'other', op: DependsOnOp.set),
      );

      expect(DependsOnEvaluator.evaluate(param, {'other': 'value'}), isTrue);
      expect(DependsOnEvaluator.evaluate(param, {'other': true}), isTrue);
      expect(
        DependsOnEvaluator.evaluate(param, {
          'other': ['a'],
        }),
        isTrue,
      );

      expect(DependsOnEvaluator.evaluate(param, {'other': ''}), isFalse);
      expect(DependsOnEvaluator.evaluate(param, {'other': []}), isFalse);
      expect(DependsOnEvaluator.evaluate(param, {'other': null}), isFalse);
      expect(DependsOnEvaluator.evaluate(param, {}), isFalse);
    });

    test('unset — true when referenced param has no value', () {
      var param = buildParam(
        const DependsOnCondition(key: 'other', op: DependsOnOp.unset),
      );

      expect(DependsOnEvaluator.evaluate(param, {'other': ''}), isTrue);
      expect(DependsOnEvaluator.evaluate(param, {'other': []}), isTrue);
      expect(DependsOnEvaluator.evaluate(param, {'other': null}), isTrue);
      expect(DependsOnEvaluator.evaluate(param, {}), isTrue);

      expect(DependsOnEvaluator.evaluate(param, {'other': 'value'}), isFalse);
      expect(DependsOnEvaluator.evaluate(param, {'other': true}), isFalse);
      expect(
        DependsOnEvaluator.evaluate(param, {
          'other': ['a'],
        }),
        isFalse,
      );
    });

    test('eq — true when value matches exactly', () {
      var param = buildParam(
        const DependsOnCondition(
          key: 'other',
          op: DependsOnOp.eq,
          value: 'expected',
        ),
      );

      expect(DependsOnEvaluator.evaluate(param, {'other': 'expected'}), isTrue);

      expect(
        DependsOnEvaluator.evaluate(param, {'other': 'Expected'}),
        isFalse,
      ); // Case sensitive.
      expect(
        DependsOnEvaluator.evaluate(param, {'other': 'different'}),
        isFalse,
      );
      expect(DependsOnEvaluator.evaluate(param, {}), isFalse);
    });

    test('neq — true when value does not match', () {
      var param = buildParam(
        const DependsOnCondition(
          key: 'other',
          op: DependsOnOp.neq,
          value: 'expected',
        ),
      );

      expect(
        DependsOnEvaluator.evaluate(param, {'other': 'different'}),
        isTrue,
      );
      expect(DependsOnEvaluator.evaluate(param, {'other': 'Expected'}), isTrue);
      expect(
        DependsOnEvaluator.evaluate(param, {}),
        isTrue,
      ); // `null` != 'expected'.

      expect(
        DependsOnEvaluator.evaluate(param, {'other': 'expected'}),
        isFalse,
      );
    });
  });
}
