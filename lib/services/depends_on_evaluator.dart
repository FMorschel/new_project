import '../models/template_parameter.dart';

class DependsOnEvaluator {
  /// Evaluates whether a parameter's dependsOn conditions are all met
  /// given a map of currently entered answers.
  ///
  /// Returns `true` if there are no conditions or if all conditions are satisfied.
  static bool evaluate(TemplateParameter param, Map<String, Object?> answers) {
    if (param.dependsOn == null || param.dependsOn!.isEmpty) return true;

    for (var condition in param.dependsOn!) {
      var refValue = answers[condition.key];

      bool isEmpty(Object? v) {
        if (v == null) return true;
        if (v is String) return v.isEmpty;
        if (v is List) return v.isEmpty;
        return false;
      }

      var isSet = !isEmpty(refValue);

      switch (condition.op) {
        case DependsOnOp.set:
          if (!isSet) return false;
        case DependsOnOp.unset:
          if (isSet) return false;
        case DependsOnOp.eq:
          if (refValue?.toString() != condition.value) return false;
        case DependsOnOp.neq:
          if (refValue?.toString() == condition.value) return false;
      }
    }
    return true;
  }
}
