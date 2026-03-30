import '../models/template_parameter.dart';
import 'depends_on_evaluator.dart';

class CommandBuilder {
  /// Builds the list of command-line arguments.
  static List<String> buildArguments(
    List<TemplateParameter> parameters,
    Map<String, Object?> answers,
  ) {
    var args = <String>[];

    for (var param in parameters) {
      // 1. Evaluate dependsOn
      var isActive = DependsOnEvaluator.evaluate(param, answers);
      if (!isActive) continue;

      var value = answers[param.key];

      // 2. Format value based on multiSelect, skipped, etc.
      String? computedValue;

      if (value == null) {
        // Skipped.
        continue;
      }

      if (param.multiSelect && value is List) {
        if (value.isEmpty) {
          continue; // Multi-select with no selections is omitted entirely.
        }
        computedValue =
            '${param.passing.prefix}${value.join(param.passing.separator)}${param.passing.suffix}';
      } else if (param.type == ParameterType.boolean) {
        if (value == false) {
          continue; // Boolean: flag is present when true, omitted when false.
        }
        computedValue = null; // No "value" literal per se for flag.
      } else {
        computedValue = value.toString();
      }

      // 3. Append to args using PassingStyle
      var style = param.passing.style;
      var flag = param.passing.flag;

      if (style == PassingStyle.flag) {
        if (flag != null) args.add(flag);
      } else if (style == PassingStyle.flagSpaceValue) {
        if (flag != null) args.add(flag);
        if (computedValue != null) args.add(computedValue);
      } else if (style == PassingStyle.flagEqualsValue) {
        if (flag != null && computedValue != null) {
          args.add('$flag=$computedValue');
        }
      } else if (style == PassingStyle.positional) {
        if (computedValue != null) args.add(computedValue);
      }
    }

    return args;
  }
}
