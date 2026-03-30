// ignore_for_file: essential_lints/returning_widgets previews

import 'package:flutter/material.dart';
import 'package:flutter/widget_previews.dart';
import '../models/template_parameter.dart';
import '../widgets/boolean_input_widget.dart';

const _param = TemplateParameter(
  key: 'nullSafety',
  label: 'Enable Null Safety',
  type: ParameterType.boolean,
  required: true,
  passing: PassingConfig(style: PassingStyle.flag, flag: '--null-safety'),
);

void _noOp(bool _) {}

@Preview(name: 'Unchecked')
Widget booleanInputUnchecked() => const MaterialApp(
  home: Scaffold(
    body: Padding(
      padding: EdgeInsets.all(16),
      child: BooleanInputWidget(parameter: _param, onChanged: _noOp),
    ),
  ),
);

@Preview(name: 'Checked')
Widget booleanInputChecked() => const MaterialApp(
  home: Scaffold(
    body: Padding(
      padding: EdgeInsets.all(16),
      child: BooleanInputWidget(
        parameter: _param,
        onChanged: _noOp,
        initialValue: true,
      ),
    ),
  ),
);

@Preview(name: 'Disabled')
Widget booleanInputDisabled() => const MaterialApp(
  home: Scaffold(
    body: Padding(
      padding: EdgeInsets.all(16),
      child: BooleanInputWidget(
        parameter: _param,
        onChanged: _noOp,
        isActive: false,
        disabledExplanation: "Requires 'SDK' to be set.",
      ),
    ),
  ),
);
