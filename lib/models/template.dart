import 'template_parameter.dart';

export 'template_parameter.dart';

class Template {
  const Template({required this.parameters});

  factory Template.fromJson(Map<String, dynamic> json) {
    var rawList = json['parameters'];
    if (rawList is! List) {
      throw const FormatException('parameters must be a list');
    }
    var parameters = rawList.map((e) {
      if (e is! Map<String, dynamic>) {
        throw const FormatException('each parameter must be a JSON object');
      }
      return TemplateParameter.fromJson(e);
    }).toList();

    var keys = parameters.map((p) => p.key).toSet();
    if (!keys.contains('projectTitle') || !keys.contains('projectPath')) {
      throw const FormatException(
        'parameters.json must define both `projectTitle` and `projectPath`.',
      );
    }

    var seenKeys = <String>{};
    for (var param in parameters) {
      for (var condition in param.dependsOn ?? <DependsOnCondition>[]) {
        if (!seenKeys.contains(condition.key)) {
          throw FormatException(
            "Parameter '${param.key}' has a dependsOn reference to "
            "'${condition.key}' which is not declared before it.",
          );
        }
      }
      seenKeys.add(param.key);
    }

    var projectTitle = parameters.firstWhere((p) => p.key == 'projectTitle');
    var rest = parameters.where((p) => p.key != 'projectTitle').toList();

    return Template(parameters: [projectTitle, ...rest]);
  }

  final List<TemplateParameter> parameters;
}
