import 'package:flutter_test/flutter_test.dart';
import 'package:new_project/models/template_parameter.dart';

void main() {
  group('TemplateParameter', () {
    test('deserializes all fields from JSON', () {
      var json = {
        'key': 'platforms',
        'label': 'Target Platforms',
        'description': 'Choose platforms',
        'type': 'options',
        'options': ['android', 'ios', 'web'],
        'multiSelect': true,
        'required': true,
        'passing': {
          'style': 'flag_space_value',
          'flag': '--platforms',
          'separator': ',',
          'prefix': '[',
          'suffix': ']',
        },
        'dependsOn': [
          {'key': 'pub', 'op': 'eq', 'value': 'true'},
        ],
      };

      var param = TemplateParameter.fromJson(json);

      expect(param.key, 'platforms');
      expect(param.label, 'Target Platforms');
      expect(param.description, 'Choose platforms');
      expect(param.type, ParameterType.options);
      expect(param.options, ['android', 'ios', 'web']);
      expect(param.multiSelect, true);
      expect(param.required, true);
      expect(param.passing.style, PassingStyle.flagSpaceValue);
      expect(param.passing.flag, '--platforms');
      expect(param.passing.separator, ',');
      expect(param.passing.prefix, '[');
      expect(param.passing.suffix, ']');
      expect(param.dependsOn, isNotNull);
      expect(param.dependsOn!.length, 1);
      expect(param.dependsOn!.first.key, 'pub');
      expect(param.dependsOn!.first.op, DependsOnOp.eq);
      expect(param.dependsOn!.first.value, 'true');
    });

    test('multiSelect defaults to false when absent', () {
      var json = {
        'key': 'org',
        'label': 'Organization',
        'type': 'string',
        'required': false,
        'passing': {'style': 'flag_space_value', 'flag': '--org'},
      };

      var param = TemplateParameter.fromJson(json);
      expect(param.multiSelect, false);
    });

    test('passing.separator defaults to " ", prefix/suffix default to ""', () {
      var json = {
        'key': 'org',
        'label': 'Organization',
        'type': 'string',
        'required': false,
        'passing': {'style': 'flag_space_value', 'flag': '--org'},
      };

      var param = TemplateParameter.fromJson(json);
      expect(param.passing.separator, ' ');
      expect(param.passing.prefix, '');
      expect(param.passing.suffix, '');
    });

    test('unknown type value throws a FormatException', () {
      var json = {
        'key': 'org',
        'label': 'Organization',
        'type': 'invalid_type',
        'required': false,
        'passing': {'style': 'flag_space_value', 'flag': '--org'},
      };

      expect(
        () => TemplateParameter.fromJson(json),
        throwsA(isA<FormatException>()),
      );
    });

    test('multiSelect: true on non-options type throws a FormatException', () {
      var json = {
        'key': 'org',
        'label': 'Organization',
        'type': 'string',
        'multiSelect': true,
        'required': false,
        'passing': {'style': 'flag_space_value', 'flag': '--org'},
      };

      expect(
        () => TemplateParameter.fromJson(json),
        throwsA(isA<FormatException>()),
      );
    });
  });
}
