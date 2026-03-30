import 'dart:convert';
import 'dart:io';

import 'package:path/path.dart' as p;
import 'package:path_provider/path_provider.dart';

import '../models/template.dart';

export '../models/template.dart';

class TemplateNotFoundException implements Exception {
  const TemplateNotFoundException(this.name);
  final String name;

  @override
  String toString() => "Template '$name' not found.";
}

class TemplateParametersFileMissingException implements Exception {
  const TemplateParametersFileMissingException(this.name);
  final String name;

  @override
  String toString() => 'This template is missing a `_parameters.json` file.';
}

class TemplateParseException implements Exception {
  const TemplateParseException(this.name, this.details);
  final String name;
  final String details;

  @override
  String toString() => 'Failed to parse template "$name": $details';
}

class TemplateLoader {
  TemplateLoader({Future<Directory> Function()? getTemplatesDir})
    : _getTemplatesDir = getTemplatesDir ?? _defaultGetTemplatesDir;

  final Future<Directory> Function() _getTemplatesDir;

  static Future<Directory> _defaultGetTemplatesDir() async {
    var cacheDir = await getApplicationCacheDirectory();
    return Directory(p.join(cacheDir.path, 'templates'));
  }

  Future<List<String>> listTemplates() async {
    var dir = await _getTemplatesDir();
    if (!dir.existsSync()) return [];

    var names = <String>[];
    await for (var entry in dir.list()) {
      if (entry is Directory) {
        names.add(p.basename(entry.path));
      }
    }
    return names;
  }

  Future<String> getTemplatePath(String name) async {
    var dir = await _getTemplatesDir();
    return p.join(dir.path, name);
  }

  Future<Template> loadTemplate(String name) async {
    var dir = await _getTemplatesDir();
    var templateDir = Directory(p.join(dir.path, name));

    if (!templateDir.existsSync()) {
      throw TemplateNotFoundException(name);
    }

    var parametersFile = File(p.join(templateDir.path, '_parameters.json'));
    if (!parametersFile.existsSync()) {
      throw TemplateParametersFileMissingException(name);
    }

    var content = await parametersFile.readAsString();
    Map<String, dynamic> json;
    try {
      var decoded = jsonDecode(content);
      if (decoded is! Map<String, dynamic>) {
        throw TemplateParseException(
          name,
          '_parameters.json must be a JSON object',
        );
      }
      json = decoded;
    } on FormatException catch (e) {
      throw TemplateParseException(name, e.message);
    }

    try {
      return Template.fromJson(json);
    } on FormatException catch (e) {
      throw TemplateParseException(name, e.message);
    }
  }
}
