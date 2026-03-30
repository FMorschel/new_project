import 'package:json_annotation/json_annotation.dart';

part 'passing_config.g.dart';

enum PassingStyle {
  @JsonValue('flag')
  flag,
  @JsonValue('flag_space_value')
  flagSpaceValue,
  @JsonValue('flag_equals_value')
  flagEqualsValue,
  @JsonValue('positional')
  positional,
}

@JsonSerializable()
class PassingConfig {
  const PassingConfig({
    required this.style,
    this.flag,
    this.separator = ' ',
    this.prefix = '',
    this.suffix = '',
  });

  factory PassingConfig.fromJson(Map<String, dynamic> json) =>
      _$PassingConfigFromJson(json);

  final PassingStyle style;
  final String? flag;
  @JsonKey(defaultValue: ' ')
  final String separator;
  @JsonKey(defaultValue: '')
  final String prefix;
  @JsonKey(defaultValue: '')
  final String suffix;

  Map<String, dynamic> toJson() => _$PassingConfigToJson(this);
}
