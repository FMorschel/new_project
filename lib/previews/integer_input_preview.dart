// ignore_for_file: essential_lints/returning_widgets previews

import 'package:flutter/material.dart';
import 'package:flutter/widget_previews.dart';
import '../models/template_parameter.dart';
import '../widgets/integer_input_widget.dart';

const _param = TemplateParameter(
  key: 'count',
  label: 'Item Count',
  description: 'Number of items to generate.',
  type: ParameterType.integer,
  required: true,
  passing: PassingConfig(style: PassingStyle.flagSpaceValue, flag: '--count'),
);

void _noOp(String? _) {}

@Preview(name: 'Active – empty')
Widget integerInputActive() => const MaterialApp(
  home: Scaffold(
    body: Padding(
      padding: EdgeInsets.all(16),
      child: IntegerInputWidget(parameter: _param, onChanged: _noOp),
    ),
  ),
);

@Preview(name: 'Active – pre-filled')
Widget integerInputPrefilled() => const MaterialApp(
  home: Scaffold(
    body: Padding(
      padding: EdgeInsets.all(16),
      child: IntegerInputWidget(
        parameter: _param,
        onChanged: _noOp,
        initialValue: '42',
      ),
    ),
  ),
);

@Preview(name: 'Disabled')
Widget integerInputDisabled() => const MaterialApp(
  home: Scaffold(
    body: Padding(
      padding: EdgeInsets.all(16),
      child: IntegerInputWidget(
        parameter: _param,
        onChanged: _noOp,
        isActive: false,
        disabledExplanation: "Requires 'Mode' to be set.",
      ),
    ),
  ),
);
