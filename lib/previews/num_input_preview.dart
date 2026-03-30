// ignore_for_file: essential_lints/returning_widgets previews

import 'package:flutter/material.dart';
import 'package:flutter/widget_previews.dart';
import '../models/template_parameter.dart';
import '../widgets/num_input_widget.dart';

const _param = TemplateParameter(
  key: 'ratio',
  label: 'Aspect Ratio',
  description: 'Width-to-height ratio (e.g. 1.77).',
  type: ParameterType.num,
  required: true,
  passing: PassingConfig(style: PassingStyle.flagSpaceValue, flag: '--ratio'),
);

void _noOp(String? _) {}

@Preview(name: 'Active – empty')
Widget numInputActive() => const MaterialApp(
  home: Scaffold(
    body: Padding(
      padding: EdgeInsets.all(16),
      child: NumInputWidget(parameter: _param, onChanged: _noOp),
    ),
  ),
);

@Preview(name: 'Active – pre-filled')
Widget numInputPrefilled() => const MaterialApp(
  home: Scaffold(
    body: Padding(
      padding: EdgeInsets.all(16),
      child: NumInputWidget(
        parameter: _param,
        onChanged: _noOp,
        initialValue: '1.777',
      ),
    ),
  ),
);

@Preview(name: 'Disabled')
Widget numInputDisabled() => const MaterialApp(
  home: Scaffold(
    body: Padding(
      padding: EdgeInsets.all(16),
      child: NumInputWidget(
        parameter: _param,
        onChanged: _noOp,
        isActive: false,
        disabledExplanation: "Requires 'Format' to be set.",
      ),
    ),
  ),
);
