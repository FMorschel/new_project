import 'package:flutter_test/flutter_test.dart';
import 'package:new_project/models/template.dart';

Map<String, dynamic> _param(String key) => {
  'key': key,
  'label': key,
  'type': 'string',
  'required': false,
  'passing': {'style': 'positional'},
};

Map<String, dynamic> _paramWithDeps(
  String key,
  List<Map<String, dynamic>> dependsOn,
) => {
  'key': key,
  'label': key,
  'type': 'string',
  'required': false,
  'passing': {'style': 'positional'},
  'dependsOn': dependsOn,
};

Map<String, dynamic> _validJson({List<Map<String, dynamic>>? extra}) => {
  'parameters': [_param('projectTitle'), _param('projectPath'), ...?extra],
};

void main() {
  group('Template', () {
    test('parses _parameters.json with valid content', () {
      var json = _validJson(extra: [_param('org')]);
      var template = Template.fromJson(json);
      expect(template.parameters.length, 3);
      expect(
        template.parameters.map((p) => p.key),
        containsAll(['projectTitle', 'projectPath', 'org']),
      );
    });

    test('reports error when projectTitle is absent', () {
      var json = {
        'parameters': [_param('projectPath'), _param('org')],
      };
      expect(() => Template.fromJson(json), throwsA(isA<FormatException>()));
    });

    test('reports error when projectPath is absent', () {
      var json = {
        'parameters': [_param('projectTitle'), _param('org')],
      };
      expect(() => Template.fromJson(json), throwsA(isA<FormatException>()));
    });

    test(
      'reports error when dependsOn key references a parameter declared later',
      () {
        var json = {
          'parameters': [
            _param('projectTitle'),
            _param('projectPath'),
            _paramWithDeps('org', [
              {'key': 'platforms', 'op': 'set'},
            ]),
            _param('platforms'),
          ],
        };
        expect(() => Template.fromJson(json), throwsA(isA<FormatException>()));
      },
    );

    test('projectTitle is placed first regardless of position in array', () {
      var json = {
        'parameters': [
          _param('projectPath'),
          _param('org'),
          _param('projectTitle'),
        ],
      };
      var template = Template.fromJson(json);
      expect(template.parameters.first.key, 'projectTitle');
    });
  });
}
