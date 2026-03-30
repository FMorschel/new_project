// ignore_for_file: essential_lints/explicit_casts necessario

import 'package:flutter/material.dart';

import '../models/template_parameter.dart';
import 'boolean_input_widget.dart';
import 'integer_input_widget.dart';
import 'multi_options_input_widget.dart';
import 'num_input_widget.dart';
import 'single_options_input_widget.dart';
import 'string_input_widget.dart';

class ParameterInputWidget extends StatelessWidget {
  const ParameterInputWidget({
    required this.parameter,
    required this.onChanged,
    super.key,
    this.isActive = true,
    this.disabledExplanation,
    this.initialValue,
  });

  final TemplateParameter parameter;

  /// Called with the new value whenever the user changes the input.
  ///
  /// The runtime type of the value depends on the parameter type:
  ///
  /// - `string`, `integer`, `num`, `options` (single): `String?`
  /// - `boolean`: `bool`
  /// - `options` (multiSelect): `List<String>`
  final ValueChanged<Object?> onChanged;

  final bool isActive;
  final String? disabledExplanation;

  /// Seed value for the input. Must match the expected runtime type above.
  final Object? initialValue;

  @override
  Widget build(BuildContext context) => switch (parameter.type) {
    .string => StringInputWidget(
      key: ValueKey(parameter.key),
      parameter: parameter,
      onChanged: onChanged,
      isActive: isActive,
      disabledExplanation: disabledExplanation,
      initialValue: initialValue as String?,
    ),
    .integer => IntegerInputWidget(
      key: ValueKey(parameter.key),
      parameter: parameter,
      onChanged: onChanged,
      isActive: isActive,
      disabledExplanation: disabledExplanation,
      initialValue: initialValue as String?,
    ),
    .num => NumInputWidget(
      key: ValueKey(parameter.key),
      parameter: parameter,
      onChanged: onChanged,
      isActive: isActive,
      disabledExplanation: disabledExplanation,
      initialValue: initialValue as String?,
    ),
    .boolean => BooleanInputWidget(
      key: ValueKey(parameter.key),
      parameter: parameter,
      onChanged: onChanged,
      isActive: isActive,
      disabledExplanation: disabledExplanation,
      initialValue: (initialValue as bool?) ?? false,
    ),
    .options when parameter.multiSelect => MultiOptionsInputWidget(
      key: ValueKey(parameter.key),
      parameter: parameter,
      onChanged: onChanged,
      isActive: isActive,
      disabledExplanation: disabledExplanation,
      initialValue: (initialValue as List<String>?) ?? const [],
    ),
    .options => SingleOptionsInputWidget(
      key: ValueKey(parameter.key),
      parameter: parameter,
      onChanged: onChanged,
      isActive: isActive,
      disabledExplanation: disabledExplanation,
      initialValue: initialValue as String?,
    ),
  };
}
