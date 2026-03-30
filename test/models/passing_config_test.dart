import 'package:flutter_test/flutter_test.dart';
import 'package:new_project/models/passing_config.dart';

void main() {
  group('PassingConfig', () {
    test('parses flag style', () {
      var json = {'style': 'flag', 'flag': '--verbose'};
      var config = PassingConfig.fromJson(json);
      expect(config.style, PassingStyle.flag);
      expect(config.flag, '--verbose');
    });

    test('parses flag_space_value style', () {
      var json = {'style': 'flag_space_value', 'flag': '--name'};
      var config = PassingConfig.fromJson(json);
      expect(config.style, PassingStyle.flagSpaceValue);
      expect(config.flag, '--name');
    });

    test('parses flag_equals_value style', () {
      var json = {'style': 'flag_equals_value', 'flag': '--output'};
      var config = PassingConfig.fromJson(json);
      expect(config.style, PassingStyle.flagEqualsValue);
      expect(config.flag, '--output');
    });

    test('parses positional style', () {
      var json = {'style': 'positional'};
      var config = PassingConfig.fromJson(json);
      expect(config.style, PassingStyle.positional);
    });

    test('flag field is optional when style is positional', () {
      var json = {'style': 'positional'};
      var config = PassingConfig.fromJson(json);
      expect(config.flag, isNull);
    });
  });
}
