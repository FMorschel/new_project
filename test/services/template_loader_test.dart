import 'dart:convert';
import 'dart:io';

import 'package:flutter_test/flutter_test.dart';
import 'package:new_project/services/template_loader.dart';
import 'package:path/path.dart' as p;

Map<String, dynamic> _param(String key) => {
  'key': key,
  'label': key,
  'type': 'string',
  'required': false,
  'passing': {'style': 'positional'},
};

String _validParametersJson({List<Map<String, dynamic>>? extra}) => jsonEncode({
  'parameters': [_param('projectTitle'), _param('projectPath'), ...?extra],
});

void main() {
  late Directory tempDir;
  late Directory templatesDir;

  setUp(() async {
    tempDir = await Directory.systemTemp.createTemp('template_loader_test_');
    templatesDir = Directory(p.join(tempDir.path, 'templates'));
    await templatesDir.create();
  });

  tearDown(() async {
    await tempDir.delete(recursive: true);
  });

  TemplateLoader makeLoader() =>
      TemplateLoader(getTemplatesDir: () async => templatesDir);

  group('TemplateLoader.listTemplates', () {
    test(
      'lists all subfolders under templates/ as available templates',
      () async {
        await Directory(p.join(templatesDir.path, 'flutter_app')).create();
        await Directory(p.join(templatesDir.path, 'dart_package')).create();

        var names = await makeLoader().listTemplates();

        expect(names, containsAll(['flutter_app', 'dart_package']));
        expect(names.length, 2);
      },
    );

    test(
      'returns empty list when templates folder has no subfolders',
      () async {
        var names = await makeLoader().listTemplates();
        expect(names, isEmpty);
      },
    );

    test('ignores files — only returns subdirectories', () async {
      await Directory(p.join(templatesDir.path, 'my_template')).create();
      await File(p.join(templatesDir.path, 'readme.txt')).writeAsString('hi');

      var names = await makeLoader().listTemplates();

      expect(names, ['my_template']);
    });
  });

  group('TemplateLoader.loadTemplate', () {
    test('returns TemplateNotFoundException when folder is missing', () async {
      await expectLater(
        makeLoader().loadTemplate('nonexistent'),
        throwsA(isA<TemplateNotFoundException>()),
      );
    });

    test(
      'returns TemplateParametersFileMissingException when _parameters.json is absent',
      () async {
        await Directory(p.join(templatesDir.path, 'my_template')).create();

        await expectLater(
          makeLoader().loadTemplate('my_template'),
          throwsA(isA<TemplateParametersFileMissingException>()),
        );
      },
    );

    test(
      'returns TemplateParseException with details when _parameters.json is malformed JSON',
      () async {
        await Directory(p.join(templatesDir.path, 'my_template')).create();
        await File(
          p.join(templatesDir.path, 'my_template', '_parameters.json'),
        ).writeAsString('{ this is not valid json }');

        await expectLater(
          makeLoader().loadTemplate('my_template'),
          throwsA(isA<TemplateParseException>()),
        );
      },
    );

    test(
      'returns TemplateParseException when model validation fails (forward dependsOn ref)',
      () async {
        var invalidJson = jsonEncode({
          'parameters': [
            _param('projectTitle'),
            _param('projectPath'),
            {
              'key': 'org',
              'label': 'Org',
              'type': 'string',
              'required': false,
              'passing': {'style': 'positional'},
              'dependsOn': [
                {'key': 'platforms', 'op': 'set'},
              ],
            },
            _param('platforms'), // Declared AFTER org — forward reference.
          ],
        });

        await Directory(p.join(templatesDir.path, 'my_template')).create();
        await File(
          p.join(templatesDir.path, 'my_template', '_parameters.json'),
        ).writeAsString(invalidJson);

        await expectLater(
          makeLoader().loadTemplate('my_template'),
          throwsA(isA<TemplateParseException>()),
        );
      },
    );

    test('successfully loads and returns a valid template', () async {
      await Directory(p.join(templatesDir.path, 'my_template')).create();
      await File(
        p.join(templatesDir.path, 'my_template', '_parameters.json'),
      ).writeAsString(_validParametersJson(extra: [_param('org')]));

      var template = await makeLoader().loadTemplate('my_template');

      expect(template.parameters.length, 3);
      expect(
        template.parameters.map((p) => p.key),
        containsAll(['projectTitle', 'projectPath', 'org']),
      );
    });
  });
}
