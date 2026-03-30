import '../models/template_parameter.dart';

String dependsOnExplanation(
  DependsOnCondition condition,
  String parameterLabel,
) => switch (condition.op) {
  DependsOnOp.set => "Requires '$parameterLabel' to be set.",
  DependsOnOp.unset => "Requires '$parameterLabel' to not be set.",
  DependsOnOp.eq => "Requires '$parameterLabel' to be '${condition.value}'.",
  DependsOnOp.neq =>
    "Not available when '$parameterLabel' is '${condition.value}'.",
};
