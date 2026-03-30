import 'package:json_annotation/json_annotation.dart';

part 'depends_on_condition.g.dart';

enum DependsOnOp {
  @JsonValue('set')
  set,
  @JsonValue('unset')
  unset,
  @JsonValue('eq')
  eq,
  @JsonValue('neq')
  neq,
}

@JsonSerializable()
class DependsOnCondition {
  const DependsOnCondition({required this.key, required this.op, this.value});

  factory DependsOnCondition.fromJson(Map<String, dynamic> json) =>
      _$DependsOnConditionFromJson(json);

  final String key;
  final DependsOnOp op;
  final String? value;

  Map<String, dynamic> toJson() => _$DependsOnConditionToJson(this);
}
