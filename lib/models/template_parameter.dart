import 'package:json_annotation/json_annotation.dart';

import 'depends_on_condition.dart';
import 'passing_config.dart';

export 'depends_on_condition.dart';
export 'passing_config.dart';

part 'template_parameter.g.dart';

enum ParameterType {
  @JsonValue('string')
  string,
  @JsonValue('integer')
  integer,
  @JsonValue('num')
  num,
  @JsonValue('options')
  options,
  @JsonValue('boolean')
  boolean,
}

const Map<ParameterType, String> _parameterTypeJsonValues = {
  ParameterType.string: 'string',
  ParameterType.integer: 'integer',
  ParameterType.num: 'num',
  ParameterType.options: 'options',
  ParameterType.boolean: 'boolean',
};

ParameterType _parameterTypeFromJson(String value) {
  for (var entry in _parameterTypeJsonValues.entries) {
    if (entry.value == value) return entry.key;
  }
  throw FormatException('Unknown parameter type: "$value"');
}

String _parameterTypeToJson(ParameterType type) =>
    _parameterTypeJsonValues[type]!;

@JsonSerializable()
class TemplateParameter {
  const TemplateParameter({
    required this.key,
    required this.label,
    required this.type,
    required this.required,
    required this.passing,
    this.description,
    this.options,
    this.multiSelect = false,
    this.dependsOn,
  });

  factory TemplateParameter.fromJson(Map<String, dynamic> json) {
    var param = _$TemplateParameterFromJson(json);
    if (param.multiSelect && param.type != ParameterType.options) {
      throw FormatException(
        'multiSelect can only be true when type is "options", '
        'but got type "${_parameterTypeToJson(param.type)}"',
      );
    }
    return param;
  }

  final String key;
  final String label;
  final String? description;
  @JsonKey(fromJson: _parameterTypeFromJson, toJson: _parameterTypeToJson)
  final ParameterType type;
  final List<String>? options;
  @JsonKey(defaultValue: false)
  final bool multiSelect;
  final bool required;
  final PassingConfig passing;
  final List<DependsOnCondition>? dependsOn;

  Map<String, dynamic> toJson() => _$TemplateParameterToJson(this);
}
